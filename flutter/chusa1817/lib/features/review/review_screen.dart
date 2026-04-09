import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/hanja_colors.dart';
import '../../core/utils/route_builders.dart';
import '../../shared/widgets/accuracy_progress_row.dart';
import '../../shared/widgets/editorial_top_bar.dart';
import '../../shared/widgets/hanja_character_badge.dart';
import '../../shared/widgets/section_header.dart';
import '../../core/router/app_router.dart';

/// 오답노트·복습 화면.
///
/// SM-2 알고리즘 기반 복습 대상 한자를 보여주고,
/// 쓰기 연습으로 바로 진입할 수 있다.
class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final dueAsync = ref.watch(dueForReviewHanjaProvider);
    final upcomingAsync = ref.watch(upcomingReviewHanjaProvider);

    final dueToday = dueAsync.value ?? const <(String, String, String, double)>[];
    final upcoming = upcomingAsync.value ??
        const <(String, String, String, DateTime, double)>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        const EditorialTopBar(title: '복습'),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => context.push(AppRoutes.wrongAnswers),
            icon: const Icon(Icons.error_outline_rounded, size: 16),
            label: const Text('오답노트'),
            style: TextButton.styleFrom(
              foregroundColor: HanjaColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              textStyle: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SectionHeader(tag: 'DUE TODAY', title: '오늘의 복습 (${dueToday.length}자)'),
        const SizedBox(height: 12),
        if (dueAsync.isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
        else if (dueAsync.hasError)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('복습 목록을 불러오지 못했습니다.\n${dueAsync.error}',
                textAlign: TextAlign.center),
          )
        else if (dueToday.isEmpty)
          const _EmptyCard()
        else
          ...dueToday.map((item) => _ReviewCard(
                hanjaId: item.$1,
                hanja: item.$2,
                meaning: item.$3,
                dueLabel: '복습',
                accuracy: item.$4,
                onStudyTap: () => context.push(RouteBuilders.study(item.$1, item.$3)),
              )),
        const SizedBox(height: 22),
        SectionHeader(tag: 'UPCOMING', title: '다가오는 복습 (${upcoming.length}자)'),
        const SizedBox(height: 12),
        if (upcomingAsync.isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
        else if (upcomingAsync.hasError)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('예정 복습을 불러오지 못했습니다.\n${upcomingAsync.error}',
                textAlign: TextAlign.center),
          )
        else if (upcoming.isEmpty)
          const _EmptyCard()
        else
          ...upcoming.map((item) => _ReviewCard(
                hanjaId: item.$1,
                hanja: item.$2,
                meaning: item.$3,
                dueLabel: _formatUpcomingLabel(item.$4),
                accuracy: item.$5,
                onStudyTap: () => context.push(RouteBuilders.study(item.$1, item.$3)),
              )),
      ],
    );
  }
}

String _formatUpcomingLabel(DateTime nextReviewAt) {
  final now = DateTime.now();
  final days = DateTime(nextReviewAt.year, nextReviewAt.month, nextReviewAt.day)
      .difference(DateTime(now.year, now.month, now.day))
      .inDays;
  if (days <= 0) return '곧 복습';
  if (days == 1) return '내일';
  if (days < 7) return '$days일 후';
  return '${(days / 7).ceil()}주 후';
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.hanjaId,
    required this.hanja,
    required this.meaning,
    required this.dueLabel,
    required this.accuracy,
    required this.onStudyTap,
  });

  final String hanjaId;
  final String hanja;
  final String meaning;
  final String dueLabel;
  final double accuracy;
  final VoidCallback onStudyTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onStudyTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                HanjaCharacterBadge(character: hanja, size: 62),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meaning,
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 13, color: HanjaColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            dueLabel,
                            style: textTheme.bodySmall?.copyWith(color: HanjaColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AccuracyProgressRow(accuracy: accuracy),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
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
            style: textTheme.bodySmall?.copyWith(color: HanjaColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
