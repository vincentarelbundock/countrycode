"""Country-code conversion functions."""

from __future__ import annotations

import csv
import math
import os
import re
import warnings
from collections.abc import Mapping, Sequence
from pathlib import Path
from typing import Any

try:
    import polars as pl
except ImportError:
    pl = None
try:
    import pandas as pd
except ImportError:
    pd = None


pkg_dir = Path(__file__).resolve().parent

_DEFAULT_NOMATCH = object()
_REGEX_ORIGINS = {
    "country.name.de.regex",
    "country.name.en.regex",
    "country.name.es.regex",
    "country.name.fr.regex",
    "country.name.it.regex",
}
_NAME_ALIASES = {
    "country.name.de",
    "country.name.en",
    "country.name.es",
    "country.name.fr",
    "country.name.it",
}
_VALID_DEFAULT_ORIGINS = {
    "cctld",
    "country.name",
    "country.name.de",
    "country.name.fr",
    "country.name.it",
    "country.name.es",
    "cowc",
    "cown",
    "dhs",
    "ecb",
    "eurostat",
    "fao",
    "fips",
    "gaul",
    "genc2c",
    "genc3c",
    "genc3n",
    "gwc",
    "gwn",
    "imf",
    "ioc",
    "iso2c",
    "iso3c",
    "iso3n",
    "p5c",
    "p5n",
    "p4c",
    "p4n",
    "un",
    "un_m49",
    "unicode.symbol",
    "unhcr",
    "unpd",
    "vdem",
    "wb",
    "wb_api2c",
    "wb_api3c",
    "wvs",
    *_REGEX_ORIGINS,
}


def _is_missing(value: Any) -> bool:
    if value is None:
        return True
    try:
        return isinstance(value, float) and math.isnan(value)
    except TypeError:
        return False


def _read_csv(path: Path) -> dict[str, list[Any]]:
    opener = __import__("gzip").open if path.suffix == ".gz" else open
    with opener(path, "rt", encoding="utf-8", newline="") as stream:
        reader = csv.DictReader(stream)
        result = {name: [] for name in (reader.fieldnames or [])}
        for row in reader:
            for name, value in row.items():
                result[name].append(None if value == "" else value)
    for name, values in result.items():
        present = [value for value in values if value is not None]
        if present and all(
            re.fullmatch(r"-?(0|[1-9]\d*)", value) is not None for value in present
        ):
            result[name] = [None if value is None else int(value) for value in values]
    return result


def _prepare_codelist(
    custom_dict: Any = None,
    origin: str | None = None,
    destinations: Sequence[str] | None = None,
) -> dict[str, list[Any]]:
    """Load and validate a conversion dictionary."""
    source = "built-in codelist"
    if custom_dict is None:
        result = _read_csv(pkg_dir / "data" / "codelist.csv.gz")
    elif isinstance(custom_dict, (str, os.PathLike)):
        path = Path(custom_dict)
        source = f"file '{path}'"
        if not path.exists():
            raise FileNotFoundError(f"Could not find {source}.")
        if path.suffix == ".csv" or path.name.endswith(".csv.gz"):
            result = _read_csv(path)
        else:
            raise NotImplementedError(
                f"Custom dictionaries with '{path.suffix}' are not supported; "
                "use .csv or .csv.gz."
            )
    elif isinstance(custom_dict, Mapping):
        source = "provided mapping"
        result = dict(custom_dict)
    elif pl is not None and isinstance(custom_dict, pl.DataFrame):
        source = "provided Polars DataFrame"
        result = custom_dict.to_dict(as_series=False)
    elif pd is not None and isinstance(custom_dict, pd.DataFrame):
        source = "provided Pandas DataFrame"
        result = custom_dict.to_dict(orient="list")
    else:
        raise NotImplementedError(
            "custom_dict must be one of: None, a mapping, a Pandas or Polars "
            "DataFrame, or a path to a .csv or .csv.gz file."
        )

    if not isinstance(result, Mapping):
        raise ValueError(f"{source} must contain a mapping of columns.")
    if not result:
        raise ValueError(f"{source} cannot be empty.")

    normalized: dict[str, list[Any]] = {}
    for name, values in result.items():
        if not isinstance(values, (list, tuple)):
            raise ValueError(
                f"Column '{name}' in {source} must be a list or tuple, "
                f"got {type(values).__name__}."
            )
        normalized[str(name)] = list(values)

    lengths = {name: len(values) for name, values in normalized.items()}
    if len(set(lengths.values())) != 1:
        raise ValueError(
            f"All columns in {source} must have the same length: {lengths}"
        )

    if origin and origin not in normalized:
        raise ValueError(
            f"{source} must contain the origin column '{origin}'. "
            f"Available columns: {', '.join(normalized)}"
        )
    missing_destinations = [
        name for name in (destinations or []) if name not in normalized
    ]
    if missing_destinations:
        raise ValueError(
            f"{source} must contain the destination column(s) "
            f"{', '.join(missing_destinations)}. "
            f"Available columns: {', '.join(normalized)}"
        )
    return normalized


