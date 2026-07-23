"""Load the supplementary datasets distributed with countrycode."""

from __future__ import annotations

from pathlib import Path
from typing import Literal

from .countrycode import _read_csv, pd, pl

_DATA_DIR = Path(__file__).resolve().parent / "data"
_DATASETS = {
    "codelist_panel": _DATA_DIR / "codelist_panel.csv.gz",
    "countryname_dict": _DATA_DIR / "countryname_dict.csv.gz",
    "cldr_examples": _DATA_DIR / "cldr_examples.csv.gz",
}


def load_dataset(name: str, as_type: Literal["dict", "pandas", "polars"] = "dict"):
    """Load a packaged supplementary dataset."""
    if name not in _DATASETS:
        raise ValueError(f"name must be one of: {', '.join(sorted(_DATASETS))}")
    data = _read_csv(_DATASETS[name])
    if as_type == "dict":
        return data
    if as_type == "pandas":
        if pd is None:
            raise ImportError("Pandas is not installed.")
        return pd.DataFrame(data)
    if as_type == "polars":
        if pl is None:
            raise ImportError("Polars is not installed.")
        return pl.DataFrame(data)
    raise ValueError("as_type must be 'dict', 'pandas', or 'polars'.")


def load_codelist_panel(as_type="dict"):
    return load_dataset("codelist_panel", as_type)


def load_countryname_dict(as_type="dict"):
    return load_dataset("countryname_dict", as_type)


def load_cldr_examples(as_type="dict"):
    return load_dataset("cldr_examples", as_type)
