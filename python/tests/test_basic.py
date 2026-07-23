from countrycode import countrycode
import polars as pl

"""
Test to check that finding the iso3n representation of an iso3c row is
equivalent to finding the corresponding cell in the countrycode dataframe.
"""


def test_basic_conversions():
    def name_of(iso3c_code):
        return countrycode(iso3c_code, origin="iso3c", destination="country.name")

    assert name_of("CAN") == "Canada"
    assert name_of(["USA", "CAN"]) == ["United States", "Canada"]


def test_issue_252():
    assert countrycode("United States", "country.name", "p5c") == "USA"
    assert countrycode("United States", "country.name", "p5n") == 2


def test_invalid_iso3c_to_country_name():
    def name_of(iso3c_code):
        return countrycode(iso3c_code, "iso3c", "country.name")

    assert name_of("BAD") is None
    assert name_of(["BAD", "BLA", "CAN"]) == [None, None, "Canada"]


def test_readme_examples():
    # Example 1: Convert ISO numeric codes to French country names
    assert countrycode([12, 124], origin="iso3n", destination="cldr.short.fr") == [
        "Algérie",
        "Canada",
    ]

    assert countrycode(12, origin="iso3n", destination="cldr.short.fr") == "Algérie"

    # Example 2: Convert country names to ISO3C codes
    assert countrycode(
        ["canada", "United States", "alGeria"],
        origin="country.name.en.regex",
        destination="iso3c",
    ) == ["CAN", "USA", "DZA"]

    # Example 3: Convert using Polars Series
    result = countrycode(
        pl.Series(["DZA", "CAN", "USA"]), origin="iso3c", destination="cldr.short.fr"
    )
    assert isinstance(result, pl.Series)
    assert result.to_list() == ["Algérie", "Canada", "É.-U."]

    # Example 4: Convert ISO3C to ISO numeric
    assert countrycode(["DZA", "CAN", "USA"], origin="iso3c", destination="iso3n") == [
        12,
        124,
        840,
    ]

    # Example 5: Convert single ISO numeric to German country name
    assert countrycode(12, origin="iso3n", destination="cldr.short.de") == "Algerien"

    # Example 6: Convert long country names to ISO3C
    assert countrycode(
        ["Democratic Republic of Vietnam", "Algeria"],
        origin="country.name.en.regex",
        destination="iso3c",
    ) == ["VNM", "DZA"]

    # Example 7: Convert German country name to ISO3C
    assert countrycode(["Algerien"], origin="country.name.de", destination="iso3c") == [
        "DZA"
    ]
