import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'hanja_colors.dart';

/// 앱 전역 [ThemeData] 팩토리.
///
/// - UI 레이어: Inter
/// - 한자 레이어: Noto Serif
/// - Material 3 기반, 라이트/다크 모두 지원
abstract final class HanjaTheme {
  // ── 다크 팔레트 상수 ────────────────────────────────────────────────────────
  static const Color _dSurface                = Color(0xFF111318);
  static const Color _dSurfaceContainerLowest = Color(0xFF1A1C22); // 카드 배경
  static const Color _dSurfaceContainerLow    = Color(0xFF1E2028);
  static const Color _dSurfaceContainer       = Color(0xFF23252E);
  static const Color _dSurfaceContainerHigh   = Color(0xFF282B34);
  static const Color _dSurfaceContainerHighest= Color(0xFF2D303A);
  static const Color _dOnSurface              = Color(0xFFE2E2E9);
  static const Color _dOnSurfaceVariant       = Color(0xFFC5C6D0);
  static const Color _dOutline                = Color(0xFF8E9099);
  static const Color _dOutlineVariant         = Color(0xFF43454E);
  static const Color _dPrimary                = Color(0xFF98B4FF); // 어두운 배경 위 밝은 파란색
  static const Color _dPrimaryContainer       = Color(0xFF4E6EF8);

  // ── 공통 텍스트 테마 헬퍼 ────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(ThemeData base) {
    final inter  = GoogleFonts.interTextTheme(base.textTheme);
    final serif  = GoogleFonts.notoSerifKrTextTheme(inter);
    return serif
        .copyWith(
          bodyLarge:   inter.bodyLarge,
          bodyMedium:  inter.bodyMedium,
          bodySmall:   inter.bodySmall,
          labelLarge:  inter.labelLarge,
          labelMedium: inter.labelMedium,
          labelSmall:  inter.labelSmall,
        )
        .copyWith(
          displaySmall: serif.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
          headlineSmall: serif.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
          titleLarge: inter.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        );
  }

  // ── 라이트 테마 ──────────────────────────────────────────────────────────────
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary:           HanjaColors.primary,
        onPrimary:         HanjaColors.onPrimary,
        primaryContainer:  HanjaColors.primaryContainer,
        secondary:         HanjaColors.secondary,
        secondaryContainer:HanjaColors.secondaryContainer,
        tertiary:          HanjaColors.tertiary,
        tertiaryContainer: HanjaColors.tertiaryContainer,
        error:             HanjaColors.error,
        surface:           HanjaColors.surface,
        onSurface:         HanjaColors.onSurface,
        onSurfaceVariant:  HanjaColors.onSurfaceVariant,
        outline:           HanjaColors.outline,
        outlineVariant:    HanjaColors.outlineVariant,
      ).copyWith(
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow:    HanjaColors.surfaceContainerLow,
        surfaceContainer:       HanjaColors.surfaceContainer,
        surfaceContainerHigh:   HanjaColors.surfaceContainerHigh,
        surfaceContainerHighest:HanjaColors.surfaceContainerHighest,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: HanjaColors.surface,
      textTheme: _buildTextTheme(base),
      inputDecorationTheme: _inputDecoration(HanjaColors.surfaceContainerLowest),
      textButtonTheme: _textButtonTheme(GoogleFonts.interTextTheme(base.textTheme)),
    );
  }

  // ── 다크 테마 ────────────────────────────────────────────────────────────────
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary:           _dPrimary,
        onPrimary:         const Color(0xFF002884),
        primaryContainer:  _dPrimaryContainer,
        secondary:         const Color(0xFF6DDBA2),
        onSecondary:       const Color(0xFF003823),
        secondaryContainer:const Color(0xFF005235),
        tertiary:          const Color(0xFFFFB3AE),
        tertiaryContainer: const Color(0xFF93000A),
        error:             const Color(0xFFFFB4AB),
        errorContainer:    const Color(0xFF93000A),
        surface:           _dSurface,
        onSurface:         _dOnSurface,
        onSurfaceVariant:  _dOnSurfaceVariant,
        outline:           _dOutline,
        outlineVariant:    _dOutlineVariant,
      ).copyWith(
        surfaceContainerLowest: _dSurfaceContainerLowest,
        surfaceContainerLow:    _dSurfaceContainerLow,
        surfaceContainer:       _dSurfaceContainer,
        surfaceContainerHigh:   _dSurfaceContainerHigh,
        surfaceContainerHighest:_dSurfaceContainerHighest,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: _dSurface,
      textTheme: _buildTextTheme(base),
      inputDecorationTheme: _inputDecoration(_dSurfaceContainerLow),
      textButtonTheme: _textButtonTheme(GoogleFonts.interTextTheme(base.textTheme)),
    );
  }

  // ── 공통 데코 헬퍼 ─────────────────────────────────────────────────────────
  static InputDecorationTheme _inputDecoration(Color fillColor) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: HanjaColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: HanjaColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: HanjaColors.primary, width: 2),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(TextTheme inter) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: HanjaColors.primaryContainer,
        textStyle: inter.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// 스크롤 시 화면이 늘어나는 현상(Android 12+ Stretch Overscroll)을 방지하는 커스텀 [ScrollBehavior].
class NoStretchScrollBehavior extends ScrollBehavior {
  const NoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // 늘어남(Stretch) 및 오버스크롤 파동(Glow) 효과를 완전히 제거
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // 스크롤 경계에서 늘어나지 않고 딱 고정되는 ClampingScrollPhysics 적용
    return const ClampingScrollPhysics();
  }
}

/// [BuildContext] 헬퍼 — 테마 적응형 색상 단축키.
extension HanjaThemeContext on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;

  /// 카드·패널 배경색 (라이트: white, 다크: dark card).
  Color get cardSurface => Theme.of(this).colorScheme.surfaceContainerLowest;

  /// 설정 화면 섹션 배경 (라이트: surfaceContainerLow, 다크: 살짝 어두운 버전).
  Color get settingsSurface => Theme.of(this).colorScheme.surfaceContainerLow;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
