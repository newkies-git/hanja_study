아래 방식이 가장 현실적입니다.

핵심 전제는 두 가지입니다.
첫째, 교육용 기초 한자 1800자는 공개된 목록으로 확인 가능하며, 한국어문회 3급 배정한자는 1,817자이고 교육부 1,800자를 모두 포함합니다. 따라서 17자는 “3급 1,817자 − 교육용 1,800자”의 차집합으로 계산할 수 있습니다.  ￼
둘째, 네이버 한자사전은 교육등급, 부수, 단어/성어, 학습정보, 획순 보기 등을 제공하지만 공개 API가 별도로 확인되지 않아, 실제 구현은 브라우저 자동화 기반 수집이 가장 적절합니다.  ￼

다만 제가 현재 환경에서는 namu.wiki와 hanja.dict.naver.com 본문을 직접 안정적으로 열 수 없었습니다. namu.wiki는 열기 오류가 있었고, hanja.dict.naver.com은 robots 제한이 걸렸습니다. 그래서 아래 코드는 “실서비스 브라우저 환경에서 실행하는 수집기”로 작성했습니다. 실행 전 CSS selector나 텍스트 패턴은 한 번 점검하는 것이 좋습니다.  ￼

아래 코드는 다음을 수행합니다.
	1.	교육용 한자 1800자 목록 추출
	2.	3급 1,817자 목록에서 17자 차집합 계산
	3.	네이버 한자사전에서 한자 상세를 열어
	•	12.1 한자 엔티티
	•	12.2 획순 엔티티
	•	12.3 단어 엔티티
를 JSON으로 생성

구현 의견도 함께 적으면, 획순 엔티티는 가능하면 네이버 페이지 내부의 SVG path 또는 네트워크 응답 JSON에서 뽑는 것이 가장 좋습니다. 이미지 캡처 기반보다는 벡터 path를 그대로 저장하는 편이 필기검증 엔진으로 이어지기 쉽습니다. 네이버 고객센터도 획순 보기와 단어/성어, 교육등급, 부수 등 세부정보 제공을 명시하고 있습니다.  ￼

# -*- coding: utf-8 -*-
"""
hanja_pipeline.py

목적
1) 교육용 한자 1800자 추출
2) 3급 1817자와 비교하여 교육용 1800자에 없는 17자 추출
3) 네이버 한자사전에서
   - 12.1 한자 엔티티
   - 12.2 획순 엔티티
   - 12.3 단어 엔티티
   생성

실행 전 준비
pip install playwright beautifulsoup4 lxml regex svgpathtools pydantic
playwright install chromium

주의
- namu.wiki / 네이버 한자사전 DOM 구조가 바뀌면 selector 보정이 필요할 수 있음
- robots / 약관 / 서비스 정책은 반드시 검토 후 사용
"""

from __future__ import annotations

import json
import re
import time
import urllib.parse
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

from bs4 import BeautifulSoup
from pydantic import BaseModel, Field
from playwright.sync_api import sync_playwright, Page, BrowserContext
from svgpathtools import parse_path


# ============================================================
# 설정
# ============================================================

NAMU_URL = "https://namu.wiki/w/%ED%95%9C%EB%AC%B8%20%EA%B5%90%EC%9C%A1%EC%9A%A9%20%EA%B8%B0%EC%B4%88%20%ED%95%9C%EC%9E%90"
NAVER_URL_TMPL = "https://hanja.dict.naver.com/#/search?query={query}"

OUT_DIR = Path("./output")
OUT_DIR.mkdir(parents=True, exist_ok=True)

# 차집합 계산을 위해 1817자 원본을 파일로 둘 수 있게 함.
# 우선순위:
# 1) namu wiki 본문/주석 [2] 에서 직접 17자 추출 시도
# 2) grade3_1817.txt 존재 시 파일에서 읽어서 1800과 diff 계산
GRADE3_1817_FILE = Path("./grade3_1817.txt")


