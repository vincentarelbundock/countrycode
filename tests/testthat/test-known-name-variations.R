context('Known country name variations')

source('data-known-name-variations.R')

test_that('correct matches are returned for known country name variations', {
  match_known <- function(known_variations) countrycode(known_variations, 'country.name', 'country.name')

  for (i in 1:length(variations)) {
    expect_match(match_known(variations[[i]]), names(variations)[i], all = T)
  }
})
