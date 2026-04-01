import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/editorial_text_field.dart';
import '../../shared/widgets/form_field_label.dart';
import '../../shared/widgets/gradient_primary_button.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSendEmailPressed() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(authControllerProvider.notifier).sendPasswordResetEmail(
            email: _emailController.text.trim(),
          );
      if (!mounted) return;
      context.push(AppRoutes.resetSent);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('메일 발송에 실패했습니다. 잠시 후 다시 시도해 주세요.'),
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
      appBar: AppBar(
        title: Text(
          '비밀번호 재설정',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: HanjaColors.primaryContainer,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.login);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: HanjaColors.outlineVariant.withAlpha(40)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 10)),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('비밀번호 재설정', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Text(
                            '가입하신 이메일 주소를 입력하시면 링크를 보내드립니다.',
                            style: textTheme.bodyMedium?.copyWith(color: HanjaColors.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: FormFieldLabel(label: '이메일 주소'),
                          ),
                          const SizedBox(height: 8),
                          EditorialTextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            hintText: 'example@scholar.com',
                            prefix: const Padding(
                              padding: EdgeInsets.only(left: 16, right: 8),
                              child: Icon(Icons.mail, color: HanjaColors.outline, size: 20),
                            ),
                            validator: (value) =>
                                (value == null || value.trim().isEmpty) ? '이메일을 입력해 주세요' : null,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: GradientPrimaryButton(
                              label: '인증 메일 보내기',
                              onPressed: () => _onSendEmailPressed(),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Divider(),
                          const SizedBox(height: 16),
                          Text.rich(
                            TextSpan(
                              text: '기억이 나셨나요? ',
                              style: textTheme.bodyMedium?.copyWith(
                                color: HanjaColors.onSurfaceVariant,
                              ),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => context.go(AppRoutes.login),
                                    child: Text(
                                      '로그인으로 돌아가기',
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
