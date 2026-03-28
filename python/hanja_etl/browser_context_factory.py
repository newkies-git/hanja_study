"""Playwright Chromium 컨텍스트 생성."""

from __future__ import annotations

from typing import Tuple

from playwright.sync_api import Browser, BrowserContext, Error, Playwright


class ChromiumBrowserFactory:
    @staticmethod
    def create_browser_and_context(
        playwright: Playwright,
        headless: bool = True,
    ) -> Tuple[Browser, BrowserContext]:
        try:
            browser = playwright.chromium.launch(headless=headless)
        except Error as exc:
            msg = str(exc)
            if "Executable doesn't exist" in msg or "playwright install" in msg:
                raise RuntimeError(
                    "Playwright Chromium이 이 환경에 설치되어 있지 않습니다.\n"
                    "프로젝트 가상환경을 켠 뒤 아래를 한 번 실행하세요.\n"
                    "  python -m playwright install chromium\n"
                    f"(상세: {msg})"
                ) from exc
            raise
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
