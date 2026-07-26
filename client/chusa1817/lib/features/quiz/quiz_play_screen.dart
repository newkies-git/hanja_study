import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/hanja_colors.dart';
import '../../core/theme/hanja_theme.dart';
import '../study/widgets/writing_canvas_widget.dart';
import 'quiz_models.dart';

/// 퀴즈 진행 화면.
///
/// [GoRouterState.extra]로 [QuizSession]을 받는다.
/// 객관식(readingChoice / characterChoice)과 쓰기(writing) 유형을 모두 지원한다.
/// 타이머가 설정된 경우 카운트다운 후 자동으로 다음 문제로 넘어간다.
class QuizPlayScreen extends StatefulWidget {
  const QuizPlayScreen({super.key, required this.session});

  final QuizSession session;

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  static const Duration _mcFeedbackDelay = Duration(milliseconds: 700);

  int _currentIndex = 0;
  final List<int> _userAnswers = [];

  // 객관식용
  int? _selectedAnswer;
  Timer? _feedbackTimer;

  // 타이머용
  int _timeLeft = 0;
  Timer? _countdownTimer;

  // 쓰기 시험용
  final WritingCanvasController _canvasController = WritingCanvasController();
  bool _writingRevealed = false;

  QuizQuestion get _current => widget.session.questions[_currentIndex];
  int get _total => widget.session.questions.length;
  bool get _hasTimer => widget.session.timerSeconds > 0;

  @override
  void initState() {
    super.initState();
    _beginQuestion();
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    _countdownTimer?.cancel();
    _canvasController.dispose();
    super.dispose();
  }

  // ── 문제 전환 ────────────────────────────────────────────────────────────────

