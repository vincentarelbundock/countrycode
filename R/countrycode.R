#' Convert Country Codes
#'
#' Converts long country names into one of many different coding schemes.
#' Translates from one scheme to another. Converts country name or coding
#' scheme to the official short English country name. Creates a new variable
#' with the name of the continent or region to which each country belongs.
#'
#' @note
#' For a complete description of available country codes and languages,
#' please see the documentation for the [`codelist`][codelist] conversion
#' dictionary.
#'
#' Panel data (i.e., country-year) can pose particular problems when
#' converting codes. For instance, some countries like Vietnam or Serbia go
#' through political transitions that justify changing codes over time. This
#' can pose problems when using codes from organizations like CoW or Polity IV,
#' which produce codes in country-year format. Instead of converting codes
#' using `countrycode()`, we recommend that users use the
#' [`codelist_panel`][codelist_panel] data.frame as a base into which they can
#' merge their other data. This data.frame includes most relevant code, and is
#' already "reconciled" to ensure that each political unit is only represented
#' by one row in any given year. From there, it is just a matter of using [merge()]
#' to combine different datasets which use different codes.
#'
#' @param sourcevar Vector which contains the codes or country names to be
#'   converted (character or factor)
#' @param origin A string which identifies the coding scheme of origin (e.g., `"iso3c"`). See
#'   [`codelist`][codelist] for a list of available codes.
#' @param destination A string or vector of strings which identify the coding
#'   scheme of destination (e.g., `"iso3c"` or `c("cowc", "iso3c")`). See
#'   [`codelist`][codelist] for a list of available codes. When users supply a
#'   vector of destination codes, they are used sequentially to fill in
#'   missing values not covered by the previous destination code in the
#'   vector.
#' @param warn Prints unique elements from sourcevar for which no match was found
#' @param nomatch When countrycode fails to find a match for the code of
#'   origin, it fills-in the destination vector with `nomatch`. The default
#'   behavior is to fill non-matching codes with `NA`. If `nomatch = NULL`,
#'   countrycode tries to use the origin vector to fill-in missing values in the
#'   destination vector. `nomatch` must be either `NULL`, of length 1, or of the same
#'   length as `sourcevar`.
#' @param custom_dict A data frame which supplies a new dictionary to
#'   replace the built-in country code dictionary. Each column
#'   contains a different code and must include no duplicates. The
#'   data frame format should resemble [`codelist`][codelist]. Users
#'   can pre-assign attributes to this custom dictionary to affect
#'   behavior (see Examples section):
#'   \itemize{
#'   \item "origin.regex" attribute: a character vector with the names
#'     of columns containing regular expressions.
#'   \item "origin.valid" attribute: a character vector with the names
#'     of columns that are accepted as valid origin codes.
#'   }
#' @param custom_match A named vector which supplies custom origin and
#'   destination matches that will supercede any matching default result. The name
#'   of each element will be used as the origin code, and the value of each
#'   element will be used as the destination code.
#' @param origin_regex NULL or Logical: When using a custom
#'   dictionary, if TRUE then the origin codes will be matched as
#'   regex, if FALSE they will be matched exactly. When NULL,
#'   `countrycode` will behave as TRUE if the origin name is in the
#'   `custom_dictionary`'s `origin_regex` attribute, and FALSE
#'   otherwise. See examples section below.
#' @keywords countrycode
#' @export
#' @aliases countrycode
#' @examples
#' library(countrycode)
#'
#' # ISO to Correlates of War
#' countrycode(c('USA', 'DZA'), origin = 'iso3c', destination = 'cown')
#'
#' # English to ISO
#' countrycode('Albania', origin = 'country.name', destination = 'iso3c')
#'
#' # German to French
#' countrycode('Albanien', origin = 'country.name.de', destination = 'iso.name.fr')
#'
#' # Using custom_match to supercede default codes
#' countrycode(c('United States', 'Algeria'), 'country.name', 'iso3c')
#' countrycode(c('United States', 'Algeria'), 'country.name', 'iso3c',
#'             custom_match = c('Algeria' = 'ALG'))
#'
#' \dontrun{
#'  # Download the dictionary of US states from Github
#'  state_dict <- "https://bit.ly/2ToSrFv"
#'  state_dict <- read.csv(state_dict)
#' 
#'  # The "state.regex" column includes regular expressions, so we set an attribute.
#'  attr(state_dict, "origin_regex") <- "state.regex"
#
#'  countrycode(c('AL', 'AK'), 'abbreviation', 'state',
#'              custom_dict = state_dict)
#'  countrycode(c('Alabama', 'North Dakota'), 'state.regex', 'state',
#'              custom_dict = state_dict)
#' }
countrycode <- function(sourcevar, origin, destination, warn = TRUE, nomatch = NA,
                        custom_dict = NULL, custom_match = NULL, origin_regex = NULL) {

    # default dictionary
    if (is.null(custom_dict)) {
        dictionary <- countrycode::codelist
        attr(dictionary, "origin_valid") <- c(
            "cctld", "country.name", "country.name.de", "country.name.fr", "country.name.it",
            "cowc", "cown", "dhs", "ecb", "eurostat", "fao", "fips", "gaul",
            "genc2c", "genc3c", "genc3n", "gwc", "gwn", "imf", "ioc", "iso2c",
            "iso3c", "iso3n", "p5c", "p5n", "p4c", "p4n", "un", "un_m49", "unicode.symbol",
            "unhcr", "unpd", "vdem", "wb", "wb_api2c", "wb_api3c", "wvs",
            "country.name.en.regex", "country.name.de.regex", "country.name.fr.regex", "country.name.it.regex")
        attr(dictionary, "origin_regex") <- c("country.name.de.regex",
                                              "country.name.en.regex",
                                              "country.name.fr.regex",
                                              "country.name.it.regex")
    } else {
        dictionary <- custom_dict
    }

    # default country names (only for default dictionary)
    if (is.null(custom_dict)) { 
        if (origin == 'country.name') {
            origin <- 'country.name.en'
        }
        if (origin %in% c('country.name.en', 'country.name.de', 'country.name.it', 'country.name.fr')) {
            origin <- paste0(origin, '.regex')
        }
        destination[destination == "country.name"] <- 'country.name.en'
    }

    # dictionary attributes
    if (is.null(attr(dictionary, "origin_valid"))) {
        origin_valid <- colnames(dictionary)
    } else {
        origin_valid <- attr(dictionary, "origin_valid")
    }

    if (is.null(attr(dictionary, "destination_valid"))) {
        destination_valid <- colnames(dictionary)
    } else {
        destination_valid <- attr(dictionary, "destination_valid")
    }

    if (is.null(origin_regex)) { # user can override
        if (!is.null(attr(dictionary, "origin_regex"))) {
            origin_regex <- origin %in% attr(dictionary, "origin_regex")
        } else {
            origin_regex <- FALSE
        }
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
        stop('sourcevar must be a character or numeric vector. This error often arises when users pass a tibble (e.g., from dplyr) instead of a column vector from a data.frame (i.e., my_tbl[, 2] vs. my_df[, 2] vs. my_tbl[[2]]). This can also happen when `sourcevar` is entirely composed of `NA`, which `R` treats as entries of class logical.')
    }

    if (!is.null(nomatch) & (length(nomatch) != 1) & (length(nomatch) != length(sourcevar))) {
        stop('nomatch needs to be NULL, or of length 1 or ', length(sourcevar), '.')
    }

    if (!is.character(origin) ||
        length(origin) != 1 ||
        !origin %in% origin_valid) {
        stop(sprintf("The `origin` argument must be a string of length 1 equal to one of these values: %s.",
                     paste(origin_valid, collapse = ", ")))
    }

    if (!is.character(destination) ||
        !all(destination %in% destination_valid)) {
        stop("The `destination` argument must be a string or a vector of strings where each element is equal to one of the column names in the conversion directory (by default: `codelist`).")
    }

    if(!inherits(dictionary, "data.frame")) {
        stop("The `dictionary` argument must be a data frame or tibble with codes as columns.")
    }

    dups = any(duplicated(stats::na.omit(dictionary[, origin])))
    if(dups){
        stop("Countrycode cannot accept dictionaries with duplicated origin codes")
    }

    # Copy origin_vector for later re-use
    origin_vector <- sourcevar

    # Case-insensitive matching
    if(is.null(custom_dict)){ # only for built-in dictionary
        # unicode.symbol breaks uppercase on Windows R-devel 2022-02-02; rejected by CRAN
        if(inherits(origin_vector, 'character') & !grepl('country|unicode.symbol', origin)){
            origin_vector = toupper(origin_vector)
        }
    }

    out <- rep(NA, length(sourcevar))
    for (dest in destination) {
        out <- ifelse(is.na(out),
                      countrycode_convert(
                          ## user-supplied arguments
                          sourcevar = sourcevar,
                          origin = origin,
                          destination = dest,
                          warn = warn,
                          nomatch = nomatch,
                          custom_dict = custom_dict,
                          custom_match = custom_match,
                          origin_regex = origin_regex,
                          ## countrycode-supplied arguments
                          origin_vector = origin_vector,
                          dictionary = dictionary),
                      out)
    }
    return(out)
}
                        

