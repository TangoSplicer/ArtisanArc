import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// A validated, portable backup archive that can be previewed before restore.
class BackupPreview {
  final File archiveFile;
  final DateTime createdAt;
  final List<String> includedBoxes;
  final String reason;

  const BackupPreview({
    required this.archiveFile,
    required this.createdAt,
    required this.includedBoxes,
    required this.reason,
  });

  String get description =>
      '${includedBoxes.length} data area${includedBoxes.length == 1 ? '' : 's'} · ${_formatDate(createdAt)}';

  static String _formatDate(DateTime value) =>
      value.toLocal().toString().split('.').first;
}

/// Metadata for an on-device automatic safety snapshot.
class AutomaticSnapshotInfo {
  final Directory directory;
  final DateTime createdAt;
  final List<String> includedBoxes;
  final String reason;

  const AutomaticSnapshotInfo({
    required this.directory,
    required this.createdAt,
    required this.includedBoxes,
    required this.reason,
  });

  String get description =>
      '${includedBoxes.length} data area${includedBoxes.length == 1 ? '' : 's'} · ${BackupPreview._formatDate(createdAt)}';
}

/// Creates portable backup archives and short-lived automatic on-device safety snapshots.
/// Snapshots copy Hive's persisted box files after open boxes have been flushed, preserving
/// typed records without serialising them into fragile JSON maps.
class BackupService {
  static const _boxNames = <String>[
    'inventoryBox',
    'stockAdjustmentsBox',
    'salesBox',
    'stallSessionsBox',
    'complianceBox',
    'projectsBox',
    'productionRunsBox',
    'shoppingListsBox',
  ];
  static const _manifestName = 'artisanarc-backup-manifest.json';
  static const _formatVersion = 2;
  static const _automaticRetentionCount = 5;
  static const _automaticSnapshotInterval = Duration(hours: 12);

  static Future<Directory> _backupRoot() async {
    final documents = await getApplicationDocumentsDirectory();
    final root = Directory(p.join(documents.path, 'artisanarc_backups'));
    if (!await root.exists()) await root.create(recursive: true);
    return root;
  }

  static Future<Directory> _automaticRoot() async {
    final root = await _backupRoot();
    final directory = Directory(p.join(root.path, 'automatic'));
    if (!await directory.exists()) await directory.create(recursive: true);
    return directory;
  }

  static Future<void> _flushOpenBoxes() async {
    for (final name in _boxNames) {
      if (Hive.isBoxOpen(name)) await Hive.box(name).flush();
    }
  }

  static Future<List<String>> _availableBoxNames() async {
    final documents = await getApplicationDocumentsDirectory();
    final names = <String>[];
    for (final name in _boxNames) {
      if (await File(p.join(documents.path, '$name.hive')).exists())
        names.add(name);
    }
    return names;
  }

  static Future<AutomaticSnapshotInfo?> createAutomaticSnapshot(
      {String reason = 'scheduled safety snapshot'}) async {
    await _flushOpenBoxes();
    final includedBoxes = await _availableBoxNames();
    if (includedBoxes.isEmpty) return null;

    final automaticRoot = await _automaticRoot();
    final createdAt = DateTime.now();
    final snapshotDirectory = Directory(
        p.join(automaticRoot.path, _snapshotDirectoryName(createdAt)));
    await snapshotDirectory.create(recursive: true);
    await _copyBoxesToDirectory(
        snapshotDirectory, includedBoxes, createdAt, reason);
    await _trimAutomaticSnapshots();

    return AutomaticSnapshotInfo(
      directory: snapshotDirectory,
      createdAt: createdAt,
      includedBoxes: includedBoxes,
      reason: reason,
    );
  }

  /// Creates at most one normal safety snapshot per interval when the app starts.
  static Future<void> createStartupSnapshotIfDue() async {
    final snapshots = await listAutomaticSnapshots();
    if (snapshots.isNotEmpty &&
        DateTime.now().difference(snapshots.first.createdAt) <
            _automaticSnapshotInterval) return;
    await createAutomaticSnapshot(reason: 'app startup');
  }

  static Future<List<AutomaticSnapshotInfo>> listAutomaticSnapshots() async {
    final root = await _automaticRoot();
    final snapshots = <AutomaticSnapshotInfo>[];
    await for (final entity in root.list()) {
      if (entity is! Directory) continue;
      final manifest = File(p.join(entity.path, _manifestName));
      if (!await manifest.exists()) continue;
      try {
        final data =
            jsonDecode(await manifest.readAsString()) as Map<String, dynamic>;
        final createdAt = DateTime.parse(data['createdAt'] as String);
        final boxes = (data['includedBoxes'] as List<dynamic>).cast<String>();
        snapshots.add(AutomaticSnapshotInfo(
          directory: entity,
          createdAt: createdAt,
          includedBoxes: boxes,
          reason: data['reason'] as String? ?? 'automatic safety snapshot',
        ));
      } catch (_) {
        // A damaged/incomplete snapshot is ignored instead of blocking the app.
      }
    }
    snapshots.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return snapshots;
  }

  static Future<AutomaticSnapshotInfo?> latestAutomaticSnapshot() async {
    final snapshots = await listAutomaticSnapshots();
    return snapshots.isEmpty ? null : snapshots.first;
  }

