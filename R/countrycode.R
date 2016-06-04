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
countrycode <- function (sourcevar, origin, destination, warn=FALSE, dictionary=NULL){
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
    destination_vector <- rep(NA, length(sourcevar))
    if (origin == 'country.name'){ # regex codes
        dict = na.omit(dictionary[,c('regex', destination)])
        # For each regex in the database -> find matches
        destination_list <- lapply(sourcevar, function(k) k)
        for (i in 1:nrow(dict)){
            matches <- grep(dict$regex[i], sourcevar, perl=TRUE, ignore.case=TRUE, value=FALSE)
            destination_vector[matches] <- dict[i, destination]
            # Warning-related
            destination_list[matches] <- lapply(destination_list[matches], function(k) c(k, dict[i, destination]))
        }
        destination_list <- destination_list[lapply(destination_list, length) > 2]
    }else{ # non-regex codes
        dict = na.omit(dictionary[, c(origin, destination)])
        matches <- match(sourcevar, dict[, origin])
        destination_vector <- dict[matches, destination]
    }

    # Warnings
    if(warn){
        nomatch <- sort(unique(sourcevar[is.na(destination_vector)]))
        if(length(nomatch) > 0){
            warning("Some values were not matched: ", paste(nomatch, collapse=", "), "\n")
        }
        if(origin=='country.name'){
           if(length(destination_list) > 0){
               destination_list <- lapply(destination_list, function(k) paste(k, collapse=','))
               destination_list <- sort(unique(do.call('c', destination_list)))
               warning("Some strings were matched more than once: ", paste(destination_list, collapse="; "), "\n")
           }
        }
    }
    return(destination_vector)
}
