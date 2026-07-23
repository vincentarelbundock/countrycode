test_that("vector of destination codes", {
  expect_warning(expect_equal(
    countrycode("Serbia", "country.name", "cowc"),
    NA_character_
  ))
  expect_warning(expect_equal(
    countrycode("Serbia", "country.name", c("cowc", "iso3c")),
    read_shared_fixture("conversions.yaml")$country.name$iso3c$Serbia
  ))
})
