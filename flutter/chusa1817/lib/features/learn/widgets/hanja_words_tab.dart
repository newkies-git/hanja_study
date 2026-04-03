import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/hanja_colors.dart';
import '../../../shared/widgets/related_word_tile.dart';

/// 관련 단어 탭 화면.
/// 단어 및 사자성어 목록을 표시한다.
class HanjaWordsTab extends ConsumerWidget {
  const HanjaWordsTab({
    super.key,
    required this.hanjaId,
  });

  final String hanjaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final wordsAsync = ref.watch(hanjaWordsProvider(hanjaId));
    final idiomsAsync = ref.watch(hanjaIdiomsProvider(hanjaId));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              '관련 단어',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: HanjaColors.primary,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (wordsAsync.isLoading || idiomsAsync.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (wordsAsync.hasError || idiomsAsync.hasError)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '관련 단어를 불러오지 못했습니다.',
                style: textTheme.bodyMedium?.copyWith(color: HanjaColors.error),
                textAlign: TextAlign.center,
              ),
            )
          else ...[
            ...((wordsAsync.value ?? const []).map(
              (w) => RelatedWordTile(
                hanja: w.word,
                reading: w.reading,
                meaning: w.meaning,
                category: '단어',
              ),
            )),
            ...((idiomsAsync.value ?? const []).map(
              (i) => RelatedWordTile(
                hanja: i.idiom,
                reading: i.reading,
                meaning: i.meaning,
                category: '성어',
              ),
            )),
            if ((wordsAsync.value?.isEmpty ?? true) &&
                (idiomsAsync.value?.isEmpty ?? true))
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    '표시할 단어/성어 데이터가 없습니다.',
                    style: textTheme.bodySmall?.copyWith(color: HanjaColors.outline),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
