import os

import pytest

try:
    import polars as pl

    _has_polars = True

    pkg_dir, pkg_filename = os.path.split(__file__)
    pkg_dir = os.path.dirname(pkg_dir)
    data_path = os.path.join(pkg_dir, "countrycode", "data", "codelist.csv.gz")
    codelist = pl.read_csv(data_path)
except ImportError:
    _has_polars = False
    from custom_strategies import codelist


@pytest.mark.skipif(not _has_polars, reason=".Shape method assumes polars installation")
def test_codelist_dimensions_polars():
    """
    Unit test to validate the dimensions of the data.
    """
    assert codelist.shape == (292, 628)


@pytest.mark.skipif(
    _has_polars, reason="Test assumed dictionary representation of codelist"
)
def test_codelist():
    assert len(codelist.keys()) == 624
    assert all(len(codelist.get(key)) == 291 for key in codelist.keys())
