# main.dart 분리 및 pubspec.yaml 패키지 추가

기존 `lib/main.dart` 단일 파일(1,976줄)을 OOP 설계 원칙에 따라 `features/`, `shared/`, `core/` 계층으로 분리하고, 상태 관리·DB·라우팅 등 핵심 패키지를 추가합니다.

---

## 분리 대상 클래스 목록 (현재 main.dart)

| 클래스 | 역할 | 이동 위치 |
|--------|------|-----------|
| `HanjaColors` | 컬러 토큰 | `core/theme/hanja_colors.dart` |
| `HanjaTheme` | ThemeData 빌더 | `core/theme/hanja_theme.dart` |
| `HanjaApp` | 앱 루트 | `main.dart` (유지) |
| `LandingScreen` | 랜딩 화면 | `features/landing/landing_screen.dart` |
| `LoginScreen`, `_LoginScreenState` | 로그인 화면 | `features/auth/login_screen.dart` |
| `AppShell`, `_AppShellState` | 바텀 nav 셸 | `features/shell/app_shell.dart` |
| `EditorialBottomNav`, `_BottomNavItem`, `_BottomNavButton` | 공용 바텀 nav | `shared/widgets/editorial_bottom_nav.dart` |
| `EditorialTopBar` | 공용 상단 바 | `shared/widgets/editorial_top_bar.dart` |
| `HomeScreen` | 홈 화면 | `features/home/home_screen.dart` |
| `LearnListScreen`, `_Pill`, `_HanjaCard` | 학습 목록 | `features/learn/learn_list_screen.dart` |
| `HanjaDetailScreen`, `_HanjaDetailScreenState`, `_DetailTab`, `_RelatedWordTile` | 한자 상세 | `features/learn/hanja_detail_screen.dart` |
| `StudyScreen`, `_PracticeTopBar` | 쓰기 연습 | `features/study/study_screen.dart` |
| `PracticeCanvasCard` | 쓰기 캔버스 카드 | `features/study/widgets/practice_canvas_card.dart` |
| `PracticeActionTile`, `PracticeActionTileVariant` | 연습 액션 버튼 | `features/study/widgets/practice_action_tile.dart` |
| `PracticeResultScreen` | 연습 결과 화면 | `features/study/practice_result_screen.dart` |
| `StatisticsScreen` | 통계 화면 | `features/statistics/statistics_screen.dart` |
| `ProfileScreen` | 프로필 화면 | `features/profile/profile_screen.dart` |
| `PlanSettingsScreen`, `_PlanSettingsScreenState`, `_PlanChoiceCard`, `_RadioRow` | 학습 계획 설정 | `features/profile/plan_settings_screen.dart` |
| `WonGoJiGrid`, `_WonGoJiGridPainter` | 원고지 그리드 | `shared/widgets/won_go_ji_grid.dart` |
| `StrokeHintOverlay`, `_StrokeHintPainter` | 획 힌트 오버레이 | `shared/widgets/stroke_hint_overlay.dart` |
| `GradientPrimaryButton` | CTA 버튼 | `shared/widgets/gradient_primary_button.dart` |
| `GhostButton` | 보조 버튼 | `shared/widgets/ghost_button.dart` |
| `EditorialTextField` | 입력 필드 | `shared/widgets/editorial_text_field.dart` |
| `_FieldLabel` | 필드 레이블 | `shared/widgets/form_field_label.dart` (public으로 승격) |
| `_GhostDivider` | 구분선 | `shared/widgets/ghost_divider.dart` (public으로 승격) |

---

## 최종 디렉터리 구조

