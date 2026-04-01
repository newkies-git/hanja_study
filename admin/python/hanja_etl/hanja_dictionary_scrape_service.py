"""한 글자에 대해 네이버 사전 페이지를 한 번 열고 엔티티 세트를 수집."""

from __future__ import annotations

from typing import List, Tuple

from playwright.sync_api import Page

from hanja_etl.models import HanjaEntity, StrokeEntity, WordEntity
from hanja_etl.naver_dictionary_browser_client import NaverHanjaDictionaryBrowserClient
from hanja_etl.naver_hanja_text_parser import NaverHanjaTextParser
from hanja_etl.stroke_entity_extractor import StrokeEntityExtractor


class HanjaDictionaryScrapeService:
    def __init__(
        self,
        text_parser: NaverHanjaTextParser | None = None,
        stroke_extractor: StrokeEntityExtractor | None = None,
    ) -> None:
        self._text_parser = text_parser or NaverHanjaTextParser()
        self._stroke_extractor = stroke_extractor or StrokeEntityExtractor()

    def scrape_one_character(
        self, page: Page, character: str
    ) -> Tuple[HanjaEntity, StrokeEntity, List[WordEntity]]:
        dictionary_client = NaverHanjaDictionaryBrowserClient(page)
        dictionary_client.open_search_for_character(character)
        page_text = dictionary_client.get_inner_text_for_parsing()
        hanja_entity = self._text_parser.build_hanja_entity(character, page_text)
        stroke_entity = self._stroke_extractor.extract_from_page(
            page,
            character,
            hanja_entity.stroke_count,
            browser_client=dictionary_client,
        )
        word_entities = self._text_parser.build_word_entities(character, page_text)
        return hanja_entity, stroke_entity, word_entities
