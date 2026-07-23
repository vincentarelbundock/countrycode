import importlib
import subprocess
import sys

from countrycode import countrycode

countrycode_module = importlib.import_module("countrycode.countrycode")


def test_default_conversion_reuses_loaded_codelist(monkeypatch):
    def fail_if_called(*args, **kwargs):
        raise AssertionError("the built-in codelist was read again")

    monkeypatch.setattr(countrycode_module, "_read_csv", fail_if_called)
    assert countrycode("USA", "iso3c", "iso2c") == "US"


def test_regex_conversion_matches_each_unique_input_once(monkeypatch):
    searches = 0

    class Pattern:
        def search(self, value):
            nonlocal searches
            searches += 1
            return True

    monkeypatch.setattr(
        countrycode_module.re,
        "compile",
        lambda pattern, flags: Pattern(),
    )
    matches = countrycode_module._regex_match_rows(
        ["Canada"] * 100,
        "name",
        {"name": ["Canada", "CA"]},
    )
    assert matches == [[0, 1]] * 100
    assert searches == 2


def test_import_does_not_eagerly_load_optional_dataframe_libraries():
    script = (
        "import sys; import countrycode; "
        "assert 'pandas' not in sys.modules; "
        "assert 'polars' not in sys.modules"
    )
    subprocess.run([sys.executable, "-c", script], check=True)
