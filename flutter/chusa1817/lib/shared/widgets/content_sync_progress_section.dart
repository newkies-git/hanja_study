import 'package:flutter/material.dart';

import '../../core/firebase/content_sync_progress.dart';
import '../../core/theme/hanja_colors.dart';

/// Firestore → 로컬 동기화 단계별 진행 표시.
///
/// 프로필 카드·동기화 전용 화면 등에서 공통 사용.
class ContentSyncProgressSection extends StatelessWidget {
  const ContentSyncProgressSection({
    super.key,
    required this.progress,
    required this.isSyncLoading,
  });

  final ContentSyncProgressState? progress;
  final bool isSyncLoading;

  static const List<(ContentSyncStage, String)> _rows = [
    (ContentSyncStage.resetLocal, '로컬 테이블 초기화'),
    (ContentSyncStage.hanjaBasis, 'hanja_basis'),
    (ContentSyncStage.hanjaExtend, 'hanja_extend'),
    (ContentSyncStage.hanjaStroke, 'hanja_stroke'),
    (ContentSyncStage.hanjaWord, 'hanja_word'),
    (ContentSyncStage.savingVersion, 'config/content 버전 저장'),
  ];

  @override
  Widget build(BuildContext context) {
    if (!isSyncLoading && progress == null) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;
    final ContentSyncStage effective = progress?.stage ??
        (isSyncLoading ? ContentSyncStage.resetLocal : ContentSyncStage.idle);
    final String? detail = progress?.detail;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '동기화 진행',
            style: textTheme.labelLarge?.copyWith(
              color: HanjaColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ..._rows.map((e) {
            final ContentSyncStage rowStage = e.$1;
            final String label = e.$2;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: _leadingIcon(effective, rowStage),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (detail != null && effective == rowStage)
                          Text(
                            detail,
                            style: textTheme.bodySmall?.copyWith(
                              color: HanjaColors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static Widget _leadingIcon(ContentSyncStage current, ContentSyncStage row) {
    const double size = 18;
    if (current == ContentSyncStage.idle) {
      return Icon(
        Icons.radio_button_unchecked,
        size: size,
        color: HanjaColors.outlineVariant,
      );
    }
    if (current == ContentSyncStage.done || current.index > row.index) {
      return Icon(
        Icons.check_circle,
        size: size,
        color: HanjaColors.secondary,
      );
    }
    if (current == row) {
      return const SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return Icon(
      Icons.radio_button_unchecked,
      size: size,
      color: HanjaColors.outlineVariant,
    );
  }
}
