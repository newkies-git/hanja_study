import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/editorial_input_group.dart';
import '../../shared/widgets/gradient_primary_button.dart';
import '../../core/auth/firebase_auth_error_message.dart';
import '../../shared/widgets/ghost_divider.dart';
import '../../shared/widgets/social_auth_button.dart';
import '../../shared/widgets/editorial_modal.dart';
import '../../shared/widgets/terms_modal_content.dart';

/// 회원가입 화면 (Premium Re-design).
/// 
/// 로그인 화면과 일관된 Glassmorphism 및 애니메이션 효과를 적용하며,
/// 모든 입력 요소의 높이를 42px 규격으로 최적화함.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isSubmitting = false;
  bool _startAnimation = false;

  @override
  void initState() {
    super.initState();
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onSignUpPressed() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSubmitting) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이용약관 및 개인정보처리방침에 동의해 주세요.'),
          backgroundColor: HanjaColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('비밀번호가 일치하지 않습니다.'),
          backgroundColor: HanjaColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(authControllerProvider.notifier).signUpWithEmailPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
          );
      if (!mounted) return;
      context.push(AppRoutes.signUpSuccess);
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

  Future<void> _submitGoogleSignUp() async {
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

  Future<void> _submitAppleSignUp() async {
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

  void _showTermsOfUse() {
    EditorialModal.show(
      context: context,
      title: '이용약관',
      child: const TermsModalContent(
        title: '이용약관',
        content: TermsModalContent.termsOfUse,
      ),
    );
  }

  void _showPrivacyPolicy() {
    EditorialModal.show(
      context: context,
      title: '개인정보처리방침',
      child: const TermsModalContent(
        title: '개인정보처리방침',
        content: TermsModalContent.privacyPolicy,
      ),
    );
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
          
          // 3. SignUp Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    // Top Bar (Back & Title)
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: _startAnimation ? 1.0 : 0.0),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, child) {
                        return Opacity(opacity: value, child: child);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkResponse(
                            radius: 24,
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(AppRoutes.login);
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
                          Text(
                            '추사 1817',
                            style: textTheme.titleMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w900,
                              color: Colors.white.withValues(alpha: 0.9),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 480),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    '회원가입',
                                    style: textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  EditorialInputGroup(
                                    label: '성함',
                                    labelColor: Colors.white70,
                                    controller: _nameController,
                                    hintText: '당신의 이름을 알려주세요',
                                    fillColor: Colors.white.withValues(alpha: 0.08),
                                    textColor: Colors.white,
                                    hintColor: Colors.white24,
                                    isRequired: true,
                                    validator: (value) =>
                                        (value == null || value.trim().isEmpty) ? '이름을 입력해 주세요' : null,
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  EditorialInputGroup(
                                    label: '이메일 주소',
                                    labelColor: Colors.white70,
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    hintText: 'scholar@example.com',
                                    fillColor: Colors.white.withValues(alpha: 0.08),
                                    textColor: Colors.white,
                                    hintColor: Colors.white24,
                                    isRequired: true,
                                    validator: (value) =>
                                        (value == null || value.trim().isEmpty) ? '이메일을 입력해 주세요' : null,
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  EditorialInputGroup(
                                    label: '비밀번호',
                                    labelColor: Colors.white70,
                                    controller: _passwordController,
                                    obscureText: true,
                                    hintText: '••••••••',
                                    fillColor: Colors.white.withValues(alpha: 0.08),
                                    textColor: Colors.white,
                                    hintColor: Colors.white24,
                                    isRequired: true,
                                    validator: (value) =>
                                        (value == null || value.isEmpty) ? '비밀번호를 입력해 주세요' : null,
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  EditorialInputGroup(
                                    label: '비밀번호 확인',
                                    labelColor: Colors.white70,
                                    controller: _confirmController,
                                    obscureText: true,
                                    hintText: '••••••••',
                                    fillColor: Colors.white.withValues(alpha: 0.08),
                                    textColor: Colors.white,
                                    hintColor: Colors.white24,
                                    isRequired: true,
                                    validator: (value) =>
                                        (value == null || value.isEmpty) ? '비밀번호를 다시 한번 입력해 주세요' : null,
                                  ),
                                  const SizedBox(height: 10),
                                  
                                  // Terms Agreement
                                  Row(
                                    children: [
                                      Theme(
                                        data: ThemeData(
                                          unselectedWidgetColor: Colors.white24,
                                        ),
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Checkbox(
                                            value: _agreedToTerms,
                                            onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                                            activeColor: HanjaColors.primaryContainer,
                                            checkColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                            side: const BorderSide(color: Colors.white24),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              WidgetSpan(
                                                alignment: PlaceholderAlignment.middle,
                                                child: GestureDetector(
                                                  onTap: _showTermsOfUse,
                                                  child: Text(
                                                    '이용약관',
                                                    style: textTheme.labelMedium?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      decoration: TextDecoration.underline,
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const TextSpan(text: ' 및 ', style: TextStyle(color: Colors.white38)),
                                              WidgetSpan(
                                                alignment: PlaceholderAlignment.middle,
                                                child: GestureDetector(
                                                  onTap: _showPrivacyPolicy,
                                                  child: Text(
                                                    '개인정보처리방침',
                                                    style: textTheme.labelMedium?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      decoration: TextDecoration.underline,
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const TextSpan(text: '에 동의합니다.', style: TextStyle(color: Colors.white38)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  GradientPrimaryButton(
                                    label: '가입하기',
                                    onPressed: () => _onSignUpPressed(),
                                  ),
                                  const SizedBox(height: 12),
                                  
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
                                  const SizedBox(height: 12),
                                  
                                  SocialAuthButton(
                                    label: 'Google 로그인',
                                    isLoading: _isSubmitting,
                                    onPressed: () => _submitGoogleSignUp(),
                                  ),
                                  const SizedBox(height: 8),
                                  SocialAuthButton(
                                    label: 'Apple 로그인',
                                    provider: SocialAuthProvider.apple,
                                    isLoading: _isSubmitting,
                                    onPressed: () => _submitAppleSignUp(),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  Center(
                                    child: GestureDetector(
                                      onTap: () => context.go(AppRoutes.login),
                                      child: Text.rich(
                                        TextSpan(
                                          text: '이미 계정이 있으신가요? ',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: Colors.white70,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '로그인',
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
