#' Convert Country Codes
#'
#' Converts long country names into one of many different coding schemes.
#' Translates from one scheme to another. Converts country name or coding
#' scheme to the official short English country name. Creates a new variable
#' with the name of the continent or region to which each country belongs.
#'
#' @param sourcevar Vector which contains the codes or country names to be
#' converted (character or factor)
#' @param origin Coding scheme of origin (string enclosed in quotes ""):
#' "cowc", "cown", "eurostat", "fao", "fips105", "imf", "ioc", "iso2c", "iso3c",
#' "iso3n", "p4_ccode", "p4_scode", "un", "wb", "wb_api2c", "wb_api3c", "wvs",
#' "country.name", "country.name.de".
#' @param destination Coding scheme of destination (string enclosed in quotes ""):
#' "ar5", "continent", "cowc", "cown", "eurostat", "eu28", "eurocontrol_pru",
#' "eurocontrol_statfor", "fao", "fips105", "icao", "icao_region", "imf",
#' "ioc", "iso2c", "iso3c", "iso3n", "p4_ccode", "p4_scode", "region", "un",
#' "wb", "wb_api2c", "wb_api3c", "wvs", "country.name", "country.name.ar",
#' "country.name.de", "country.name.en", "country.name.es", "country.name.fr",
#' "country.name.ru", "country.name.zh".
#' @param warn Prints unique elements from sourcevar for which no match was found
#' @param return_na When countrycode fails to find a match for the code of
#' origin, it returns NA (return_na = TRUE) or the origin code (return_na =
#' FALSE).
#' @param custom_dict A data frame which supplies custom country codes.
#' Variables correspond to country codes, observations must refer to unique
#' countries.  When countrycode uses a user-supplied dictionary, no sanity
#' checks are conducted. The data frame format must resemble
#' countrycode::countrycode_data.
#' @param custom_match A named vector which supplies custom origin and
#' destination matches that will supercede any matching default result. The name
#' of each element will be used as the origin code, and the value of each
#' element will be used as the destination code.
#' @param origin_regex Logical: When using a custom dictionary, if TRUE then the
#' origin codes will be matched as regex, if FALSE they will be matched exactly.
#' When using the default dictionary (dictionary = NULL), origin_regex will be ignored.
#' @keywords countrycode
#' @note For a complete description of available country codes and languages,
#' please read the documentation for the \code{countrycode_data} conversion
#' dictionary.  Type: \code{?countrycode_data}.
#' @export
#' @aliases countrycode
#' @examples
#' # ISO to Correlates of War
#' countrycode(c('USA', 'DZA'), 'iso3c', 'cown')
#' # English to ISO
#' countrycode('Albania', 'country.name', 'iso3c')
#' # German to French
#' countrycode('Albanien', 'country.name.de', 'country.name.fr')
countrycode <- function(sourcevar, origin, destination, warn = TRUE, return_na = TRUE,
                        custom_dict = NULL, custom_match = NULL, origin_regex = FALSE) {

    # Regex naming scheme
    if (is.null(custom_dict)) { # only for default dictionary
        # English regex is default
        if (origin == 'country.name') {
            origin <- 'country.name.en'
        }
        if (destination == 'country.name') {
            destination <- 'country.name.en'
        }
        # .regex extension in dictionary colnames
        if (origin %in% c('country.name.en', 'country.name.de')) {
            origin <- paste0(origin, '.regex')
            origin_regex <- TRUE
        } else {
            origin_regex <- FALSE
        }
    }

    # Set conversion dictionary
    if (!is.null(custom_dict)) {
        dictionary <- custom_dict
        valid_origin <- colnames(dictionary)
        valid_destination <- colnames(dictionary)
    } else {
        dictionary = countrycode::countrycode_data
        # Modify this manually when adding codes
        valid_origin = c("cowc", "cown", "fao", "fips105", "imf", "ioc",
                         "iso2c", "iso3c", "iso3n", "p4_ccode", "p4_scode",
                         "un", "wb", "wb_api2c", "wb_api3c", "wvs",
                         "country.name.en.regex", "country.name.de.regex")
        valid_destination <- colnames(dictionary)
    }

    # Allow tibbles as conversion dictionary
    if('tbl_df' %in% class(dictionary)){ # allow tibble
        dictionary <- as.data.frame(dictionary)
    }

    # Sanity checks
    if (missing(sourcevar)) {
        stop('sourcevar is NULL (does not exist).')
    }

    if (!mode(sourcevar) %in% c('character', 'numeric')) {
        stop('sourcevar must be a character or numeric vector. This error often
             arises when users pass a tibble (e.g., from dplyr) instead of a
             column vector from a data.frame (i.e., my_tbl[, 2] vs. my_df[, 2]
                                              vs. my_tbl[[2]])')
    }

    if (!origin %in% valid_origin) {
        stop('Origin code not supported by countrycode or present in the user-supplied custom_dict.')
    }

    if (!destination %in% valid_destination) {
        stop('Destination code not supported by countrycode or present in the user-supplied custom_dict.')
    }

    if(class(dictionary) != 'data.frame'){
        stop("Dictionary must be a data frame or tibble with codes as columns.")
    }

    if(!destination %in% colnames(dictionary)){
        stop("Destination code must correpond to a column name in the dictionary data frame.")
    }

    dups = any(duplicated(stats::na.omit(dictionary[, origin])))
    if(dups){
        stop("Countrycode cannot accept dictionaries with duplicated origin codes")
    }

    # Copy origin_vector for later re-use
    origin_vector <- sourcevar 

    # Case-insensitive matching 
    if(is.null(custom_dict)){ # only for built-in dictionary
        if((class(origin_vector) == 'character') & !grepl('country', origin)){
            origin_vector = toupper(origin_vector)
        }
    }

    # Convert
    if (origin_regex) { # regex codes
        dict <- stats::na.omit(dictionary[, c(origin, destination)])
        sourcefctr <- factor(origin_vector)

        # match levels of sourcefctr
        matches <-
          sapply(c(levels(sourcefctr), NA), function(x) { # add NA so there's at least one item
            matchidx <- sapply(dict[[origin]], function(y) grepl(y, x, perl = TRUE, ignore.case = TRUE))
            dict[matchidx, destination]
          })

        # fill elements that have zero matches with the appropriate NA
        matches[sapply(matches, length) == 0] <- `class<-`(NA, class(dict[[destination]]))

        # create destination_list with elements that have more than one match
        destination_list <- matches[sapply(matches, length) > 1]

        # add origin_vector value to beginning of match results to replicate previous behavior
        destination_list <- Map(c, names(destination_list), destination_list)

        # set elements with multiple matches to the appropriate NA
        matches[sapply(matches, length) > 1] <- `class<-`(NA, class(dict[[destination]]))

        # remove all but last match to replicate previous behavior
        matches <- sapply(matches, function(x) { x[length(x)] })

        # replace with custom matches if set
        if (!is.null(custom_match)) {
          matchidxs <- match(names(matches), names(custom_match))
          cust_matched <- !is.na(matchidxs)
          matches[cust_matched] <- custom_match[matchidxs][cust_matched]
        }

        # apply new levels to sourcefctr and unname
        destination_vector <- unname(matches[as.numeric(sourcefctr)])

    } else { # non-regex codes
        dict <- stats::na.omit(dictionary[, c(origin, destination)])
        sourcefctr <- factor(origin_vector)

        # match levels of sourcefctr
        matchidxs <- match(levels(sourcefctr), dict[[origin]])
        matches <- dict[[destination]][matchidxs]

        # replace with custom matches if set
        if (!is.null(custom_match)) {
          matchidxs <- match(levels(sourcefctr), names(custom_match))
          cust_matched <- !is.na(matchidxs)
          matches[cust_matched] <- custom_match[matchidxs][cust_matched]
        }

        # apply new levels to sourcefctr
        destination_vector <- matches[as.numeric(sourcefctr)]
    }

    # Replace NA with origin code if return_na = FALSE and classes match
    if (return_na == FALSE) {
        if (class(destination_vector)[1] == class(origin_vector)[1]) {
            idx <- is.na(destination_vector)
            destination_vector[idx] <- origin_vector[idx]
        } else {
            warning("The argument `return_na` cannot equal TRUE when the origin and destination vectors are of different classes (e.g., character vs. numeric)")
        }
    }

    # Warnings
    if(warn){
        nomatch <- sort(unique(origin_vector[is.na(destination_vector)]))
        nomatch <- nomatch[!nomatch %in% names(custom_match)]  # do not report <NA>'s that were set explicitly by custom_match
        if(length(nomatch) > 0){
            warning("Some values were not matched unambiguously: ", paste(nomatch, collapse=", "), "\n")
        }
        if(origin_regex){
           if(length(destination_list) > 0){
               destination_list <- lapply(destination_list, function(k) paste(k, collapse=','))
               destination_list <- sort(unique(do.call('c', destination_list)))
               warning("Some strings were matched more than once, and therefore set to <NA> in the result: ", paste(destination_list, collapse="; "), "\n")
           }
        }
    }
    return(destination_vector)
}
