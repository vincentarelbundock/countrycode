question <- c("Aroba", "Canuda")
answer <- c("Aruba", "Canada")

test_that("no attributes", {

  dict <- data.frame(
    a = c("ar.ba", "can.da"),
    b = c("Aruba", "Canada"))

  expect_warning(expect_equal(
    c(NA_character_, NA_character_),
    countrycode(question, "a", "b", custom_dict = dict, origin_regex = FALSE)))

  expect_warning(expect_equal(
    c(NA_character_, NA_character_),
    countrycode(question, "a", "b", custom_dict = dict, origin_regex = NULL)))

  expect_equal(
    answer,
    countrycode(question, "a", "b", custom_dict = dict, origin_regex = TRUE))
})

test_that("origin_regex attribute", {
  dict <- data.frame(
    a = c("ar.ba", "can.da"),
    b = c("Aruba", "Canada"))
  attr(dict, "origin_regex") <- "a"

  expect_equal(
    answer,
    countrycode(question, "a", "b", custom_dict = dict, origin_regex = NULL))

  expect_equal(
    answer,
    countrycode(question, "a", "b", custom_dict = dict))
})

test_that("origin_valid attribute", {
  dict <- data.frame(
    a = c("ar.ba", "can.da"),
    b = c("Aruba", "Canada"))
  attr(dict, "origin_valid") <- "a"
  attr(dict, "origin_regex") <- "a"
  expect_equal(
    answer,
    countrycode(question, "a", "b", custom_dict = dict))
  expect_error(countrycode(question, "b", "a", custom_dict = dict),
               regexp = "origin")
})
