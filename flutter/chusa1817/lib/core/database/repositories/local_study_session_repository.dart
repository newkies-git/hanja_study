import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import 'repository_interfaces.dart';

/// [StudySessionRepository]의 로컬 DB 구현체.
class LocalStudySessionRepository implements StudySessionRepository {
  const LocalStudySessionRepository(this._database, this._firebaseAuth);

  final AppDatabase _database;
  final FirebaseAuth _firebaseAuth;
  static const _uuid = Uuid();

  String get _currentUserId => _firebaseAuth.currentUser?.uid ?? '';

  @override
  Future<String> startSession(String sessionType) async {
    final String id = _uuid.v4();
    await _database.into(_database.studySessionTable).insert(StudySessionTableCompanion(
          id: Value(id),
          startedAt: Value(DateTime.now()),
          sessionType: Value(sessionType),
        ));
    return id;
  }

  @override
  Future<void> endSession(String sessionId,
      {required int correctCount}) async {
    final now = DateTime.now();
    await (_database.update(_database.studySessionTable)
          ..where((t) => t.id.equals(sessionId)))
        .write(StudySessionTableCompanion(
      endedAt: Value(now),
      correctCount: Value(correctCount),
      updatedAt: Value(now),
    ));

    // ── 일별 통계 동기화 ───────────────────────────────────────────────────
    // 세션 종료 후 당일 학습 횟수(sessionCount) 증가
    final date = DateTime(now.year, now.month, now.day);
    final userId = _currentUserId;
    final statsId = '${date.millisecondsSinceEpoch}_$userId';

    await _database.customStatement(
        'INSERT INTO daily_activity_stats (id, date, user_id, session_count, created_at, updated_at) '
        'VALUES (?, ?, ?, 1, ?, ?) '
        'ON CONFLICT(id) DO UPDATE SET session_count = session_count + 1, updated_at = ?',
        [statsId, date.toIso8601String(), userId, now.toIso8601String(), now.toIso8601String(), now.toIso8601String()],
      );
  }

  @override
  Future<void> saveAnswer(AnswerHistoryTableCompanion data) =>
      _database.into(_database.answerHistoryTable).insert(data);
}
