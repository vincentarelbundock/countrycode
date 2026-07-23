context('Basic conversions')

basic_cases <- read_shared_fixture("conversions.yaml")$iso3c$country.name
cowc_iso2c_cases <- read_shared_fixture("conversions.yaml")$cowc$iso2c

test_that('valid iso3c vectors convert to country.name', {
  name_of <- function(iso3c_code) {
    countrycode(iso3c_code, 'iso3c', 'country.name')
  }
  source <- c('usa', 'CAN')
  expected <- unname(unlist(basic_cases[source]))
  expect_equal(name_of(source), expected)
})


test_that('invalid iso3c to country.name returns NA', {
  name_of <- function(iso3c_code) {
    countrycode(iso3c_code, 'iso3c', 'country.name', warn = FALSE)
  }
  expect_equal(
    name_of(c('BAD', 'BLA', 'CAN')),
    c(NA_character_, NA_character_, basic_cases$CAN)
  )
})

test_that('warn=TRUE gives warnings, but does not break conversion', {
  iso2c_of <- function(cowc_code) {
    countrycode(cowc_code, 'cowc', 'iso2c', warn = TRUE)
  }
  expect_warning(val <- iso2c_of('BLA'), 'not matched')
  expect_equal(val, NA_character_)
  expect_warning(val <- iso2c_of(c('ALG', 'USA')), NA)
  expect_equal(
    val,
    unname(unlist(cowc_iso2c_cases[c('ALG', 'USA')]))
  )
  expect_warning(val <- iso2c_of(c('BLA', 'USA')), 'not matched')
  expect_equal(val, c(NA_character_, cowc_iso2c_cases$USA))
})

test_that('warn=FALSE does not give warnings', {
  iso2c_of <- function(cowc_code) {
    countrycode(cowc_code, 'cowc', 'iso2c', warn = FALSE)
  }
  expect_warning(iso2c_of('BLA'), NA)
  expect_warning(iso2c_of(c('BLA', 'USA')), NA)
})


test_that("Issue #272", {
  expect_error(
    countrycode("2", "cown", "country.name"),
    regexp = "must be numeric"
  )
})
