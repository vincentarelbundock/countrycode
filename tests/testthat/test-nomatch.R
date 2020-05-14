context('nomatch argument to fill-in non-matching code')

origin <- c('ALG', 'AUH', 'BAD')
test_that('nomatch argument works correctly', {
    expect_equal(countrycode(origin, 'cowc', 'iso3c', warn = FALSE), c('DZA', NA, NA))
    expect_equal(countrycode(origin, 'cowc', 'iso3c', warn = FALSE, nomatch = 'TEST'), c('DZA', 'TEST', 'TEST'))
    expect_equal(countrycode(origin, 'cowc', 'iso3c', warn = FALSE, nomatch = NULL), c('DZA', 'AUH', 'BAD'))
    expect_warning(countrycode(origin, 'cowc', 'iso3n', warn = FALSE, nomatch = NULL))
    expect_error(countrycode(origin, 'cowc', 'iso3c', warn = FALSE, nomatch = c('a', 'b')))
})

test_that('nomatch: numeric and character output types',{
    # numeric are coerced to character. is this desirable?
    expect_equal(countrycode('XXX', 'country.name', 'cowc', nomatch = 0), '0')
    expect_equal(countrycode('XXX', 'country.name', 'cown', nomatch = 0), 0)
    expect_warning(countrycode('XXX', 'country.name', 'cown', nomatch = 'Bad'))
})

test_that('nomatch argument works correctly when sourcevar is a factor', {
    # nomatch vector of length 1 that is the same class as the destination code
    # vector should replace all non-match elements with the nomatch value
    expect_equal(countrycode(factor('XXX'), 'iso3c', 'iso2c', nomatch = c('YYY')), 'YYY')
    expect_equal(countrycode(factor(c('XXX', 'USA', 'YYY')), 'iso3c', 'iso2c', nomatch = c('YY')), c('YY', 'US', 'YY'))

    # nomatch NULL should replace unmatched elements with the value in the
    # original sourcevar (if it's the same class as the destination code vector)
    expect_equal(countrycode(factor('XXX'), 'iso3c', 'iso2c', nomatch = NULL), 'XXX')
    expect_equal(countrycode(factor(c('XXX', 'USA', 'YYY')), 'iso3c', 'iso2c', nomatch = NULL), c('XXX', 'US', 'YYY'))

    # nomatch NA should replace unmatched elements with NA
    expect_equal(countrycode(factor('XXX'), 'iso3c', 'iso2c', nomatch = NA, warn = FALSE), NA_character_)
    expect_equal(countrycode(factor(c('XXX', 'USA', 'YYY')), 'iso3c', 'iso2c', nomatch = NA, warn = FALSE), c(NA, 'US', NA))

    # nomatch factor vector (undecided behavior; currently skipped/ignored)
    # expect_equal(countrycode(factor('XXX'), 'iso3c', 'iso2c', nomatch = factor('YY')), factor('YY'))
})
