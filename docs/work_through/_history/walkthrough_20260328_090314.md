# main.dart 분리 & pubspec 패키지 추가 — 완료 보고

## 결과 요약

| 항목 | 이전 | 이후 |
|------|------|------|
| `main.dart` 줄 수 | 1,976줄 | **25줄** |
| 파일 수 | 1개 | **26개** (신규 25개) |
| `flutter analyze` | — | ✅ **No issues found** |
| 패키지 추가 | 2개 | **11개** (운영 9 + dev 4) |

---

## 생성된 파일 목록

```
lib/
├─ main.dart                                        ← 25줄 (HanjaApp + runApp)
├─ core/theme/
│  ├─ hanja_colors.dart                             ← HanjaColors (상수 토큰)
│  └─ hanja_theme.dart                              ← HanjaTheme.light()
├─ shared/widgets/
│  ├─ won_go_ji_grid.dart
│  ├─ stroke_hint_overlay.dart
│  ├─ gradient_primary_button.dart
│  ├─ ghost_button.dart
│  ├─ editorial_text_field.dart
│  ├─ form_field_label.dart                         ← _FieldLabel → public
│  ├─ ghost_divider.dart                            ← _GhostDivider → public
│  ├─ editorial_bottom_nav.dart
│  └─ editorial_top_bar.dart
└─ features/
   ├─ landing/landing_screen.dart
   ├─ auth/login_screen.dart
   ├─ shell/app_shell.dart
   ├─ home/home_screen.dart
   ├─ learn/
   │  ├─ learn_list_screen.dart
   │  └─ hanja_detail_screen.dart
   ├─ study/
   │  ├─ study_screen.dart
   │  ├─ practice_result_screen.dart
   │  └─ widgets/
   │     ├─ practice_canvas_card.dart
   │     └─ practice_action_tile.dart
   ├─ statistics/statistics_screen.dart
   └─ profile/
      ├─ profile_screen.dart
      └─ plan_settings_screen.dart
```

---

## OOP 명명 규칙 주요 변경 사항

| 구 이름 (main.dart) | 신 이름 | 변경 이유 |
|---------------------|---------|-----------|
| `_FieldLabel` | `FormFieldLabel` | private → public 재사용 가능 위젯으로 승격 |
| `_GhostDivider` | `GhostDivider` | 동일 |
| `_RelatedWordTile` | `RelatedWordTile` | 단어 목록 화면(Phase 2)에서 재사용 예정 |
| `_PlanChoiceCard` | `_DailyGoalCard` | 역할을 명확히 표현 |
| `_RadioRow` | `_OrderRadioRow` | 학습 순서 선택 라디오 전용임을 명시 |
| `index` (AppShell) | `selectedIndex` | 의미 전달 명확화 |
| `onChanged` (BottomNav) | `onItemSelected` | 이벤트 주체 명시 |
| `_pwController` | `_passwordController` | 약어 → 완전한 이름 |
| `_pwVisible` | `_isPasswordVisible` | bool 프리픽스 `is` 적용 |
| `selected` (Pill, Tab) | `isSelected` | bool 프리픽스 `is` 적용 |

---

## 검증 결과

```bash
$ flutter pub get
Got dependencies!  ✅

$ flutter analyze --no-fatal-infos
No issues found! (ran in 0.9s)  ✅
```

---

## 추가된 pubspec.yaml 패키지

```yaml
# 운영 패키지
flutter_riverpod: ^2.6.1      # 상태 관리
go_router: ^14.8.1            # 선언형 라우팅
drift: ^2.23.1                # SQLite ORM
sqlite3_flutter_libs: ^0.5.26 # SQLite 네이티브 바인딩
path_provider: ^2.1.5         # DB 파일 경로
path: ^1.9.1                  # 경로 유틸
dio: ^5.8.0                   # HTTP 클라이언트
flutter_svg: ^2.0.17          # SVG 렌더링
shared_preferences: ^2.3.5    # 앱 설정 저장

# dev 패키지
drift_dev / build_runner / riverpod_generator / riverpod_lint
```
