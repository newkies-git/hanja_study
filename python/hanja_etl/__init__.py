"""한자 ETL: CSV에서 한자를 읽어 네이버 한자사전을 스크래핑."""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from hanja_etl.pipeline_runner import PipelineRunner

__all__ = ["PipelineRunner"]


def __getattr__(name: str) -> Any:
    if name == "PipelineRunner":
        from hanja_etl.pipeline_runner import PipelineRunner as _PipelineRunner

        return _PipelineRunner
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")
