#' Get Custom Dictionaries
#' 
#' Download a custom dictionary to use in the `custom_dict` argument of `countrycode()`
#'
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
#' cd <- get_dictionary("us_states")
#' countrycode::countrycode(c("MO", "MN"), origin = "state.abb", "state.name", custom_dict = cd)
#' }
#' @export
get_dictionary <- function(dictionary = NULL) {
    valid <- sort(c("global_burden_of_disease", "ch_cantons", "us_states", "exiobase3", "gtap10"))
    if (is.null(dictionary)) {
        message(sprintf("Available dictionaries: %s", paste(valid, collapse = ", ")))
        return(invisible(NULL))
    }
    if (isTRUE(is.character(dictionary) && length(dictionary) == 1 && dictionary %in% valid)) {
        url <- sprintf("https://github.com/vincentarelbundock/countrycode/raw/main/data/custom_dictionaries/data_%s.rds", dictionary)
        tmp <- tempfile()
        utils::download.file(url, tmp)
        out <- readRDS(tmp)
        unlink(tmp)
        return(out)
    } else {
        stop("dictionary must be a character vector of length 1 and one of: ", paste(valid, collapse = ", "))
    }
}
