#' Convert country codes
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
#' @keywords countrycode 
#' @note Supports the following coding schemes: Correlates of War character, 
#'   CoW-numeric, ISO3-character, ISO3-numeric, ISO2-character, IMF numeric, FIPS 10-4,
#'   FAO numeric, United Nations numeric, World Bank character, 
#'   official English short country names (ISO), continent, region. 
#' 
#'   The following strings can be used as arguments for \code{origin} or \code{destination}: 
#'   "cowc", "cown", "iso3c", "iso3n", "iso2c", "imf", "fips104", "fao", "un", "wb", "country.name". 
#'   The following strings can be used as arguments for \code{destination}
#'   \emph{only}:  "continent", "region"
#' @export
#' @aliases countrycode
#' @examples
#' codes.of.origin <- countrycode_data$cowc # Vector of values to be converted
#' countrycode(codes.of.origin, "cowc", "iso3c")
countrycode <- function (sourcevar, origin, destination, warn=FALSE){
    # Sanity check
    origin_codes<-c("cowc", "cown", "fips04", "imf", "iso2c", "iso3c", "iso3n", "fao", "un", "wb", "country.name")
    destination_codes<-c("region", "continent", "cowc", "cown", "fao", "fips04", "imf", 
                "iso2c", "iso3c", "iso3n", "un", "wb", "country.name")
    if (!origin %in% origin_codes){stop("Origin code not supported")}
    if (!destination %in% destination_codes){stop("Destination code not supported")}
    # Prepare output vector
    destination_vector <- rep(NA, length(sourcevar))
    # All but regex-based operations
    if (origin != "country.name"){
        matches <- match(sourcevar, countrycode_data[, origin])
        destination_vector <- countrycode_data[matches, destination]
    }else{
        # For each regex in the database -> find matches
        destination_list <- lapply(sourcevar, function(k) k)
        for (i in 1:nrow(countrycode_data)){
            matches <- grep(countrycode_data$regex[i], sourcevar, perl=TRUE, ignore.case=TRUE, value=FALSE)
            destination_vector[matches] <- countrycode_data[i, destination]
            # Warning-related
            destination_list[matches] <- lapply(destination_list[matches], function(k) c(k, countrycode_data[i, destination]))
        }
        destination_list <- destination_list[lapply(destination_list, length) > 2]
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

#' countrycode tests
#'
#' Runs a series of tests.
#' Returns TRUE if all tests passed.
#' Prints test description when some tests fail. 
#'
#' @keywords countrycode_test 
#' @aliases countrycode_test
countrycode_test <- function(){
    print("Don't worry about warning messages produced by this function. What matters is the TRUE outcome")
    test_result = TRUE
    # Missing values
    x = countrycode(c('BAD', 'BLA', 'CAN'), 'iso3c', 'country.name')
    if(!is.na(x[1]) | !is.na(x[2]) | x[3] != 'CANADA'){
       test_result = FALSE
       warning('Missing values test failed')
    }
    # Congo
    congos = c('republic of congo', 'republic of the congo', 'congo, republic of the', 'congo, republic', 
               'democratic republic of the congo', 'congo, democratic republic of the', 'dem rep of the congo', 
               'the democratic republic of congo')
    x = countrycode(congos, 'country.name', 'iso3c')
    if(!all(x == c(rep('COG',4), rep('COD',4)))){
        test_result = FALSE
        warning('Congo test failed')
    }
    # Does warn break conversion?
    x = countrycode(c('ALG', 'USA'), 'cowc', 'iso2c', warn=TRUE)
    y = countrycode(c('BLA', 'USA'), 'cowc', 'iso2c', warn=TRUE)
    if(!all(x == c('DZ','US')) & !all(y == c(NA, 'US'))){
        test_result = FALSE
        warning('nomatch test failed')
    }
    # Multiple regex matches
    x = countrycode(countrycode_data[,'country.name'], 'country.name', 'cowc', warn=TRUE)  
    return(test_result)
}

