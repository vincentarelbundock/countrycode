context('Known country name variations')

library(utf8)

source('data-known-name-variations.R')

test_that('correct matches are returned for known country name variations', {
  name_of <- function(known_variations) {
      countrycode(known_variations, 'country.name', 'country.name', warn=FALSE)
  }
  for (i in seq_along(variations)) {
      for (j in seq_along(variations[[i]])) {
          expect_identical(utf8_format(names(variations)[i]), 
                           name_of(variations[[i]][j]))
      }
  }
})
