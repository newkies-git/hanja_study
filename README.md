# hanja_study (한자정습 — 추사 1817)

한국 교육용 기초 한자 1,800자를 중심으로 한 **한자 학습 모바일 앱(추사 1817)**과 어드민 관리 백오피스 및 데이터 파이프라인 저장소입니다.

---

## 📁 저장소 구조 (Repository Structure)

| 경로 | 설명 |
|------|------|
| [`docs/`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/docs/PRD.md) | **기획·요구사항·명세 통합 문서** (`PRD.md`, `SM-2.md`, `impl_plan/`, `work_through/`) |
| [`flutter/chusa1817/`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/flutter/chusa1817/README.md) | **Flutter 클라이언트 앱** (Riverpod, Drift, GoRouter, Firebase App Check) |
| [`admin/`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/admin/admin-readme.md) | **어드민 포털 및 파이프라인** (`webapp/`: Vue 3 어드민 UI, `admin-etl/`: 데이터 정제, `firestore/`: CLI 보안 규칙) |

---

## 📚 주요 문서 인덱스 (Documentation Index)

- **제품 요구사항 (PRD)**: [`docs/PRD.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/docs/PRD.md) (기능·비기능 명세, 교육용 1,800자 개정 내역 포함)
- **간격 반복 알고리즘**: [`docs/SM-2.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/docs/SM-2.md) (SM-2 알고리즘 스펙)
- **구현 현황 & 로드맵**: [`docs/impl_plan/implementation_plan.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/docs/impl_plan/implementation_plan.md) (프로젝트 현황 점검 및 로드맵)
- **실행 & 검증 기록**: [`docs/work_through/walkthrough.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/docs/work_through/walkthrough.md) (최신 변경 및 테스트 검증)
- **Firestore 연동 & 보안**: [`admin/firestore/firestore_connect.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/admin/firestore/firestore_connect.md) (App Check, API Key, 스키마)

---

## 🚀 빠르게 실행하기 (Quick Start)

### 1. Flutter 모바일 앱 실행
```bash
cd flutter/chusa1817
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter run
```

### 2. 어드민 관리 웹 실행
```bash
cd admin/webapp
npm install
npm run dev
```

### 3. Python 데이터 파이프라인
```bash
cd admin/admin-etl
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python hanja_pipeline.py
```

---

## 📄 라이선스

본 서비스 및 데이터는 **비상업적 교육 목적으로 개발 및 운영**됩니다.
