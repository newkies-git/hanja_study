import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/editorial_input_group.dart';
import '../../shared/widgets/ghost_divider.dart';
import '../../shared/widgets/gradient_primary_button.dart';
import '../../core/router/app_router.dart';
import '../../core/auth/firebase_auth_error_message.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/social_auth_button.dart';

/// 이메일/비밀번호 로그인 화면 (Premium Re-design).
///
/// 기존의 단순한 리스트 뷰에서 Glassmorphism과 배경 이미지를 활용한 
/// 프리미엄 디자인으로 업그레이드됨.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;
  bool _startAnimation = false;

  @override
  void initState() {
    super.initState();
    // 디버그 빌드에서만 이메일 기본값
    if (kDebugMode) {
      _emailController.text = 'rladbxor@gmail.com';
    }
    
    // 엔트리 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _startAnimation = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLoginForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(authControllerProvider.notifier).signInWithEmailPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(firebaseAuthErrorMessage(error)),
          backgroundColor: HanjaColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitGoogleLogin() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();
      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(firebaseAuthErrorMessage(error)),
          backgroundColor: HanjaColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitAppleLogin() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(authControllerProvider.notifier).signInWithApple();
      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(firebaseAuthErrorMessage(error)),
          backgroundColor: HanjaColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
          Image.asset(
            'assets/images/landing_hero_bg.png',
            fit: BoxFit.cover,
          ),
          
          // 2. Dark Scrim
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
          
          // 3. Login Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    // Back Button (Floating style)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InkResponse(
                        radius: 24,
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.push(AppRoutes.landing);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Main Glass Card
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: _startAnimation ? 1.0 : 0.0),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutQuart,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1.0 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: GlassCard(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    '로그인',
                                    style: textTheme.headlineSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  
                                    EditorialInputGroup(
                                      label: '이메일',
                                      labelColor: Colors.white70,
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      hintText: 'email@example.com',
                                      fillColor: Colors.white.withValues(alpha: 0.08),
                                      textColor: Colors.white,
                                      hintColor: Colors.white24,
                                      validator: (value) =>
                                          (value == null || value.trim().isEmpty)
                                              ? '이메일을 입력해 주세요'
                                              : null,
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    EditorialInputGroup(
                                      label: '비밀번호',
                                      labelColor: Colors.white70,
                                      controller: _passwordController,
                                      obscureText: !_isPasswordVisible,
                                      hintText: '비밀번호 입력',
                                      fillColor: Colors.white.withValues(alpha: 0.08),
                                      textColor: Colors.white,
                                      hintColor: Colors.white24,
                                      suffix: IconButton(
                                        onPressed: () => setState(
                                          () => _isPasswordVisible = !_isPasswordVisible,
                                        ),
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.white54,
                                        ),
                                      ),
                                      validator: (value) =>
                                          (value == null || value.isEmpty)
                                              ? '비밀번호를 입력해 주세요'
                                              : null,
                                    ),
                                  
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => context.push(AppRoutes.resetPassword),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white70,
                                      ),
                                      child: const Text('비밀번호를 잊으셨나요?'),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  GradientPrimaryButton(
                                    label: '로그인하기',
                                    onPressed: () => _submitLoginForm(),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  Row(
                                    children: [
                                      const Expanded(child: GhostDivider(color: Colors.white24)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          '또는',
                                          style: textTheme.labelSmall?.copyWith(
                                            color: Colors.white38,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                      const Expanded(child: GhostDivider(color: Colors.white24)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  SocialAuthButton(
                                    label: 'Google 로그인',
                                    isLoading: _isSubmitting,
                                    onPressed: () => _submitGoogleLogin(),
                                  ),
                                  const SizedBox(height: 12),
                                  SocialAuthButton(
                                    label: 'Apple 로그인',
                                    provider: SocialAuthProvider.apple,
                                    isLoading: _isSubmitting,
                                    onPressed: () => _submitAppleLogin(),
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  Center(
                                    child: GestureDetector(
                                      onTap: () => context.push(AppRoutes.signUp),
                                      child: Text.rich(
                                        TextSpan(
                                          text: '아직 계정이 없으신가요? ',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: Colors.white70,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '회원가입',
                                              style: textTheme.bodyMedium?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
