import 'package:flutter/material.dart';
import '../../../core/theme/hanja_colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// 추천 복습 한자 섹션.
class RecommendedReviewSection extends StatelessWidget {
  const RecommendedReviewSection({
    super.key,
    required this.hanjaList,
    required this.textTheme,
    required this.onStudyTap,
  });

  final List<Map<String, String>> hanjaList;
  final TextTheme textTheme;
  final void Function(String hanjaId, String meaning) onStudyTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REVIEW',
          style: textTheme.labelSmall?.copyWith(
            color: HanjaColors.primaryContainer,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '오늘의 추천 복습',
          style: textTheme.headlineSmall?.copyWith(
            fontSize: 22, // DESIGN.md: Title-LG (1.375rem = 22px)
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        ...hanjaList.map((item) {
          final String hanjaId = item['hanjaId']!;
          final String hanja = item['hanja']!;
          final String meaning = item['meaning']!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: () => onStudyTap(hanjaId, meaning),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: HanjaColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            hanja,
                            style: GoogleFonts.notoSerif(
                              textStyle: textTheme.titleLarge?.copyWith(
                                color: HanjaColors.primaryContainer,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meaning,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '쓰기 연습',
                              style: textTheme.bodySmall?.copyWith(
                                color: HanjaColors.primaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: HanjaColors.outline,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
