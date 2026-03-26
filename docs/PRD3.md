좋습니다.
다음 단계로 바로 사용할 수 있도록 아래 4가지를 운영 설계 수준으로 정리하겠습니다.
	1.	데이터 수집/정규화 프로젝트 디렉터리 구조
	2.	Python 코드 골격
	3.	SQLite/PostgreSQL 테이블 설계
	4.	Flutter 앱에서 사용할 API 스펙

이 설계의 기준은 다음과 같습니다.
	•	한자 목록은 이미 확보되었거나 별도 원천 데이터로 관리
	•	이후 파이프라인은 “수집 → 원본보관 → 정규화 → 배포용 데이터 생성” 흐름으로 운영
	•	앱은 읽기 중심 API를 사용하고, 학습 기록은 별도 사용자 데이터 테이블에 저장
	•	획순 데이터는 표시용과 판정용을 함께 유지

아래 문서는 바로 개발 착수용 초안으로 사용할 수 있습니다.

# 한자학습 앱 데이터 파이프라인 및 서비스 설계서

## 1. 프로젝트 디렉터리 구조

```text
hanja-learning-platform/
├─ README.md
├─ .env
├─ pyproject.toml
├─ requirements.txt
├─ apps/
│  ├─ collector/
│  │  ├─ main.py
│  │  ├─ browser_collector.py
│  │  ├─ response_logger.py
│  │  ├─ raw_store.py
│  │  └─ source_router.py
│  ├─ extractor/
│  │  ├─ main.py
│  │  ├─ extractors/
│  │  │  ├─ basic_info_extractor.py
│  │  │  ├─ stroke_extractor.py
│  │  │  ├─ word_extractor.py
│  │  │  ├─ idiom_extractor.py
│  │  │  └─ learning_info_extractor.py
│  │  ├─ normalizers/
│  │  │  ├─ text_normalizer.py
│  │  │  ├─ hanja_normalizer.py
│  │  │  ├─ stroke_normalizer.py
│  │  │  └─ meaning_normalizer.py
│  │  └─ validators/
│  │     ├─ schema_validator.py
│  │     ├─ content_validator.py
│  │     └─ duplicate_validator.py
│  ├─ builder/
│  │  ├─ main.py
│  │  ├─ build_search_index.py
│  │  ├─ build_learning_profiles.py
│  │  ├─ build_reverse_index.py
│  │  └─ export_bundle.py
│  └─ api/
│     ├─ main.py
│     ├─ routers/
│     │  ├─ hanja.py
│     │  ├─ words.py
│     │  ├─ idioms.py
│     │  ├─ lessons.py
│     │  ├─ reviews.py
│     │  └─ progress.py
│     ├─ services/
│     │  ├─ hanja_service.py
│     │  ├─ stroke_service.py
│     │  ├─ word_service.py
│     │  ├─ idiom_service.py
│     │  └─ progress_service.py
│     └─ schemas/
│        ├─ hanja.py
│        ├─ stroke.py
│        ├─ word.py
│        ├─ idiom.py
│        └─ progress.py
├─ data/
│  ├─ source/
│  │  ├─ hanja_master/
│  │  │  ├─ education_1800.json
│  │  │  ├─ grade3_1817.json
│  │  │  └─ extra_17.json
│  │  └─ mappings/
│  │     ├─ school_level_map.json
│  │     ├─ radical_map.json
│  │     └─ grade_level_map.json
│  ├─ raw/
│  │  └─ naver_hanja/
│  │     ├─ 4F73/
│  │     │  ├─ page.html
│  │     │  ├─ responses/
│  │     │  │  ├─ 001.json
│  │     │  │  ├─ 002.json
│  │     │  │  └─ 003.svg
│  │     │  └─ meta.json
│  │     └─ ...
│  ├─ normalized/
│  │  ├─ hanja/
│  │  ├─ strokes/
│  │  ├─ words/
│  │  ├─ idioms/
│  │  └─ learning_info/
│  ├─ bundles/
│  │  ├─ mobile/
│  │  │  ├─ hanja.bundle.json
│  │  │  ├─ stroke.bundle.json
│  │  │  ├─ words.bundle.json
│  │  │  └─ idioms.bundle.json
│  │  └─ search/
│  │     ├─ char_index.json
│  │     ├─ word_index.json
│  │     └─ reverse_index.json
│  └─ logs/
│     ├─ collector.log
│     ├─ extractor.log
│     └─ validator.log
├─ scripts/
│  ├─ run_collect.sh
│  ├─ run_extract.sh
│  ├─ run_build.sh
│  └─ seed_db.sh
├─ migrations/
│  ├─ 001_init.sql
│  ├─ 002_learning_profiles.sql
│  └─ 003_progress_tables.sql
└─ tests/
   ├─ test_extractors.py
   ├─ test_normalizers.py
   ├─ test_validators.py
   └─ test_api.py


⸻

2. 아키텍처 흐름

원천 한자 목록
   ↓
브라우저 수집기(collector)
   ↓
raw payload 저장(html/json/svg)
   ↓
extractor + normalizer
   ↓
정규화 엔티티 생성
   ├─ hanja_entity
   ├─ stroke_entity
   ├─ word_entity
   ├─ idiom_entity
   └─ learning_info_entity
   ↓
validator
   ↓
DB 적재 / bundle export
   ↓
모바일 앱 API / 오프라인 번들


⸻

3. Python 코드 골격

3.1 공통 엔티티 모델

from pydantic import BaseModel, Field
from typing import List, Optional

class HanjaEntity(BaseModel):
    id: str
    char: str
    reading: str
    meaning: str
    radical: str
    radical_meaning: str = ""
    stroke_count: int
    school_level: str = ""
    grade_level: str = ""
    category: str = "education"
    shape_explanation: str = ""
    origin_note: str = ""
    difficulty: int = 0
    stroke_data_id: str = ""

class StrokeStep(BaseModel):
    order: int
    type: str = ""
    svg_path: str = ""
    normalized_points: List[List[float]] = Field(default_factory=list)
    start_hint: List[float] = Field(default_factory=list)
    end_hint: List[float] = Field(default_factory=list)
    direction: str = ""
    bbox: List[float] = Field(default_factory=list)

class StrokeEntity(BaseModel):
    stroke_data_id: str
    char: str
    total_strokes: int
    canonical_width: int = 1000
    canonical_height: int = 1000
    display_scale: float = 0.8
    anchor_box: List[float] = Field(default_factory=list)
    strokes: List[StrokeStep] = Field(default_factory=list)

class WordEntity(BaseModel):
    word_id: str
    word: str
    hanja: str
    meaning: str
    related_hanja: List[str] = Field(default_factory=list)
    school_recommended: bool = False
    content_type: str = "word"

class IdiomEntity(BaseModel):
    idiom_id: str
    phrase: str
    hanja: str
    meaning: str
    source_note: str = ""
    related_hanja: List[str] = Field(default_factory=list)
    school_recommended: bool = False
    content_type: str = "idiom"


⸻

3.2 collector 골격

from pathlib import Path
from playwright.sync_api import sync_playwright

class RawStore:
    def __init__(self, base_dir: Path):
        self.base_dir = base_dir

    def save_response(self, char_code: str, seq: int, url: str, content_type: str, body: bytes):
        char_dir = self.base_dir / char_code / "responses"
        char_dir.mkdir(parents=True, exist_ok=True)

        ext = ".bin"
        if "json" in content_type:
            ext = ".json"
        elif "html" in content_type:
            ext = ".html"
        elif "svg" in content_type:
            ext = ".svg"
        elif "javascript" in content_type:
            ext = ".js"

        path = char_dir / f"{seq:03d}{ext}"
        path.write_bytes(body)

    def save_page_html(self, char_code: str, html: str):
        char_dir = self.base_dir / char_code
        char_dir.mkdir(parents=True, exist_ok=True)
        (char_dir / "page.html").write_text(html, encoding="utf-8")

def collect_one_char(page, raw_store: RawStore, ch: str):
    seq = {"value": 0}
    char_code = f"{ord(ch):04X}"

    def on_response(response):
        try:
            seq["value"] += 1
            body = response.body()
            ctype = response.headers.get("content-type", "")
            raw_store.save_response(char_code, seq["value"], response.url, ctype, body)
        except Exception as e:
            print("response error", e)

    page.on("response", on_response)

    url = f"https://hanja.dict.naver.com/#/search?query={ch}"
    page.goto(url, wait_until="domcontentloaded", timeout=60000)
    page.wait_for_timeout(3000)

    raw_store.save_page_html(char_code, page.content())


⸻

3.3 extractor 골격

from pathlib import Path
from bs4 import BeautifulSoup

class BasicInfoExtractor:
    def extract(self, html: str, ch: str) -> HanjaEntity:
        soup = BeautifulSoup(html, "lxml")
        text = soup.get_text(" ", strip=True)

        reading = ""
        meaning = ""
        radical = ""
        radical_meaning = ""
        stroke_count = 0
        school_level = ""
        grade_level = ""

        # 실제 구현부는 정규식 + payload 분석으로 고도화
        return HanjaEntity(
            id=f"hanja_{ord(ch):04X}",
            char=ch,
            reading=reading,
            meaning=meaning,
            radical=radical,
            radical_meaning=radical_meaning,
            stroke_count=stroke_count,
            school_level=school_level,
            grade_level=grade_level,
            stroke_data_id=f"stroke_{ord(ch):04X}",
        )


⸻

3.4 stroke extractor 골격

import math
from svgpathtools import parse_path

class StrokeExtractor:
    def sample_svg(self, path_d: str, sample_count: int = 32):
        path = parse_path(path_d)
        points = []
        for i in range(sample_count):
            t = i / max(sample_count - 1, 1)
            p = path.point(t)
            points.append([float(p.real), float(p.imag)])
        return points

    def normalize_points(self, points):
        xs = [p[0] for p in points]
        ys = [p[1] for p in points]
        min_x, max_x = min(xs), max(xs)
        min_y, max_y = min(ys), max(ys)

        dx = max(max_x - min_x, 1e-6)
        dy = max(max_y - min_y, 1e-6)

        return [[(x - min_x) / dx, (y - min_y) / dy] for x, y in points]

    def infer_direction(self, points):
        x1, y1 = points[0]
        x2, y2 = points[-1]
        dx = x2 - x1
        dy = y2 - y1
        if abs(dx) >= abs(dy):
            return "left_to_right" if dx >= 0 else "right_to_left"
        return "top_to_bottom" if dy >= 0 else "bottom_to_top"

    def build_stroke_entity(self, ch: str, svg_paths: list[str]) -> StrokeEntity:
        steps = []
        for idx, path_d in enumerate(svg_paths, start=1):
            raw_points = self.sample_svg(path_d)
            normalized = self.normalize_points(raw_points)
            xs = [p[0] for p in normalized]
            ys = [p[1] for p in normalized]
            bbox = [min(xs), min(ys), max(xs), max(ys)]

            steps.append(
                StrokeStep(
                    order=idx,
                    svg_path=path_d,
                    normalized_points=normalized,
                    start_hint=normalized[0],
                    end_hint=normalized[-1],
                    direction=self.infer_direction(normalized),
                    bbox=bbox,
                )
            )

        return StrokeEntity(
            stroke_data_id=f"stroke_{ord(ch):04X}",
            char=ch,
            total_strokes=len(steps),
            anchor_box=[0.1, 0.1, 0.9, 0.9],
            strokes=steps,
        )


⸻

3.5 word / idiom extractor 골격

import re

class WordExtractor:
    WORD_PATTERN = re.compile(r"([가-힣]{2,10})$begin:math:text$\(\[一\-龥\]\{2\,10\}\)$end:math:text$\s*[:：]\s*(.+)")

    def extract(self, lines: list[str], target_char: str) -> list[WordEntity]:
        out = []
        for line in lines:
            m = self.WORD_PATTERN.search(line)
            if not m:
                continue

            word = m.group(1).strip()
            hanja = m.group(2).strip()
            meaning = m.group(3).strip()

            if target_char not in hanja:
                continue

            out.append(
                WordEntity(
                    word_id=f"word_{abs(hash(word + hanja))}",
                    word=word,
                    hanja=hanja,
                    meaning=meaning,
                    related_hanja=[c for c in hanja],
                    school_recommended=False,
                )
            )
        return out

class IdiomExtractor:
    IDIOM_PATTERN = re.compile(r"([가-힣]{2,12})\s+([一-龥]{4,8})\s+(.+)")

    def extract(self, lines: list[str], target_char: str) -> list[IdiomEntity]:
        out = []
        for line in lines:
            m = self.IDIOM_PATTERN.search(line)
            if not m:
                continue

            phrase = m.group(1).strip()
            hanja = m.group(2).strip()
            meaning = m.group(3).strip()

            if target_char not in hanja:
                continue

            out.append(
                IdiomEntity(
                    idiom_id=f"idiom_{abs(hash(phrase + hanja))}",
                    phrase=phrase,
                    hanja=hanja,
                    meaning=meaning,
                    related_hanja=[c for c in hanja],
                )
            )
        return out


⸻

3.6 learning profile builder 골격

class LearningProfileBuilder:
    def build_for_stroke(self, stroke_step: StrokeStep, level: str) -> dict:
        if level == "beginner":
            return {
                "start_radius": 0.10,
                "end_radius": 0.10,
                "direction_tolerance_deg": 45,
                "shape_tolerance": 0.35,
                "order_required": True,
            }
        if level == "intermediate":
            return {
                "start_radius": 0.07,
                "end_radius": 0.07,
                "direction_tolerance_deg": 30,
                "shape_tolerance": 0.25,
                "order_required": True,
            }
        return {
            "start_radius": 0.05,
            "end_radius": 0.05,
            "direction_tolerance_deg": 20,
            "shape_tolerance": 0.18,
            "order_required": True,
        }


⸻

4. DB 테이블 설계

운영 단계에서는 PostgreSQL을 권장합니다.
로컬/프로토타입은 SQLite로 충분하지만, 사용자 진도, 통계, 검색, 컨텐츠 버전 관리를 고려하면 PostgreSQL이 적합합니다.

⸻

4.1 hanja 테이블

CREATE TABLE hanja (
    id VARCHAR(32) PRIMARY KEY,
    char VARCHAR(4) NOT NULL UNIQUE,
    reading VARCHAR(50) NOT NULL,
    meaning VARCHAR(100) NOT NULL,
    radical VARCHAR(10),
    radical_meaning VARCHAR(100),
    stroke_count INT NOT NULL,
    school_level VARCHAR(20),
    grade_level VARCHAR(20),
    category VARCHAR(50) NOT NULL,
    shape_explanation TEXT,
    origin_note TEXT,
    difficulty INT DEFAULT 0,
    stroke_data_id VARCHAR(32) NOT NULL,
    content_version VARCHAR(20) DEFAULT 'v1',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


⸻

4.2 stroke_data / stroke_step 테이블

CREATE TABLE stroke_data (
    stroke_data_id VARCHAR(32) PRIMARY KEY,
    hanja_id VARCHAR(32) NOT NULL REFERENCES hanja(id),
    char VARCHAR(4) NOT NULL,
    total_strokes INT NOT NULL,
    canonical_width INT DEFAULT 1000,
    canonical_height INT DEFAULT 1000,
    display_scale NUMERIC(4,2) DEFAULT 0.80,
    anchor_box JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE stroke_step (
    id BIGSERIAL PRIMARY KEY,
    stroke_data_id VARCHAR(32) NOT NULL REFERENCES stroke_data(stroke_data_id),
    stroke_order INT NOT NULL,
    stroke_type VARCHAR(50),
    svg_path TEXT NOT NULL,
    normalized_points JSONB NOT NULL,
    start_hint JSONB,
    end_hint JSONB,
    direction VARCHAR(30),
    bbox JSONB,
    UNIQUE (stroke_data_id, stroke_order)
);


⸻

4.3 word / idiom 테이블

CREATE TABLE word (
    word_id VARCHAR(32) PRIMARY KEY,
    word VARCHAR(100) NOT NULL,
    hanja VARCHAR(100) NOT NULL,
    meaning TEXT NOT NULL,
    school_recommended BOOLEAN DEFAULT FALSE,
    content_type VARCHAR(20) DEFAULT 'word',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE word_hanja_map (
    id BIGSERIAL PRIMARY KEY,
    word_id VARCHAR(32) NOT NULL REFERENCES word(word_id),
    hanja_id VARCHAR(32) NOT NULL REFERENCES hanja(id),
    UNIQUE (word_id, hanja_id)
);

CREATE TABLE idiom (
    idiom_id VARCHAR(32) PRIMARY KEY,
    phrase VARCHAR(100) NOT NULL,
    hanja VARCHAR(100) NOT NULL,
    meaning TEXT NOT NULL,
    source_note TEXT,
    school_recommended BOOLEAN DEFAULT FALSE,
    content_type VARCHAR(20) DEFAULT 'idiom',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE idiom_hanja_map (
    id BIGSERIAL PRIMARY KEY,
    idiom_id VARCHAR(32) NOT NULL REFERENCES idiom(idiom_id),
    hanja_id VARCHAR(32) NOT NULL REFERENCES hanja(id),
    UNIQUE (idiom_id, hanja_id)
);


⸻

4.4 learning profile 테이블

CREATE TABLE learning_profile (
    id BIGSERIAL PRIMARY KEY,
    stroke_data_id VARCHAR(32) NOT NULL REFERENCES stroke_data(stroke_data_id),
    difficulty_level VARCHAR(20) NOT NULL,
    profile_json JSONB NOT NULL,
    UNIQUE (stroke_data_id, difficulty_level)
);


⸻

4.5 사용자 학습 기록 테이블

CREATE TABLE app_user (
    id UUID PRIMARY KEY,
    provider VARCHAR(20),
    nickname VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_hanja_progress (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES app_user(id),
    hanja_id VARCHAR(32) NOT NULL REFERENCES hanja(id),
    meaning_score INT DEFAULT 0,
    reading_score INT DEFAULT 0,
    stroke_score INT DEFAULT 0,
    mastery_level VARCHAR(20) DEFAULT 'new',
    review_due_at TIMESTAMP,
    last_studied_at TIMESTAMP,
    study_count INT DEFAULT 0,
    wrong_count INT DEFAULT 0,
    UNIQUE (user_id, hanja_id)
);

CREATE TABLE user_stroke_attempt (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES app_user(id),
    hanja_id VARCHAR(32) NOT NULL REFERENCES hanja(id),
    stroke_order INT NOT NULL,
    passed BOOLEAN NOT NULL,
    score INT DEFAULT 0,
    error_code VARCHAR(30),
    error_detail JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_review_log (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES app_user(id),
    hanja_id VARCHAR(32) NOT NULL REFERENCES hanja(id),
    review_type VARCHAR(20) NOT NULL,
    result VARCHAR(20) NOT NULL,
    score INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


⸻

5. API 스펙

기준: REST API
앱에서는 검색, 상세조회, 쓰기학습, 진도저장을 수행한다.

기본 prefix:
/api/v1

⸻

5.1 한자 목록 조회

GET /api/v1/hanja

query
	•	school_level=middle|high|both
	•	grade_level=준3급
	•	radical=人
	•	stroke_count=8
	•	q=가
	•	page=1
	•	size=20

response

{
  "items": [
    {
      "id": "hanja_4F73",
      "char": "佳",
      "reading": "가",
      "meaning": "아름다울",
      "stroke_count": 8,
      "school_level": "middle",
      "grade_level": "준3급",
      "mastery_level": "learning"
    }
  ],
  "page": 1,
  "size": 20,
  "total": 1
}


⸻

5.2 한자 상세 조회

GET /api/v1/hanja/{hanjaId}

response

{
  "id": "hanja_4F73",
  "char": "佳",
  "reading": "가",
  "meaning": "아름다울",
  "radical": "人",
  "radical_meaning": "사람인변",
  "stroke_count": 8,
  "school_level": "middle",
  "grade_level": "준3급",
  "shape_explanation": "자형 설명",
  "origin_note": "유래 설명",
  "stroke_data_id": "stroke_4F73",
  "progress": {
    "mastery_level": "learning",
    "meaning_score": 80,
    "stroke_score": 65
  }
}


⸻

5.3 획순 상세 조회

GET /api/v1/hanja/{hanjaId}/strokes

response

{
  "stroke_data_id": "stroke_4F73",
  "char": "佳",
  "total_strokes": 8,
  "display_scale": 0.8,
  "anchor_box": [0.1, 0.1, 0.9, 0.9],
  "strokes": [
    {
      "order": 1,
      "type": "left_falling",
      "svg_path": "M10,20...",
      "normalized_points": [[0.12, 0.18], [0.15, 0.26], [0.18, 0.31]],
      "start_hint": [0.12, 0.18],
      "end_hint": [0.24, 0.82],
      "direction": "top_to_bottom",
      "bbox": [0.12, 0.18, 0.24, 0.82]
    }
  ]
}


⸻

5.4 단어 목록 조회

GET /api/v1/hanja/{hanjaId}/words

response

{
  "items": [
    {
      "word_id": "word_1001",
      "word": "가경",
      "hanja": "佳境",
      "meaning": "흥미와 분위기가 고조되어 가장 좋은 단계",
      "related_hanja": ["佳", "境"]
    }
  ]
}


⸻

5.5 성어/숙어 목록 조회

GET /api/v1/hanja/{hanjaId}/idioms

response

{
  "items": [
    {
      "idiom_id": "idiom_2001",
      "phrase": "점입가경",
      "hanja": "漸入佳境",
      "meaning": "들어갈수록 점점 재미가 있음",
      "source_note": "사기, 진서",
      "related_hanja": ["漸", "入", "佳", "境"]
    }
  ]
}


⸻

5.6 학습 제출 - 쓰기 결과 저장

POST /api/v1/learning/stroke-attempts

request

{
  "user_id": "uuid",
  "hanja_id": "hanja_4F73",
  "stroke_order": 1,
  "input_points": [[0.11, 0.19], [0.14, 0.26], [0.18, 0.39]],
  "pointer_type": "pen",
  "device_scale": {
    "width": 1080,
    "height": 1920
  }
}

response

{
  "passed": true,
  "score": 87,
  "feedback": {
    "error_code": null,
    "message": "정확합니다."
  },
  "expected": {
    "start_hint": [0.12, 0.18],
    "end_hint": [0.24, 0.82],
    "direction": "top_to_bottom"
  }
}


⸻

5.7 한 글자 완료 처리

POST /api/v1/learning/complete

request

{
  "user_id": "uuid",
  "hanja_id": "hanja_4F73",
  "meaning_score": 90,
  "reading_score": 100,
  "stroke_score": 78,
  "passed": true
}

response

{
  "mastery_level": "learning",
  "review_due_at": "2026-03-29T10:00:00Z",
  "next_recommended": "hanja_5883"
}


⸻

5.8 복습 목록 조회

GET /api/v1/reviews/today?user_id={uuid}

response

{
  "items": [
    {
      "hanja_id": "hanja_4F73",
      "char": "佳",
      "reading": "가",
      "meaning": "아름다울",
      "review_type": "stroke_retry",
      "priority": 10
    }
  ]
}


⸻

6. Flutter 연동 설계

6.1 추천 앱 구조

lib/
├─ app/
│  ├─ router/
│  ├─ theme/
│  └─ di/
├─ features/
│  ├─ hanja/
│  │  ├─ data/
│  │  │  ├─ datasources/
│  │  │  ├─ models/
│  │  │  └─ repositories/
│  │  ├─ domain/
│  │  │  ├─ entities/
│  │  │  ├─ repositories/
│  │  │  └─ usecases/
│  │  └─ presentation/
│  │     ├─ pages/
│  │     ├─ widgets/
│  │     └─ controllers/
│  ├─ writing/
│  ├─ review/
│  ├─ progress/
│  └─ settings/
└─ shared/
   ├─ network/
   ├─ storage/
   ├─ canvas/
   └─ utils/


⸻

6.2 Flutter에서 쓰기판 처리 포인트
	•	CustomPainter로 정사각형 격자 렌더링
	•	하단 정사각형은 가용 영역 기준 최대 정사각형 계산
	•	1/2 파선, 1/10 및 1/20 점선 표시
	•	정답 글자는 80% scale로 중앙 렌더링
	•	현재 획만 강조
	•	사용자의 입력 좌표는 즉시 정규화
	•	로컬 1차 판정 후 서버 2차 판정 가능

⸻

6.3 추천 로컬 저장소
	•	isar 또는 hive: 오프라인 캐시
	•	sqflite: 진도/복습 로그
	•	앱 최초 설치 시 hanja.bundle.json, stroke.bundle.json 로드 가능

⸻

7. 운영 배치 설계

배치 1. 원본 수집
	•	신규/변경 대상 한자만 수집
	•	raw payload 저장

배치 2. 정규화
	•	extractor 실행
	•	validator 실행
	•	오류 목록 출력

배치 3. 번들 생성
	•	앱 배포용 JSON 생성
	•	검색 인덱스 생성
	•	reverse index 생성

배치 4. DB 반영
	•	upsert
	•	content_version 증가
	•	변경 이력 저장

⸻

8. 권장 개발 순서

Phase 1
	•	DB 스키마 생성
	•	원천 한자 목록 적재
	•	collector 기본 구현
	•	raw payload 저장 확인

Phase 2
	•	basic info extractor
	•	stroke extractor
	•	word / idiom extractor
	•	validator

Phase 3
	•	API 서버 구현
	•	Flutter 상세 조회/목록 조회 연동
	•	쓰기판 렌더링

Phase 4
	•	stroke learning profile
	•	필기 판정 로직
	•	복습 알고리즘

Phase 5
	•	오프라인 번들
	•	성능 최적화
	•	관리자 배치 자동화

추가로, 바로 착수 가능한 수준의 핵심 파일 초안을 함께 제안합니다.

아래는 `FastAPI` 기준 최소 서버 진입점입니다.

```python
from fastapi import FastAPI
from apps.api.routers import hanja, words, idioms, reviews, progress

