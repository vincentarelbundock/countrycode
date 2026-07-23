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

_COUNTRYNAME_DICT: dict[str, list[Any]] | None = None

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
    """Guess which coding scheme or name field contains a collection of values.

    Compares the unique supplied values with every field in the built-in
    ``countrycode`` dictionary and ranks fields by their match percentage.

    Args:
        codes: Country codes or country names. Scalars and iterable inputs
            accepted by :func:`countrycode` are supported.
        min_similarity: Minimum percentage of unique, non-missing values that
            must occur in a field for that field to be returned.

    Returns:
        A list of dictionaries sorted by decreasing match percentage. Each
        dictionary contains ``"code"`` and
        ``"percent_of_unique_matched"``. Returns an empty list when no
        non-missing values are supplied or no field meets the threshold.

    Examples:
        >>> guess_field(["DZA", "CAN", "DEU"])[0]
        {'code': 'genc3c', 'percent_of_unique_matched': 100.0}
    """
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
    """Convert country names in many languages to another name or code.

    The function makes two passes over the data. First it detects country-name
    variations in many languages extracted from the Unicode Common Locale Data
    Repository. It then applies the English country-name patterns used by
    :func:`countrycode` to unresolved values.

    Because the two-pass approach is permissive, some names can be ambiguous,
    such as Saint Martin versus Saint Martin (French part). Use
    ``countrycode(x, "country.name", "country.name")`` when stricter English
    name matching is preferable.

    Args:
        sourcevar: Country names to convert. Non-ASCII names are supported.
            Accepts the same scalar and container types as :func:`countrycode`.
        destination: Destination country-name or coding field. Defaults to the
            standardized English name, ``"country.name.en"``.
        nomatch: Replacement for unmatched values. By default they become
            ``None``. Pass ``None`` to preserve the original input, or pass a
            scalar or same-length sequence of replacements.
        warn: Emit warnings listing values that could not be matched.

    Returns:
        Converted names or codes, preserving the scalar or container type of
        ``sourcevar`` where supported.

    Examples:
        >>> countryname(["Barbadas", "Sverige", "UK"])
        ['Barbados', 'Sweden', 'United Kingdom']
        >>> countryname(["Barbadas", "Sverige"], destination="iso3c")
        ['BRB', 'SWE']
    """
    source, input_type = _normalize_input(sourcevar)
    global _COUNTRYNAME_DICT
    if _COUNTRYNAME_DICT is None:
        _COUNTRYNAME_DICT = load_countryname_dict()
    alternative_names = _COUNTRYNAME_DICT
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
    """List or download a maintained custom conversion dictionary.

    Downloaded dictionaries can be passed directly to the ``custom_dict``
    argument of :func:`countrycode`.

    Args:
        dictionary: Name of the dictionary to retrieve. If omitted, return the
            names of all available dictionaries.

    Returns:
        A tuple of available names when ``dictionary`` is ``None``; otherwise,
        a mapping of column names to values suitable for ``custom_dict``.

    Raises:
        ValueError: If ``dictionary`` is not one of the available names.
        urllib.error.URLError: If the remote dictionary cannot be downloaded.

    Examples:
        List available dictionaries:

        >>> "us_states" in get_dictionary()
        True

        Download and use a dictionary:

        >>> states = get_dictionary("us_states")  # doctest: +SKIP
        >>> countrycode(  # doctest: +SKIP
        ...     "MO", "state.abb", "state.name", custom_dict=states
        ... )
        'Missouri'
    """
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
