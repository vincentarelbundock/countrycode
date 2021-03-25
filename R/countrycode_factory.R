#' Create new conversion functions with alternative dictionaries
#' and/or defaults arguments.
#'
#' This function can be used to set new default arguments for the
#' `countrycode` functions, or to create alternative functions using
#' your own conversion dictionary. The Examples section shows how to
#' use `countrycode_factory` to create a `statecode` function which
#' can be used to convert US states to abbreviations or long names.
#' 
#' @inheritParams countrycode
#' @examples
#' \dontrun{
#'  # Download the dictionary of US states from Github
#'  state_dict <- "https://raw.githubusercontent.com/vincentarelbundock/countrycode/main/data/custom_dictionaries/us_states.csv"
#'  state_dict <- read.csv(state_dict)
#' 
#'  # The "state.regex" column includes regular expressions, so we set an attribute.
#'  attr(state_dict, "origin_regex") <- "state.regex"
#'
#'  # Set default values for the custom conversion function
#'  statecode <- countrycode_factory(
#'    origin = "state.regex",
#'    destination = "abbreviation",
#'    custom_dict = state_dict)
#'
#'  # Voilà!
#'  x <- c("Alabama", "New Mexico")
#'  expect_equal(c("AL", "NM"), statecode(x, "state.regex", "abbreviation"))
#'
#'  x <- c("AL", "NM", "VT")
#'  expect_equal(c("Alabama", "New Mexico", "Vermont"),
#'               statecode(x, "abbreviation", "state"))
#'
#' }
#' @export
countrycode_factory <- function(
  origin = NULL,
  destination = NULL,
  warn = NULL,
  nomatch = NULL,
  custom_dict = NULL,
  custom_match = NULL) {

  # default function
  out = countrycode

  # change defaults
  for (name in names(formals())) {
    arg <- get(name)
    if (!is.null(arg)) {
      formals(out)[[name]] <- arg
    }
  }

  # return function
  out

}
