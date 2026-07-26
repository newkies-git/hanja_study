# 서브시스템별 모듈 README.md 최신화 워크스루

## 1. 개요
저장소 3대 탑레벨 디렉터리인 **`admin` (어드민 백오피스)**, **`admin-etl` (Python 데이터 파이프라인)**, **`client` (Flutter 모바일 앱)** 각각에 독립적인 최신 [`README.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/README.md) 안내 문서를 작성 및 갱신했습니다.

---

## 2. 모듈별 README.md 작성 내역

| 서브시스템 | 파일 경로 | 주요 수록 내용 |
| :--- | :--- | :--- |
| **`admin`** | **[`admin/README.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/admin/README.md)** | 어드민 백오피스 개요, `webapp/` (Vue 3 앱) 및 `firestore/` (Rules 배포) 구조, 빠른 실행 명령, [`docs/SPEC-admin.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/docs/SPEC-admin.md) 연동 |
| **`admin-etl`** | **[`admin-etl/README.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/admin-etl/README.md)** | 데이터 파이프라인 개요, 스크래퍼/업로더 파일 맵, Python 가상환경 설치, 스크래핑 및 Firestore 업로드 CLI 가이드, [`docs/SPEC-admin-etl.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/docs/SPEC-admin-etl.md) 연동 |
| **`client`** | **[`client/README.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/client/README.md)** | Flutter 클라이언트 개요, `chusa1817/` 앱 및 `scripts/` 구성, Flutter test/run 가이드, Firebase App Check 자동 설정 가이드, [`docs/SPEC-client.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/docs/SPEC-client.md) 연동 |

---

## 3. 검증 결과
- **루트 마스터 README 인덱스 갱신**: [`README.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/README.md) 저장소 구조 표의 링크가 `admin/README.md`, `admin-etl/README.md`, `client/README.md`를 각각 정확히 가리키도록 업데이트 완료