app = FastAPI(title="Hanja Learning API", version="1.0.0")

app.include_router(hanja.router, prefix="/api/v1/hanja", tags=["hanja"])
app.include_router(words.router, prefix="/api/v1/words", tags=["words"])
app.include_router(idioms.router, prefix="/api/v1/idioms", tags=["idioms"])
app.include_router(reviews.router, prefix="/api/v1/reviews", tags=["reviews"])
app.include_router(progress.router, prefix="/api/v1/progress", tags=["progress"])

hanja router 예시는 다음과 같이 시작할 수 있습니다.

from fastapi import APIRouter, Query

router = APIRouter()

@router.get("")
def get_hanja_list(
    q: str | None = Query(default=None),
    school_level: str | None = Query(default=None),
    radical: str | None = Query(default=None),
    page: int = 1,
    size: int = 20,
):
    return {
        "items": [],
        "page": page,
        "size": size,
        "total": 0,
    }

@router.get("/{hanja_id}")
def get_hanja_detail(hanja_id: str):
    return {
        "id": hanja_id
    }

@router.get("/{hanja_id}/strokes")
def get_hanja_strokes(hanja_id: str):
    return {
        "stroke_data_id": f"stroke_{hanja_id}"
    }

실무 관점에서 가장 중요한 판단도 함께 적겠습니다.

