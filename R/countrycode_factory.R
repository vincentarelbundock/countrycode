#' create new `countrycode` functions with alternative dictionaries and
#' defaults
#' 
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
  args <- formals()

  for (name in names(args)) {
    if(!is.null(args[[name]])) {
        formals(out)[[name]] <- args[[name]]
    }
  }

  # return function
  out

}
