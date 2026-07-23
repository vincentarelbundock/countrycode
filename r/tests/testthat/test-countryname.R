context('countryname function')

countryname_cases <- read_shared_fixture("countryname.yaml")$country.name.en
countryname_sources <- names(countryname_cases)
countryname_expected <- unname(unlist(countryname_cases))
countryname_cowc_cases <- read_shared_fixture("countryname.yaml")$cowc

test_that('numeric output does not emit an irrelevant warning', {
  # issue 309: irrelevant warning with numeric destination
  source <- names(read_shared_fixture("countryname.yaml")$cown)[[1]]
  expect_warning(countryname(source, 'cown'), NA)
})

test_that('input: character ', {
  expect_identical(countryname(countryname_sources), countryname_expected)
})

test_that('input: factor vector', {
  expect_identical(
    countryname(factor(countryname_sources)),
    countryname_expected
  )
})

test_that('input: tibble ', {
  library(tibble)
  x <- tibble(x = countryname_sources)
  expect_identical(countryname(x$x), countryname_expected)
})


test_that("issue 336", {
  x <- c("canada", "antarctica")
  expect_identical(countryname(x), unname(unlist(countryname_cases[x])))
  expect_identical(
    countryname(x, destination = "cowc", warn = FALSE),
    c(countryname_cowc_cases$canada, NA)
  )
  expect_identical(
    countryname(x, destination = "cowc", warn = FALSE, nomatch = x),
    c(countryname_cowc_cases$canada, x[[2]])
  )
})
