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
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/selectable_value_card.dart';
import 'quiz_models.dart';

/// 퀴즈 탭 — 설정(로비) 화면.
///
/// 문제 유형, 출제 수, 타이머, 범위(학교급)를 선택하고 퀴즈를 시작한다.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  QuizTypeOption _selectedType = QuizTypeOption.readingChoice;
  int _questionCount = 10;
  QuizTimerOption _selectedTimer = QuizTimerOption.none;
  QuizLevelFilter _levelFilter = QuizLevelFilter.all;

  static const List<int> _countOptions = [5, 10, 20];

  Future<void> _startQuiz() async {
    final repository = ref.read(hanjaRepositoryProvider);
    final sampleSize = (_questionCount * 8).clamp(40, 200);
    final pool = await repository.fetchRandomHanjaSample(
      limit: sampleSize,
      schoolLevel: _levelFilter == QuizLevelFilter.all ? null : _levelFilter.value,
    );
    if (!mounted) return;
    if (pool.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('선택한 범위에 해당하는 한자 데이터가 없습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final session = QuizSession(
      questions: _generateQuestions(pool),
      timerSeconds: _selectedTimer.seconds,
    );
    context.push(AppRoutes.quizPlay, extra: session);
  }

  List<QuizQuestion> _generateQuestions(List<HanjaTableData> pool) {
    final rng = Random();
    final shuffled = List.of(pool)..shuffle(rng);
    final count = _questionCount.clamp(1, shuffled.length);
    final selected = shuffled.sublist(0, count);

    return List.generate(count, (i) {
      final hanja = selected[i];

      final QuizQuestionType type = switch (_selectedType) {
        QuizTypeOption.readingChoice => QuizQuestionType.readingChoice,
        QuizTypeOption.characterChoice => QuizQuestionType.characterChoice,
        QuizTypeOption.writing => QuizQuestionType.writing,
        QuizTypeOption.mixed =>
          i.isEven ? QuizQuestionType.readingChoice : QuizQuestionType.characterChoice,
      };

      // writing 유형은 선택지가 필요 없다.
      if (type == QuizQuestionType.writing) {
        return QuizQuestion(
          hanjaId: hanja.id,
          character: hanja.character,
          reading: hanja.reading,
          meaning: hanja.meaning,
          choices: const [],
          correctIndex: 0,
          type: type,
        );
      }

      final wrongs = shuffled.where((h) => h != hanja).take(3).toList();
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
    final totalCountAsync = ref.watch(totalHanjaCountProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        const EditorialTopBar(title: '퀴즈'),
        const SizedBox(height: 4),

        // ── 문제 유형 ─────────────────────────────────────────────────────────
        const SectionHeader(tag: 'QUIZ TYPE', title: '문제 유형'),
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

        // ── 문제 수 ───────────────────────────────────────────────────────────
        const SectionHeader(tag: 'QUESTIONS', title: '문제 수'),
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
        const SizedBox(height: 24),

        // ── 범위 필터 ─────────────────────────────────────────────────────────
        const SectionHeader(tag: 'RANGE', title: '범위'),
        const SizedBox(height: 14),
        Row(
          children: QuizLevelFilter.values.map((filter) {
            final isSelected = _levelFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filter.label),
                selected: isSelected,
                onSelected: (_) => setState(() => _levelFilter = filter),
                selectedColor: HanjaColors.primaryContainer,
                labelStyle: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : HanjaColors.onSurface,
                ),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: isSelected ? Colors.transparent : HanjaColors.outlineVariant,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // ── 타이머 ────────────────────────────────────────────────────────────
        const SectionHeader(tag: 'TIMER', title: '문제당 시간'),
        const SizedBox(height: 14),
        Row(
          children: QuizTimerOption.values.map((opt) {
            final isSelected = _selectedTimer == opt;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: opt != QuizTimerOption.values.last ? 8 : 0,
                ),
                child: _TimerChip(
                  option: opt,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedTimer = opt),
                  textTheme: textTheme,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),

        totalCountAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(child: Text('한자 데이터를 불러오지 못했습니다.')),
          data: (total) => total == 0
              ? const Center(child: Text('학습 데이터가 없습니다. 콘텐츠를 먼저 동기화해 주세요.'))
              : GradientPrimaryButton(
                  label: '퀴즈 시작',
                  onPressed: _startQuiz,
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

class _TimerChip extends StatelessWidget {
  const _TimerChip({
    required this.option,
    required this.isSelected,
    required this.onTap,
    required this.textTheme,
  });

  final QuizTimerOption option;
  final bool isSelected;
  final VoidCallback onTap;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? HanjaColors.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : HanjaColors.outlineVariant,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          option.label,
          style: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : HanjaColors.onSurface,
          ),
        ),
      ),
    );
  }
}
