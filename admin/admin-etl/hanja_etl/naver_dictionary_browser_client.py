"""Playwright Page로 네이버 한자사전 검색 URL을 연다."""

from __future__ import annotations

import re
import urllib.parse

from bs4 import BeautifulSoup
from playwright.sync_api import Page

from hanja_etl.config import NAVER_HANJA_SEARCH_URL_TEMPLATE
from hanja_etl.text_utils import normalize_whitespace

_STROKE_PATH_ID_ORDER_RE = re.compile(r"d(\d+)\s*$")

# 획순 애니메이션 SVG는 메인 문서가 아니라 이 iframe에 로드됨
_STROKE_IFRAME_SELECTOR = "iframe.svgAni[src*='dicimg']"


class NaverHanjaDictionaryBrowserClient:
    """https://hanja.dict.naver.com/#/search?query={} 탐색."""

    def __init__(self, page: Page, post_navigation_delay_ms: int = 2500) -> None:
        self._page = page
        self._post_navigation_delay_ms = post_navigation_delay_ms

    def open_search_for_character(self, character: str) -> None:
        encoded = urllib.parse.quote(character)
        url = NAVER_HANJA_SEARCH_URL_TEMPLATE.format(query=encoded)
        self._page.goto(url, wait_until="domcontentloaded", timeout=60000)
        self._page.wait_for_timeout(self._post_navigation_delay_ms)

    def get_normalized_visible_text(self) -> str:
        html = self._page.content()
        soup = BeautifulSoup(html, "lxml")
        return normalize_whitespace(soup.get_text(" ", strip=True))

    def get_inner_text_for_parsing(self) -> str:
        """
        본문 줄바꿈을 유지한 텍스트. 단어·성어·부수 줄 단위 파싱에 사용.
        (공백만 합친 get_normalized_visible_text 는 구조가 무너짐)
        """
        raw_body_text = self._page.inner_text("body", timeout=30000)
        lines = [line.strip() for line in raw_body_text.splitlines()]
        normalized_lines: list[str] = []
        prev_empty = False
        for line in lines:
            empty = not line
            if empty and prev_empty:
                continue
            normalized_lines.append(line)
            prev_empty = empty
        return "\n".join(normalized_lines)

    def open_stroke_order_modal(self) -> bool:
        """
        '획순보기' 버튼을 눌러 레이어를 연다.
        SVG는 iframe.svgAni( ssl.pstatic.net dicimg aniSVG )에 로드된다.
        """
        try:
            stroke_order_button = self._page.get_by_role("button", name="획순보기").first
            stroke_order_button.wait_for(state="visible", timeout=10000)
            stroke_order_button.click(timeout=8000)
        except Exception:
            for selector in (
                "text=획순보기",
                "role=button >> text=획순보기",
            ):
                try:
                    self._page.locator(selector).first.click(timeout=5000)
                    break
                except Exception:
                    continue
            else:
                return False

        try:
            self._page.locator(_STROKE_IFRAME_SELECTOR).first.wait_for(
                state="visible", timeout=15000
            )
        except Exception:
            return False
        self._page.wait_for_timeout(800)
        return True

    def close_stroke_order_modal(self) -> None:
        """획순 레이어 닫기 (다음 글자 처리 시 중복 iframe 방지)."""
        try:
            close_btn = self._page.locator(
                "div.ly_hanja_stroke button.btn_close, "
                "div._ly_hanja_stroke button.btn_close"
            ).first
            if close_btn.is_visible(timeout=1500):
                close_btn.click(timeout=3000)
                self._page.wait_for_timeout(400)
        except Exception:
            pass

    def get_ordered_stroke_svg_path_commands(self) -> list[str]:
        """
        획순 iframe 내부에서 stroke-normal / stroke-radical path의 d를
        id 접미 숫자(d1, d2, …) 순으로 정렬해 반환한다.
        """
        stroke_iframe_locator = self._page.frame_locator(_STROKE_IFRAME_SELECTOR).first
        stroke_iframe_locator.locator("path[d]").first.wait_for(
            state="attached", timeout=15000
        )

        path_element_count = stroke_iframe_locator.locator("path[d]").count()
        ordered: list[tuple[int, str]] = []
        for path_index in range(path_element_count):
            path = stroke_iframe_locator.locator("path[d]").nth(path_index)
            class_attr = path.get_attribute("class") or ""
            if "stroke-normal" not in class_attr and "stroke-radical" not in class_attr:
                continue
            path_id = path.get_attribute("id") or ""
            match = _STROKE_PATH_ID_ORDER_RE.search(path_id)
            if not match:
                continue
            d_attr = (path.get_attribute("d") or "").strip()
            if len(d_attr) < 20:
                continue
            ordered.append((int(match.group(1)), d_attr))

        ordered.sort(key=lambda order_and_d: order_and_d[0])
        return [path_d for _, path_d in ordered]
