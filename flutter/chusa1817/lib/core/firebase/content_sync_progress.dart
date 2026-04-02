import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firestore 콘텐츠 동기화 단계 (컬렉션 단위).
enum ContentSyncStage {
  /// 동기화 없음 / 초기값
  idle,

  /// 로컬 콘텐츠 테이블 비우기
  resetLocal,

  /// `hanja_basis`
  hanjaBasis,

  /// `hanja_extend`
  hanjaExtend,

  /// `hanja_stroke`
  hanjaStroke,

  /// `hanja_word` (+ 성어 → hanja_idiom)
  hanjaWord,

  /// `content_config`에 버전 기록
  savingVersion,

  /// 완료
  done,
}

/// UI용 진행 상태 (상세 문구는 선택).
class ContentSyncProgressState {
  const ContentSyncProgressState(this.stage, [this.detail]);

  final ContentSyncStage stage;
  final String? detail;
}

final contentSyncProgressProvider =
    NotifierProvider<ContentSyncProgressNotifier, ContentSyncProgressState?>(
  ContentSyncProgressNotifier.new,
);

class ContentSyncProgressNotifier extends Notifier<ContentSyncProgressState?> {
  @override
  ContentSyncProgressState? build() => null;
}
