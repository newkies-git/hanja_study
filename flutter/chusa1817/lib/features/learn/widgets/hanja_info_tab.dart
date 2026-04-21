import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../core/theme/hanja_colors.dart';

/// 기본 정보 탭 화면.
/// 부수, 총획, 유래 텍스트, 유의자·반의자·유사자·이체자를 표시한다.
class HanjaInfoTab extends StatelessWidget {
  const HanjaInfoTab({
    super.key,
    required this.originText,
    this.synonymsJson,
    this.antonymsJson,
    this.analogueJson,
    this.variantsJson,
  });

  final String originText;
  final String? synonymsJson;
  final String? antonymsJson;
  final String? analogueJson;
  final String? variantsJson;

  static List<String> _parseJson(String? json) {
    if (json == null || json.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final List<String> synonyms = _parseJson(synonymsJson);
    final List<String> antonyms = _parseJson(antonymsJson);
    final List<String> analogue = _parseJson(analogueJson);
    final List<String> variants = _parseJson(variantsJson);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 유래 설명
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: HanjaColors.outlineVariant.withValues(alpha: 0.05),
            ),
          ),
          child: Text(
            originText.isNotEmpty
                ? originText
                : '아직 유래 설명이 준비되지 않았습니다.',
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: HanjaColors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ),

        // 관계어 섹션
        if (synonyms.isNotEmpty || antonyms.isNotEmpty || analogue.isNotEmpty || variants.isNotEmpty) ...[
          const SizedBox(height: 16),
          _RelatedSection(
            synonyms: synonyms,
            antonyms: antonyms,
            analogue: analogue,
            variants: variants,
          ),
        ],
      ],
    );
  }
}

class _RelatedSection extends StatelessWidget {
  const _RelatedSection({
    required this.synonyms,
    required this.antonyms,
    required this.analogue,
    required this.variants,
  });

  final List<String> synonyms;
  final List<String> antonyms;
  final List<String> analogue;
  final List<String> variants;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: HanjaColors.outlineVariant.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (synonyms.isNotEmpty) _TagRow(label: '유의자', items: synonyms),
          if (antonyms.isNotEmpty) _TagRow(label: '반의자', items: antonyms),
          if (analogue.isNotEmpty) _TagRow(label: '유사자', items: analogue),
          if (variants.isNotEmpty) _TagRow(label: '이체자', items: variants),
        ],
      ),
    );
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({required this.label, required this.items});

  final String label;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: HanjaColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: items
                  .map((item) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: HanjaColors.surfaceVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: HanjaColors.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          item,
                          style: textTheme.bodySmall?.copyWith(
                            color: HanjaColors.onSurface,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
