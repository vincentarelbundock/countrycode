import pytest

from countrycode import countrycode, countryname

from fixture_data import (
    CONVERSIONS_BY_CODE,
    COUNTRYNAME_BY_DESTINATION,
    NAME_NONMATCHES_BY_CODE,
    NAME_VARIATIONS_BY_EXPECTED,
)


NAME_VARIATIONS = [
    (variation, expected)
    for expected, variations in NAME_VARIATIONS_BY_EXPECTED.items()
    for variation in variations
]
CONVERSIONS = [
    (source, origin, destination, expected)
    for origin, destinations in CONVERSIONS_BY_CODE.items()
    for destination, mapping in destinations.items()
    for source, expected in mapping.items()
]
NAME_NONMATCHES = [
    (source, origin, destination)
    for origin, destinations in NAME_NONMATCHES_BY_CODE.items()
    for destination, sources in destinations.items()
    for source in sources
]
COUNTRYNAME_CASES = [
    (source, destination, expected)
    for destination, mapping in COUNTRYNAME_BY_DESTINATION.items()
    for source, expected in mapping.items()
]


@pytest.mark.parametrize(
    ("variation", "expected"),
    NAME_VARIATIONS,
)
def test_known_name_variations(variation, expected):
    actual = countrycode(
        variation,
        "country.name",
        "country.name",
        warn=False,
    )
    assert actual == expected


@pytest.mark.parametrize(
    ("source", "origin", "destination", "expected"),
    CONVERSIONS,
)
def test_shared_conversion_cases(source, origin, destination, expected):
    actual = countrycode(source, origin, destination, warn=False)
    assert actual == expected


@pytest.mark.parametrize(
    ("variation", "origin", "destination"),
    NAME_NONMATCHES,
)
def test_shared_name_nonmatches(variation, origin, destination):
    actual = countrycode(variation, origin, destination, warn=False)
    assert actual is None


@pytest.mark.parametrize(
    ("source", "destination", "expected"),
    COUNTRYNAME_CASES,
)
def test_shared_countryname_cases(source, destination, expected):
    assert countryname(source, destination, warn=False) == expected