# ============================================================
# 엔티티 정의 (요청한 12.1 / 12.2 / 12.3 형식 기준)
# ============================================================

class HanjaEntity(BaseModel):
    id: str
    char: str
    reading: str
    meaning: str
    radical: str
    radical_meaning: str = ""
    stroke_count: int
    school_level: str = ""      # middle / high / both / unknown
    grade_level: str = ""       # 예: 준3급
    category: str = "education_1800_or_grade3_extra"
    shape_explanation: str = ""
    origin_note: str = ""
    difficulty: int = 0
    stroke_data_id: str = ""


class StrokeStep(BaseModel):
    order: int
    type: str = ""
    points: List[List[float]] = Field(default_factory=list)
    start_hint: List[float] = Field(default_factory=list)
    end_hint: List[float] = Field(default_factory=list)
    direction: str = ""


class StrokeEntity(BaseModel):
    stroke_data_id: str
    char: str
    total_strokes: int
    strokes: List[StrokeStep] = Field(default_factory=list)
    svg_paths: List[str] = Field(default_factory=list)


class WordEntity(BaseModel):
    word_id: str
    word: str
    hanja: str
    meaning: str
    related_hanja: List[str] = Field(default_factory=list)
    school_recommended: bool = False


# ============================================================
# 공통 유틸
# ============================================================

CJK_RE = re.compile(r"[\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF]")
KOR_RE = re.compile(r"[가-힣]+")


