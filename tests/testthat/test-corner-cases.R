context('Corner cases')

test_that('Namibia iso2c is not converted to NA', {
    expect_equal('NA', countrycode("Namibia", 'country.name', 'iso2c'))
    expect_equal('NA', countrycode("Namibia", 'country.name', 'genc2c'))
    expect_equal('NA', countrycode("Namibia", 'country.name', 'eurostat'))
    expect_equal('NA', countrycode("Namibia", 'country.name', 'wb_api2c'))
    expect_equal('NA', countrycode("Namibia", 'country.name', 'ecb'))
})
