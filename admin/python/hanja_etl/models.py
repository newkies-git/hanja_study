"""도메인 엔티티 (Pydantic)."""

from __future__ import annotations

from typing import List

from pydantic import BaseModel, Field


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
    category: str = "from_csv_naver"
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
    entry_type: str = ""  # "단어" | "성어" (네이버 단어·성어 구분)
