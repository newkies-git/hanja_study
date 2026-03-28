"""엔티티 ID 생성."""

from __future__ import annotations


def make_hanja_entity_id(character: str) -> str:
    return f"hanja_{ord(character):05X}"


def make_stroke_entity_id(character: str) -> str:
    return f"stroke_{ord(character):05X}"


def make_word_entity_id(word: str, hanja: str, entry_type: str = "") -> str:
    base = f"{entry_type}|{word}|{hanja}"
    return f"word_{abs(hash(base)) % 10_000_000}"
