import csv
import string
import os
from typing import Optional, Union

from hypothesis import strategies as st
from hypothesis.strategies import SearchStrategy

pkg_dir, pkg_filename = os.path.split(__file__)
pkg_dir = os.path.dirname(pkg_dir)
data_path = os.path.join(pkg_dir, "countrycode", "data", "codelist.csv")
with open(data_path) as f:
    rows = csv.reader(f)
    codelist = {col[0]: list(col[1:]) for col in zip(*rows)}


def empty_string_to_null(s: str) -> Optional[str]:
    """
    Helper function to convert empty strings to `None`. Diract extraction from
    the `codelist` dictionary stores empty values as `""` while
    `countrycode` represents those values as None
    Args:
        s: A string

    Returns: `None` is the string is empty, otherwise the function will return
        the input string `s`.

    """
    if s == "":
        return None
    return s


def _select_codes(code: str = "iso3c") -> list:
    """
    Select all distinct values for a given column `code` from codelist
    Args:
        code: String representation of a column in `codelist` representing the field
        of distinct values you wish to access

    Returns: An array of non-empty values of the `code` column
    """
    return list(filter(lambda z: z != "", codelist.get(code)))


def build_valid_code(code: str = "iso3c") -> SearchStrategy[str]:
    """
    Builder function that returns a strategy to pick one of a valid 'code'.
    """
    return st.sampled_from(_select_codes(code))


def select_filtered_row(
    input_column: str, column_value: str, target_col="country.name.en"
) -> Union[Optional[int], Optional[str]]:
    """
    Function to return the `target_col` row that matches the `column_value` value of `column`
    Assuming `codelist` is from the `polars` package:
    codelist.filter(pl.col(column) == column_value).item(0, target_col)
    Args:
        input_column: Column from codelist to filter
        column_value: The value with which to filter the specified column
        target_col: THe column to be selected
    Returns:
        The first cell of target_column after filtering column as equals to column_value
    """
    input_value_idx = codelist.get(input_column).index(column_value)
    return codelist.get(target_col)[input_value_idx]


def build_invalid_code(code="iso3c") -> SearchStrategy[str]:
    """
    Returns a string that is not represented in code within codelist
    """
    return st.text(alphabet=string.printable, min_size=1, max_size=10).filter(
        lambda z: z not in _select_codes(code)
    )
