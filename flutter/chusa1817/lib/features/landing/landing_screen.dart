import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/gradient_primary_button.dart';
import '../../core/router/app_router.dart';

/// 앱 진입 랜딩 화면 (Aesthetic Design).
///
/// 전체 화면 배경 이미지와 Glassmorphism 패널을 사용하여 
/// 사용자에게 프리미엄 오리엔탈 분위기를 전달한다.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _startAnimation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _startAnimation = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.black, // fallback
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full Bleed Background Image
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: _startAnimation ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 1.05 - (value * 0.05), // Subtle zoom out effect
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Image.asset(
              'assets/images/landing_hero_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // 2. Dark Gradient Scrim to ensure text readability
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          
          // 3. Glassmorphism Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: _startAnimation ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutQuart,
              builder: (context, value, child) {
                return FractionalTranslation(
                  translation: Offset(0, 1.0 - value),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "추사 1817",
                                textAlign: TextAlign.center,
                                style: textTheme.displaySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '사라진 천 년의 지혜,\n스마트폰에서 깨워보세요',
                                textAlign: TextAlign.center,
                                style: textTheme.titleMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                height: 56,
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => context.push(AppRoutes.onboarding),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                      color: Colors.white54,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    '앱 둘러보기',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              GradientPrimaryButton(
                                label: '가입 / 로그인',
                                onPressed: () => context.push(AppRoutes.login),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