#' internal function called by `countrycode()`
#'
#' @keywords internal
#' @noRd
countrycode_convert <- function(# user-supplied arguments
                                sourcevar,
                                origin,
                                destination,
                                warn,
                                nomatch,
                                custom_dict,
                                custom_match,
                                origin_regex,
                                # countrycode-supplied arguments
                                origin_vector,
                                dictionary
                                ) {


    # Convert
    if (origin_regex) { # regex codes
        dict <- stats::na.omit(dictionary[, c(origin, destination)])
        sourcefctr <- factor(origin_vector)

        # match levels of sourcefctr
        matches <-
          sapply(c(levels(sourcefctr), NA), function(x) { # add NA so there's at least one item
            x <- tryCatch(trimws(x), error = function(e) x) # sometimes an error is triggered by encoding issues
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

        # sanity check
        if (is.character(origin_vector) && is.numeric(dictionary[[origin]])) {
            msg <- sprintf("To convert a `%s` code, `sourcevar` must be numeric.", origin)
            stop(msg, call. = FALSE)
        }

        dict <- stats::na.omit(dictionary[, c(origin, destination)])

        sourcefctr <- factor(origin_vector)

        # match levels of sourcefctr
        if (identical(origin, "cctld")) {
          matchidxs <- match(levels(sourcefctr), toupper(dict[[origin]]))
        } else {
          matchidxs <- match(levels(sourcefctr), dict[[origin]])
        }
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
                    class. Filling-in bad matches with NA instead.", call. = FALSE)
        }
    } else if ((length(nomatch) == 1) & is.na(nomatch)) { # NA
    } else if ((length(nomatch) == 1) & sane_nomatch) { # single replacement
        destination_vector[idx] <- nomatch
    } else if ((length(nomatch) == length(sourcevar)) & sane_sourcevar) { # vector replacement
        destination_vector[idx] <- nomatch[idx]
    } else {
        warning("The argument `nomatch` must be NULL, NA, or of the same class
                as the destination vector. Filling-in bad matches with NA instead.", call. = FALSE)
    }

    # Warnings
    if(warn){
        badmatch <- sort(unique(origin_vector[is.na(destination_vector)]))
        badmatch <- badmatch[!badmatch %in% names(custom_match)]  # do not report <NA>'s that were set explicitly by custom_match
        if(length(badmatch) > 0){
            warning("Some values were not matched unambiguously: ", paste(badmatch, collapse=", "), "\n", call. = FALSE)
        }
        if(origin_regex){
           if(length(destination_list) > 0){
               destination_list <- lapply(destination_list, function(k) paste(k, collapse=','))
               destination_list <- sort(unique(do.call('c', destination_list)))
               warning("Some strings were matched more than once, and therefore set to <NA> in the result: ", paste(destination_list, collapse="; "), "\n", call. = FALSE)
           }
        }
    }
    return(destination_vector)
}