첫째, 앱용 데이터와 운영용 데이터는 분리하는 것이 좋습니다. 운영 DB에는 raw와 normalized를 모두 두고, 앱에는 가볍게 정리된 bundle 또는 API 응답만 제공해야 합니다.

둘째, 획순 데이터는 반드시 별도 버전 관리가 필요합니다. 필기 판정 로직을 조정하면 동일 한자라도 learning profile이 바뀔 수 있기 때문입니다. 따라서 content_version과 별도로 stroke_profile_version을 두는 것이 바람직합니다.

셋째, 초기에는 서버 판정보다 로컬 1차 판정 + 서버 저장 구조가 현실적입니다. 펜 입력은 응답속도가 중요하므로 모든 stroke를 실시간 서버 판정으로 보내면 UX가 나빠질 수 있습니다. 추천 구조는 이렇습니다.
	•	앱 로컬: 시작점, 방향, 순서, 대략 형상 1차 판정
	•	서버: 최종 점수화, 학습 통계 반영, 모델 개선용 로그 저장

넷째, 단어/성어는 한자별 조회뿐 아니라 역검색도 필요합니다. 예를 들어 사용자가 “점입가경”을 검색했을 때 佳로 연결되어야 하므로, API에는 hanja -> words/idioms만 아니라 word/phrase -> related hanja 검색도 추가하는 것이 좋습니다.

다음으로 진행할 실무 순서는 아래가 적절합니다.
	1.	PostgreSQL DDL 확정
	2.	Python 프로젝트 초기화
	3.	collector와 raw_store 먼저 구현
	4.	1개 한자(예: 佳) 기준으로 extractor 테스트
	5.	stroke_entity 표준 포맷 확정
	6.	FastAPI로 상세 조회 API 3개 먼저 개통
	7.	Flutter에서 한자 상세 + 획순 렌더링 화면 연결

원하시면 다음 답변에서 바로 이어서
migrations/001_init.sql, FastAPI 실제 구현 코드, Flutter 모델 클래스, 쓰기판 CustomPainter 구조까지 코드 형태로 작성하겠습니다.