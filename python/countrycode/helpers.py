"""Higher-level helpers matching the R package."""

from __future__ import annotations

import csv
import io
import urllib.request
from typing import Any

from .countrycode import (
    _DEFAULT_NOMATCH,
    _is_missing,
    _normalize_input,
    _prepare_codelist,
    _restore_type,
    codelist,
    countrycode,
)
from .datasets import load_countryname_dict

AVAILABLE_DICTIONARIES = (
    "ch_cantons",
    "exiobase3",
    "global_burden_of_disease",
    "gtap6",
    "gtap7",
    "gtap8",
    "gtap9",
    "gtap10",
    "gtap11",
    "us_states",
)


def guess_field(codes: Any, min_similarity: float = 80) -> list[dict[str, Any]]:
    """Rank dictionary fields by the percentage of unique values matched."""
    values, _ = _normalize_input(codes)
    unique = list(dict.fromkeys(value for value in values if not _is_missing(value)))
    if not unique:
        return []
    result = []
    for name, column in codelist.items():
        available = set(value for value in column if not _is_missing(value))
        percent = sum(value in available for value in unique) / len(unique) * 100
        if percent >= min_similarity:
            result.append({"code": name, "percent_of_unique_matched": float(percent)})
    return sorted(
        result, key=lambda item: (-item["percent_of_unique_matched"], item["code"])
    )


def countryname(
    sourcevar: Any,
    destination: str = "country.name.en",
    *,
    nomatch: Any = _DEFAULT_NOMATCH,
    warn: bool = True,
) -> Any:
    """Convert country names in many languages to a name or country code."""
    source, input_type = _normalize_input(sourcevar)
    alternative_names = load_countryname_dict()
    english = countrycode(
        source,
        "country.name.alt",
        "country.name.en",
        custom_dict=alternative_names,
        warn=False,
    )
    unresolved = [
        original if _is_missing(match) else match
        for original, match in zip(source, english)
    ]
    english = countrycode(
        unresolved,
        "country.name.en",
        "country.name.en",
        warn=warn,
        nomatch=nomatch,
    )
    if destination != "country.name.en":
        english = countrycode(
            english,
            "country.name.en",
            destination,
            warn=warn,
            nomatch=nomatch,
        )
    return _restore_type(list(english), sourcevar, input_type)


def get_dictionary(
    dictionary: str | None = None,
) -> dict[str, list[Any]] | tuple[str, ...]:
    """Download one of the maintained custom conversion dictionaries."""
    if dictionary is None:
        return AVAILABLE_DICTIONARIES
    if dictionary not in AVAILABLE_DICTIONARIES:
        raise ValueError(
            "dictionary must be one of: " + ", ".join(AVAILABLE_DICTIONARIES)
        )
    url = (
        "https://raw.githubusercontent.com/vincentarelbundock/countrycode/"
        f"main/custom-dictionaries/data_{dictionary}.csv"
    )
    with urllib.request.urlopen(url) as response:
        text = response.read().decode("utf-8-sig")
    reader = csv.DictReader(io.StringIO(text))
    data = {name: [] for name in (reader.fieldnames or [])}
    for row in reader:
        for name, value in row.items():
            data[name].append(None if value == "" else value)
    return _prepare_codelist(data)