  void _beginQuestion() {
    _canvasController.reset();
    if (_hasTimer) {
      _timeLeft = widget.session.timerSeconds;
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _timeLeft--);
        if (_timeLeft <= 0) {
          _countdownTimer?.cancel();
          // 시간 초과 → 미응답 처리
          if (_current.type == QuizQuestionType.writing) {
            _recordAndAdvance(-1);
          } else {
            _onChoiceTap(-1); // -1: 미응답
          }
        }
      });
    }
  }

  void _recordAndAdvance(int answer) {
    _feedbackTimer?.cancel();
    _countdownTimer?.cancel();
    _userAnswers.add(answer);

    if (_currentIndex < _total - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _writingRevealed = false;
      });
      _beginQuestion();
    } else {
      _navigateToResult();
    }
  }

  void _navigateToResult() {
    final result = QuizResultData(
      questions: widget.session.questions,
      userAnswers: _userAnswers,
    );
    context.pushReplacement(AppRoutes.quizResult, extra: result);
  }

  // ── 객관식 ────────────────────────────────────────────────────────────────────

  void _onChoiceTap(int index) {
    if (_selectedAnswer != null) return;
    _countdownTimer?.cancel();
    setState(() => _selectedAnswer = index);
    if (index == -1) {
      // 시간 초과 즉시 넘김
      _recordAndAdvance(-1);
    } else {
      _feedbackTimer = Timer(_mcFeedbackDelay, () => _recordAndAdvance(index));
    }
  }

  // ── 쓰기 시험 ─────────────────────────────────────────────────────────────────

  void _revealWriting() {
    _countdownTimer?.cancel();
    setState(() => _writingRevealed = true);
  }

  void _submitWriting({required bool isCorrect}) {
    // 정답이면 correctIndex(=0), 오답이면 -1
    _recordAndAdvance(isCorrect ? _current.correctIndex : -1);
  }

  // ── UI ───────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWriting = _current.type == QuizQuestionType.writing;

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
        actions: [
          if (_hasTimer)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _CountdownBadge(
                timeLeft: _timeLeft,
                total: widget.session.timerSeconds,
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / _total,
            backgroundColor: HanjaColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(HanjaColors.primaryContainer),
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: isWriting ? _buildWritingLayout(textTheme) : _buildMCLayout(textTheme),
        ),
      ),
    );
  }

  // ── 객관식 레이아웃 ───────────────────────────────────────────────────────────

  Widget _buildMCLayout(TextTheme textTheme) {
    final q = _current;
    final answered = _selectedAnswer != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 3,
          child: _QuestionDisplay(question: q, textTheme: textTheme),
        ),
        const SizedBox(height: 24),
        Expanded(
          flex: 4,
          child: _ChoiceGrid(
            question: q,
            selectedAnswer: _selectedAnswer,
            answered: answered,
            onChoiceTap: _onChoiceTap,
            textTheme: textTheme,
          ),
        ),
      ],
    );
  }

  // ── 쓰기 시험 레이아웃 ────────────────────────────────────────────────────────

  Widget _buildWritingLayout(TextTheme textTheme) {
    final q = _current;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 문제 제시 (훈·음)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            children: [
              Text(
                'Q. 한자를 쓰세요',
                style: textTheme.labelMedium?.copyWith(
                  color: HanjaColors.primaryContainer,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                q.reading,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: HanjaColors.onSurface,
                ),
              ),
              Text(
                q.meaning,
                style: textTheme.titleMedium?.copyWith(
                  color: HanjaColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 캔버스 (LayoutBuilder로 정사각형 확보)
        Expanded(
          child: WritingCanvasWidget(
            hanja: q.character,
            controller: _canvasController,
            showGuide: _writingRevealed, // 제출 후 가이드 표시
          ),
        ),
        const SizedBox(height: 16),

        // 하단 버튼
        if (!_writingRevealed) ...[
          Row(
            children: [
              _IconActionButton(
                icon: Icons.undo_rounded,
                tooltip: '한 획 지우기',
                onTap: _canvasController.undo,
              ),
              const SizedBox(width: 10),
              _IconActionButton(
                icon: Icons.refresh_rounded,
                tooltip: '전체 지우기',
                onTap: _canvasController.reset,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _revealWriting,
                  style: FilledButton.styleFrom(
                    backgroundColor: HanjaColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          // 자가 채점 버튼
          Text(
            '정답: ${q.character}  (${q.reading} ${q.meaning})',
            style: textTheme.bodyMedium?.copyWith(
              color: HanjaColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _submitWriting(isCorrect: false),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('틀렸어요'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: HanjaColors.error,
                    side: const BorderSide(color: HanjaColors.error),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _submitWriting(isCorrect: true),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('맞혔어요'),
                  style: FilledButton.styleFrom(
                    backgroundColor: HanjaColors.statusSuccess,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
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

// ── 타이머 뱃지 ─────────────────────────────────────────────────────────────────

class _CountdownBadge extends StatelessWidget {
  const _CountdownBadge({required this.timeLeft, required this.total});

  final int timeLeft;
  final int total;

  Color get _color {
    if (total == 0) return HanjaColors.onSurface;
    final ratio = timeLeft / total;
    if (ratio > 0.5) return HanjaColors.statusSuccess;
    if (ratio > 0.25) return HanjaColors.statusWarning;
    return HanjaColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? (timeLeft / total).clamp(0.0, 1.0) : 0.0;
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: ratio,
            strokeWidth: 3,
            backgroundColor: HanjaColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(_color),
          ),
          Text(
            '$timeLeft',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 아이콘 버튼 ─────────────────────────────────────────────────────────────────

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: HanjaColors.outlineVariant),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 22, color: HanjaColors.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

// ── 기존 객관식 위젯 (변경 없음) ────────────────────────────────────────────────

class _QuestionDisplay extends StatelessWidget {
  const _QuestionDisplay({required this.question, required this.textTheme});

  final QuizQuestion question;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardSurface,
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

  Color _bgColor(BuildContext context) {
    if (!answered) return context.cardSurface;
    if (index == correctIndex) return HanjaColors.secondaryContainer;
    if (index == selectedAnswer) return HanjaColors.tertiaryContainer;
    return context.cardSurface;
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
      color: _bgColor(context),
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

