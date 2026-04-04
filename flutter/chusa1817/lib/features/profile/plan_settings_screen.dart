import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/providers/app_providers.dart';
import '../../core/settings/app_settings_keys.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/gradient_primary_button.dart';
import '../../shared/widgets/selectable_value_card.dart';
import 'widgets/plan_day_selector.dart';

/// 학습 계획 설정 화면 (Premium UI Version).
class PlanSettingsScreen extends ConsumerStatefulWidget {
  const PlanSettingsScreen({super.key});

  @override
  ConsumerState<PlanSettingsScreen> createState() => _PlanSettingsScreenState();
}

class _PlanSettingsScreenState extends ConsumerState<PlanSettingsScreen> {
  int _dailyGoal = 5;
  int _orderIndex = 0; // 0 = 가나다순, 1 = 획순, 2 = 랜덤
  bool _isAscending = true;
  String _schoolLevel = 'all'; // 'middle' | 'high' | 'all'
  final List<bool> _selectedDays = List.generate(7, (i) => i < 5);

  static const List<int> _dailyGoalOptions = [5, 10, 15, 20, 25];
  static const List<String> _dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = ref.read(settingsRepositoryProvider);

      final dailyGoalRaw = await settings.get(AppSettingsKeys.dailyGoal);
      final orderIndexRaw = await settings.get(AppSettingsKeys.orderIndex);
      final schoolLevelRaw = await settings.get(AppSettingsKeys.schoolLevel);
      final selectedDaysRaw = await settings.get(AppSettingsKeys.selectedDays);

      final dailyGoal = int.tryParse(dailyGoalRaw ?? '');
      final orderIndex = int.tryParse(orderIndexRaw ?? '');
      final isAscendingRaw = await settings.get(AppSettingsKeys.isAscending);

      if (dailyGoal != null) setState(() => _dailyGoal = dailyGoal);
      if (orderIndex != null) setState(() => _orderIndex = orderIndex);
      if (isAscendingRaw != null) {
        setState(() => _isAscending = isAscendingRaw.toLowerCase() == 'true');
      }
      if (schoolLevelRaw != null) setState(() => _schoolLevel = schoolLevelRaw);

