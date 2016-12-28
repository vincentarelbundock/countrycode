#' Convert Country Codes
#'
#' Converts long country names into one of many different coding schemes.
#' Translates from one scheme to another. Converts country name or coding
#' scheme to the official short English country name. Creates a new variable
#' with the name of the continent or region to which each country belongs.
#'
#' @param sourcevar Vector which contains the codes or country names to be converted
#' @param origin Coding scheme of origin (name enclosed in quotes "")
#' @param destination Coding scheme of destination (name enclosed in quotes "")
#' @param warn Prints unique elements from sourcevar for which no match was found
#' @param dictionary A data frame which supplies custom country codes.
#' Variables correspond to country codes, observations must refer to unique
#' countries.  When countrycode uses a user-supplied dictionary, no sanity
#' checks are conducted. The data frame format must resemble
#' countrycode::countrycode_data. Custom dictionaries only work with strings
#' (no regexes).
#' @param origin_regex Logical: When using a custom dictionary, if TRUE then the
#' origin codes will be matched as regex, if FALSE they will be matched exactly.
#' When using the default dictionary (dictionary = NULL), origin_regex will be ignored.
#' @keywords countrycode
#' @note Supports the following coding schemes: Correlates of War character,
#'   CoW-numeric, ISO3-character, ISO3-numeric, ISO2-character, IMF numeric, International
#'   Olympic Committee, FIPS 10-4, FAO numeric, United Nations numeric,
#'   World Bank character, official English short country names (ISO), continent, region.
#'
#'   The following strings can be used as arguments for \code{origin} or
#'   \code{destination}: "cowc", "cown", "iso3c", "iso3n", "iso2c", "imf",
#'   "fips104", "fao", "ioc", "un", "wb", "country.name".  The following strings can be
#'   used as arguments for \code{destination} \emph{only}:  "continent", "region",
#'   "eu28", "ar5"
#' @export
#' @aliases countrycode
#' @examples
#' codes.of.origin <- countrycode::countrycode_data$cowc # Vector of values to be converted
#' countrycode(codes.of.origin, "cowc", "iso3c")
countrycode <- function (sourcevar, origin, destination, warn=FALSE, dictionary=NULL, origin_regex=FALSE){
    # auto-set origin_regex for regex origins in default dictionary
    default_regex_codes <- c('country.name', 'country.name.de')
    if (is.null(dictionary)) {
        if (origin %in% default_regex_codes) {
            origin <- paste0(origin, '.regex')
            origin_regex <- TRUE
        } else {
            origin_regex <- FALSE
        }
    }
    # Sanity check
    if(is.null(dictionary)){ # no sanity check if custom dictionary
        if(is.null(sourcevar)){
            stop("sourcevar is NULL (does not exist).", call. = FALSE)
        }
        codes = names(countrycode::countrycode_data)
        codes_origin = codes[!codes %in% c("continent","region","regex", "eu28", "ar5")]
        codes_destination = codes[!codes %in% c('regex')]
        if (!origin %in% codes_origin){
            stop("Origin code not supported")
        }
        if (!destination %in% codes_destination){
            stop("Destination code not supported")
        }
        dictionary = countrycode::countrycode_data
    }

    # Convert
    if (origin_regex) { # regex codes
        dict <- stats::na.omit(dictionary[, c(origin, destination)])
        sourcefctr <- factor(sourcevar)

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

        # add sourcevar value to beginning of match results to replicate previous behavior
        destination_list <- Map(c, names(destination_list), destination_list)

        # remove all but last match to replicate previous behavior
        matches <- sapply(matches, function(x) { x[length(x)] })

        # apply new levels to sourcefctr and unname
        destination_vector <- unname(matches[as.numeric(sourcefctr)])

    } else { # non-regex codes
        dict <- stats::na.omit(dictionary[, c(origin, destination)])
        sourcefctr <- factor(sourcevar)

        # match levels of sourcefctr
        matchidxs <- match(levels(sourcefctr), dict[[origin]])
        matches <- dict[[destination]][matchidxs]

        # apply new levels to sourcefctr
        destination_vector <- matches[as.numeric(sourcefctr)]
    }

    # Warnings
    if(warn){
        nomatch <- sort(unique(sourcevar[is.na(destination_vector)]))
        if(length(nomatch) > 0){
            warning("Some values were not matched: ", paste(nomatch, collapse=", "), "\n")
        }
        if(origin_regex){
           if(length(destination_list) > 0){
               destination_list <- lapply(destination_list, function(k) paste(k, collapse=','))
               destination_list <- sort(unique(do.call('c', destination_list)))
               warning("Some strings were matched more than once: ", paste(destination_list, collapse="; "), "\n")
           }
        }
    }
    return(destination_vector)
}
