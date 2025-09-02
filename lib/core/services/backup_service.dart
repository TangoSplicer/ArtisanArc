import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';

class BackupService {
  static Future<String> createBackup() async {
    final Map<String, dynamic> backupData = {};
    
    // Backup all Hive boxes
    final boxNames = ['inventoryBox', 'salesBox', 'complianceBox', 'projectsBox', 'shoppingListsBox'];
    
    for (final boxName in boxNames) {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        backupData[boxName] = box.toMap();
      }
    }
    
    backupData['timestamp'] = DateTime.now().toIso8601String();
    backupData['version'] = '1.0.0';
    
    return jsonEncode(backupData);
  }

  static Future<void> exportBackup() async {
    try {
      final backupJson = await createBackup();
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${directory.path}/artisanarc_backup_$timestamp.json');
      
      await file.writeAsString(backupJson);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'ArtisanArc Backup - ${DateTime.now().toString().split(' ')[0]}',
      );
    } catch (e) {
      throw Exception('Failed to export backup: $e');
    }
  }

  static Future<bool> importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final backupJson = await file.readAsString();
        final backupData = jsonDecode(backupJson) as Map<String, dynamic>;
        
        // Validate backup format
        if (!backupData.containsKey('timestamp') || !backupData.containsKey('version')) {
          throw Exception('Invalid backup file format');
        }
        
        // Restore data to Hive boxes
        for (final entry in backupData.entries) {
          if (entry.key.endsWith('Box') && entry.value is Map) {
            final boxName = entry.key;
            final boxData = entry.value as Map<String, dynamic>;
            
            if (!Hive.isBoxOpen(boxName)) {
              await Hive.openBox(boxName);
            }
            
            final box = Hive.box(boxName);
            await box.clear();
            await box.putAll(boxData);
          }
        }
        
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to import backup: $e');
    }
  }
}