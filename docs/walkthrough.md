# 서브시스템별 기능 명세서 수립 (`docs/`) 워크스루

## 1. 개요
저장소의 3대 핵심 서브시스템인 **`admin` (어드민 대시보드 Web App)**, **`admin-etl` (Python 데이터 파이프라인)**, **`client` (Flutter 모바일 클라이언트)**에 대한 기술 사양 및 상세 모듈별 기능 명세서를 분석 수립하여 [`docs/`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/docs/PRD.md) 최상위에 작성했습니다.

---

## 2. 생성된 서브시스템별 기능 명세서 목록

| 문서 파일 | 서브시스템 | 주요 기술 스택 & 포함 명세 |
| :--- | :--- | :--- |
| **[`docs/SPEC-admin.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/docs/SPEC-admin.md)** | **`admin` (어드민 백오피스)** | Vue 3, Vite 6, TypeScript, Tailwind, 4개 대시보드 지표 카드, JSON/CSV 배치 업로더, Firestore 관리 탭, `firestore.rules` 보안 규칙 |
| **[`docs/SPEC-admin-etl.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/docs/SPEC-admin-etl.md)** | **`admin-etl` (데이터 파이프라인)** | Python 3, Playwright, BeautifulSoup, 1,817자 사전 수집, 획순 SVG 정규화, `upload_to_firestore.py`, Admin Auth Claim 부여 |
| **[`docs/SPEC-client.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/docs/SPEC-client.md)** | **`client` (모바일 클라이언트)** | Flutter 3.x, Riverpod, Drift (SQLite), Firebase Auth/App Check, 1,817자 학습, 획순 필기 채점 캔버스, SM-2 간격 복습, 오프라인 듀얼 DB 동기화 |

---

## 3. 검증 및 인덱스 동기화 결과
- **마스터 문서 인덱스 연동**: [`README.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/README.md)에 새로 작성된 3종의 기능 명세서 하이퍼링크 인덱싱 완료
- **문서 무결성**: 각 명세서에 모듈 디렉터리 구조, 상세 기능 요구사항, 실행 및 빌드/테스트 가이드 포함
