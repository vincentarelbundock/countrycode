import io
import warnings

import pytest

from countrycode import (
    AVAILABLE_DICTIONARIES,
    countrycode,
    countryname,
    get_dictionary,
    guess_field,
    load_cldr_examples,
    load_codelist_panel,
    load_countryname_dict,
)


def test_nomatch_semantics():
    source = ["ALG", "AUH", "BAD"]
    assert countrycode(source, "cowc", "iso3c", warn=False) == [
        "DZA",
        None,
        None,
    ]
    assert countrycode(source, "cowc", "iso3c", warn=False, nomatch="TEST") == [
        "DZA",
        "TEST",
        "TEST",
    ]
    assert countrycode(source, "cowc", "iso3c", warn=False, nomatch=None) == [
        "DZA",
        "AUH",
        "BAD",
    ]
    assert countrycode(
        source,
        "cowc",
        "iso3c",
        warn=False,
        nomatch=["x", "y", "z"],
    ) == ["DZA", "y", "z"]
    with pytest.raises(ValueError, match="same length"):
        countrycode(source, "cowc", "iso3c", nomatch=["x", "y"])


def test_warn_and_case_insensitive_exact_matching():
    assert countrycode("usa", "iso3c", "country.name", warn=False) == "United States"
    with pytest.raises(ValueError, match="must be numeric"):
        countrycode("2", "cown", "country.name")
    with pytest.warns(UserWarning, match="not matched"):
        assert countrycode("BAD", "iso3c", "country.name") is None
    with warnings.catch_warnings():
        warnings.simplefilter("error")
        assert countrycode("BAD", "iso3c", "country.name", warn=False) is None


def test_multiple_destinations_fill_missing_values():
    assert countrycode("Serbia", "country.name", ["cowc", "iso3c"], warn=False) == "SRB"


def test_regex_override_ambiguity_and_custom_match():
    dictionary = {
        "regex": ["china", "hong"],
        "code": ["CHN", "HKG"],
    }
    with pytest.warns(UserWarning, match="matched more than once"):
        assert (
            countrycode(
                "china_hong_kong",
                "regex",
                "code",
                custom_dict=dictionary,
                origin_regex=True,
            )
            is None
        )
    assert (
        countrycode(
            "china_hong_kong",
            "regex",
            "code",
            custom_dict=dictionary,
            custom_match={"china_hong_kong": "HKG"},
            origin_regex=True,
        )
        == "HKG"
    )


def test_custom_dictionary_regex_control_and_duplicates():
    dictionary = {"regex": ["qu.bec"], "code": ["QC"]}
    assert (
        countrycode(
            "Québec",
            "regex",
            "code",
            custom_dict=dictionary,
            origin_regex=True,
        )
        == "QC"
    )
    assert countrycode("qu.bec", "regex", "code", dictionary) == "QC"
    assert (
        countrycode(
            "Québec",
            "regex",
            "code",
            custom_dict=dictionary,
            origin_regex=False,
            warn=False,
        )
        is None
    )
    with pytest.raises(ValueError, match="duplicated origin"):
        countrycode(
            "A",
            "code",
            "name",
            custom_dict={"code": ["A", "A"], "name": ["One", "Two"]},
        )


def test_spanish_country_name_origin():
    assert (
        countrycode(
            "Caribe holandes",
            "country.name.es",
            "country.name.en",
            warn=False,
        )
        == "Netherlands Antilles"
    )


def test_countryname_multilingual_and_destination():
    source = ["ジンバブエ", "Afeganistãu", "Barbadas", "Sverige", "UK"]
    assert countryname(source, warn=False) == [
        "Zimbabwe",
        "Afghanistan",
        "Barbados",
        "Sweden",
        "United Kingdom",
    ]
    assert countryname("ジンバブエ", "iso3c", warn=False) == "ZWE"


def test_guess_field():
    result = guess_field(["DZA", "CAN", "DEU"])
    assert result
    assert {"iso3c", "genc3c"} <= {item["code"] for item in result}
    assert all(item["percent_of_unique_matched"] == 100 for item in result)


def test_supplementary_dataset_loaders():
    panel = load_codelist_panel()
    names = load_countryname_dict()
    examples = load_cldr_examples()
    assert len(panel["year"]) > 1_000
    assert isinstance(panel["year"][0], int)
    assert "country.name.alt" in names
    assert examples["Code"][0].startswith("cldr.")


def test_pandas_metadata_is_preserved():
    pd = pytest.importorskip("pandas")
    source = pd.Series(["USA", "CAN"], index=["a", "b"], name="country")
    result = countrycode(source, "iso3c", "country.name")
    assert result.index.tolist() == ["a", "b"]
    assert result.name == "country"


def test_get_dictionary_catalog_and_download(monkeypatch):
    assert "us_states" in get_dictionary()
    assert tuple(AVAILABLE_DICTIONARIES) == get_dictionary()

    class Response(io.BytesIO):
        def __enter__(self):
            return self

        def __exit__(self, *args):
            self.close()

    monkeypatch.setattr(
        "urllib.request.urlopen",
        lambda url: Response(b"state.abb,state.name\nMO,Missouri\nMN,Minnesota\n"),
    )
    dictionary = get_dictionary("us_states")
    assert (
        countrycode("MO", "state.abb", "state.name", custom_dict=dictionary)
        == "Missouri"
    )
    with pytest.raises(ValueError, match="dictionary must be one of"):
        get_dictionary("invalid")
