import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/editorial_top_bar.dart';
import '../../shared/widgets/gradient_primary_button.dart';
import '../../shared/widgets/selectable_value_card.dart';
import 'quiz_models.dart';

/// 퀴즈 탭 — 설정(로비) 화면.
///
/// 문제 유형, 출제 수를 선택하고 퀴즈를 시작한다.
/// 시작 버튼을 누르면 문항을 생성한 뒤 [QuizPlayScreen]으로 push 한다.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  QuizTypeOption _selectedType = QuizTypeOption.readingChoice;
  int _questionCount = 10;

  static const List<int> _countOptions = [5, 10, 20];

  void _startQuiz(List<HanjaTableData> pool) {
    if (pool.isEmpty) return;
    final questions = _generateQuestions(pool);
    context.push(AppRoutes.quizPlay, extra: questions);
  }

  List<QuizQuestion> _generateQuestions(List<HanjaTableData> pool) {
    final rng = Random();
    final shuffled = List.of(pool)..shuffle(rng);
    final count = _questionCount.clamp(1, shuffled.length);
    final selected = shuffled.take(count).toList();

    return List.generate(count, (i) {
      final hanja = selected[i];

      final QuizQuestionType type = switch (_selectedType) {
        QuizTypeOption.readingChoice => QuizQuestionType.readingChoice,
        QuizTypeOption.characterChoice => QuizQuestionType.characterChoice,
        QuizTypeOption.mixed =>
          i.isEven ? QuizQuestionType.readingChoice : QuizQuestionType.characterChoice,
      };

      // 오답 보기: 출제 한자를 제외한 풀에서 3개 선택
      final wrongPool = List.of(pool)..remove(hanja);
      wrongPool.shuffle(rng);
      final wrongs = wrongPool.take(3).toList();

      final correctPos = rng.nextInt(4);
      final allItems = <HanjaTableData>[];
      int wrongIdx = 0;
      for (int j = 0; j < 4; j++) {
        allItems.add(j == correctPos ? hanja : wrongs[wrongIdx++]);
      }

      final choices = allItems.map((h) {
        return type == QuizQuestionType.readingChoice
            ? '${h.reading}  ${h.meaning}'
            : h.character;
      }).toList();

      return QuizQuestion(
        hanjaId: hanja.id,
        character: hanja.character,
        reading: hanja.reading,
        meaning: hanja.meaning,
        choices: choices,
        correctIndex: correctPos,
        type: type,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hanjaAsync = ref.watch(learnHanjaListProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        const EditorialTopBar(title: '퀴즈'),
        const SizedBox(height: 4),

        // ── 유형 선택 ───────────────────────────────────────────
        Text(
          'QUIZ TYPE',
          style: textTheme.labelSmall?.copyWith(
            color: HanjaColors.primaryContainer,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '문제 유형',
          style: textTheme.headlineSmall?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 14),
        ...QuizTypeOption.values.map((opt) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TypeCard(
                option: opt,
                isSelected: _selectedType == opt,
                onTap: () => setState(() => _selectedType = opt),
                textTheme: textTheme,
              ),
            )),

        const SizedBox(height: 24),

        // ── 문제 수 선택 ─────────────────────────────────────────
        Text(
          'QUESTIONS',
          style: textTheme.labelSmall?.copyWith(
            color: HanjaColors.primaryContainer,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '문제 수',
          style: textTheme.headlineSmall?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: List.generate(_countOptions.length, (idx) {
            final n = _countOptions[idx];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: idx < _countOptions.length - 1 ? 10 : 0),
                child: SelectableValueCard(
                  valueLabel: '$n',
                  unitLabel: '문제',
                  isSelected: _questionCount == n,
                  onTap: () => setState(() => _questionCount = n),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 32),

        // ── 시작 버튼 ────────────────────────────────────────────
        hanjaAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(child: Text('한자 데이터를 불러오지 못했습니다.')),
          data: (list) => list.isEmpty
              ? const Center(child: Text('학습 데이터가 없습니다. 콘텐츠를 먼저 동기화해 주세요.'))
              : GradientPrimaryButton(
                  label: '퀴즈 시작',
                  onPressed: () => _startQuiz(list),
                ),
        ),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
    required this.textTheme,
  });

  final QuizTypeOption option;
  final bool isSelected;
  final VoidCallback onTap;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? null : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.transparent : HanjaColors.outlineVariant,
            ),
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [HanjaColors.primary, HanjaColors.primaryContainer],
                  )
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : HanjaColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      option.description,
                      style: textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : HanjaColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
