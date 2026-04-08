import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/hanja_colors.dart';

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
          if (list.isEmpty) {
            return _EmptyState(textTheme: textTheme);
          }

          return Column(
            children: [
              // 헤더 요약
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    Text(
                      '총 ${list.length}개',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '정확도 낮은 순',
                      style: textTheme.bodySmall?.copyWith(
                        color: HanjaColors.onSurfaceVariant,
                      ),
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
                        '${AppRoutes.study}/${item.hanjaId}'
                        '?meaning=${Uri.encodeComponent('${item.reading} ${item.meaning}')}',
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

  Color get _accuracyColor {
    if (item.accuracy >= 0.85) return HanjaColors.statusSuccess;
    if (item.accuracy >= 0.60) return HanjaColors.statusWarning;
    return HanjaColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (item.accuracy * 100).toInt();

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
              // 한자
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: HanjaColors.primaryFixed,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    item.hanja,
                    style: GoogleFonts.notoSerif(
                      textStyle: textTheme.headlineSmall?.copyWith(
                        color: HanjaColors.primaryContainer,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.reading}  ${item.meaning}',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
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
                          '$pct%',
                          style: textTheme.labelSmall?.copyWith(
                            color: _accuracyColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.correctAttempts}/${item.totalAttempts}회 정답',
                      style: textTheme.bodySmall?.copyWith(
                        color: HanjaColors.onSurfaceVariant,
                      ),
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
            Icon(
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
