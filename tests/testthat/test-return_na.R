context('return_na allows passthrough of unmatched codes')

na_true <- function(name) countrycode(name, 'cowc', 'iso3c', warn = FALSE, return_na = TRUE)
na_false <- function(name) countrycode(name, 'cowc', 'iso3c', warn = FALSE, return_na = FALSE)
na_warn <- function(name) countrycode(name, 'cowc', 'iso3n', warn = FALSE, return_na = FALSE)
origin <- c('ALG', 'AUH', 'BAD')
test_that('return_na argument works correctly', {
    testthat::expect_equal(na_true(origin), c('DZA', NA, NA))
    testthat::expect_equal(na_false(origin), c('DZA', 'AUH', 'BAD'))
    testthat::expect_warning(na_warn(origin))
})
