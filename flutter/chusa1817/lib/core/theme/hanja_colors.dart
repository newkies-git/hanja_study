import 'package:flutter/material.dart';

/// 한자학습 앱 전역 색상 토큰.
///
/// 디자인 시스템 "The Scholar's Editorial"의 Scholar Blue 팔레트 기반.
/// 모든 속성은 컴파일 타임 상수이므로 위젯 트리 어디서든 직접 참조 가능.
abstract final class HanjaColors {
  // ── Primary ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF003FB1);
  static const Color primaryContainer = Color(0xFF1A56DB);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryFixed = Color(0xFFDBE1FF);

  // ── Secondary (Success / Stroke correct) ─────────────────────────────────
  static const Color secondary = Color(0xFF006C4A);
  static const Color secondaryContainer = Color(0xFF82F5C1);

  // ── Tertiary (Error / Stroke wrong) ──────────────────────────────────────
  static const Color tertiary = Color(0xFF98000C);
  static const Color tertiaryContainer = Color(0xFFFFDAD6);

  // ── Surface hierarchy ────────────────────────────────────────────────────
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceVariant = Color(0xFFE1E3E4);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F5);
  static const Color surfaceContainer = Color(0xFFEDEEEF);
  static const Color surfaceContainerHigh = Color(0xFFE7E8E9);
  static const Color surfaceContainerHighest = Color(0xFFE1E3E4);

  // ── On-Surface ───────────────────────────────────────────────────────────
  static const Color onSurface = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF434654);

  // ── Outline ──────────────────────────────────────────────────────────────
  static const Color outline = Color(0xFF737686);
  static const Color outlineVariant = Color(0xFFC3C5D7);

  // ── UI System (Standardized from legacy) ──────────────────────────────────
  static const Color neutralIcon = Color(0xFF9A9DA0);
  static const Color surfaceSoft = Color(0xFFFAFAFA);
  static const Color shadow = Color(0x14000000);

  // ── Semantic Status (@Scholar's Palette) ──────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color statusSuccess = Color(0xFF2E7D32);
  static const Color statusWarning = Color(0xFFE65100);
  static const Color statusWarningContainer = Color(0xFFFFE0B2); // Pastel Orange

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// 정확도(0.0~1.0)에 따른 시맨틱 색상.
  /// 85% 이상 → 성공, 60% 이상 → 경고, 그 이하 → 오류.
  static Color forAccuracy(double accuracy) {
    if (accuracy >= 0.85) return statusSuccess;
    if (accuracy >= 0.60) return statusWarning;
    return error;
  }
}
