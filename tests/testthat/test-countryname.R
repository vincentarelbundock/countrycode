context('countryname function')

test_that('reported bugs', {
  expect_identical(countryname("Federated States of Micronesia"),
                   "Micronesia (Federated States of)")
})

test_that('output types', {
    expect_identical(countryname('ジンバブエ'), 'Zimbabwe')
    expect_identical(countryname('ジンバブエ', 'country.name.de'), 'Simbabwe')
    expect_identical(countryname('ジンバブエ', 'iso3c'), 'ZWE')
    expect_identical(countryname('ジンバブエ', 'cown'), 552)
    # issue 309: irrelevant warning with numeric destination
    expect_warning(countryname('ジンバブエ', 'cown'), NA)
})

test_that('input: character ', {

    x <- c('ジンバブエ', 'Afeganistãu',  'Barbadas', 'Sverige', 'UK',
           'il-Georgia tan-Nofsinhar u l-Gżejjer Sandwich tan-Nofsinhar')
    answers <- c("Zimbabwe", "Afghanistan", "Barbados", "Sweden", "United Kingdom", 
                 "South Georgia & South Sandwich Islands")
    expect_identical(countryname(x), answers)

})

test_that('input: factor vector', {

    x <- c('ジンバブエ', 'Afeganistãu',  'Barbadas', 'Sverige', 'United Kingdom',
           'il-Georgia tan-Nofsinhar u l-Gżejjer Sandwich tan-Nofsinhar')
    x <- factor(x)

    answers <- c("Zimbabwe", "Afghanistan", "Barbados", "Sweden", "United Kingdom", 
                 "South Georgia & South Sandwich Islands")
    expect_identical(countryname(x), answers)

})

test_that('input: tibble ', {

    library(tibble)
    x <- c('ジンバブエ', 'Afeganistãu',  'Barbadas', 'Sverige', 'UK',
           'il-Georgia tan-Nofsinhar u l-Gżejjer Sandwich tan-Nofsinhar')
    x <- tibble(x)

    answers <- c("Zimbabwe", "Afghanistan", "Barbados", "Sweden", "United Kingdom", 
                 "South Georgia & South Sandwich Islands")
    expect_identical(countryname(x$x), answers)

})


test_that("issue 336", {
    a <- countrycode("antarctica", origin = "country.name", destination = "cowc", warn = FALSE)
    expect_true(is.na(a))

    a <- countryname("antarctica", destination = "cowc", warn = FALSE)
    expect_true(is.na(a))

    a <- countryname("xyz", destination = "cowc", warn = FALSE)
    expect_true(is.na(a))

    x <- c("canada", "antarctica")
    expect_identical(countryname(x), c("Canada", "Antarctica"))
    expect_identical(countryname(x, destination = "cowc", warn = FALSE), c("CAN", NA))
    expect_identical(countryname(x, destination = "cowc", warn = FALSE, nomatch = x), c("CAN", "antarctica"))
})
