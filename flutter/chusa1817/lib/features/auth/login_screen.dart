import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/editorial_text_field.dart';
import '../../shared/widgets/form_field_label.dart';
import '../../shared/widgets/ghost_divider.dart';
import '../../shared/widgets/gradient_primary_button.dart';
import '../../core/router/app_router.dart';

/// 이메일/비밀번호 로그인 화면.
///
/// 폼 검증 후 [AppShell]로 이동한다.
/// 소셜 로그인은 Phase 2에서 추가 예정.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_emailController.text == 'admin@test.com' && _passwordController.text == 'admin!1') {
      isLoggedIn = true;
      context.go(AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('아이디 또는 비밀번호가 올바르지 않습니다.'),
          backgroundColor: HanjaColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InkResponse(
                      radius: 24,
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.landing);
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.arrow_back, color: HanjaColors.onSurface),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('이메일로 로그인', style: textTheme.displaySmall),
                      const SizedBox(height: 8),
                      Text(
                        '학습을 이어가기 위해 정보를 입력해 주세요.',
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
                        const FormFieldLabel(label: '이메일'),
                        const SizedBox(height: 8),
                        EditorialTextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          hintText: '이메일 주소를 입력해 주세요',
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? '이메일을 입력해 주세요'
                                  : null,
                        ),
                        const SizedBox(height: 20),
                        const FormFieldLabel(label: '비밀번호'),
                        const SizedBox(height: 8),
                        EditorialTextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          hintText: '비밀번호를 입력해 주세요',
                          suffix: IconButton(
                            onPressed: () => setState(
                              () => _isPasswordVisible = !_isPasswordVisible,
                            ),
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: HanjaColors.outline,
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
                            child: const Text('비밀번호를 잊으셨나요?'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GradientPrimaryButton(
                          label: '로그인',
                          onPressed: _onLoginPressed,
                        ),
                        const SizedBox(height: 20),
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
                        const SizedBox(height: 18),
                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: '아직 계정이 없으신가요? ',
                              style: textTheme.bodyMedium?.copyWith(
                                color: HanjaColors.onSurfaceVariant,
                              ),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => context.push(AppRoutes.signUp),
                                    child: Text(
                                      '회원가입',
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
