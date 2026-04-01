import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/editorial_top_bar.dart';
import '../../core/router/app_router.dart';

/// 오답노트·복습 화면.
///
/// SM-2 알고리즘 기반 복습 대상 한자를 보여주고,
/// 쓰기 연습으로 바로 진입할 수 있다.
/// Phase 3에서 Drift DB 및 Riverpod Provider로 실데이터 교체.
class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final dueAsync = ref.watch(dueForReviewHanjaProvider);
    final upcomingAsync = ref.watch(upcomingReviewHanjaProvider);

    final dueToday = dueAsync.value ?? const <(String, String, String)>[];
    final upcoming = upcomingAsync.value ??
        const <(String hanjaId, String hanja, String meaning, DateTime nextReviewAt)>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        const EditorialTopBar(title: '복습'),
        const SizedBox(height: 14),
        // ── 오늘 복습 섹션 ──────────────────────────────────────────
        _SectionHeader(
          label: 'DUE TODAY',
          title: '오늘의 복습 (${dueToday.length}자)',
          textTheme: textTheme,
        ),
        const SizedBox(height: 12),
        if (dueAsync.isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
        else if (dueToday.isEmpty)
          _EmptyCard(textTheme: textTheme)
        else
          ...dueToday.map((item) => _ReviewCard(
                item: _ReviewItem(
                  hanjaId: item.$1,
                  hanja: item.$2,
                  meaning: item.$3,
                  dueLabel: '복습',
                  accuracy: 0.0,
                ),
                textTheme: textTheme,
                onStudyTap: () => context.push(
                  '${AppRoutes.study}/${item.$1}'
                  '?meaning=${Uri.encodeComponent(item.$3)}',
                ),
              )),
        const SizedBox(height: 22),
        // ── 예정 복습 섹션 ──────────────────────────────────────────
        _SectionHeader(
          label: 'UPCOMING',
          title: '다가오는 복습 (${upcoming.length}자)',
          textTheme: textTheme,
        ),
        const SizedBox(height: 12),
        if (upcomingAsync.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (upcoming.isEmpty)
          _EmptyCard(textTheme: textTheme)
        else
          ...upcoming.map((item) => _ReviewCard(
                item: _ReviewItem(
                  hanjaId: item.$1,
                  hanja: item.$2,
                  meaning: item.$3,
                  dueLabel: _formatUpcomingLabel(item.$4),
                  accuracy: 0.0,
                ),
                textTheme: textTheme,
                onStudyTap: () => context.push(
                  '${AppRoutes.study}/${item.$1}'
                  '?meaning=${Uri.encodeComponent(item.$3)}',
                ),
              )),
      ],
    );
  }
}

String _formatUpcomingLabel(DateTime nextReviewAt) {
  final DateTime now = DateTime.now();
  final DateTime startOfToday = DateTime(now.year, now.month, now.day);
  final DateTime startOfTarget =
      DateTime(nextReviewAt.year, nextReviewAt.month, nextReviewAt.day);
  final int days = startOfTarget.difference(startOfToday).inDays;
  if (days <= 0) return '곧 복습';
  if (days == 1) return '내일';
  if (days < 7) return '$days일 후';
  final int weeks = (days / 7).ceil();
  return '$weeks주 후';
}

/// 복습 항목 데이터 모델 (더미).
class _ReviewItem {
  const _ReviewItem({
    required this.hanjaId,
    required this.hanja,
    required this.meaning,
    required this.dueLabel,
    required this.accuracy,
  });

  final String hanjaId;
  final String hanja;
  final String meaning;
  final String dueLabel;

  /// 0.0 ~ 1.0 정확도.
  final double accuracy;
}

/// 섹션 헤더.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.title,
    required this.textTheme,
  });

  final String label;
  final String title;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: HanjaColors.primaryContainer,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

/// 복습 카드.
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.item,
    required this.textTheme,
    required this.onStudyTap,
  });

  final _ReviewItem item;
  final TextTheme textTheme;
  final VoidCallback onStudyTap;

  Color get _accuracyColor {
    if (item.accuracy >= 0.85) return const Color(0xFF2E7D32); // 초록
    if (item.accuracy >= 0.60) return const Color(0xFFE65100); // 주황
    return const Color(0xFFC62828); // 빨강
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onStudyTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 한자 아이콘
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: HanjaColors.primaryFixed,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      item.hanja,
                      style: textTheme.headlineMedium?.copyWith(
                        color: HanjaColors.primaryContainer,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // 정보 영역
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.meaning,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 13,
                            color: HanjaColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.dueLabel,
                            style: textTheme.bodySmall?.copyWith(
                              color: HanjaColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 정확도 바
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: item.accuracy,
                                minHeight: 5,
                                backgroundColor: HanjaColors.surfaceContainerLow,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _accuracyColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(item.accuracy * 100).toInt()}%',
                            style: textTheme.labelSmall?.copyWith(
                              color: _accuracyColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 연습 버튼
                Container(
                  decoration: BoxDecoration(
                    color: HanjaColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: onStudyTap,
                    icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                    tooltip: '쓰기 연습',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 복습 목록이 비었을 때 표시하는 카드.
class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            '오늘의 복습을 모두 완료했어요!',
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '훌륭합니다. 내일도 꾸준히 이어가세요.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: HanjaColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
