import 'package:flutter/material.dart';

import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/gradient_primary_button.dart';

/// 학습 계획 설정 화면.
///
/// 하루 학습량, 학습 순서(가나다순/랜덤), 학습 요일을 설정한다.
class PlanSettingsScreen extends StatefulWidget {
  const PlanSettingsScreen({super.key});

  @override
  State<PlanSettingsScreen> createState() => _PlanSettingsScreenState();
}

class _PlanSettingsScreenState extends State<PlanSettingsScreen> {
  int _dailyGoal = 5;
  int _orderIndex = 0; // 0 = 가나다순, 1 = 랜덤
  final List<bool> _selectedDays = List.generate(7, (i) => i < 5);

  static const List<int> _dailyGoalOptions = [5, 10, 15, 20];
  static const List<String> _dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: HanjaColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              children: [
                _buildAppBar(context, textTheme),
                const SizedBox(height: 16),
                Text(
                  'ACADEMIC DISCIPLINE',
                  style: textTheme.labelSmall?.copyWith(
                    color: HanjaColors.primaryContainer,
                    letterSpacing: 2.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '지속적인 학습을 위한 나만의 계획을 세워보세요.',
                  style: textTheme.displaySmall?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 22),
                _buildDailyGoalSection(textTheme),
                const SizedBox(height: 22),
                _buildOrderSection(textTheme),
                const SizedBox(height: 22),
                _buildDaySection(textTheme),
              ],
            ),
            _buildSaveButton(context, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, TextTheme textTheme) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: HanjaColors.primaryContainer),
        ),
        Expanded(
          child: Text(
            '학습 계획 설정',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: HanjaColors.primaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildDailyGoalSection(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '하루 학습량 설정',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Row(
          children: _dailyGoalOptions.asMap().entries.map((entry) {
            final int index = entry.key;
            final int goalValue = entry.value;
            final bool isSelected = goalValue == _dailyGoal;
            final bool isLast = index == _dailyGoalOptions.length - 1;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 10),
                child: _DailyGoalCard(
                  goalValue: goalValue,
                  isSelected: isSelected,
                  onTap: () => setState(() => _dailyGoal = goalValue),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOrderSection(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '학습 순서',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        _OrderRadioRow(
          isSelected: _orderIndex == 0,
          icon: Icons.format_list_numbered,
          label: '가나다순',
          onTap: () => setState(() => _orderIndex = 0),
        ),
        const SizedBox(height: 10),
        _OrderRadioRow(
          isSelected: _orderIndex == 1,
          icon: Icons.shuffle,
          label: '랜덤',
          onTap: () => setState(() => _orderIndex = 1),
        ),
      ],
    );
  }

  Widget _buildDaySection(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '학습 요일',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(7, (index) {
              final bool isSelected = _selectedDays[index];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () =>
                      setState(() => _selectedDays[index] = !_selectedDays[index]),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? HanjaColors.primaryContainer
                          : Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isSelected
                            ? HanjaColors.primaryContainer
                            : HanjaColors.outlineVariant,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _dayLabels[index],
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF9A9DA0),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, TextTheme textTheme) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: GradientPrimaryButton(
              label: '설정 완료',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      ),
    );
  }
}

/// 하루 학습량 선택 카드.
class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({
    required this.goalValue,
    required this.isSelected,
    required this.onTap,
  });

  final int goalValue;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Material(
      color: isSelected ? null : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HanjaColors.outlineVariant),
            gradient: isSelected
                ? const LinearGradient(
                    colors: [HanjaColors.primary, HanjaColors.primaryContainer],
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$goalValue',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.white : HanjaColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'CHARS',
                style: textTheme.labelSmall?.copyWith(
                  letterSpacing: 2.2,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.85)
                      : const Color(0xFF9A9DA0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 학습 순서 라디오 행.
class _OrderRadioRow extends StatelessWidget {
  const _OrderRadioRow({
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool isSelected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: HanjaColors.primaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? HanjaColors.primaryContainer
                    : HanjaColors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
