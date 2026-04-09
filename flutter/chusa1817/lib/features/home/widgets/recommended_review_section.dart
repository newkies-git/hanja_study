import 'package:flutter/material.dart';
import '../../../core/theme/hanja_colors.dart';
import '../../../shared/widgets/hanja_character_badge.dart';

/// 추천 복습 한자 섹션.
class RecommendedReviewSection extends StatelessWidget {
  const RecommendedReviewSection({
    super.key,
    required this.hanjaList,
    required this.textTheme,
    required this.onStudyTap,
    this.onSeedTap,
  });

  final List<Map<String, String>> hanjaList;
  final TextTheme textTheme;
  final void Function(String hanjaId, String meaning) onStudyTap;
  final VoidCallback? onSeedTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 추천 복습',
                  style: textTheme.headlineSmall?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            if (hanjaList.isEmpty && onSeedTap != null)
              TextButton.icon(
                onPressed: onSeedTap,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('샘플 데이터 추가'),
                style: TextButton.styleFrom(
                  foregroundColor: HanjaColors.primary,
                  textStyle: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (hanjaList.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: HanjaColors.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history_edu_rounded,
                    size: 40,
                    color: HanjaColors.outline.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '아직 복습할 한자가 없습니다.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: HanjaColors.outline,
                    ),
                  ),
                  if (onSeedTap != null) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: onSeedTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HanjaColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('샘플 오답 데이터 생성'),
                    ),
                  ],
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 64, // 72 -> 64로 더욱 축소
            ),
            itemCount: hanjaList.length,
            itemBuilder: (context, index) {
              final item = hanjaList[index];
              final String hanjaId = item['hanjaId']!;
              final String hanja = item['hanja']!;
              final String meaning = item['meaning']!;
              final String subInfo = item['subInfo']!;

              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  onTap: () => onStudyTap(hanjaId, meaning),
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // 8 -> 6로 축소
                    child: Row(
                      children: [
                        HanjaCharacterBadge(character: hanja, size: 40),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                meaning,
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12, // 13 -> 12
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                              ),
                              const SizedBox(height: 1),
                              Text(
                                subInfo,
                                style: textTheme.bodySmall?.copyWith(
                                  color: HanjaColors.outline,
                                  fontSize: 10, // 11 -> 10
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
