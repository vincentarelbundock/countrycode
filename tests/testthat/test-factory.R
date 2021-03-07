test_that("new function: name_to_iso3c", {
  name_to_iso3c <- countrycode_factory(
      origin = "country.name", destination = "iso3c")
  expect_equal(c("DZA", "CAN"), name_to_iso3c(c("Algeria", "Canada")))
})


test_that("statecode", {
  # Download dictionary
  state_dict <- "https://raw.githubusercontent.com/vincentarelbundock/countrycode/main/data/custom_dictionaries/us_states.csv"
  state_dict <- read.csv(state_dict)

  # Identify regular expression origin codes
  attr(state_dict, "origin_regex") <- "state.regex"

  # Set default values for the custom conversion function
  statecode <- countrycode_factory(
    origin = "state.regex",
    destination = "abbreviation",
    custom_dict = state_dict)

  # Voilà!
  x <- c("Alabama", "New Mexico")
  expect_equal(c("AL", "NM"), statecode(x, "state.regex", "abbreviation"))

  x <- c("AL", "NM", "VT")
  expect_equal(c("Alabama", "New Mexico", "Vermont"),
               statecode(x, "abbreviation", "state"))

})
