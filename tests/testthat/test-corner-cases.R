context('Corner cases')

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

