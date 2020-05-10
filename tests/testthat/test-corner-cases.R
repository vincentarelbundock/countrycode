context('Corner cases')

test_that('Namibia iso2c is not converted to NA', {
    iso2c_of <- function(country) countrycode(country, 'country.name', 'iso2c')
    expect_equal(iso2c_of('Namibia'), 'NA')
})
