from countrycode import countrycode


def test_corner_cases_issue_299():
    assert (
        countrycode("Trinidad and Tobago", "country.name", "un.name.es")
        == "Trinidad y Tabago"
    )


def test_corner_cases_issue_244():
    assert countrycode(".de", "cctld", "country.name") == "Germany"


def test_corner_cases_namibia_iso2c():
    assert countrycode("Namibia", "country.name", "iso2c") == "NA"
    assert countrycode("Namibia", "country.name", "genc2c") == "NA"
    assert countrycode("Namibia", "country.name", "eurostat") == "NA"
    assert countrycode("Namibia", "country.name", "wb_api2c") == "NA"
    assert countrycode("Namibia", "country.name", "ecb") == "NA"


def test_corner_cases_viet_nam_variations():
    assert countrycode("Republic of Viet Nam", "country.name", "cowc") == "RVN"
    assert countrycode("Republic of VietNam", "country.name", "cowc") == "RVN"
    assert countrycode("South VietNam", "country.name", "cowc") == "RVN"
    assert (
        countrycode("Democratic Republic of VietNam", "country.name", "cowc") == "DRV"
    )
    assert (
        countrycode("Democratic Republic of Viet Nam", "country.name", "cowc") == "DRV"
    )
    assert countrycode("North Viet Nam", "country.name", "cowc") == "DRV"
    assert countrycode("Republic of VietNam", "country.name", "vdem") == 35
    assert countrycode("Democratic Republic of Viet Nam", "country.name", "vdem") == 34
    assert countrycode("VietNam", "country.name", "vdem") == 34


def test_corner_cases_bangladesh():
    assert countrycode("Bangladesh", "country.name.de", "iso3c") == "BGD"
    assert countrycode("Bangladesch", "country.name.de", "iso3c") == "BGD"
    assert True


def test_corner_cases_netherlands():
    assert countrycode("Holland", "country.name", "country.name") == "Netherlands"
    assert countrycode("Hollande", "country.name.fr", "country.name") == "Netherlands"
    assert (
        countrycode("Niederländische Antillen", "country.name.de", "country.name.en")
        == "Netherlands Antilles"
    )
    assert (
        countrycode("Karibische Niederlande", "country.name.de", "country.name.en")
        == "Caribbean Netherlands"
    )
    assert (
        countrycode("Caraibi olandesi", "country.name.it", "country.name.en")
        == "Caribbean Netherlands"
    )
    assert True


def test_corner_cases_macedonia():
    assert (
        countrycode("Macédoine du Nord", "country.name.fr", "country.name.en")
        == "North Macedonia"
    )
    assert (
        countrycode("FYROM", "country.name.fr", "country.name.en") == "North Macedonia"
    )


def test_corner_cases_misc():
    assert countrycode("Sint Maarten", "country.name.de", "iso3c") == "SXM"
    assert countrycode("Aruba", "country.name.de", "iso3c") == "ABW"
    assert countrycode("Curaçao", "country.name.de", "iso3c") == "CUW"