      if (selectedDaysRaw != null && selectedDaysRaw.isNotEmpty) {
        final parsed = selectedDaysRaw
            .replaceAll('[', '')
            .replaceAll(']', '')
            .split(',')
            .map((e) => e.trim().toLowerCase() == 'true')
            .toList();
        if (parsed.length == 7) {
          setState(() {
            for (var i = 0; i < 7; i++) {
              _selectedDays[i] = parsed[i];
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: HanjaColors.surfaceContainerLow,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, textTheme),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSectionHeader(
                      textTheme,
                      'GOAL & PACE',
                      '체계적인 학습을 위한 목표를 설정하세요.',
                    ),
                    const SizedBox(height: 24),
                    _buildSettingsCard(
                      icon: Icons.auto_graph_rounded,
                      title: '하루 학습량 (Chars)',
                      child: _buildDailyGoalGrid(),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsCard(
                      icon: Icons.tune_rounded, // '학습 방법' 전체 설정을 대표하는 아이콘
                      title: '학습 방법',
                      child: _buildOrderOptions(),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsCard(
                      icon: Icons.calendar_today_rounded,
                      title: '학습 요일',
                      child: PlanDaySelector(
                        selectedDays: _selectedDays,
                        dayLabels: _dayLabels,
                        onDayToggled: (index) {
                          setState(() => _selectedDays[index] = !_selectedDays[index]);
                        },
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
          _buildGlassSaveButton(context, textTheme),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, TextTheme textTheme) {
    return SliverAppBar(
      backgroundColor: HanjaColors.surfaceContainerLow,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: HanjaColors.onSurface,
      ),
      title: Text(
        '학습 계획 설정',
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSectionHeader(TextTheme textTheme, String label, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: HanjaColors.primary,
            letterSpacing: 2.2,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(
            fontSize: 16, // 폰트 크기 추가 축소 (3차)
            fontWeight: FontWeight.w900,
            height: 1.3,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // 상하 패딩 축소
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: HanjaColors.shadow.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: HanjaColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // 간격 축소
          child,
        ],
      ),
    );
  }

  Widget _buildDailyGoalGrid() {
    return Row(
      children: [
        for (int i = 0; i < _dailyGoalOptions.length; i++) ...[
          Expanded(
            child: SelectableValueCard(
              valueLabel: '${_dailyGoalOptions[i]}',
              unitLabel: null,
              isSelected: _dailyGoalOptions[i] == _dailyGoal,
              onTap: () => setState(() => _dailyGoal = _dailyGoalOptions[i]),
            ),
          ),
          if (i < _dailyGoalOptions.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _buildOrderOptions() {
    return Column(
      children: [
        // 1. 학습 방법 세그먼트
        Row(
          children: [
            const Icon(Icons.sort_rounded, size: 20, color: HanjaColors.primaryContainer),
            const SizedBox(width: 8), // 간격 축소
            Expanded(
              child: Text(
                '정렬', // '순서' -> '정렬'
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                maxLines: 1,
                softWrap: false,
              ),
            ),
            SizedBox(
              width: 200, // 너비를 200으로 최적화
              height: 36,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: HanjaColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSegment(
                        value: 0,
                        selectedValue: _orderIndex,
                        label: '가나다',
                        isAscending: _isAscending,
                        onTap: (v) {
                          if (_orderIndex == v) {
                            setState(() => _isAscending = !_isAscending);
                          } else {
                            setState(() => _orderIndex = v);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildSegment(
                        value: 1,
                        selectedValue: _orderIndex,
                        label: '획순',
                        isAscending: _isAscending,
                        onTap: (v) {
                          if (_orderIndex == v) {
                            setState(() => _isAscending = !_isAscending);
                          } else {
                            setState(() => _orderIndex = v);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildSegment(
                        value: 2,
                        selectedValue: _orderIndex,
                        label: '랜덤',
                        onTap: (v) => setState(() => _orderIndex = v),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 2. 학교 구분 세그먼트
        Row(
          children: [
            const Icon(Icons.category_rounded, size: 20, color: HanjaColors.primaryContainer),
            const SizedBox(width: 8), // 간격 축소
            Expanded(
              child: Text(
                '유형',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14, // 폰트 크기 살짝 축소
                    ),
                maxLines: 1,
                softWrap: false,
              ),
            ),
            SizedBox(
              width: 200, // 너비를 200으로 최적화
              height: 36,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: HanjaColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSegment(
                        value: 'middle',
                        selectedValue: _schoolLevel,
                        label: '중등',
                        onTap: (v) => setState(() => _schoolLevel = v),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildSegment(
                        value: 'high',
                        selectedValue: _schoolLevel,
                        label: '고등',
                        onTap: (v) => setState(() => _schoolLevel = v),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildSegment(
                        value: 'all',
                        selectedValue: _schoolLevel,
                        label: '전체',
                        onTap: (v) => setState(() => _schoolLevel = v),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSegment<T>({
    required T value,
    required T selectedValue,
    required String label,
    required ValueChanged<T> onTap,
    bool? isAscending,
  }) {
    final bool isSelected = value == selectedValue;
    // 0 = 가나다, 1 = 획순, 2 = 랜덤
    final bool showArrow = isSelected && isAscending != null && (value == 0 || value == 1);

    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: isSelected ? HanjaColors.primary : HanjaColors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 4),
              Icon(
                isAscending ? Icons.north_rounded : Icons.south_rounded,
                size: 12,
                color: HanjaColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGlassSaveButton(BuildContext context, TextTheme textTheme) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.white.withValues(alpha: 0.6),
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: GradientPrimaryButton(
              label: '설정 저장하기',
              onPressed: () async {
                final settings = ref.read(settingsRepositoryProvider);
                await settings.set(AppSettingsKeys.dailyGoal, '$_dailyGoal');
                await settings.set(AppSettingsKeys.orderIndex, '$_orderIndex');
                await settings.set(AppSettingsKeys.isAscending, '$_isAscending');
                await settings.set(AppSettingsKeys.schoolLevel, _schoolLevel);
                await settings.set(
                  AppSettingsKeys.selectedDays,
                  '[${_selectedDays.map((e) => e.toString()).join(',')}]',
                );
                
                if (!context.mounted) return;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('학습 계획이 저장되었습니다.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                
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
