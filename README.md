# hanja_study (한자정습 — 추사 1817)

한국 교육용 기초 한자 1,800자를 중심으로 한 **한자 학습 모바일 앱(추사 1817)**과 어드민 관리 백오피스 및 데이터 파이프라인 저장소입니다.

---

## 📁 저장소 구조 (Repository Structure)

| 경로 | 설명 |
|------|------|
| [`client/`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/client/chusa1817/README.md) | **Flutter 클라이언트 앱** (`chusa1817`: Riverpod, Drift, GoRouter, Firebase App Check) |
| [`admin/`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/admin/admin-readme.md) | **어드민 백오피스 Web App** (`webapp`: Vue 3 어드민 UI, `firestore`: CLI 보안 규칙) |
| [`admin-etl/`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/admin-etl/run_hanja_etl.sh) | **데이터 파이프라인 (ETL)** (Python 한자/획순/어휘 수집·정제 및 Firestore 업로더) |
| [`docs/`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/docs/PRD.md) | **기획·요구사항·명세 통합 문서** (`PRD.md`, `SPEC-client.md`, `SPEC-admin.md`, `SPEC-admin-etl.md`, `implementation_plan.md`, `walkthrough.md`) |

---

## 📚 주요 문서 인덱스 (Documentation Index)

- **제품 요구사항 (PRD)**: [`docs/PRD.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/docs/PRD.md) (기능·비기능 명세, 교육용 1,800자 개정 내역 포함)
- **모바일 클라이언트 기능 명세서**: [`docs/SPEC-client.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/docs/SPEC-client.md) (Flutter 앱 학습/필기채점/SM-2복습/오프라인 싱크)
- **어드민 백오피스 기능 명세서**: [`docs/SPEC-admin.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/docs/SPEC-admin.md) (Vue 3 대시보드/JSON배치업로드/Firestore규칙)
- **ETL 파이프라인 기능 명세서**: [`docs/SPEC-admin-etl.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/docs/SPEC-admin-etl.md) (Python Playwright 크롤링/SVG추출/Admin SDK)
- **구현 현황 & 로드맵**: [`docs/implementation_plan.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/docs/implementation_plan.md) (프로젝트 현황 점검 및 로드맵)
- **실행 & 검증 기록**: [`docs/walkthrough.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/docs/walkthrough.md) (최신 변경 및 테스트 검증)
- **Firestore 연동 & 보안**: [`admin/firestore/firestore_connect.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/admin/firestore/firestore_connect.md) (App Check, API Key, 스키마)

---

## 🚀 빠르게 실행하기 (Quick Start)

### 1. Flutter 모바일 앱 실행 (`client`)
```bash
cd client/chusa1817
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter run
```

### 2. 어드민 관리 웹 실행 (`admin`)
```bash
cd admin/webapp
npm install
npm run dev
```

### 3. Python 데이터 파이프라인 (`admin-etl`)
```bash
cd admin-etl
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python hanja_pipeline.py
```

---

## 📄 라이선스

본 서비스 및 데이터는 **비상업적 교육 목적으로 개발 및 운영**됩니다.
