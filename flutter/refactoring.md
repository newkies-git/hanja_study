우선순위 1 — 버그/데이터 정합성 (즉시 수정 권장)
B-1. practice_result_screen.dart — 탭 인덱스 오류
"학습 통계 보기" 버튼이 AppShell(initialIndex: 2) 로 이동하는데, 탭 2는 복습(ReviewScreen) 이고 통계는 탭 3 입니다.

lib/features/study/practice_result_screen.dart → initialIndex: 2 → 3으로 수정 필요
B-2. firestore_content_sync.dart — 동기화 중간 실패 시 데이터 공백 위험
전체 삭제 후 재삽입 구조에서, 중간에 네트워크 오류가 나면 로컬 DB가 빈 상태로 남습니다. 또한 content_config의 버전은 삭제 전에 이미 써버려서, 실패 후 재시도 시 "버전이 맞다고 판단해 스킵"하는 상황이 이론상 가능합니다.

lib/core/firebase/firestore_content_sync.dart — content_config 갱신 위치를 동기화 완료 후로 이동 필요
B-3. StrokeAnimationPlayer — 빈 strokes 전달 시 런타임 에러
widget.strokes[_currentStrokeIndex] 는 빈 리스트 시 RangeError. 현재 HanjaDetailScreen이 호출 전에 usable.isEmpty 로 막고 있지만, 위젯 자체에도 방어 필요.

lib/features/study/widgets/stroke_animation_player.dart
B-4. firestore_mappers.dart — 단어 reading 필드 오매핑
FirestoreWordMapper.wordRow / idiomRow 에서 reading: word(단어 문자열)를 독음에 넣고 있어, Firestore에 reading/pronunciation 필드가 있다면 의미 손실.

lib/core/firebase/firestore_mappers.dart
B-5. _normalizeSchoolLevel — 비표준 값 그대로 DB 저장
middle/high/both 외 값이 오면 원본 문자열을 그대로 저장 → fetchByLevel('middle') 조회에서 누락됩니다.

lib/core/firebase/firestore_mappers.dart
우선순위 2 — 미완성(Stub) 기능 (기능 완성 필요)
U-1. 학습 계획 설정이 저장되지 않음
PlanSettingsScreen의 일과 목표·요일·순서는 setState로만 관리, SharedPreferences나 DB 저장 없음.

lib/features/profile/plan_settings_screen.dart
U-2. practice_result_screen.dart — 점수·EXP 하드코딩
'5', '+150 EXP'가 하드코딩. 실제 세션/진도 결과를 받아서 표시해야 합니다.

lib/features/study/practice_result_screen.dart
U-3. statistics_screen.dart — 전체 더미 데이터
_weeklyHeightRatios 등 모두 상수. StudySessionRepository.fetchRecentSessions 와 ProgressRepository 가 이미 구현돼 있으므로 연결 가능합니다.

lib/features/statistics/statistics_screen.dart
U-4. review_screen.dart — 예정 복습 섹션 항상 빈 카드
"다가오는 복습" 섹션이 _EmptyCard로 고정. dueForReviewHanjaProvider 를 날짜 범위별로 확장해야 합니다.

U-5. profile_screen.dart — 사용자 정보 하드코딩
이름·이메일이 Scholar/scholar@example.com로 고정. FirebaseAuth.currentUser의 displayName/email로 교체 필요.

U-6. home_screen.dart — 오늘 목표가 하드코딩 5
_todayGoal = 5가 상수. PlanSettingsScreen 저장값(SharedPreferences/AppSettingsRepository)을 읽어야 합니다.

U-7. 온보딩 완료 플래그 미저장
OnboardingScreen 마지막 페이지에서 home?tab=1로 이동만 하고, 완료 여부를 영속하지 않아 앱 재실행 시 온보딩이 다시 뜹니다.

lib/features/onboarding/onboarding_screen.dart
U-8. learn_list_screen.dart — 정렬 필터 미구현
가나다순·획수순·랜덤 Pill이 onTap: () {}로 동작하지 않습니다.

lib/features/learn/learn_list_screen.dart
U-9. hanja_detail_screen.dart — 어원·관련 단어 연동 미완
기본정보 탭 어원 설명이 하드코딩. HanjaTable.origin 컬럼에서 읽어야 합니다. RelatedWordTile에 탭/네비게이션 없음.

U-10. hanja_detail_screen.dart — 공유 버튼 미구현
상단 우측 Icons.share 는 Icon만 있고 액션이 없습니다.

U-11. study_screen.dart — 힌트·정답보기·채점·저장 없음
힌트(onPressed: () {})/정답보기 모두 무동작
쓰기 완료 후 세션 저장(StudySessionRepository.endSession), 진도 갱신(ProgressRepository.saveProgress) 없음
lessonLabel: '제 4강', _totalStrokes = 8 하드코딩 (DB의 totalStrokes를 써야 함)
U-12. profile_screen.dart — 로그아웃이 Firebase signOut을 호출하지 않음
context.go(AppRoutes.landing) 만 실행하고, AuthController.signOut()이 불리지 않습니다.

우선순위 3 — 에러/로딩 처리 보완
파일	현황
home_screen.dart	value ?? 0 / value ?? [] — 로딩·에러 UI 없음
review_screen.dart	로딩은 스피너, 에러는 분기 없음
hanja_detail_screen.dart	관련 단어 탭 에러 분기 없음(valueOrNull만 사용)
study_screen.dart	한자 로딩 중 빈 문자 표시, 에러 분기 없음
우선순위 4 — 코드 품질·구조
Q-1. 더미 데이터 주석과 실제 구현 불일치
learn_list_screen.dart, home_screen.dart 에 "더미 데이터 / Phase 3 교체" 주석이 남아 있지만 실제 Provider 로 이미 전환됨 → 오해를 유발하는 주석 정리 필요.

Q-2. riverpod_lint / riverpod_generator가 pubspec.yaml에 있지만 실제 적용 안 됨
analysis_options.yaml에 custom_lint만 선언, riverpod_generator로 생성된 @riverpod 코드 없음. Provider들이 수동으로 작성되어 있어 자동 생성 규칙과 혼용될 때 린트 오류 가능.

Q-3. dio 의존성이 실제로 쓰이지 않음
pubspec.yaml에 dio: ^5.8.0 있으나, 현재 코드에서 직접 사용하는 곳이 없습니다 (Firestore SDK로만 통신).

Q-4. flutter_svg 의존성이 실제로 쓰이지 않음
pubspec.yaml에 flutter_svg: ^2.0.17 있으나, SVG 렌더링이 아직 구현되지 않았습니다.

Q-5. 하드코딩 색상 값이 여러 파일에 분산
0xFF9A9DA0, 0xFFFAFAFA, Colors.white, 0x14000000 등이 HanjaColors 토큰 없이 여러 위젯에 분산되어 있습니다.

Q-6. WonGoJiGrid.shouldRepaint에 cellSize 누락
cellSize가 바뀌어도 shouldRepaint가 opacity만 비교해 리페인트하지 않을 수 있습니다.

Q-7. UserProgressTable에 사용자 스코프 없음
멀티 유저 / 계정 전환 시 userId 컬럼 없이 hanjaId 만 unique → 나중에 마이그레이션이 어렵습니다.

우선순위 5 — 테스트 보강
현재 테스트 파일 5개 / 커버리지가 낮은 영역:

ContentSyncController 버전 비교·스킵 로직
FirestoreContentSyncService 중간 실패 복구
GoRouter redirect 로직 (로그인/로그아웃 시 경로)
AuthController (signIn 에러 처리)
statistics_screen, review_screen, practice_result_screen 위젯 테스트