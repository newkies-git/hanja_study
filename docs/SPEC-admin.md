# [SPEC-admin] 어드민 백오피스 Web App 기능 명세서

## 1. 개요 (Overview)
- **모듈명**: `admin`
- **구분**: 어드민 백오피스 웹 애플리케이션 & Firestore 규칙 인프라
- **기술 스택**: Vue 3 (`<script setup>`), Vite 6, TypeScript, Tailwind CSS, Firebase Web SDK (v11), Vitest
- **목적**: 한국 교육용 기초 한자 1,817자 및 연관 획순 SVG, 어휘(7,000+), 고사성어(1,000+) 데이터의 조회/등록/수정/배치 업로드 및 Firestore 보안/인증 관리

---

## 2. 모듈 구성 및 경로 (Directory Structure)

```text
admin/
├── webapp/                 # Vue 3 어드민 대시보드 웹 앱
│   ├── src/
│   │   ├── views/dashboard/ # 대시보드 메인, 데이터 동기화, 한자 관리, 획순 등록, 인증 설정 뷰
│   │   ├── components/     # 테이블, 모달, 폼, 사이드바, 헤더 컴포넌트
│   │   ├── composables/    # useDbSync, usePaginatedCollection, useFocusTrap 등
│   │   ├── stores/         # Pinia 상태 관리 (auth, notifications, workbench)
│   │   ├── utils/          # firestoreStrokeMerge, hanjaBasis 변환 유틸
│   │   └── firebase.ts     # Firebase App, Auth, Firestore 초기화
│   └── package.json        # Vite, Vue 3, Tailwind, Vitest 의존성
└── firestore/              # Firestore CLI 규칙 배포 디렉터리
    ├── firebase.json       # Firebase CLI 설정
    ├── .firebaserc         # Firebase 프로젝트 매핑 (chusa-1817)
    └── firestore.rules     # Firestore 보안 규칙 (Admin Claim 기반 쓰기 제어)
```

---

## 3. 상세 기능 명세 (Functional Specifications)

### 3.1 대시보드 메인 지표 모니터링 (`DashboardHomeView.vue`)
- **지표 카드 4종 현황 시각화**:
  1. 🎓 **교육용 기초 한자**: 1,817자 구축 완료율 (2000년 개정 1,800자 + 급수 17자)
  2. ✍️ **획순 SVG 데이터셋**: 1,817자 획별 좌표 정규화 및 SVG Path 수록 현황 (100%)
  3. 📚 **연관 어휘 및 고사성어**: 8,000+개 (단어 7,000+ / 고사성어 1,000+) 구축 현황
  4. 🔒 **보안 & 서비스 상태**: Firebase App Check 강제 적용 및 Security Rules 운영 상태 표출
- **빠른 바로가기**: 한자 마스터 등록, 획순 좌표 등록, DB 동기화 도구 링크 연동

### 3.2 Drag & Drop 배치 파일 업로더 (`DatabaseSyncView.vue`)
- **웹 UI 마우스 드래그 앤 드롭**: `.json` 및 `.csv` 파이프라인 산출물 배치 업로드 지원
- **데이터셋 자동 판별**:
  - `stroke_entities.json` $\rightarrow$ `hanja_stroke` 컬렉션
  - `word_entities.json` $\rightarrow$ `hanja_word` 컬렉션
  - `hanja_entities.json` $\rightarrow$ `hanja_extend` 컬렉션
  - `hanja_basis.csv` $\rightarrow$ `hanja_basis` 컬렉션 (유니코드 `H[0-9A-F]+` 정규화 문서 ID 적용)
- **Firestore Batch Commit**: 400개 단위 배치 분할 커밋 및 업로드 진행률 프로그레스 바 실시간 제공

### 3.3 Firestore 한자 및 연관 어휘 관리 (`FirestoreManageLayout.vue` / `FirestoreHanjaDetailView.vue`)
- **한자 마스터 조회 & 검색**: 부수, 총획, 음/뜻, 급수 기반 실시간 다중 필터링
- **한자 상세 편집 탭**:
  - **기본 정보**: 한자, 대표음, 뜻, 부수, 총획, 교육용 여부
  - **훈음/뜻풀이**: 다중 음/뜻 태그 에디터 (`TagArrayEditor.vue`)
  - **획순 애니메이션**: stroke SVG 미리보기 및 획수 연결 상태 확인
  - **연관 단어/성어 렌더링**: `HanjaDetailWordsContainingTable.vue`를 통한 해당 한자 포함 어휘 목록 조회 및 CRUD
- **로컬 SQLite 데이터 교로 (`LocalHanjaManageLayout.vue`)**: SQLite `chusa.db` 원천 데이터 조망 지원

### 3.4 획순 SVG 좌표 등록기 (`HanjaStrokeRegisterView.vue`)
- **SVG Path 및 획 좌표 편집**: 한자 획별 정규화된 포인트 좌표 (`[{x, y}, ...]`) 직접 편집 및 대치
- **캔버스 실시간 미리보기**: 획순 번호 및 그리기 순서 가이드 비주얼 렌더링

### 3.5 인증 & 권한 관리 (`SettingsAuthView.vue`)
- **Firebase Auth 로그인**: 이메일/비밀번호 기반 어드민 인증
- **Custom Claim (`admin: true`) 상태 검증**: JWT 토큰 내 Admin 클레임 여부 확인 및 토큰 새로고침 기능 제공

### 3.6 Firestore 보안 규칙 (`firestore.rules`)
- **읽기 권한 (`read`)**: 인증된 모든 사용자 (`request.auth != null`) 읽기 허용 (Flutter 클라이언트 포함)
- **쓰기 권한 (`write`)**: JWT 토큰 내 커스텀 클레임이 `request.auth.token.admin == true`인 관리자만 허용

---

## 4. 검증 및 빌드 절차 (Verification & Build)

```bash
# 1. 의존성 설치 및 개발 서버 실행
cd admin/webapp
npm install
npm run dev

# 2. 유닛 테스트 실행 (Vitest)
npm run test -- --run

# 3. 타입 체크 및 프로덕션 빌드
npm run build
```
