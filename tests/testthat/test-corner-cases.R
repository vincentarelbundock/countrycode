context('Corner cases')


test_that("Issue #258", {
    expect_equal(
        codelist_panel[codelist_panel$country.name.en == "Germany" & codelist_panel$year == 1900,]$gwn,
        255,
        ignore_attr = TRUE)
    expect_equal(
        codelist_panel[grepl("Korea", codelist_panel$country.name.en) & codelist_panel$year == 1900,]$gwn,
        730)
})


test_that("UN spanish name is Trinidad y Tabago: Issue #299", {
    expect_equal(countrycode("Trinidad and Tobago", "country.name", "un.name.es"), "Trinidad y Tabago")
})


test_that("Issue #244", {
    expect_equal(countrycode('.de', 'cctld', 'country.name'), "Germany")
})


test_that('Namibia iso2c is not converted to NA', {
    expect_equal('NA', countrycode("Namibia", 'country.name', 'iso2c'))
    expect_equal('NA', countrycode("Namibia", 'country.name', 'genc2c'))
    expect_equal('NA', countrycode("Namibia", 'country.name', 'eurostat'))
    expect_equal('NA', countrycode("Namibia", 'country.name', 'wb_api2c'))
    expect_equal('NA', countrycode("Namibia", 'country.name', 'ecb'))
})

test_that("Viet Nam variations", {
  expect_equal("RVN", countrycode("Republic of Viet Nam", "country.name", "cowc"))
  expect_equal("RVN", countrycode("Republic of VietNam", "country.name", "cowc"))
  expect_equal("RVN", countrycode("South VietNam", "country.name", "cowc"))
  expect_equal("DRV", countrycode("Democratic Republic of VietNam", "country.name", "cowc"))
  expect_equal("DRV", countrycode("Democratic Republic of Viet Nam", "country.name", "cowc"))
  expect_equal("DRV", countrycode("North Viet Nam", "country.name", "cowc"))

  expect_equal(35, countrycode("Republic of VietNam", "country.name", "vdem"))
  expect_equal(34, countrycode("Democratic Republic of Viet Nam", "country.name", "vdem"))
  expect_equal(34, countrycode("VietNam", "country.name", "vdem"))
})

test_that("bangladesh", {
    expect_equal(
        countrycode("Bangladesh", "country.name.de", "iso3c"),
        "BGD")
    expect_equal(
        countrycode("Bangladesch", "country.name.de", "iso3c"),
        "BGD")
})

test_that("netherlands", {
    expect_equal(
        countrycode("Holland", "country.name", "country.name"),
        "Netherlands")
    expect_equal(
        countrycode("Hollande", "country.name.fr", "country.name"),
        "Netherlands")
    expect_equal(
        countrycode("Niederländische Antillen", "country.name.de", "country.name.en"),
        "Netherlands Antilles")
    expect_equal(
        countrycode("Karibische Niederlande", "country.name.de", "country.name.en"),
        "Caribbean Netherlands")
    expect_equal(
        countrycode("Caraibi olandesi", "country.name.it", "country.name.en"),
        "Caribbean Netherlands")
})


test_that("macedonia", {
    expect_equal(
        countrycode("Macédoine du Nord", "country.name.fr", "country.name.en"),
        "North Macedonia")
    expect_equal(
        countrycode("FYROM", "country.name.fr", "country.name.en"),
        "North Macedonia")
})



test_that("misc", {
    expect_equal(
        countrycode("Sint Maarten", "country.name.de", "iso3c"),
        "SXM")
    expect_equal(
        countrycode("Aruba", "country.name.de", "iso3c"),
        "ABW")
    expect_equal(
        countrycode("Curaçao", "country.name.de", "iso3c"),
        "CUW")
})

