"""엔티티 ID 생성."""

from __future__ import annotations


def _codepoint_h_id(character: str) -> str:
    """hanja_extend `id` · hanja_stroke `stroke_data_id` 등: H + 대문자 16진 코드포인트."""
    return f"H{ord(character):X}"


def make_hanja_entity_id(character: str) -> str:
    return _codepoint_h_id(character)


def make_stroke_entity_id(character: str) -> str:
    return _codepoint_h_id(character)


def make_word_entity_id(word: str, hanja: str, entry_type: str = "") -> str:
    base = f"{entry_type}|{word}|{hanja}"
    return f"word_{abs(hash(base)) % 10_000_000}"