def _normalize_input(sourcevar: Any) -> tuple[list[Any], str]:
    if pl is not None and isinstance(sourcevar, pl.Series):
        return sourcevar.to_list(), "polars"
    if pd is not None and isinstance(sourcevar, pd.Series):
        return sourcevar.tolist(), "pandas"
    if isinstance(sourcevar, (str, int, float)) or sourcevar is None:
        return [sourcevar], "scalar"
    if isinstance(sourcevar, Sequence):
        return list(sourcevar), "tuple" if isinstance(sourcevar, tuple) else "list"
    try:
        return list(sourcevar), "list"
    except TypeError as error:
        raise TypeError("sourcevar must be a scalar or iterable of codes.") from error


def _restore_type(values: list[Any], original: Any, input_type: str) -> Any:
    if input_type == "scalar":
        return values[0]
    if input_type == "tuple":
        return tuple(values)
    if input_type == "polars":
        return pl.Series(original.name, values)
    if input_type == "pandas":
        return pd.Series(values, index=original.index, name=original.name)
    return values


def _coerce_numeric(value: Any) -> Any:
    if isinstance(value, str) and value.isdigit():
        return int(value)
    return value


def _warn_unmatched(values: list[Any]) -> None:
    unmatched = list(dict.fromkeys(repr(value) for value in values))
    if unmatched:
        warnings.warn(
            f"Some values were not matched: {', '.join(unmatched)}",
            UserWarning,
            stacklevel=3,
        )


def _exact_convert(
    source: list[Any],
    origin: str,
    destination: str,
    dictionary: dict[str, list[Any]],
    *,
    ignore_case: bool,
) -> tuple[list[Any], dict[int, list[Any]]]:
    lookup: dict[Any, list[Any]] = {}
    for key, value in zip(dictionary[origin], dictionary[destination]):
        if _is_missing(key) or _is_missing(value):
            continue
        normalized = key.casefold() if ignore_case and isinstance(key, str) else key
        lookup.setdefault(normalized, []).append(value)

    output = []
    ambiguous = {}
    for index, value in enumerate(source):
        normalized = (
            value.casefold() if ignore_case and isinstance(value, str) else value
        )
        matches = lookup.get(normalized, [])
        if len(matches) == 1:
            output.append(_coerce_numeric(matches[0]))
        else:
            output.append(None)
            if len(matches) > 1:
                ambiguous[index] = matches
    return output, ambiguous


def _regex_convert(
    source: list[Any],
    origin: str,
    destination: str,
    dictionary: dict[str, list[Any]],
) -> tuple[list[Any], dict[int, list[Any]]]:
    patterns = []
    for pattern, value in zip(dictionary[origin], dictionary[destination]):
        if _is_missing(pattern) or _is_missing(value):
            continue
        patterns.append((re.compile(str(pattern), re.IGNORECASE), value))

    output = []
    ambiguous = {}
    for index, value in enumerate(source):
        if _is_missing(value):
            output.append(None)
            continue
        matches = [
            destination_value
            for pattern, destination_value in patterns
            if pattern.search(str(value).strip())
        ]
        if len(matches) == 1:
            output.append(_coerce_numeric(matches[0]))
        else:
            output.append(None)
            if len(matches) > 1:
                ambiguous[index] = matches
    return output, ambiguous


