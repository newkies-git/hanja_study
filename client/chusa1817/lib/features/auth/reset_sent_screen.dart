import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/hanja_colors.dart';
import '../../shared/widgets/gradient_primary_button.dart';

class ResetSentScreen extends StatelessWidget {
  const ResetSentScreen({super.key});

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
          onPressed: () => context.go(AppRoutes.login),
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
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: HanjaColors.outlineVariant.withAlpha(40)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: HanjaColors.surfaceContainerLow,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.mark_email_read, size: 48, color: HanjaColors.primary),
                        ),
                        const SizedBox(height: 32),
                        Text('인증 메일이 발송되었습니다', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Text(
                          '비밀번호 재설정을 위한 안내 메일을 아래 주소로 보내드렸습니다.',
                          style: textTheme.bodyMedium?.copyWith(color: HanjaColors.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: HanjaColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: HanjaColors.outlineVariant.withAlpha(25)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.alternate_email, color: HanjaColors.outline, size: 20),
                              const SizedBox(width: 12),
                              Text('schol****@domain.com', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: HanjaColors.primary)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        SizedBox(
                          width: double.infinity,
                          child: GradientPrimaryButton(
                            label: '로그인으로 돌아가기',
                            onPressed: () => context.go(AppRoutes.login),
                          ),
                        ),
                      ],
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
