#' Convert country codes
#'
#' Converts long country names into one of seven different coding schemes.
#' Translates from one scheme to another. Converts country name or coding
#' scheme to the official short English country name. Creates a new variable
#' with the name of the continent or region to which each country belongs. 
#'
#' @param sourcevar Vector which contains the codes or country names to be converted
#' @param origin Coding scheme of origin (name enclosed in quotes "")
#' @param destination Coding scheme of destination (name enclosed in quotes "")
#' @param nomatch Prints unique elements from sourcevar for which no match was found
#' @keywords countrycode 
#' @note Supports the following coding schemes: Correlates of War character, 
#'   CoW-numeric, ISO3-character, ISO3-numeric, ISO2-character, IMF, FIPS 10-4, 
#'   official English short country names (ISO), continent, region. 
#' 
#'   The following strings can be used as arguments for \code{origin} or \code{destination}: 
#'   "cowc", "cown", "iso3c", "iso3n", "iso2c", "imf", "fips104", "country.name". 
#'   The following strings can be used as arguments for \code{destination}
#'   \emph{only}:  "continent", "region"
#' @export
#' @aliases countrycode
#' @examples
#' codes.of.origin <- countrycode_data$cowc # Vector of values to be converted
#' countrycode(codes.of.origin, "cowc", "iso3c")
countrycode <- function (sourcevar, origin, destination, nomatch=FALSE){
    o_codes<-c("cowc", "cown", "fips04", "imf", "iso2c", "iso3c", "iso3n", "country.name")
    d_codes<-c("region", "continent", "cowc", "cown", "fips04", "imf", 
                "iso2c", "iso3c", "iso3n", "country.name")
    if (!origin %in% o_codes){stop("Origin code not supported")}
    if (!destination %in% d_codes){stop("Destination code not supported")}
    if (origin != "country.name"){
        matches <- match(sourcevar, countrycode_data[, origin])
        destination.vector <- countrycode_data[matches, destination]
        destination.vector[is.na(sourcevar) == TRUE] <- NA
    }else{
        # Prepare destination.vector
        destination.vector <- rep(NA, length(sourcevar))
        # For each regex in the database -> find matches
        for (i in 1:nrow(countrycode_data)){
            Origin_code <- countrycode_data$regex[i]
            Destination_code <- countrycode_data[i, destination]
            matches <- as.vector(grep(Origin_code, as.vector(sourcevar), perl = TRUE, 
                                      ignore.case = TRUE, value = FALSE))
            # For each match -> replace in target vector
            for (j in matches) {
                destination.vector[j] <- Destination_code
            }
        }
    }
    if(nomatch){
        badmatch <- unique(sourcevar[is.na(destination.vector)])
        if(length(badmatch) > 0){
            warning("Some values were not matched: ", paste(badmatch, collapse=", "), "\n")
        }
    }
    return(destination.vector)
}

#' countrycode unit test
#'
#' Runs a series of tests.
#' Returns TRUE if all tests passed.
#' Prints test description when some tests fail. 
#'
#' @keywords countrycode_test 
#' @export
#' @aliases countrycode_test
#' @author Vincent Arel-Bundock \email{varel@@umich.edu}
#' @examples
#' countrycode_test()
countrycode_test <- function(){
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
    # Does nomatch break conversion?
    x = suppressWarnings(countrycode(c('ALG', 'USA'), 'cowc', 'iso2c', nomatch=TRUE))
    y = suppressWarnings(countrycode(c('BLA', 'USA'), 'cowc', 'iso2c', nomatch=TRUE))
    if(!all(x == c('DZ','US')) & !all(y == c(NA, 'US'))){
        test_result = FALSE
        warning('nomatch test failed')
    }
    return(test_result)
}