```
lib/
├─ main.dart                         ← HanjaApp + runApp만 남김
├─ core/
│  └─ theme/
│     ├─ hanja_colors.dart            ← HanjaColors (const 색상 토큰)
│     └─ hanja_theme.dart             ← HanjaTheme.light()
├─ features/
│  ├─ landing/
│  │  └─ landing_screen.dart
│  ├─ auth/
│  │  └─ login_screen.dart
│  ├─ shell/
│  │  └─ app_shell.dart
│  ├─ home/
│  │  └─ home_screen.dart
│  ├─ learn/
│  │  ├─ learn_list_screen.dart
│  │  └─ hanja_detail_screen.dart
│  ├─ study/
│  │  ├─ study_screen.dart
│  │  ├─ practice_result_screen.dart
│  │  └─ widgets/
│  │     ├─ practice_canvas_card.dart
│  │     └─ practice_action_tile.dart
│  ├─ statistics/
│  │  └─ statistics_screen.dart
│  └─ profile/
│     ├─ profile_screen.dart
│     └─ plan_settings_screen.dart
└─ shared/
   └─ widgets/
      ├─ editorial_bottom_nav.dart
      ├─ editorial_top_bar.dart
      ├─ editorial_text_field.dart
      ├─ gradient_primary_button.dart
      ├─ ghost_button.dart
      ├─ won_go_ji_grid.dart
      ├─ stroke_hint_overlay.dart
      ├─ form_field_label.dart
      └─ ghost_divider.dart
```

---

## OOP Naming Rule 준수 기준

- **클래스**: `UpperCamelCase`. 역할이 명확한 명사 + 접미사(`Screen`, `Widget`, `Painter`, `Button`, `Card`, `Tile`)
- **private 클래스 → public 승격**: `_FieldLabel` → `FormFieldLabel`, `_GhostDivider` → `GhostDivider`
- **파일명**: `snake_case`. 클래스명과 1:1 매칭
- **접두사 `_` 제거**: 파일 내 전용 private 클래스만 `_` 유지 (예: `_WonGoJiGridPainter`, `_StrokeHintPainter`, `_BottomNavItem`)
- **enum**: `UpperCamelCase` 타입명, `lowerCamelCase` 값 (예: `PracticeActionTileVariant.neutral`)

---

## pubspec.yaml 추가 패키지

```yaml
dependencies:
  flutter_riverpod: ^2.6.1      # 상태 관리
  go_router: ^14.8.1            # 선언형 라우팅
  drift: ^2.23.1                # SQLite ORM (Drift)
  sqlite3_flutter_libs: ^0.5.26 # SQLite native 바인딩
  path_provider: ^2.1.5         # DB 파일 경로
  path: ^1.9.1                  # 경로 유틸
  dio: ^5.8.0                   # HTTP 클라이언트
  flutter_svg: ^2.0.17          # SVG 렌더링 (획순 애니메이션)
  shared_preferences: ^2.3.5    # 설정 로컬 저장

dev_dependencies:
  drift_dev: ^2.23.1            # Drift 코드 생성
  build_runner: ^2.4.15         # 코드 생성 러너
  riverpod_generator: ^2.6.5    # Riverpod 어노테이션 코드 생성
  riverpod_lint: ^2.6.5         # Riverpod 린트
```

---

## 검증 계획

### 자동 테스트

기존 테스트 파일 위치: `test/widget_test.dart`

```bash
# 프로젝트 루트에서 실행
cd /Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/fe/hanja_app
flutter pub get
flutter analyze
flutter test
```

### 수동 검증 (빌드 확인)

```bash
# iOS 시뮬레이터 실행
flutter run -d "iPhone 16"

# 또는 Android 에뮬레이터
flutter run -d emulator
```

확인 항목:
1. 앱 실행 시 `LandingScreen` 표시
2. '로그인' 버튼 → `LoginScreen` 전환
3. '학습 시작하기' 버튼 → `AppShell` (홈 탭)
4. 바텀 나비게이션 4개 탭 전환 정상
5. 학습 탭 → 한자 카드 탭 → 상세 화면
6. 상세 화면 '쓰기 연습 시작' → `StudyScreen`
7. 완료 → `PracticeResultScreen`
8. 프로필 → 학습 계획 설정
