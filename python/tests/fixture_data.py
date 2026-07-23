from pathlib import Path

import yaml


FIXTURE_DIR = Path(__file__).resolve().parents[2] / "r" / "inst" / "extdata"


def read_fixture(name):
    with (FIXTURE_DIR / name).open(encoding="utf-8") as stream:
        return yaml.safe_load(stream)


CONVERSIONS_BY_CODE = read_fixture("conversions.yaml")
COUNTRYNAME_BY_DESTINATION = read_fixture("countryname.yaml")
NAME_NONMATCHES_BY_CODE = read_fixture("name-nonmatches.yaml")
NAME_VARIATIONS_BY_EXPECTED = read_fixture("name-variations.yaml")
