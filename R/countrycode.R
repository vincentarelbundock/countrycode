# Convert Country Codes
#'
#' Converts long country names into one of many different coding schemes.
#' Translates from one scheme to another. Converts country name or coding
#' scheme to the official short English country name. Creates a new variable
#' with the name of the continent or region to which each country belongs.
#'
#' @param sourcevar Vector which contains the codes or country names to be
#' converted (character or factor)
#' @param origin Coding scheme of origin (string such as "iso3c" enclosed in
#' quotes ""): type "?codelist" for a list of available codes.
#' @param destination Coding scheme of destination (string such as "iso3c"
#' enclosed in quotes ""): type `?codelist` for a list of
#' available codes.
#' @param warn Prints unique elements from sourcevar for which no match was found
#' @param nomatch When countrycode fails to find a match for the code of
#' origin, it fills-in the destination vector with nomatch. The default
#' behavior is to fill non-matching codes with NA. If nomatch = NULL,
#' countrycode tries to use the origin vector to fill-in missing values in the
#' destination vector. nomatch must be either NULL, of length 1, or of the same
#' length as sourcevar.
#' @param custom_dict A data frame which supplies custom country codes.
#' Variables correspond to country codes, observations must refer to unique
#' countries.  When countrycode uses a user-supplied dictionary, no sanity
#' checks are conducted. The data frame format must resemble
#' countrycode::codelist.
#' @param custom_match A named vector which supplies custom origin and
#' destination matches that will supercede any matching default result. The name
#' of each element will be used as the origin code, and the value of each
#' element will be used as the destination code.
#' @param origin_regex Logical: When using a custom dictionary, if TRUE then the
#' origin codes will be matched as regex, if FALSE they will be matched exactly.
#' When using the default dictionary (dictionary = NULL), origin_regex will be ignored.
#' @keywords countrycode
#' @note For a complete description of available country codes and languages,
#' please read the documentation for the \code{codelist} conversion
#' dictionary.  Type: \code{?codelist}.
#' @note Panel data (i.e., country-year) can pose particular problems when
#' converting codes. For instance, some countries like Vietnam or Serbia go
#' through political transitions that justify changing codes over time. This
#' can pose problems when using codes from organizations like CoW or Polity IV,
#' which produce codes in country-year format. Instead of converting codes
#' using the `countrycode` function, we recommend that users use the
#' ``countrycode::codelist_panel`` data.frame as a base into which they can
#' merge their other data. This data.frame includes most relevant code, and is
#' already "reconciled" to ensure that each political unit is only represented
#' by one row in any given year. From there, it is just a matter of using `R`'s
#' `merge` function to combine different datasets which use different codes.
#'
#' @export
#' @aliases countrycode
#' @examples
#' # ISO to Correlates of War
#' countrycode(c('USA', 'DZA'), 'iso3c', 'cown')
#' # English to ISO
#' countrycode('Albania', 'country.name', 'iso3c')
#' # German to French
#' countrycode('Albanien', 'country.name.de', 'iso.name.fr')
countrycode <- function(sourcevar, origin, destination, warn = TRUE, nomatch = NA,
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
        dictionary = countrycode::codelist
        # Modify this manually when adding codes
        valid_origin = c("country.name", "country.name.de", "cowc", "cown",
                         "ecb", "eurostat", "fao", "fips", "gaul", "genc2c",
                         "genc3c", "genc3n", "gwc", "gwn", "imf", "ioc", "iso2c", "iso3c",
                         "iso3n", "p4c", "p4nj", "un", "un_m49", "unpd",
                         "vdem", "wb", "wb_api2c", "wb_api3c", "wvs",
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

    if (!is.null(nomatch) & (length(nomatch) != 1) & (length(nomatch) != length(sourcevar))) {
        stop('nomatch needs to be NULL, or of length 1 or ', length(sourcevar), '.')
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

    # Filling-in failed matches
    sane_sourcevar <- class(sourcevar)[1] == class(destination_vector)[1]
    sane_nomatch <- class(nomatch)[1] == class(destination_vector)[1]
    idx <- is.na(destination_vector)
    if (is.null(nomatch)) {
        if (sane_sourcevar) {
            destination_vector[idx] <- sourcevar[idx]
        } else if (class(sourcevar)[1] == "factor" & class(destination_vector)[1] == "character") {
            destination_vector[idx] <- as.character(sourcevar[idx])
        } else {
            warning("The origin and destination codes are not of the same
                    class. Filling-in bad matches with NA instead.")
        }
    } else if ((length(nomatch) == 1) & is.na(nomatch)) { # NA
    } else if ((length(nomatch) == 1) & sane_nomatch) { # single replacement
        destination_vector[idx] <- nomatch
    } else if ((length(nomatch) == length(sourcevar)) & sane_sourcevar) { # vector replacement
        destination_vector[idx] <- nomatch[idx]
    } else {
        warning("The argument `nomatch` must be NULL, NA, or of the same class
                as the destination vector. Filling-in bad matches with NA instead.")
    }

    # Warnings
    if(warn){
        badmatch <- sort(unique(origin_vector[is.na(destination_vector)]))
        badmatch <- badmatch[!badmatch %in% names(custom_match)]  # do not report <NA>'s that were set explicitly by custom_match
        if(length(badmatch) > 0){
            warning("Some values were not matched unambiguously: ", paste(badmatch, collapse=", "), "\n")
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