  static Future<File> createPortableBackup() async {
    await _flushOpenBoxes();
    final includedBoxes = await _availableBoxNames();
    if (includedBoxes.isEmpty)
      throw StateError('There is no craft data to back up yet.');

    final root = await _backupRoot();
    final createdAt = DateTime.now();
    final workingDirectory = Directory(
        p.join(root.path, '_export_${_snapshotDirectoryName(createdAt)}'));
    await workingDirectory.create(recursive: true);
    try {
      await _copyBoxesToDirectory(
          workingDirectory, includedBoxes, createdAt, 'portable export');
      final archive = File(p.join(
          root.path, 'artisanarc-backup-${_fileTimestamp(createdAt)}.zip'));
      final encoder = ZipFileEncoder();
      encoder.create(archive.path);
      await for (final entity in workingDirectory.list()) {
        if (entity is File) encoder.addFile(entity, p.basename(entity.path));
      }
      encoder.close();
      return archive;
    } finally {
      if (await workingDirectory.exists())
        await workingDirectory.delete(recursive: true);
    }
  }

  static Future<void> exportBackup() async {
    try {
      final archive = await createPortableBackup();
      await Share.shareXFiles(
        [XFile(archive.path)],
        text:
            'ArtisanArc Personal backup — ${DateTime.now().toLocal().toString().split(' ').first}',
      );
    } catch (error) {
      throw Exception('Failed to export backup: $error');
    }
  }

  static Future<BackupPreview?> pickBackupForRestore() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result == null || result.files.single.path == null) return null;
    return previewPortableBackup(File(result.files.single.path!));
  }

  static Future<BackupPreview> previewPortableBackup(File archiveFile) async {
    try {
      final archive = ZipDecoder().decodeBytes(await archiveFile.readAsBytes());
      final manifestFile = archive.files
          .where((file) => file.name == _manifestName)
          .cast<ArchiveFile?>()
          .firstWhere(
            (file) => file != null,
            orElse: () => null,
          );
      if (manifestFile == null || !manifestFile.isFile)
        throw const FormatException('Missing ArtisanArc backup manifest.');
      final manifest =
          jsonDecode(utf8.decode(manifestFile.content as List<int>))
              as Map<String, dynamic>;
      if (manifest['formatVersion'] != _formatVersion)
        throw const FormatException(
            'This backup format is not supported by this version of ArtisanArc.');
      final includedBoxes =
          (manifest['includedBoxes'] as List<dynamic>).cast<String>();
      if (includedBoxes.isEmpty ||
          includedBoxes.any((name) => !_boxNames.contains(name))) {
        throw const FormatException(
            'The backup contains an invalid data area.');
      }
      final archiveNames = archive.files
          .where((file) => file.isFile)
          .map((file) => file.name)
          .toSet();
      for (final boxName in includedBoxes) {
        if (!archiveNames.contains('$boxName.hive'))
          throw FormatException('The backup is missing $boxName data.');
      }
      return BackupPreview(
        archiveFile: archiveFile,
        createdAt: DateTime.parse(manifest['createdAt'] as String),
        includedBoxes: includedBoxes,
        reason: manifest['reason'] as String? ?? 'portable export',
      );
    } catch (error) {
      throw Exception('Could not read this ArtisanArc backup: $error');
    }
  }

  /// Protects the current files with a new automatic snapshot before replacing them.
  /// Callers should ask the user for confirmation after [previewPortableBackup].
  static Future<void> restorePortableBackup(BackupPreview preview) async {
    await createAutomaticSnapshot(reason: 'before restore');
    final archive =
        ZipDecoder().decodeBytes(await preview.archiveFile.readAsBytes());
    final archiveFiles = <String, ArchiveFile>{
      for (final file in archive.files.where((file) => file.isFile))
        file.name: file,
    };
    final documents = await getApplicationDocumentsDirectory();

    await Hive.close();
    for (final boxName in preview.includedBoxes) {
      final target = File(p.join(documents.path, '$boxName.hive'));
      final source = archiveFiles['$boxName.hive'];
      if (source == null)
        throw FormatException('The backup is missing $boxName data.');
      await target.writeAsBytes(source.content as List<int>, flush: true);
    }
  }

  static Future<void> _copyBoxesToDirectory(
    Directory targetDirectory,
    List<String> boxNames,
    DateTime createdAt,
    String reason,
  ) async {
    final documents = await getApplicationDocumentsDirectory();
    for (final boxName in boxNames) {
      final source = File(p.join(documents.path, '$boxName.hive'));
      await source.copy(p.join(targetDirectory.path, '$boxName.hive'));
    }
    final manifest = <String, dynamic>{
      'formatVersion': _formatVersion,
      'createdAt': createdAt.toIso8601String(),
      'reason': reason,
      'includedBoxes': boxNames,
    };
    await File(p.join(targetDirectory.path, _manifestName))
        .writeAsString(jsonEncode(manifest), flush: true);
  }

  static Future<void> _trimAutomaticSnapshots() async {
    final snapshots = await listAutomaticSnapshots();
    for (final snapshot in snapshots.skip(_automaticRetentionCount)) {
      if (await snapshot.directory.exists())
        await snapshot.directory.delete(recursive: true);
    }
  }

  static String _snapshotDirectoryName(DateTime value) =>
      'snapshot-${_fileTimestamp(value)}';

  static String _fileTimestamp(DateTime value) =>
      value.toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
}
