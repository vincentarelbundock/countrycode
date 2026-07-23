import os
import pytest
from countrycode import countrycode

try:
    import polars as pl

    _has_polars = True

    pkg_dir, pkg_filename = os.path.split(__file__)
    pkg_dir = os.path.dirname(pkg_dir)
    data_path = os.path.join(pkg_dir, "countrycode", "data", "codelist.csv")
    codelist = pl.read_csv(data_path)
except ImportError:
    _has_polars = False

_regex_internal_skip_reason = "Test requires polars installation"

if not _has_polars:
    pytest.skip(_regex_internal_skip_reason, allow_module_level=True)


# Test all country names with iso3c codes are matched exactly once
def test_iso3c_match():
    name = codelist.filter(pl.col("iso3c").is_not_null())
    iso3c_from_name = countrycode(
        name["country.name.en"], origin="country.name", destination="iso3c"
    )
    assert len(iso3c_from_name) == len(set(iso3c_from_name))


# Test iso3c-to-country.name-to-iso3c is internally consistent
def test_iso3c_consistency():
    tmp = codelist.filter(pl.col("iso3c").is_not_null())
    a = countrycode(tmp["iso3c"], origin="iso3c", destination="country.name")
    b = countrycode(a, origin="country.name", destination="iso3c")
    assert (b == tmp["iso3c"]).all()


# Test English regex vs. cldr.short.
def test_english_regex():
    tmp = codelist.filter(pl.col("country.name.en").is_not_null())
    tmp = tmp.with_columns(
        test=countrycode(
            tmp["country.name.en"],
            origin="country.name.en",
            destination="cldr.short.en",
        )
    )
    assert not (tmp["test"] != tmp["cldr.short.en"]).any()


# Test Italian regex vs. cldr.short.it
def test_italian_regex():
    tmp = codelist.filter(pl.col("country.name.it").is_not_null())
    tmp = tmp.with_columns(
        test=countrycode(
            tmp["country.name.it"],
            origin="country.name.it",
            destination="cldr.short.it",
        )
    )
    assert not (tmp["test"] != tmp["cldr.short.it"]).any()


# Test German regex vs. cldr.short.de
def test_german_regex():
    tmp = codelist.filter(pl.col("country.name.de").is_not_null())
    tmp = tmp.with_columns(
        test=countrycode(
            tmp["country.name.de"],
            origin="country.name.de",
            destination="cldr.short.de",
        )
    )
    assert not (tmp["test"] != tmp["cldr.short.de"]).any()


# Test French regex vs. cldr.short.fr
def test_french_regex():
    tmp = codelist.filter(pl.col("country.name.fr").is_not_null())
    tmp = tmp.with_columns(
        test=countrycode(
            tmp["country.name.fr"],
            origin="country.name.fr",
            destination="cldr.short.fr",
        )
    )
    assert not (tmp["test"] != tmp["cldr.short.fr"]).any()
