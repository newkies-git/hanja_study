# 로그아웃 후 자동 재로그인 문제 해결 계획

사용자가 '로그아웃'을 클릭했을 때, 앱이 즉시 익명 로그인을 수행하고 기존에 저장된 '온보딩 완료' 플래그를 참조하여 다시 홈 화면으로 자동 리다이렉트되는 디자인 결함을 수정합니다.

## User Review Required

> [!IMPORTANT]
> 로그아웃 시 **'온보딩 완료' 상태를 초기화**하도록 변경할 예정입니다. 이렇게 하면 로그아웃 후 다시 랜딩 페이지(앱 소개 화면)를 볼 수 있게 되지만, 나중에 다시 '게스트로 시작'할 경우 온보딩 과정을 다시 거쳐야 합니다. 이 동작 방식이 의도하신 바와 맞는지 확인 부탁드립니다.

---

## 🛠 Proposed Changes

### 1. `AuthController` 수정
- **파일**: [auth_controller.dart](file:///Users/yutaek.kim/Documents/zWorkSpace/HANJA/flutter/chusa1817/lib/core/auth/auth_controller.dart)
- **변경 사항**: `signOut()` 메서드 내에서 Firebase 로그아웃 및 익명 로그인 수행 전/후에 `onboardingCompleted` 설정을 `false` 또는 `null`로 초기화합니다.
- **이유**: `AppRouter`가 온보딩 완료 여부를 보고 자동으로 홈으로 보내는 것을 방지하기 위함입니다.

### 2. `AppRouter` 리다이렉트 로직 보강 (선택 사항)
- **파일**: [app_router.dart](file:///Users/yutaek.kim/Documents/zWorkSpace/HANJA/flutter/chusa1817/lib/core/router/app_router.dart)
- **변경 사항**: 랜딩 페이지에서의 자동 리다이렉트 조건을 좀 더 엄격하게 체크할 수 있는지 검토합니다. (현재는 `isNonAnonymousUser || hasCompletedOnboarding` 조건임)
- **개선안**: 만약 사용자가 명시적으로 로그아웃하여 익명 상태가 된 것이라면, `hasCompletedOnboarding`이 true여도 랜딩 페이지에 머물 수 있어야 합니다. 하지만 이를 판별하기 위해 전역 상태를 추가하는 것보다 1번 방식(플래그 초기화)이 더 깔끔할 수 있습니다.

---

## 🙋 Open Questions

1. 로그아웃 시 기기에 저장된 다른 설정값(예: 학습 목표 등)은 유지하고 **온보딩 완료 여부만** 초기화하는 방식으로 진행해도 될까요?
2. 아니면, 로그아웃 시 익명 로그인을 **즉시 수행하지 않고**, 사용자가 랜딩 페이지에서 '둘러보기(게스트로 시작)'를 눌렀을 때만 익명 로그인을 수행하도록 변경하는 것은 어떠신가요? (이 경우 Firestore 규칙을 위해 초기 앱 진입 시 익명 로그인이 필요한 시점이 언제인지 확인이 필요합니다.)

---

## Verification Plan

### Automated Tests
- `onboardingCompletedProvider`가 로그아웃 후 `false`를 반환하는지 확인하는 단위 테스트 작성 가능 여부 검토.

### Manual Verification
1. 이메일 계정으로 로그인합니다.
2. '내 정보' 탭에서 '로그아웃'을 클릭합니다.
3. 즉시 랜딩 페이지(`LandingScreen`)로 이동하고, 다시 자동으로 홈 화면으로 튕겨나가지 않는지 확인합니다.
4. 랜딩 페이지에서 '가입 / 로그인' 버튼이 정상 작동하는지 확인합니다.
