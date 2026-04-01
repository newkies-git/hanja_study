"""엔티티 ID 생성."""

from __future__ import annotations


def _hanja_id_from_character_codepoint(character: str) -> str:
    """hanja_extend `id` · hanja_stroke `stroke_data_id` 등: H + 대문자 16진 코드포인트."""
    return f"H{ord(character):X}"


def make_hanja_entity_id(character: str) -> str:
    return _hanja_id_from_character_codepoint(character)


def make_stroke_entity_id(character: str) -> str:
    return _hanja_id_from_character_codepoint(character)


def make_word_entity_id(word: str, hanja: str, entry_type: str = "") -> str:
    identity_seed = f"{entry_type}|{word}|{hanja}"
    return f"W{abs(hash(identity_seed)) % 10_000_000}"
