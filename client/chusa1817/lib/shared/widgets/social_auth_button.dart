import 'package:flutter/material.dart';
import '../../core/theme/hanja_colors.dart';

/// 소셜 로그인 제공자 구분.
enum SocialAuthProvider { google, apple }

/// 소셜 로그인 전용 버튼 (Google & Apple 지원).
///
/// "The Scholar's Editorial" 테마의 정체성을 유지하면서
/// 각 브랜드의 디자인 가이드라인을 준수함.
class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.provider = SocialAuthProvider.google,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final SocialAuthProvider provider;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    // 브랜드별 색상 및 로고 설정
    final bool isApple = provider == SocialAuthProvider.apple;
    final Color backgroundColor = isApple ? Colors.black : Colors.white;
    final Color textColor = isApple ? Colors.white : HanjaColors.onSurface;
    final Color borderColor = isApple ? Colors.black : HanjaColors.outlineVariant.withValues(alpha: 0.3);

    return SizedBox(
      width: double.infinity,
      height: 42,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: BorderSide(
            color: borderColor,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isApple ? Colors.white70 : HanjaColors.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isApple ? const _AppleLogo() : _GoogleLogo(),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// 구글 로고를 간단한 도형과 텍스트로 구현.
class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            fontFamily: 'Roboto',
            color: Color(0xFF4285F4),
          ),
        ),
      ),
    );
  }
}

/// 애플 로고 (SF Pro 느낌의 아이콘).
class _AppleLogo extends StatelessWidget {
  const _AppleLogo();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.apple,
      size: 22,
      color: Colors.white,
    );
  }
}
