# 스크롤 Stretch Overscroll 방지 설정 워크스루

## 1. 개요
Android 12+ (API 31+) 시스템 기본값으로 적용되는 **스크롤 경계 상/하단 늘어남 효과(Stretch Overscroll Effect)**를 완화하고, 전역적으로 경계에서 늘어나지 않고 깔끔하게 고정되는 `ClampingScrollPhysics` 기반의 `NoStretchScrollBehavior`를 적용했습니다.

---

## 2. 주요 보완 내역

1. **`lib/core/theme/hanja_theme.dart`**:
   - `NoStretchScrollBehavior` 커스텀 클래스 추가
   - `buildOverscrollIndicator`: 늘어남(Stretch) 및 파동(Glow) 효과 완전히 제거
   - `getScrollPhysics`: 경계 상/하단에서 고정되는 `ClampingScrollPhysics` 반환
2. **`lib/main.dart`**:
   - `MaterialApp.router` 내 `scrollBehavior: const NoStretchScrollBehavior()` 적용하여 앱 전체 화면 스크롤 뷰포트에 공통 적용

---

## 3. 검증 결과
- **Flutter 테스트 수트**: **16 / 16 Passed (100% 통과)**
