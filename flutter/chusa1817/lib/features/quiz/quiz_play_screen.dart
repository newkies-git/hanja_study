import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/hanja_colors.dart';
import 'quiz_models.dart';

/// 퀴즈 진행 화면.
///
/// [GoRouterState.extra]로 `List<QuizQuestion>`을 받는다.
/// 한 문제씩 표시하고 선택 즉시 정오 피드백을 준 뒤 다음 문제로 넘어간다.
/// 마지막 문제를 마치면 [QuizResultScreen]으로 push 한다.
class QuizPlayScreen extends StatefulWidget {
  const QuizPlayScreen({super.key, required this.questions});

  final List<QuizQuestion> questions;

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  int _currentIndex = 0;
  final List<int> _userAnswers = [];
  int? _selectedAnswer; // 현재 문제 선택값 (null = 미선택)
  bool _answered = false;

  QuizQuestion get _current => widget.questions[_currentIndex];
  int get _total => widget.questions.length;

  void _onChoiceTap(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
    });

    // 300ms 후 다음 문제로 이동
    Future.delayed(const Duration(milliseconds: 700), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    _userAnswers.add(_selectedAnswer ?? -1);

    if (_currentIndex < _total - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      // 모든 문제 완료 → 결과 화면
      final result = QuizResultData(
        questions: widget.questions,
        userAnswers: _userAnswers,
      );
      context.pushReplacement(AppRoutes.quizResult, extra: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final q = _current;
    final progress = (_currentIndex + 1) / _total;

    return Scaffold(
      backgroundColor: HanjaColors.surface,
      appBar: AppBar(
        backgroundColor: HanjaColors.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context),
        ),
        title: Text(
          '${_currentIndex + 1} / $_total',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: HanjaColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(HanjaColors.primaryContainer),
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 문제 영역 ──────────────────────────────────────
              Expanded(
                flex: 3,
                child: _QuestionDisplay(question: q, textTheme: textTheme),
              ),
              const SizedBox(height: 24),

              // ── 선택지 영역 ────────────────────────────────────
              Expanded(
                flex: 4,
                child: _ChoiceGrid(
                  question: q,
                  selectedAnswer: _selectedAnswer,
                  answered: _answered,
                  onChoiceTap: _onChoiceTap,
                  textTheme: textTheme,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showExitDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('퀴즈를 종료할까요?'),
        content: const Text('진행 중인 퀴즈 기록은 저장되지 않습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('계속 풀기'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('종료', style: TextStyle(color: HanjaColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted && context.mounted) context.pop();
  }
}

/// 문제 표시 위젯.
class _QuestionDisplay extends StatelessWidget {
  const _QuestionDisplay({required this.question, required this.textTheme});

  final QuizQuestion question;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: question.type == QuizQuestionType.readingChoice
            ? _CharacterPrompt(question: question, textTheme: textTheme)
            : _ReadingPrompt(question: question, textTheme: textTheme),
      ),
    );
  }
}

/// 한자 제시 (훈음 선택 문제)
class _CharacterPrompt extends StatelessWidget {
  const _CharacterPrompt({required this.question, required this.textTheme});

  final QuizQuestion question;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Q. 훈음을 고르세요',
          style: textTheme.labelMedium?.copyWith(
            color: HanjaColors.primaryContainer,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          question.character,
          style: GoogleFonts.notoSerif(
            textStyle: textTheme.displayLarge?.copyWith(
              color: HanjaColors.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

/// 훈음 제시 (한자 선택 문제)
class _ReadingPrompt extends StatelessWidget {
  const _ReadingPrompt({required this.question, required this.textTheme});

  final QuizQuestion question;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Q. 한자를 고르세요',
          style: textTheme.labelMedium?.copyWith(
            color: HanjaColors.primaryContainer,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          question.reading,
          style: textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: HanjaColors.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          question.meaning,
          style: textTheme.titleLarge?.copyWith(
            color: HanjaColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// 4지선다 선택지 그리드
class _ChoiceGrid extends StatelessWidget {
  const _ChoiceGrid({
    required this.question,
    required this.selectedAnswer,
    required this.answered,
    required this.onChoiceTap,
    required this.textTheme,
  });

  final QuizQuestion question;
  final int? selectedAnswer;
  final bool answered;
  final void Function(int) onChoiceTap;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(4, (i) {
        return _ChoiceTile(
          label: question.choices[i],
          index: i,
          selectedAnswer: selectedAnswer,
          correctIndex: question.correctIndex,
          answered: answered,
          onTap: () => onChoiceTap(i),
          isCharacterChoice: question.type == QuizQuestionType.characterChoice,
          textTheme: textTheme,
        );
      }),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.index,
    required this.selectedAnswer,
    required this.correctIndex,
    required this.answered,
    required this.onTap,
    required this.isCharacterChoice,
    required this.textTheme,
  });

  final String label;
  final int index;
  final int? selectedAnswer;
  final int correctIndex;
  final bool answered;
  final VoidCallback onTap;
  final bool isCharacterChoice;
  final TextTheme textTheme;

  Color get _bgColor {
    if (!answered) return Colors.white;
    if (index == correctIndex) return HanjaColors.secondaryContainer;
    if (index == selectedAnswer) return HanjaColors.tertiaryContainer;
    return Colors.white;
  }

  Color get _borderColor {
    if (!answered) return HanjaColors.outlineVariant;
    if (index == correctIndex) return HanjaColors.secondary;
    if (index == selectedAnswer) return HanjaColors.tertiary;
    return HanjaColors.outlineVariant;
  }

  Color get _textColor {
    if (!answered) return HanjaColors.onSurface;
    if (index == correctIndex) return HanjaColors.secondary;
    if (index == selectedAnswer) return HanjaColors.tertiary;
    return HanjaColors.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _bgColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: answered ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _borderColor, width: 1.5),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12),
          child: isCharacterChoice
              ? Text(
                  label,
                  style: GoogleFonts.notoSerif(
                    textStyle: textTheme.headlineMedium?.copyWith(
                      color: _textColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                )
              : Text(
                  label,
                  textAlign: TextAlign.center,
                  style: textTheme.titleSmall?.copyWith(
                    color: _textColor,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
        ),
      ),
    );
  }
}
