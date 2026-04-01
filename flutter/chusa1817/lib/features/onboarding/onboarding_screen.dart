import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../core/settings/app_settings_keys.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/gradient_primary_button.dart';
import '../../shared/widgets/won_go_ji_grid.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _nextPage() async {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final settings = ref.read(settingsRepositoryProvider);
      await settings.set(AppSettingsKeys.onboardingCompleted, 'true');
      if (!mounted) return;
      context.go('${AppRoutes.home}?tab=1');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildDotIndicator(int index) {
    final bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: isActive ? 32 : 6,
      decoration: BoxDecoration(
        color: isActive ? HanjaColors.primary : HanjaColors.outlineVariant.withAlpha(100),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HanjaColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: const [
                  _OnboardingPage1(),
                  _OnboardingPage2(),
                  _OnboardingPage3(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) => _buildDotIndicator(index)),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: GradientPrimaryButton(
                      label: _currentPage == 2 ? '시작하기' : '다음 단계로',
                      onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage1 extends StatelessWidget {
  const _OnboardingPage1();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 320,
            width: double.infinity,
            decoration: BoxDecoration(
              color: HanjaColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: HanjaColors.outlineVariant.withAlpha(40)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const WonGoJiGrid(opacity: 0.1, cellSize: 45),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: HanjaColors.outlineVariant.withAlpha(40)),
                          boxShadow: const [
                            BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 5)),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Text('學', style: textTheme.displayLarge?.copyWith(fontSize: 80, height: 1.0, color: HanjaColors.primary)),
                            Positioned(
                              top: -12,
                              right: -12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: HanjaColors.secondary, borderRadius: BorderRadius.circular(12)),
                                child: Text('SUCCESS', style: textTheme.labelSmall?.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: HanjaColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              children: [
                                const Icon(Icons.auto_stories, size: 18, color: HanjaColors.primary),
                                const SizedBox(width: 8),
                                Text('Essential', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: HanjaColors.primary, borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              children: [
                                const Icon(Icons.grade, size: 18, color: Colors.white),
                                const SizedBox(width: 8),
                                Text('1,800 Characters', style: textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: HanjaColors.primaryFixed, borderRadius: BorderRadius.circular(8)),
            child: Text('Step 01 / 03', style: textTheme.labelSmall?.copyWith(color: HanjaColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
          const SizedBox(height: 16),
          Text('1,800자 필수 한자 마스터', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            '중·고등학교 필수 한자 1,800자를 체계적으로 학습하세요.',
            style: textTheme.bodyMedium?.copyWith(color: HanjaColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage2 extends StatelessWidget {
  const _OnboardingPage2();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('획순 기반 필기 연습', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            '정확한 획순에 맞춰 직접 써보며 한자를 몸소 익히세요.',
            style: textTheme.bodyMedium?.copyWith(color: HanjaColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            height: 280,
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: HanjaColors.outlineVariant.withAlpha(50)),
              boxShadow: const [
                BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, 10)),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const WonGoJiGrid(opacity: 0.15, cellSize: 45),
                Text('永', style: textTheme.displayLarge?.copyWith(fontSize: 140, color: HanjaColors.outlineVariant.withAlpha(80), height: 1.0)),
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: const Icon(Icons.edit_note, size: 40, color: HanjaColors.primaryContainer),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: HanjaColors.secondary.withAlpha(25), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Text('Stroke 2', style: textTheme.labelSmall?.copyWith(color: HanjaColors.secondary, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: HanjaColors.secondary, shape: BoxShape.circle)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: HanjaColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: HanjaColors.secondary),
                      const SizedBox(height: 8),
                      Text('정확한 필압 감지', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: HanjaColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      const Icon(Icons.history_edu, color: HanjaColors.primary),
                      const SizedBox(height: 8),
                      Text('서체 가이드 제공', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage3 extends StatelessWidget {
  const _OnboardingPage3();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 320,
            width: double.infinity,
            decoration: BoxDecoration(
              color: HanjaColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const WonGoJiGrid(opacity: 0.1, cellSize: 45),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: HanjaColors.outlineVariant.withAlpha(20)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('학습 진도율', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: HanjaColors.primary)),
                          Text('84%', style: textTheme.headlineSmall?.copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: HanjaColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 100,
                        width: 200,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [40, 70, 55, 100, 30].asMap().entries.map((e) {
                            final int index = e.key;
                            final int height = e.value;
                            return Container(
                              width: 32,
                              height: height.toDouble(),
                              decoration: BoxDecoration(
                                color: index == 3 ? HanjaColors.primary : HanjaColors.primary.withAlpha(60),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Text('스마트한 복습과 성취', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            '나의 학습 기록을 확인하고 취약한 한자를 집중적으로 복습하세요.',
            style: textTheme.bodyMedium?.copyWith(color: HanjaColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
