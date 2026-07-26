# [SPEC-admin-etl] 데이터 파이프라인 (ETL) 기능 명세서

## 1. 개요 (Overview)
- **모듈명**: `admin-etl`
- **구분**: 데이터 수집·정제 파이프라인 (Extract, Transform, Load) & Firebase Admin SDK CLI 파이프라인
- **기술 스택**: Python 3.10+, Playwright (Chromium), BeautifulSoup4, Firebase Admin SDK (Python), SQLite3, Pandas
- **목적**: 네이버 한자사전 및 원천 데이터로부터 교육용 기초 한자 1,817자의 훈음, 뜻풀이, 획순 SVG 좌표, 연관 단어(7,000+) 및 고사성어(1,000+)를 자동 수집·정제하여 표준 JSON 데이터셋으로 파싱하고 Firestore에 일괄 적재

---

## 2. 모듈 구성 및 경로 (Directory Structure)

```text
admin-etl/
├── hanja_pipeline.py                 # ETL 실행 진입점 파이프라인
├── hanja_etl.py                      # 스크래퍼 및 추출 CLI 래퍼
├── upload_to_firestore.py            # Firebase Admin SDK 데이터 일괄 적재 스크립트
├── set_firebase_custom_claims.py     # Auth 관리자 커스텀 클레임(admin: true) 부여 스크립트
├── run_hanja_etl.sh                  # 병렬 분할 수집 및 자동 병합 쉘 스크립트
├── hanja_etl/                        # ETL 핵심 파이프라인 패키지
│   ├── config.py                     # URL 템플릿, 출력 경로 설정
│   ├── naver_dictionary_browser_client.py # Playwright 크롤링 클라이언트
│   ├── naver_hanja_text_parser.py    # 사전 HTML DOM 파서
│   ├── stroke_entity_extractor.py    # 획순 SVG 및 정규화 좌표 추출기
│   ├── stroke_geometry.py            # 획 좌표 변환 및 스케일링 유틸
│   └── pipeline_runner.py            # 파이프라인 오케스트레이터 및 병합기
├── input/                            # 원천 한자 입력 CSV
│   ├── HANJA_1817.csv                # 기초 한자 1,817자 목록
│   └── hanja_basis.csv               # 1단계 기초 한자 데이터
├── output/                           # 정제 완료된 표준 JSON 데이터셋
│   ├── hanja_entities.json           # 2단계 한자 확장 명세 (1,817자)
│   ├── stroke_entities.json          # 3단계 획순 SVG 명세 (1,817자 100%)
│   └── word_entities.json            # 4단계 단어 및 고사성어 명세 (8,000+개)
└── data/                             # 원천 DB
    ├── chusa.db                      # SQLite 데이터베이스
    └── chusa.sql                     # SQL DDL/DML 덤프
```

---

## 3. 상세 기능 명세 (Functional Specifications)

### 3.1 사전 스크래핑 & HTML 파싱 (`naver_dictionary_browser_client.py` / `naver_hanja_text_parser.py`)
- **Playwright 비동기 크롤러**: 네이버 한자사전 웹페이지 헤드리스 브라우저 자동화 렌더링
- **DOM 데이터 추출**:
  - 한자 유니코드, 대표음, 부수, 총획, 난이도 급수
  - 다중 훈음 및 상제 뜻풀이 항목
  - 해당 한자가 포함된 활용 단어 및 고사성어 표제어/음뜻 추출

### 3.2 획순 SVG 좌표 추출 및 정규화 (`stroke_entity_extractor.py` / `stroke_geometry.py`)
- **SVG Path Parsing**: 한자 사전 획순 애니메이션 SVG 요소로부터 `<path d="..." />` 데이터 추출
- **포인트 정규화 (Normalized Points)**:
  - 캔버스 크기와 관계없이 오차를 최소화하도록 획별 `(x, y)` 시작/중간/끝 좌표를 `[0, 1]` 실수범위 또는 1024x1024 그리드로 정규화
  - Firestore 스키마 지원 구조 (`[{x: float, y: float}, ...]`)로 획 좌표 직렬화

### 3.3 표준 데이터셋 생성 및 병합 (`pipeline_runner.py` / `run_hanja_etl.sh`)
- **분할 수집 및 배치 병합**: Large Scale 작업 시 `--limit` 및 파트 분할 (`.partNNN.json`) 수집 후 단일 `hanja_entities.json`, `stroke_entities.json`, `word_entities.json`으로 병합
- **유니코드 기반 표준 문서 ID 규격화**:
  - 한자 문서 ID: `H` + 16진수 유니코드 대문자 (예: `一` $\rightarrow$ `H4E00`)
  - 획순 문서 ID: `STROKE_H` + 16진수 유니코드 (예: `STROKE_H4E00`)
  - 단어 문서 ID: `WORD_` + 16진수 유니코드 렌더링 식별자

### 3.4 Firestore Admin SDK 적재 (`upload_to_firestore.py`)
- **서비스 계정 키 (`GOOGLE_APPLICATION_CREDENTIALS`) 인증**: 저장소 외부 보안 경로 계정 키를 통해 Security Rules를 우회하고 초당 500건 수준 일괄 업로드
- **적재 대상 컬렉션 매핑**:
  - `hanja_entities.json` $\rightarrow$ `hanja_extend`
  - `stroke_entities.json` $\rightarrow$ `hanja_stroke`
  - `word_entities.json` $\rightarrow$ `hanja_word`

### 3.5 Auth 관리자 커스텀 클레임 부여 (`set_firebase_custom_claims.py`)
- **Firebase Auth Admin Claim**: 지정한 어드민 사용자 이메일에 JWT Custom Claim `{"admin": true}` 부여

---

## 4. 파이프라인 실행 절차 (Execution Guide)

```bash
# 1. 가상환경 구축 및 의존성 설치
cd admin-etl
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
playwright install chromium

# 2. ETL 수집 실행 (1,817자 파이프라인)
python hanja_pipeline.py

# 3. Firestore 데이터 업로드 (Admin SDK)
pip install -r requirements-firebase.txt
export GOOGLE_APPLICATION_CREDENTIALS=/Users/yutaek/zWorkSpace/zBasis/.secrets/hanja/chusa-1817-firebase-adminsdk.json
python upload_to_firestore.py --project-id chusa-1817

# 4. 어드민 사용자 관리자 클레임 부여
python set_firebase_custom_claims.py --project-id chusa-1817 --email admin@example.com --admin true
```
