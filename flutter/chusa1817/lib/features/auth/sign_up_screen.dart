import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/editorial_text_field.dart';
import '../../shared/widgets/form_field_label.dart';
import '../../shared/widgets/gradient_primary_button.dart';
import '../../core/auth/firebase_auth_error_message.dart';
import '../../shared/widgets/ghost_divider.dart';
import '../../shared/widgets/social_auth_button.dart';

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
          );
      if (!mounted) return;
      context.push(AppRoutes.signUpSuccess);
    } catch (error) {
      if (!mounted) return;
      if (kDebugMode) {
        debugPrint('회원가입 실패: $error');
      }
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

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: HanjaColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
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
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.arrow_back, color: HanjaColors.primaryContainer),
                        ),
                      ),
                      Text(
                        '추사 1817',
                        style: textTheme.titleLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          color: HanjaColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Column(
                    children: [
                      Text('회원가입', style: textTheme.displaySmall?.copyWith(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        '새로운 배움의 여정을 시작하세요',
                        style: textTheme.bodyMedium?.copyWith(
                          color: HanjaColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      children: [
                        const FormFieldLabel(label: '성함'),
                        const SizedBox(height: 8),
                        EditorialTextField(
                          controller: _nameController,
                          hintText: '홍길동',
                          validator: (value) =>
                              (value == null || value.trim().isEmpty) ? '이름을 입력해 주세요' : null,
                        ),
                        const SizedBox(height: 20),
                        const FormFieldLabel(label: '이메일 주소'),
                        const SizedBox(height: 8),
                        EditorialTextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          hintText: 'scholar@example.com',
                          validator: (value) =>
                              (value == null || value.trim().isEmpty) ? '이메일을 입력해 주세요' : null,
                        ),
                        const SizedBox(height: 20),
                        const FormFieldLabel(label: '비밀번호'),
                        const SizedBox(height: 8),
                        EditorialTextField(
                          controller: _passwordController,
                          obscureText: true,
                          hintText: '••••••••',
                          validator: (value) =>
                              (value == null || value.isEmpty) ? '비밀번호를 입력해 주세요' : null,
                        ),
                        const SizedBox(height: 20),
                        const FormFieldLabel(label: '비밀번호 확인'),
                        const SizedBox(height: 8),
                        EditorialTextField(
                          controller: _confirmController,
                          obscureText: true,
                          hintText: '••••••••',
                          validator: (value) =>
                              (value == null || value.isEmpty) ? '비밀번호를 다시 한번 입력해 주세요' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _agreedToTerms,
                                onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                                activeColor: HanjaColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                side: BorderSide(color: HanjaColors.outlineVariant),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '이용약관',
                                      style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: HanjaColors.onSurfaceVariant),
                                    ),
                                    TextSpan(text: ' 및 ', style: textTheme.labelMedium?.copyWith(color: HanjaColors.onSurfaceVariant)),
                                    TextSpan(
                                      text: '개인정보처리방침',
                                      style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: HanjaColors.onSurfaceVariant),
                                    ),
                                    TextSpan(text: '에 동의합니다.', style: textTheme.labelMedium?.copyWith(color: HanjaColors.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        GradientPrimaryButton(
                          label: '가입하기',
                          onPressed: () => _onSignUpPressed(),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Expanded(child: GhostDivider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '또는',
                                style: textTheme.labelSmall?.copyWith(
                                  color: HanjaColors.outline,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                            const Expanded(child: GhostDivider()),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SocialAuthButton(
                          label: 'Google 계정으로 가입',
                          isLoading: _isSubmitting,
                          onPressed: () => _submitGoogleSignUp(),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: '이미 계정이 있으신가요? ',
                              style: textTheme.bodyMedium?.copyWith(
                                color: HanjaColors.onSurfaceVariant,
                              ),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => context.go(AppRoutes.login),
                                    child: Text(
                                      '로그인',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: HanjaColors.primaryContainer,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
