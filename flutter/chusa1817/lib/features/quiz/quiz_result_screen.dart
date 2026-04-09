import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/hanja_character_badge.dart';
import '../../shared/widgets/section_header.dart';
import 'quiz_models.dart';

/// 퀴즈 결과 화면.
///
/// [GoRouterState.extra]로 [QuizResultData]를 받는다.
/// 점수·정답률·오답 목록을 표시하고 퀴즈 탭으로 돌아가거나 홈으로 이동할 수 있다.
class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key, required this.result});

  final QuizResultData result;

  String get _scoreMessage {
    if (result.accuracy >= 0.85) return '훌륭합니다!';
    if (result.accuracy >= 0.60) return '잘 하고 있어요';
    return '조금 더 연습해봐요';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scoreColor = HanjaColors.forAccuracy(result.accuracy);
    final wrongIndices = result.wrongIndices;

    return Scaffold(
      backgroundColor: HanjaColors.surface,
      appBar: AppBar(
        backgroundColor: HanjaColors.surface,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          '퀴즈 결과',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            _ScoreCard(
              result: result,
              scoreColor: scoreColor,
              scoreMessage: _scoreMessage,
              textTheme: textTheme,
            ),
            const SizedBox(height: 24),
            if (wrongIndices.isNotEmpty) ...[
              SectionHeader(
                tag: 'WRONG ANSWERS',
                title: '틀린 문제 (${wrongIndices.length}개)',
                tagColor: HanjaColors.error,
              ),
              const SizedBox(height: 14),
              ...wrongIndices.map((idx) {
                final q = result.questions[idx];
                final userAns = result.userAnswers[idx];
                return _WrongAnswerCard(
                  question: q,
                  userAnswerText: userAns >= 0 ? q.choices[userAns] : '미응답',
                  textTheme: textTheme,
                );
              }),
              const SizedBox(height: 24),
            ],
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => context.go('${AppRoutes.home}?tab=3'),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('다시 풀기'),
          style: FilledButton.styleFrom(
            backgroundColor: HanjaColors.primaryContainer,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.home_outlined),
          label: const Text('홈으로'),
          style: OutlinedButton.styleFrom(
            foregroundColor: HanjaColors.onSurface,
            side: const BorderSide(color: HanjaColors.outlineVariant),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.result,
    required this.scoreColor,
    required this.scoreMessage,
    required this.textTheme,
  });

  final QuizResultData result;
  final Color scoreColor;
  final String scoreMessage;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Text(
            scoreMessage,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: scoreColor,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: result.accuracy,
                    strokeWidth: 10,
                    backgroundColor: HanjaColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(result.accuracy * 100).round()}%',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: scoreColor,
                      ),
                    ),
                    Text(
                      '정답률',
                      style: textTheme.labelSmall?.copyWith(
                        color: HanjaColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatChip(label: '총 문제', value: '${result.totalCount}', color: HanjaColors.onSurface, textTheme: textTheme),
              _StatChip(label: '정답', value: '${result.correctCount}', color: HanjaColors.statusSuccess, textTheme: textTheme),
              _StatChip(label: '오답', value: '${result.totalCount - result.correctCount}', color: HanjaColors.error, textTheme: textTheme),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.textTheme,
  });

  final String label;
  final String value;
  final Color color;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 2),
        Text(label, style: textTheme.labelSmall?.copyWith(color: HanjaColors.onSurfaceVariant)),
      ],
    );
  }
}

class _WrongAnswerCard extends StatelessWidget {
  const _WrongAnswerCard({
    required this.question,
    required this.userAnswerText,
    required this.textTheme,
  });

  final QuizQuestion question;
  final String userAnswerText;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final correctText = question.type == QuizQuestionType.readingChoice
        ? '${question.reading}  ${question.meaning}'
        : question.character;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: HanjaColors.tertiaryContainer),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            HanjaCharacterBadge(character: question.character, size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${question.reading}  ${question.meaning}',
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  _AnswerRow(icon: Icons.close, color: HanjaColors.error, label: '내 답: $userAnswerText', textTheme: textTheme),
                  const SizedBox(height: 3),
                  _AnswerRow(icon: Icons.check, color: HanjaColors.statusSuccess, label: '정답: $correctText', textTheme: textTheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.textTheme,
  });

  final IconData icon;
  final Color color;
  final String label;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

