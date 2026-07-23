from hypothesis import given, example

from countrycode import countrycode

from custom_strategies_polars import (
    build_invalid_code,
    build_valid_code,
    select_filtered_row,
)


@given(code_param=build_valid_code("iso3c"))
@example(code_param="CAN")
def test_numeric(code_param):
    expected = select_filtered_row("iso3c", code_param, "iso3n")
    assert countrycode(code_param, "iso3c", "iso3n") == expected


"""
Test to check that finding the country.name representation of an iso3c row is
equivalent to finding the corresponding cell in the countrycode dataframe.
"""


@given(code_param=build_valid_code("iso3c"))
@example(code_param="AFG")
def test_iso3c_conversion(code_param):
    expected = select_filtered_row("iso3c", code_param)
    assert countrycode(code_param, "iso3c", "country.name") == expected


"""
Test to confirm that when an invalid iso3c code is provided the 
countrycode function will return None
"""


@given(code_param=build_invalid_code("iso3c"))
def test_iso3c_invalid_conversion(code_param):
    assert countrycode(code_param, "iso3c", "country.name") is None


"""
Test to check that finding the country.name representation of an iso3c row is
equivalent to finding the corresponding cell in the countrycode dataframe.
"""


@given(code_param=build_valid_code("fips"))
def test_fips_conversion(code_param):
    expected = select_filtered_row("fips", code_param)
    assert countrycode(code_param, "fips", "country.name") == expected


"""
Test to confirm that when an invalid fips code is provided the countrycode 
function will return None
"""


@given(code_param=build_invalid_code("fips"))
def test_fips_invalid_conversion(code_param):
    assert countrycode(code_param, "fips", "country.name") is None
