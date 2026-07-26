# 데이터 파이프라인 & ETL (`admin-etl/`)

HANJA 저장소의 **한자 데이터 수집, 정제, 획순 SVG 좌표 추출, 표준 JSON 변환 및 Firestore 일괄 업로드 파이프라인**을 관리하는 디렉터리입니다.

---

## 📁 디렉터리 구조

| 경로 | 역할 및 구성 |
| :--- | :--- |
| **`hanja_pipeline.py`** | 사전 스크래핑, HTML 파싱, 획순 추출 통합 실행 파이프라인 |
| **`upload_to_firestore.py`** | Firebase Admin SDK를 통한 JSON 산출물 Firestore 일괄 적재 스크립트 |
| **`set_firebase_custom_claims.py`** | Firebase Auth 관리자 커스텀 클레임(`admin: true`) 부여 스크립트 |
| **`run_hanja_etl.sh`** | 분할 수집 및 자동 병합 쉘 스크립트 |
| **`hanja_etl/`** | 스크래퍼, DOM 파서, 획순 geometry 변환기 패키지 |
| **`input/`** | `HANJA_1817.csv`, `hanja_basis.csv` (원천 한자 입력 데이터) |
| **`output/`** | `hanja_entities.json`, `stroke_entities.json`, `word_entities.json` (정제 완료 데이터셋) |
| **`data/`** | `chusa.db`, `chusa.sql` (원천 SQLite DB 및 SQL 덤프) |

---

## 🚀 빠른 실행 및 파이프라인 가이드

### 1. 가상환경 구축 및 의존성 설치
```bash
cd admin-etl
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
playwright install chromium
```

### 2. ETL 수집 및 파이프라인 실행
```bash
python hanja_pipeline.py
```

### 3. Firestore 데이터 일괄 적재 (Admin SDK)
```bash
pip install -r requirements-firebase.txt
export GOOGLE_APPLICATION_CREDENTIALS=/Users/yutaek/zWorkSpace/zBasis/.secrets/hanja/chusa-1817-firebase-adminsdk.json

python upload_to_firestore.py --project-id chusa-1817
```

### 4. Admin Auth 커스텀 클레임 부여
```bash
python set_firebase_custom_claims.py --project-id chusa-1817 --email admin@example.com --admin true
```

---

## 📚 관련 명세 문서
- **ETL 파이프라인 상세 기능 명세서**: [`docs/SPEC-admin-etl.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/docs/SPEC-admin-etl.md)
- **저장소 마스터 안내서**: [`README.md`](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/README.md)
