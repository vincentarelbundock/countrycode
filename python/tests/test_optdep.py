from countrycode import countrycode

try:
    import polars as pl
except ImportError:
    pl = None
try:
    import pandas as pd
except ImportError:
    pd = None


def test_optdep():
    inp = ["USA", "CAN"]
    out = ["United States", "Canada"]

    inp_cctld = [".us", ".ca"]
    out_cctld = ["United States", "Canada"]

    if pl:
        # using replace_regex
        test = countrycode(pl.Series(inp), origin="iso3c", destination="country.name")
        ref = pl.Series(out)
        assert isinstance(test, pl.Series)
        assert test.equals(ref)

        # using replace_exact
        test = countrycode(
            pl.Series(inp_cctld), origin="cctld", destination="country.name"
        )
        ref = pl.Series(out_cctld)
        assert isinstance(test, pl.Series)
        assert test.equals(ref)

    if pd:
        # using replace_regex
        test = countrycode(pd.Series(inp), origin="iso3c", destination="country.name")
        ref = pd.Series(out)
        assert isinstance(test, pd.Series)
        assert pd.Series.compare(test, ref).empty

        # using replace_exact
        test = countrycode(
            pd.Series(inp_cctld), origin="cctld", destination="country.name"
        )
        ref = pd.Series(out_cctld)
        assert isinstance(test, pd.Series)
        assert pd.Series.compare(test, ref).empty

    # using replace_regex
    # list
    test = countrycode(inp, origin="iso3c", destination="country.name")
    ref = out
    assert isinstance(test, list)
    assert test == ref

    # str
    test = countrycode(inp[0], origin="iso3c", destination="country.name")
    ref = out[0]
    assert isinstance(test, str)
    assert test == ref

    # using replace_regex
    # list
    test = countrycode(inp_cctld, origin="cctld", destination="country.name")
    ref = out_cctld
    assert isinstance(test, list)
    assert test == ref

    # str
    test = countrycode(inp_cctld[0], origin="cctld", destination="country.name")
    ref = out_cctld[0]
    assert isinstance(test, str)
    assert test == ref
