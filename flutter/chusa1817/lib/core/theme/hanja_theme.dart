import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'hanja_colors.dart';

/// 앱 전역 [ThemeData] 팩토리.
///
/// - UI 레이어: Inter (기능성 레이블, 본문)
/// - 한자 레이어: Noto Serif (displaySmall 이상 — 한자 글자 표시에 최적)
/// - Material 3 기반, No-Line Rule 준수 (1px border 최소화)
abstract final class HanjaTheme {
  /// 라이트 테마를 반환한다.
  static ThemeData light() {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: HanjaColors.primary,
        onPrimary: HanjaColors.onPrimary,
        secondary: HanjaColors.secondary,
        error: HanjaColors.error,
        surface: HanjaColors.surface,
        onSurface: HanjaColors.onSurface,
      ),
    );

    final TextTheme interTheme = GoogleFonts.interTextTheme(base.textTheme);
    final TextTheme serifTheme = GoogleFonts.notoSerifTextTheme(interTheme);

    return base.copyWith(
      scaffoldBackgroundColor: HanjaColors.surface,
      textTheme: serifTheme
          .copyWith(
            // 본문·레이블은 Inter 유지
            bodyLarge: interTheme.bodyLarge,
            bodyMedium: interTheme.bodyMedium,
            bodySmall: interTheme.bodySmall,
            labelLarge: interTheme.labelLarge,
            labelMedium: interTheme.labelMedium,
            labelSmall: interTheme.labelSmall,
          )
          .copyWith(
            displaySmall: serifTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
            headlineSmall: serifTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
            titleLarge: interTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: HanjaColors.primaryContainer,
            ),
          ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: interTheme.bodyMedium?.copyWith(color: HanjaColors.outline),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: HanjaColors.primaryContainer,
          textStyle: interTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
