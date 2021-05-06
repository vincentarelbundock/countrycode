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

})

test_that('input: character ', {

    x <- c('ジンバブエ', 'Afeganistãu',  'Barbadas', 'Sverige', 'UK',
           'il-Georgia tan-Nofsinhar u l-Gżejjer Sandwich tan-Nofsinhar')
    answers <- c("Zimbabwe", "Afghanistan", "Barbados", "Sweden", "UK", 
                 "South Georgia & South Sandwich Islands")
    expect_identical(countryname(x), answers)

})

test_that('input: factor vector', {

    x <- c('ジンバブエ', 'Afeganistãu',  'Barbadas', 'Sverige', 'UK',
           'il-Georgia tan-Nofsinhar u l-Gżejjer Sandwich tan-Nofsinhar')
    x <- factor(x)

    answers <- c("Zimbabwe", "Afghanistan", "Barbados", "Sweden", "UK", 
                 "South Georgia & South Sandwich Islands")
    expect_identical(countryname(x), answers)

})

test_that('input: tibble ', {

    library(tibble)
    x <- c('ジンバブエ', 'Afeganistãu',  'Barbadas', 'Sverige', 'UK',
           'il-Georgia tan-Nofsinhar u l-Gżejjer Sandwich tan-Nofsinhar')
    x <- tibble(x)

    answers <- c("Zimbabwe", "Afghanistan", "Barbados", "Sweden", "UK", 
                 "South Georgia & South Sandwich Islands")
    expect_identical(countryname(x$x), answers)

})
