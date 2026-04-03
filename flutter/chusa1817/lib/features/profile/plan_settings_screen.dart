import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/providers/app_providers.dart';
import '../../core/settings/app_settings_keys.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/gradient_primary_button.dart';
import '../../shared/widgets/selectable_value_card.dart';
import '../../shared/widgets/list_radio_row.dart';
import 'widgets/plan_day_selector.dart';

/// 학습 계획 설정 화면.
///
/// 하루 학습량, 학습 순서(가나다순/랜덤), 학습 요일을 설정한다.
class PlanSettingsScreen extends ConsumerStatefulWidget {
  const PlanSettingsScreen({super.key});

  @override
  ConsumerState<PlanSettingsScreen> createState() => _PlanSettingsScreenState();
}

class _PlanSettingsScreenState extends ConsumerState<PlanSettingsScreen> {
  int _dailyGoal = 5;
  int _orderIndex = 0; // 0 = 가나다순, 1 = 랜덤
  final List<bool> _selectedDays = List.generate(7, (i) => i < 5);

  static const List<int> _dailyGoalOptions = [5, 10, 15, 20];
  static const List<String> _dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = ref.read(settingsRepositoryProvider);

      final dailyGoalRaw = await settings.get(AppSettingsKeys.dailyGoal);
      final orderIndexRaw = await settings.get(AppSettingsKeys.orderIndex);
      final selectedDaysRaw = await settings.get(AppSettingsKeys.selectedDays);

      final dailyGoal = int.tryParse(dailyGoalRaw ?? '');
      final orderIndex = int.tryParse(orderIndexRaw ?? '');

      if (dailyGoal != null) _dailyGoal = dailyGoal;
      if (orderIndex != null) _orderIndex = orderIndex;

      if (selectedDaysRaw != null && selectedDaysRaw.isNotEmpty) {
        final parsed = selectedDaysRaw
            .replaceAll('[', '')
            .replaceAll(']', '')
            .split(',')
            .map((e) => e.trim().toLowerCase() == 'true')
            .toList();
        if (parsed.length == 7) {
          for (var i = 0; i < 7; i++) {
            _selectedDays[i] = parsed[i];
          }
        }
      }

      if (mounted) setState(() {});
    });
  }

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
          onPressed: () => context.pop(),
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
                child: SelectableValueCard(
                  valueLabel: '$goalValue',
                  unitLabel: 'CHARS',
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
        ListRadioRow(
          isSelected: _orderIndex == 0,
          icon: Icons.format_list_numbered,
          label: '가나다순',
          onTap: () => setState(() => _orderIndex = 0),
        ),
        const SizedBox(height: 10),
        ListRadioRow(
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
        PlanDaySelector(
          selectedDays: _selectedDays,
          dayLabels: _dayLabels,
          onDayToggled: (index) {
            setState(() => _selectedDays[index] = !_selectedDays[index]);
          },
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
              onPressed: () async {
                final settings = ref.read(settingsRepositoryProvider);
                await settings.set(AppSettingsKeys.dailyGoal, '$_dailyGoal');
                await settings.set(AppSettingsKeys.orderIndex, '$_orderIndex');
                await settings.set(
                  AppSettingsKeys.selectedDays,
                  '[${_selectedDays.map((e) => e.toString()).join(',')}]',
                );
                if (!context.mounted) return;
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.home);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
