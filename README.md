# hanja_study

한국 교육용 기초 한자 1,800자를 중심으로 한 **한자 학습 모바일 앱**(가칭: 한자학습)과 관련 **데이터 파이프라인**을 담는 저장소입니다.

## 저장소 구조

| 경로 | 설명 |
|------|------|
| `docs/` | 기획·요구사항(PR `PRD*.md`), 질의·메모(`Q*.txt`) |
| `python/` | 한자 데이터 수집·가공 스크립트 (`hanja_pipeline.py`) |
| `flutter/fe/` | Flutter 클라이언트(앱) — 프로젝트 생성 후 배치 예정 |
| `flutter/be/` | API·BFF 등 백엔드 연동 코드 |
| `flutter/db/` | 로컬 DB 스키마·마이그레이션 등 |

## 문서

상세 기획은 `docs/PRD.md`부터 참고하면 됩니다.

## Python 파이프라인

교육용 한자 목록 정리, 네이버 한자사전 기반 엔티티 생성 등에 사용합니다.

```bash
cd python
python3 -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
playwright install chromium
python hanja_pipeline.py
```

- 산출물·중간 파일 기본 위치: `python/output/`, `python/grade3_1817.txt`(선택)
- 스크립트는 자기 디렉터리 기준으로 경로를 잡습니다.

## Flutter

`flutter/fe` 등 하위에 앱·패키지를 생성한 뒤 개발하면 됩니다. (예: `cd flutter/fe && flutter create .`)

## 라이선스

미정 — 필요 시 `LICENSE`를 추가하세요.
