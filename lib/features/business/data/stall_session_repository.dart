import 'package:hive/hive.dart';

import 'stall_session_model.dart';

abstract class StallSessionRepository {
  Future<void> saveSession(StallSession session);
  Future<StallSession?> getSessionById(String id);
  Future<StallSession?> getActiveSession();
  Future<List<StallSession>> getSessions();
}

class StallSessionRepositoryImpl implements StallSessionRepository {
  static const _boxName = 'stallSessionsBox';

  Future<Box<StallSession>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<StallSession>(_boxName);
    }
    return Hive.box<StallSession>(_boxName);
  }

  @override
  Future<StallSession?> getActiveSession() async {
    final sessions = await getSessions();
    final active = sessions.where((session) => !session.isClosed).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return active.isEmpty ? null : active.first;
  }

  @override
  Future<StallSession?> getSessionById(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  @override
  Future<List<StallSession>> getSessions() async {
    final box = await _getBox();
    final sessions = box.values.toList();
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  @override
  Future<void> saveSession(StallSession session) async {
    final box = await _getBox();
    await box.put(session.id, session);
  }
}