def countrycode(
    sourcevar: Any,
    origin: str,
    destination: str | Sequence[str],
    custom_dict: Any = None,
    *,
    warn: bool = True,
    nomatch: Any = _DEFAULT_NOMATCH,
    custom_match: Mapping[Any, Any] | None = None,
    origin_regex: bool | None = None,
) -> Any:
    """Convert country codes or names from one format to another.

    Multiple destinations are tried from left to right and fill values which
    were not covered by an earlier destination. By default, unmatched inputs
    become ``None``. Pass ``nomatch=None`` to preserve the original input, or
    pass a scalar/sequence to use explicit replacement values.
    """
    if not isinstance(origin, str):
        raise TypeError("origin must be a string.")
    destinations = [destination] if isinstance(destination, str) else list(destination)
    if not destinations or not all(isinstance(value, str) for value in destinations):
        raise TypeError(
            "destination must be a string or non-empty sequence of strings."
        )

    using_default = custom_dict is None
    if using_default:
        if origin == "country.name":
            origin = "country.name.en.regex"
        elif origin in _NAME_ALIASES:
            origin = f"{origin}.regex"
        destinations = [
            "country.name.en" if value == "country.name" else value
            for value in destinations
        ]
        if origin not in _VALID_DEFAULT_ORIGINS:
            raise ValueError(
                "origin must be one of: " + ", ".join(sorted(_VALID_DEFAULT_ORIGINS))
            )

    dictionary = _prepare_codelist(custom_dict, origin, destinations)
    if origin_regex is None:
        use_regex = using_default and origin in _REGEX_ORIGINS
    else:
        use_regex = origin_regex

    if not use_regex:
        seen = set()
        duplicates = set()
        for value in dictionary[origin]:
            if _is_missing(value):
                continue
            normalized = (
                value.casefold()
                if using_default
                and isinstance(value, str)
                and "country" not in origin
                and origin != "unicode.symbol"
                else value
            )
            if normalized in seen:
                duplicates.add(value)
            seen.add(normalized)
        if duplicates:
            raise ValueError(
                "Countrycode cannot accept dictionaries with duplicated origin "
                f"codes: {sorted(map(str, duplicates))}"
            )

    source, input_type = _normalize_input(sourcevar)
    if not use_regex:
        dictionary_origin = [
            value for value in dictionary[origin] if not _is_missing(value)
        ]
        if (
            dictionary_origin
            and all(
                isinstance(value, (int, float)) and not isinstance(value, bool)
                for value in dictionary_origin
            )
            and any(isinstance(value, str) for value in source)
        ):
            raise ValueError(
                f"To convert a '{origin}' code, sourcevar must be numeric."
            )

    result = [None] * len(source)
    all_ambiguous: dict[int, list[Any]] = {}
    for dest in destinations:
        if use_regex:
            converted, ambiguous = _regex_convert(source, origin, dest, dictionary)
        else:
            ignore_case = (
                using_default and "country" not in origin and origin != "unicode.symbol"
            )
            converted, ambiguous = _exact_convert(
                source, origin, dest, dictionary, ignore_case=ignore_case
            )
        all_ambiguous.update(ambiguous)
        result = [
            new if _is_missing(old) and not _is_missing(new) else old
            for old, new in zip(result, converted)
        ]

    if custom_match:
        result = [
            custom_match[value] if value in custom_match else converted
            for value, converted in zip(source, result)
        ]
        all_ambiguous = {
            index: matches
            for index, matches in all_ambiguous.items()
            if source[index] not in custom_match
        }

    if all_ambiguous and warn:
        values = [source[index] for index in all_ambiguous]
        warnings.warn(
            "Some values matched more than once and were set to None: "
            + ", ".join(map(repr, values)),
            UserWarning,
            stacklevel=2,
        )

    unmatched_indexes = [
        index for index, value in enumerate(result) if _is_missing(value)
    ]
    if unmatched_indexes:
        if nomatch is None:
            replacements = source
        elif nomatch is _DEFAULT_NOMATCH:
            replacements = [None] * len(source)
        elif isinstance(nomatch, Sequence) and not isinstance(nomatch, str):
            replacements = list(nomatch)
            if len(replacements) != len(source):
                raise ValueError(
                    "nomatch must be a scalar or have the same length as sourcevar."
                )
        else:
            replacements = [nomatch] * len(source)
        for index in unmatched_indexes:
            result[index] = replacements[index]
        if warn:
            _warn_unmatched(
                [
                    source[index]
                    for index in unmatched_indexes
                    if index not in all_ambiguous
                ]
            )

    return _restore_type(result, sourcevar, input_type)


# Backwards-compatible helpers. These deliberately use exact/regex semantics
# without warnings or fallback handling.
def replace_exact(sourcevar, origin, destination, codelist):
    return _exact_convert(
        list(sourcevar), origin, destination, codelist, ignore_case=False
    )[0]


def replace_regex(sourcevar, origin, destination, codelist):
    return _regex_convert(list(sourcevar), origin, destination, codelist)[0]


codelist = _prepare_codelist()
