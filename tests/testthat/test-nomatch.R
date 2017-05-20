context('nomatch argument to fill-in non-matching code')

origin <- c('ALG', 'AUH', 'BAD')
test_that('nomatch argument works correctly', {
    expect_equal(countrycode(origin, 'cowc', 'iso3c', warn = FALSE), c('DZA', NA, NA))
    expect_equal(countrycode(origin, 'cowc', 'iso3c', warn = FALSE, nomatch = 'TEST'), c('DZA', 'TEST', 'TEST'))
    expect_equal(countrycode(origin, 'cowc', 'iso3c', warn = FALSE, nomatch = NULL), c('DZA', 'AUH', 'BAD'))
    expect_warning(countrycode(origin, 'cowc', 'iso3n', warn = FALSE, nomatch = NULL))
    expect_error(countrycode(origin, 'cowc', 'iso3c', warn = FALSE, nomatch = c('a', 'b')))
})
