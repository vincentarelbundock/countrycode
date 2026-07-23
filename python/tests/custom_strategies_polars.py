import string
import os
from typing import Optional, Union

from hypothesis import strategies as st
from hypothesis.strategies import SearchStrategy

try:
    import polars as pl

    pkg_dir, pkg_filename = os.path.split(__file__)
    pkg_dir = os.path.dirname(pkg_dir)
    data_path = os.path.join(pkg_dir, "countrycode", "data", "codelist.csv")
    codelist = pl.read_csv(data_path)
except ImportError:
    pass


def _select_codes(code="iso3c") -> list:
    return codelist.get_column(code).drop_nulls().to_list()


def build_valid_code(code: str = "iso3c") -> SearchStrategy[str]:
    """
    Builder function that returns a strategy to pick one of a valid 'code'.
    """
    return st.sampled_from(_select_codes(code))


def select_filtered_row(
    column: str, column_value: str, target_col="country.name.en"
) -> Union[Optional[int], Optional[str]]:
    """
    Function to return the following operation:
    codelist.filter(pl.col(column) == column_value).item(0, target_col)
    Args:
        column: Column from codelist to filter
        column_value: The value with which to filter the specified column
        target_col: THe column to be selected
    Returns:
        The first cell of target_column after filtering column as equals to column_value
    """
    return codelist.filter(pl.col(column) == column_value).item(0, target_col)


def build_invalid_code(code="iso3c") -> SearchStrategy[str]:
    """
    Returns a string that is not represented in code within codelist
    """
    return st.text(alphabet=string.printable, min_size=1, max_size=10).filter(
        lambda z: z not in _select_codes(code)
    )
