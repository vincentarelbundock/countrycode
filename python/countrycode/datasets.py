"""Load the supplementary datasets distributed with countrycode."""

from __future__ import annotations

from pathlib import Path
from typing import Any, Literal

from .countrycode import _import_optional, _read_csv

_DATA_DIR = Path(__file__).resolve().parent / "data"
_DATASETS = {
    "codelist_panel": _DATA_DIR / "codelist_panel.csv.gz",
    "countryname_dict": _DATA_DIR / "countryname_dict.csv.gz",
    "cldr_examples": _DATA_DIR / "cldr_examples.csv.gz",
}


def load_dataset(
    name: str,
    as_type: Literal["dict", "pandas", "polars"] = "dict",
) -> Any:
    """Load a supplementary dataset distributed with ``countrycode``.

    Args:
        name: Dataset name. Valid values are ``"codelist_panel"``,
            ``"countryname_dict"``, and ``"cldr_examples"``.
        as_type: Output representation: ``"dict"``, ``"pandas"``, or
            ``"polars"``.

    Returns:
        A mapping of column names to lists, a Pandas DataFrame, or a Polars
        DataFrame, depending on ``as_type``.

    Raises:
        ValueError: If ``name`` or ``as_type`` is invalid.
        ImportError: If the requested optional DataFrame library is not
            installed.

    Examples:
        >>> panel = load_dataset("codelist_panel")
        >>> len(panel["year"]) > 1000
        True
    """
    if name not in _DATASETS:
        raise ValueError(f"name must be one of: {', '.join(sorted(_DATASETS))}")
    data = _read_csv(_DATASETS[name])
    if as_type == "dict":
        return data
    if as_type == "pandas":
        pd = _import_optional("pandas")
        if pd is None:
            raise ImportError("Pandas is not installed.")
        return pd.DataFrame(data)
    if as_type == "polars":
        pl = _import_optional("polars")
        if pl is None:
            raise ImportError("Polars is not installed.")
        return pl.DataFrame(data)
    raise ValueError("as_type must be 'dict', 'pandas', or 'polars'.")


def load_codelist_panel(
    as_type: Literal["dict", "pandas", "polars"] = "dict",
) -> Any:
    """Load the reconciled country-year conversion dictionary.

    The panel contains country-year observations with multiple coding schemes.
    It is preferable to the cross-sectional dictionary when political units
    or codes change over time.

    Args:
        as_type: Output representation: ``"dict"``, ``"pandas"``, or
            ``"polars"``.

    Returns:
        The country-year panel in the requested representation.

    Raises:
        ValueError: If ``as_type`` is invalid.
        ImportError: If the requested optional DataFrame library is absent.

    Examples:
        >>> panel = load_codelist_panel()
        >>> {"year", "iso3c"}.issubset(panel)
        True
    """
    return load_dataset("codelist_panel", as_type)


def load_countryname_dict(
    as_type: Literal["dict", "pandas", "polars"] = "dict",
) -> Any:
    """Load alternative country names used by :func:`countryname`.

    The dataset pairs standardized English country names with alternative
    names drawn from many languages and sources.

    Args:
        as_type: Output representation: ``"dict"``, ``"pandas"``, or
            ``"polars"``.

    Returns:
        The alternative-name dictionary in the requested representation.

    Raises:
        ValueError: If ``as_type`` is invalid.
        ImportError: If the requested optional DataFrame library is absent.

    Examples:
        >>> names = load_countryname_dict()
        >>> set(names) == {"country.name.en", "country.name.alt"}
        True
    """
    return load_dataset("countryname_dict", as_type)


def load_cldr_examples(
    as_type: Literal["dict", "pandas", "polars"] = "dict",
) -> Any:
    """Load examples of available Unicode CLDR destination fields.

    The dataset associates CLDR field codes with example country names and is
    useful for choosing among the hundreds of ``cldr.*`` destinations.

    Args:
        as_type: Output representation: ``"dict"``, ``"pandas"``, or
            ``"polars"``.

    Returns:
        The CLDR examples in the requested representation.

    Raises:
        ValueError: If ``as_type`` is invalid.
        ImportError: If the requested optional DataFrame library is absent.

    Examples:
        >>> examples = load_cldr_examples()
        >>> {"Code", "Example"}.issubset(examples)
        True
    """
    return load_dataset("cldr_examples", as_type)
