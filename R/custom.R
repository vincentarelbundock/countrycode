

#' Get Custom Dictionaries
#' 
#' Download a custom dictionary to use in the `custom_dict` argument of `countrycode()`
#'
#' @export
#' @param dictionary A character string that specifies the dictionary to be
#' retrieved. It must be one of "global_burden_of_disease", "ch_cantons",
#' "us_states", "exiobase3", "gtap10". If NULL, the function will print the list
#' of available dictionaries. Default is NULL.
#'
#' @return If a valid dictionary is specified, the function will return that dictionary as a data.frame.
#' If an invalid dictionary or no dictionary is specified, the function will stop and throw an error message.
#'
#' @examples
#' \dontrun{
#' cm <- get_dictionary("us_states")
#' countrycode::countrycode(sourcevar = "USA", origin = "iso2c", destination = "iso3c", custom_dict = cm)
#' }
get_dictionary <- function(dictionary = NULL) {
    valid <- sort(c("global_burden_of_disease", "ch_cantons", "us_states", "exiobase3", "gtap10"))
    if (is.null(dictionary)) {
        message(sprintf("Available dictionaries: %s", paste(valid, collapse = ", ")))
        return(invisible(NULL))
    }
    if (isTRUE(is.character(dictionary) && length(dictionary) == 1 && dictionary %in% valid)) {
        url <- sprintf("https://raw.githubusercontent.com/vincentarelbundock/countrycode/main/data/custom_dictionaries/%s.csv", dictionary)
        out <- readRDS(url)
        return(out)
    } else {
        stop("dictionary must be a character vector of length 1 and one of: ", paste(valid, collapse = ", "))
    }
}