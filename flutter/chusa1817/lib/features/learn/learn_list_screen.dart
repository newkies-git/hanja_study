import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/editorial_top_bar.dart';
import '../../core/router/app_router.dart';

/// 학습 한자 목록 화면.
///
/// 현재는 더미 데이터 8개를 표시하며, Phase 2에서 SQLite/API 연동으로 전환된다.
/// 정렬 필터(가나다순, 획수순, 랜덤)를 Pill 형태로 제공한다.
class LearnListScreen extends ConsumerWidget {
  const LearnListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hanjaListAsync = ref.watch(middleSchoolHanjaListProvider);

    return Column(
      children: [
        const EditorialTopBar(title: '추사 1817'),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterPill(label: '가나다순', isSelected: true, onTap: () {}),
                const SizedBox(width: 10),
                _FilterPill(label: '획수순', isSelected: false, onTap: () {}),
                const SizedBox(width: 10),
                _FilterPill(label: '랜덤', isSelected: false, onTap: () {}),
              ],
            ),
          ),
        ),
        Expanded(
          child: hanjaListAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                '목록을 불러오지 못했습니다.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
            data: (hanjaList) {
              if (hanjaList.isEmpty) {
                return const Center(
                  child: Text('학습할 한자가 아직 준비되지 않았습니다.'),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.1,
                ),
                itemCount: hanjaList.length,
                itemBuilder: (BuildContext context, int index) {
                  final hanjaRow = hanjaList[index];
                  final hanjaId = hanjaRow.id;
                  final hanja = hanjaRow.character;
                  final meaning = hanjaRow.meaning;

                  return _HanjaCard(
                    hanja: hanja,
                    meaning: meaning,
                    onTap: () => context.push(
                      '${AppRoutes.hanjaDetail}/$hanjaId'
                      '?meaning=${Uri.encodeComponent(meaning)}'
                      '&radical=${Uri.encodeComponent(hanjaRow.radical)}'
                      '&radicalLabel=${Uri.encodeComponent('')}'
                      '&totalStrokes=${hanjaRow.totalStrokes}',
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 정렬 필터 Pill 버튼.
class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? HanjaColors.primaryFixed
          : HanjaColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? HanjaColors.primaryContainer
                      : HanjaColors.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ),
    );
  }
}

/// 한자 그리드 카드.
class _HanjaCard extends StatelessWidget {
  const _HanjaCard({
    required this.hanja,
    required this.meaning,
    required this.onTap,
  });

  final String hanja;
  final String meaning;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hanja,
                style: textTheme.displaySmall?.copyWith(
                  fontSize: 44,
                  height: 1.0,
                ),
              ),
              const Spacer(),
              Text(
                meaning,
                style: textTheme.bodyMedium?.copyWith(
                  color: HanjaColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