def norm_space(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def unique_keep_order(seq: List[str]) -> List[str]:
    seen = set()
    out = []
    for x in seq:
        if x not in seen:
            seen.add(x)
            out.append(x)
    return out


def safe_text(el) -> str:
    if el is None:
        return ""
    return norm_space(el.get_text(" ", strip=True))


def save_json(path: Path, data: Any) -> None:
    with path.open("w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def char_id(ch: str) -> str:
    return f"hanja_{ord(ch):05X}"


def stroke_id(ch: str) -> str:
    return f"stroke_{ord(ch):05X}"


def word_id(word: str, hanja: str) -> str:
    base = f"{word}_{hanja}"
    return f"word_{abs(hash(base)) % 10_000_000}"


# ============================================================
# 1) 교육용 한자 1800 추출
# ============================================================

def parse_namu_1800_from_text(full_text: str) -> List[str]:
    """
    namu/wiki류 텍스트에서 CJK 한자를 추출.
    문서 전체에는 한자 설명, 주석, 예시가 섞일 수 있으므로
    대량 추출 후 빈도/구간 필터를 거친다.
    """
    chars = CJK_RE.findall(full_text)
    chars = unique_keep_order(chars)

    # 일반적으로 교육용 1800 페이지는 정확히 1800 또는 그 부근이 나와야 한다.
    # 만약 1800보다 훨씬 많다면 후처리가 필요하므로 여기서 단순 반환.
    return chars


def extract_education_1800(page: Page) -> List[str]:
    """
    1차: namu.wiki 페이지에서 추출 시도
    실패 시 예외 발생
    """
    page.goto(NAMU_URL, wait_until="domcontentloaded", timeout=60000)
    page.wait_for_timeout(3000)

    html = page.content()
    soup = BeautifulSoup(html, "lxml")
    text = norm_space(soup.get_text(" ", strip=True))

    chars = parse_namu_1800_from_text(text)

    # 너무 많이 잡히면 본문 영역만 재시도
    if len(chars) > 2200:
        for selector in [
            "article",
            "main",
            ".wiki-content",
            ".w",
            "#app",
            "body",
        ]:
            node = soup.select_one(selector)
            if node:
                text2 = norm_space(node.get_text(" ", strip=True))
                chars2 = parse_namu_1800_from_text(text2)
                if 1700 <= len(chars2) <= 2200:
                    chars = chars2
                    break

    # 1800 근처만 허용
    if len(chars) < 1700:
        raise RuntimeError(f"교육용 한자 추출 실패: 너무 적게 추출됨 ({len(chars)})")

    # 실무적으로는 여기서 수동 검증 후 저장하는 것이 안전
    return chars


# ============================================================
# 2) 1817자와의 차집합으로 17자 계산
# ============================================================

def load_grade3_1817_from_file() -> List[str]:
    """
    grade3_1817.txt 파일 형식 예시:
    開 景 工 久 客 京 ...
    또는 줄바꿈/공백 자유
    """
    if not GRADE3_1817_FILE.exists():
        return []

    txt = GRADE3_1817_FILE.read_text(encoding="utf-8")
    chars = unique_keep_order(CJK_RE.findall(txt))
    return chars


def try_extract_17_extra_from_namu_note(page: Page) -> List[str]:
    """
    namu wiki 본문에 '[2]' 각주나 '17개' 설명이 노출되어 있으면
    그 구간에서 직접 17자를 뽑아낸다.
    DOM이 바뀔 수 있으므로 텍스트 기반으로만 작성.
    """
    html = page.content()
    soup = BeautifulSoup(html, "lxml")
    text = norm_space(soup.get_text(" ", strip=True))

    # "17개" 주변 텍스트 탐색
    patterns = [
        r"17개.*?([一-龥\W\s]{17,200})",
        r"포함되지 않는 17개.*?([一-龥\W\s]{17,300})",
        r"17개\[2\].*?([一-龥\W\s]{17,300})",
    ]

    for pat in patterns:
        m = re.search(pat, text)
        if m:
            block = m.group(1)
            chars = unique_keep_order(CJK_RE.findall(block))
            if len(chars) >= 17:
                return chars[:17]

    return []


def compute_grade3_extra_17(education_1800: List[str], grade3_1817: List[str]) -> List[str]:
    edu_set = set(education_1800)
    diff = [ch for ch in grade3_1817 if ch not in edu_set]
    return diff


# ============================================================
# 3) 네이버 한자사전 상세 파싱
# ============================================================

def open_naver_hanja(page: Page, ch: str) -> None:
    q = urllib.parse.quote(ch)
    url = NAVER_URL_TMPL.format(query=q)
    page.goto(url, wait_until="domcontentloaded", timeout=60000)
    page.wait_for_timeout(2500)


def get_page_text(page: Page) -> str:
    html = page.content()
    soup = BeautifulSoup(html, "lxml")
    return norm_space(soup.get_text(" ", strip=True))


def infer_school_level(text: str) -> str:
    has_middle = "중학" in text or "중학교" in text or "중학용" in text
    has_high = "고등" in text or "고등학교" in text or "고등용" in text

    if has_middle and has_high:
        return "both"
    if has_middle:
        return "middle"
    if has_high:
        return "high"
    return "unknown"


def parse_hanja_entity_from_text(ch: str, text: str) -> HanjaEntity:
    """
    네이버 한자사전 화면 텍스트 기반 파서.
    DOM 변경에 덜 민감하게 regex 중심으로 구성.
    """

    # 예: "아름다울 가"
    reading = ""
    meaning = ""

    # 1) 제일 먼저 한자 다음에 오는 "뜻 + 음" 패턴 시도
    # 예: "佳 아름다울 가"
    m = re.search(rf"{re.escape(ch)}\s+([가-힣]+)\s+([가-힣]+)", text)
    if m:
        meaning = m.group(1)
        reading = m.group(2)

    # 2) fallback: 첫 줄에 "아름답다, 미려하다 ... 2. 좋..." 류가 있을 수 있으므로
    # meaning이 짧은 훈으로 잡히지 않으면 추가 정제
    if not reading:
        m2 = re.search(r"([가-힣]{1,12})\s+([가-힣]{1,6})\s+부수", text)
        if m2:
            meaning = m2.group(1)
            reading = m2.group(2)

    radical = ""
    radical_meaning = ""
    stroke_count = 0
    grade_level = ""

    # 예: "부수 1 (사람인변) | 총 획수 8획"
    mr = re.search(r"부수\s*([一-龥])?\s*\d*\s*\(?([가-힣]+)\)?", text)
    if mr:
        radical = mr.group(1) or ""
        radical_meaning = mr.group(2) or ""

    ms = re.search(r"총\s*획수\s*(\d+)획", text)
    if ms:
        stroke_count = int(ms.group(1))

    mg = re.search(r"(준?특?[\d]+급|준[\d]+급)", text)
    if mg:
        grade_level = mg.group(1)

    school_level = infer_school_level(text)

    # 유래 / 학습정보 단락
    origin_note = ""
    shape_explanation = ""
    if "한자 유래" in text:
        mo = re.search(r"한자 유래\s*(.+?)(단어|성어|숙어|학습정보|$)", text)
        if mo:
            origin_note = norm_space(mo.group(1))
            shape_explanation = origin_note[:200]

    entity = HanjaEntity(
        id=char_id(ch),
        char=ch,
        reading=reading,
        meaning=meaning,
        radical=radical,
        radical_meaning=radical_meaning,
        stroke_count=stroke_count,
        school_level=school_level,
        grade_level=grade_level,
        category="education_1800_or_grade3_extra",
        shape_explanation=shape_explanation,
        origin_note=origin_note,
        difficulty=0,
        stroke_data_id=stroke_id(ch),
    )
    return entity


# ============================================================
# 4) 획순 엔티티 생성
# ============================================================

def sample_svg_path_points(path_d: str, samples: int = 24) -> List[List[float]]:
    """
    SVG path d 문자열을 0~1 범위로 정규화하지 않고 원 좌표 기준으로 샘플링.
    필요하면 후처리에서 bbox 정규화 가능.
    """
    path = parse_path(path_d)
    points: List[List[float]] = []
    for i in range(samples):
        t = i / max(samples - 1, 1)
        pt = path.point(t)
        points.append([round(float(pt.real), 3), round(float(pt.imag), 3)])
    return points


def normalize_points(points: List[List[float]]) -> List[List[float]]:
    if not points:
        return points
    xs = [p[0] for p in points]
    ys = [p[1] for p in points]
    min_x, max_x = min(xs), max(xs)
    min_y, max_y = min(ys), max(ys)
    dx = max(max_x - min_x, 1e-6)
    dy = max(max_y - min_y, 1e-6)

    normed = []
    for x, y in points:
        normed.append([round((x - min_x) / dx, 4), round((y - min_y) / dy, 4)])
    return normed


def direction_of(points: List[List[float]]) -> str:
    if len(points) < 2:
        return ""
    x1, y1 = points[0]
    x2, y2 = points[-1]
    dx = x2 - x1
    dy = y2 - y1
    if abs(dx) > abs(dy):
        return "left_to_right" if dx >= 0 else "right_to_left"
    return "top_to_bottom" if dy >= 0 else "bottom_to_top"


def try_open_stroke_modal(page: Page) -> None:
    # 텍스트 버튼 기준. 사이트 구조에 따라 보정 필요.
    candidates = [
        "text=획순보기",
        "text=획순 보기",
        "text=필순보기",
        "text=획순",
    ]
    for sel in candidates:
        try:
            page.locator(sel).first.click(timeout=2000)
            page.wait_for_timeout(1500)
            return
        except Exception:
            pass


def parse_stroke_entity_from_page(page: Page, ch: str, total_strokes: int) -> StrokeEntity:
    """
    1차: 획순 팝업/영역의 SVG path 추출
    2차: 실패 시 빈 엔티티 반환
    """
    try_open_stroke_modal(page)

    html = page.content()
    soup = BeautifulSoup(html, "lxml")

    svg_paths = []

    # 화면에 렌더링된 svg path 수집
    for path in soup.select("svg path"):
        d = path.get("d", "").strip()
        if d and len(d) > 10:
            svg_paths.append(d)

    # 중복 제거
    svg_paths = unique_keep_order(svg_paths)

    strokes: List[StrokeStep] = []
    for idx, d in enumerate(svg_paths[:total_strokes], start=1):
        pts = sample_svg_path_points(d)
        pts = normalize_points(pts)
        step = StrokeStep(
            order=idx,
            points=pts,
            start_hint=pts[0] if pts else [],
            end_hint=pts[-1] if pts else [],
            direction=direction_of(pts),
            type="",
        )
        strokes.append(step)

    return StrokeEntity(
        stroke_data_id=stroke_id(ch),
        char=ch,
        total_strokes=total_strokes,
        strokes=strokes,
        svg_paths=svg_paths,
    )


# ============================================================
# 5) 단어 엔티티 생성
# ============================================================

def parse_word_entities_from_text(ch: str, text: str) -> List[WordEntity]:
    """
    예시 패턴
    - 가객(佳客): 반갑고 귀한 손님
    - 가경(佳境): 아름다운 경치, 좋은 경치
    """
    out: List[WordEntity] = []

    # 가장 일반적인 패턴
    p1 = re.compile(r"([가-힣]{2,10})\(([一-龥]{2,10})\)\s*[:：]\s*([^•\n\r]+)")
    for m in p1.finditer(text):
        word = norm_space(m.group(1))
        hanja = norm_space(m.group(2))
        meaning = norm_space(m.group(3))

        if ch not in hanja:
            continue

        out.append(
            WordEntity(
                word_id=word_id(word, hanja),
                word=word,
                hanja=hanja,
                meaning=meaning,
                related_hanja=[c for c in hanja if CJK_RE.match(c)],
                school_recommended=False,
            )
        )

    # 중복 제거
    dedup: Dict[Tuple[str, str], WordEntity] = {}
    for item in out:
        dedup[(item.word, item.hanja)] = item

    return list(dedup.values())


# ============================================================
# 6) 한 글자 처리
# ============================================================

def scrape_one_hanja(page: Page, ch: str) -> Tuple[HanjaEntity, StrokeEntity, List[WordEntity]]:
    open_naver_hanja(page, ch)
    text = get_page_text(page)

    hanja_entity = parse_hanja_entity_from_text(ch, text)
    stroke_entity = parse_stroke_entity_from_page(page, ch, hanja_entity.stroke_count)
    word_entities = parse_word_entities_from_text(ch, text)

    return hanja_entity, stroke_entity, word_entities


# ============================================================
# 7) 전체 파이프라인
# ============================================================

def create_browser_context(pw):
    browser = pw.chromium.launch(headless=True)
    context = browser.new_context(
        locale="ko-KR",
        user_agent=(
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/124.0.0.0 Safari/537.36"
        ),
        viewport={"width": 1440, "height": 2200},
    )
    return browser, context


def main():
    with sync_playwright() as pw:
        browser, context = create_browser_context(pw)
        page = context.new_page()

        # ----------------------------------------------------
        # A. 교육용 1800 추출
        # ----------------------------------------------------
        print("[1] 교육용 한자 1800 추출 중...")
        education_1800 = extract_education_1800(page)
        print(f"  - 추출 수: {len(education_1800)}")

        save_json(OUT_DIR / "education_1800.json", education_1800)

        # ----------------------------------------------------
        # B. 17자 추출
        # ----------------------------------------------------
        print("[2] 교육용 1800 외 17자 추출 중...")
        extra_17 = try_extract_17_extra_from_namu_note(page)

        if len(extra_17) != 17:
            print("  - namu note 직접 추출 실패 또는 17자 불일치, 파일 기반 diff 시도")
            grade3_1817 = load_grade3_1817_from_file()
            if not grade3_1817:
                raise RuntimeError(
                    "grade3_1817.txt 파일이 없고 namu note에서도 17자를 안정적으로 추출하지 못했습니다.\n"
                    "grade3_1817.txt에 3급 1817자를 넣고 다시 실행하세요."
                )

            extra_17 = compute_grade3_extra_17(education_1800, grade3_1817)

        print(f"  - 17자: {''.join(extra_17)}")
        save_json(OUT_DIR / "grade3_extra_17.json", extra_17)

        # ----------------------------------------------------
        # C. 네이버 한자사전에서 엔티티 생성
        # ----------------------------------------------------
        print("[3] 네이버 한자사전 엔티티 생성 중...")
        target_chars = extra_17  # 필요시 education_1800 전체로 확장 가능

        hanja_entities: List[Dict[str, Any]] = []
        stroke_entities: List[Dict[str, Any]] = []
        word_entities: List[Dict[str, Any]] = []

        naver_page = context.new_page()

        for idx, ch in enumerate(target_chars, start=1):
            print(f"  - ({idx}/{len(target_chars)}) {ch}")
            try:
                h, s, words = scrape_one_hanja(naver_page, ch)
                hanja_entities.append(h.model_dump())
                stroke_entities.append(s.model_dump())
                word_entities.extend([w.model_dump() for w in words])

                # 요청 부담 완화
                naver_page.wait_for_timeout(1200)

            except Exception as e:
                print(f"    ! 오류: {ch} -> {e}")

        save_json(OUT_DIR / "hanja_entities.json", hanja_entities)
        save_json(OUT_DIR / "stroke_entities.json", stroke_entities)
        save_json(OUT_DIR / "word_entities.json", word_entities)

        browser.close()

        print("\n완료")
        print(f"- {OUT_DIR / 'education_1800.json'}")
        print(f"- {OUT_DIR / 'grade3_extra_17.json'}")
        print(f"- {OUT_DIR / 'hanja_entities.json'}")
        print(f"- {OUT_DIR / 'stroke_entities.json'}")
        print(f"- {OUT_DIR / 'word_entities.json'}")


if __name__ == "__main__":
    main()

추가로, 실제 운영 가능한 수준으로 보완하려면 아래 4가지는 바로 넣는 것이 좋습니다.

첫째, grade3_1817.txt를 별도 원천 데이터로 관리하십시오. 공식 목록이 명확하면 차집합 계산이 가장 안정적입니다. “3급은 1,817자이며 교육부 1,800자를 모두 포함한다”는 점은 공식 급수 안내에서 확인되지만, 17자의 실제 목록은 서비스 화면 구조에 따라 직접 추출보다 별도 마스터 파일 관리가 더 안전합니다.  ￼

둘째, 네이버 한자사전 파서는 텍스트 정규식만으로 끝내지 말고, 개발 단계에서 브라우저 네트워크 로그를 함께 기록하십시오. 공개 API는 확인되지 않았지만, 실제 페이지는 내부 XHR/JSON 또는 SVG 기반 리소스를 사용할 가능성이 높습니다. 그러면 획순 엔티티.points를 현재 예시보다 훨씬 정확하게 만들 수 있습니다.  ￼

셋째, stroke_entities는 최종적으로 svg_paths와 points를 둘 다 저장하는 것이 좋습니다. 앱에서 애니메이션 재생용으로는 SVG path가 유리하고, 필기 채점용으로는 정규화된 point sequence가 유리합니다.

넷째, 단어 엔티티는 한 글자 상세 화면의 “단어·성어” 섹션을 분리 파싱하는 쪽이 좋습니다. 지금 코드는 가객(佳客): ... 같은 일반 패턴 위주라서, 성어 카드나 출전 정보 카드가 섞이면 분리 정제가 필요합니다.

원하시면 다음 단계로 이어서 grade3_1817.txt 없이도 동작하도록, 제가 Playwright + 응답 인터셉트(response listener) 방식으로 획순 JSON까지 직접 잡아내는 버전으로 더 구체화해 드리겠습니다.