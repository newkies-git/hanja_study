import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../core/utils/route_builders.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/accuracy_progress_row.dart';
import '../../shared/widgets/hanja_character_badge.dart';

/// 오답노트 화면.
///
/// 학습 이력이 있고 정확도가 낮은 한자를 정확도 오름차순으로 나열한다.
/// 항목을 탭하면 해당 한자의 쓰기 연습 화면으로 이동한다.
class WrongAnswerScreen extends ConsumerWidget {
  const WrongAnswerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final listAsync = ref.watch(wrongAnswerHanjaProvider);

    return Scaffold(
      backgroundColor: HanjaColors.surface,
      appBar: AppBar(
        backgroundColor: HanjaColors.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          '오답노트',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오답 목록을 불러오지 못했습니다.\n$e')),
        data: (list) {
          if (list.isEmpty) return _EmptyState(textTheme: textTheme);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    Text(
                      '총 ${list.length}개',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '정확도 낮은 순',
                      style: textTheme.bodySmall?.copyWith(color: HanjaColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _WrongAnswerTile(
                      item: item,
                      textTheme: textTheme,
                      onStudyTap: () => context.push(
                        RouteBuilders.study(item.hanjaId, '${item.reading} ${item.meaning}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WrongAnswerTile extends StatelessWidget {
  const _WrongAnswerTile({
    required this.item,
    required this.textTheme,
    required this.onStudyTap,
  });

  final ({
    String hanjaId,
    String hanja,
    String reading,
    String meaning,
    double accuracy,
    int totalAttempts,
    int correctAttempts,
  }) item;
  final TextTheme textTheme;
  final VoidCallback onStudyTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onStudyTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              HanjaCharacterBadge(character: item.hanja, size: 58),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.reading}  ${item.meaning}',
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    AccuracyProgressRow(accuracy: item.accuracy),
                    const SizedBox(height: 4),
                    Text(
                      '${item.correctAttempts}/${item.totalAttempts}회 정답',
                      style: textTheme.bodySmall?.copyWith(color: HanjaColors.onSurfaceVariant),
                    ),
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
                  visualDensity: VisualDensity.compact,
                  tooltip: '쓰기 연습',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 64,
              color: HanjaColors.statusSuccess,
            ),
            const SizedBox(height: 16),
            Text(
              '오답 기록이 없어요',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '학습하고 채점을 받으면\n오답 한자가 여기 표시됩니다.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: HanjaColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
