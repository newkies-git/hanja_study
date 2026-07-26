# [계획] Admin 백오피스 기능 보완 및 고도화 구현 계획

본 계획은 Flutter 클라이언트 앱(`flutter/chusa1817`)의 전체 데이터 모델(한자 1,817자, 획순 SVG, 단어 7,000+, 성어 1,000+) 대비 Admin 백오피스(`admin/frontend`)의 부족한 관리 기능을 보완하고 고도화하는 작업을 정의합니다.

---

## 1. 개요 및 보완 목표

- **목적**:
  1. **배치 데이터 파일 업로드 (Batch Uploader)**: 터미널 스크립트 없이 어드민 웹 화면에서 JSON/CSV 파일 Drag & Drop으로 Firestore 컬렉션 일괄 반영 지원.
  2. **대시보드 통계 카드 및 지표 요약**: 기초 한자 1,817자, 획순 SVG, 연관 단어/성어 수량 및 시스템 상태 시각화.
  3. **단어 및 고사성어 탭 데이터 연동 강화**: 상세 화면(`FirestoreHanjaDetailView.vue`, `LocalHanjaDetailView.vue`)에서 관련 단어/고사성어 조회 및 정제 UI 보강.

---

## 2. 주요 변경 파일 및 컴포넌트

### Component 1: Admin Dashboard Home ([DashboardHomeView.vue](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/admin/frontend/src/views/dashboard/DashboardHomeView.vue))
- **[MODIFY]** [DashboardHomeView.vue](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/admin/frontend/src/views/dashboard/DashboardHomeView.vue)
  - 대시보드 메인 화면에 4대 핵심 지표 요약 카드 추가:
    - 🎓 기초 한자 (1,817자)
    - ✍️ 획순 SVG 데이터 완성도
    - 📚 관련 단어 (7,000+개) & 고사성어 (1,000+개)
    - 🔒 Firebase App Check & Auth 상태

### Component 2: Drag & Drop Batch File Uploader ([DatabaseSyncView.vue](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/admin/frontend/src/views/dashboard/DatabaseSyncView.vue))
- **[MODIFY]** [DatabaseSyncView.vue](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/admin/frontend/src/views/dashboard/DatabaseSyncView.vue)
  - Drag & Drop 파일 드롭존 추가 (`.json`, `.csv`)
  - 파일 타입 자동 감지 (`hanja_basis.csv`, `stroke_entities.json`, `word_entities.json`)
  - Firestore 컬렉션 Batch Write 연동 및 실시간 프로그레스 바 제공

### Component 3: Related Words & Idioms Tab UI ([HanjaDetailTabRelated.vue](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/admin/frontend/src/components/dashboard/HanjaDetailTabRelated.vue))
- **[MODIFY]** [HanjaDetailTabRelated.vue](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/admin/frontend/src/components/dashboard/HanjaDetailTabRelated.vue)
  - 단어 및 고사성어 항목 렌더링, 검색, 추가/삭제 UI 기능 보강

---

## 3. 검증 계획

### 1. 자동화 및 단위 테스트 (`npm run test`)
- Admin Frontend Vitest 컴포넌트 및 유틸리티 테스트 수행
- `vue-tsc --noEmit && vite build` 타입 검사 및 프로덕션 빌드 성공 여부 검증

### 2. 수동 검증
- Admin 대시보드 웹 실행 (`npm run dev`) 후 대시보드 지표 카드 및 Batch Drag & Drop Uploader 동작 확인
