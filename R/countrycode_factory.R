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
  if(!is.null(origin)) formals(out)$origin <- origin
  if(!is.null(destination)) formals(out)$destination <- destination
  if(!is.null(warn)) formals(out)$warn <- warn
  if(!is.null(nomatch)) formals(out)$nomatch <- nomatch
  if(!is.null(custom_dict)) formals(out)$custom_dict <- custom_dict
  if (!is.null(custom_match)) formals(out)$custom_match <- custom_match

  # return function
  out

}
