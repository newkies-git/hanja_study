import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/editorial_top_bar.dart';
import '../../core/router/app_router.dart';

/// 학습 한자 목록 화면.
///
/// 현재는 더미 데이터 8개를 표시하며, Phase 2에서 SQLite/API 연동으로 전환된다.
/// 정렬 필터(가나다순, 획수순, 랜덤)를 Pill 형태로 제공한다.
class LearnListScreen extends StatelessWidget {
  const LearnListScreen({super.key});

  /// TODO: Phase 2 — SQLite HanjaRepository로 교체
  static const List<(String hanja, String meaning)> _dummyHanjaList = [
    ('佳', '아름다울'),
    ('學', '배울'),
    ('印', '도장'),
    ('永', '길 영'),
    ('人', '사람'),
    ('木', '나무'),
    ('水', '물'),
    ('火', '불'),
  ];

  @override
  Widget build(BuildContext context) {
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
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.1,
            ),
            itemCount: _dummyHanjaList.length,
            itemBuilder: (BuildContext context, int index) {
              final (String hanja, String meaning) = _dummyHanjaList[index];
              return _HanjaCard(
                hanja: hanja,
                meaning: meaning,
                onTap: () => context.push(
                  '${AppRoutes.hanjaDetail}/$hanja'
                  '?meaning=${Uri.encodeComponent(meaning)}'
                  '&radical=${Uri.encodeComponent('人')}'
                  '&radicalLabel=${Uri.encodeComponent('사람인변')}'
                  '&totalStrokes=8',
                ),
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
