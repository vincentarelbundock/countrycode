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
#' @keywords countrycode
#' @note Supports the following coding schemes: Correlates of War character,
#'   CoW-numeric, ISO3-character, ISO3-numeric, ISO2-character, IMF numeric, International
#'   Olympic Committee, FIPS 10-4, FAO numeric, United Nations numeric,
#'   World Bank character, official English short country names (ISO), continent, region.
#'
#'   The following strings can be used as arguments for \code{origin} or
#'   \code{destination}: "cowc", "cown", "iso3c", "iso3n", "iso2c", "imf",
#'   "fips104", "fao", "ioc", "un", "wb", "country.name".  The following strings can be
#'   used as arguments for \code{destination} \emph{only}:  "continent", "region"
#' @export
#' @aliases countrycode
#' @examples
#' codes.of.origin <- countrycode::countrycode_data$cowc # Vector of values to be converted
#' countrycode(codes.of.origin, "cowc", "iso3c")
countrycode <- function (sourcevar, origin, destination, warn=FALSE){
    # Sanity check
    origin_codes <- names(countrycode::countrycode_data)[!(names(countrycode::countrycode_data) %in% c("continent","region","regex"))] #,"country.name.english","country.name.afrikaans","country.name.albanian"))] #,"country.name.armenian","country.name.azeri","country.name.basque","country.name.belarusian","country.name.bengali","country.name.bosnian","country.name.breton","country.name.bulgarian","country.name.catalan","country.name.croatian","country.name.czech","country.name.danish","country.name.dari-persian","country.name.dutch","country.name.esperanto","country.name.estonian","country.name.faroese","country.name.finnish","country.name.french","country.name.galician","country.name.georgian and mengrelian","country.name.german","country.name.greek","country.name.gujarati","country.name.hebrew","country.name.hindi","country.name.hungarian","country.name.icelandic","country.name.indonesian","country.name.interlingua","country.name.inuktitut","country.name.irish","country.name.italian","country.name.japanese","country.name.latin","country.name.latvian","country.name.lithuanian","country.name.maltese","country.name.mandarin chinese","country.name.norwegian","country.name.pashtu","country.name.polish","country.name.portuguese","country.name.quechua","country.name.romanian","country.name.russian","country.name.sanskrit","country.name.scots gaelic","country.name.serbian","country.name.slovak","country.name.slovene","country.name.spanish","country.name.swedish","country.name.tamil","country.name.telugu","country.name.thai","country.name.turkish","country.name.ukrainian","country.name.urdu","country.name.vietnamese","country.name.võro","country.name.welsh"))]
    destination_codes <- names(countrycode::countrycode_data)[!(names(countrycode::countrycode_data) %in% c("regex"))]
    if (!origin %in% origin_codes){stop("Origin code not supported")}
    if (!destination %in% destination_codes){stop("Destination code not supported")}
    if (origin == 'country.name'){
        dict = na.omit(countrycode::countrycode_data[,c('regex', destination)])
    }else{
        dict = na.omit(countrycode::countrycode_data[,c(origin, destination)])
    }
    # Prepare output vector
    destination_vector <- rep(NA, length(sourcevar))
    # All but regex-based operations
    if (origin != "country.name"){
        matches <- match(sourcevar, dict[, origin])
        destination_vector <- dict[matches, destination]
    }else{
        # For each regex in the database -> find matches
        destination_list <- lapply(sourcevar, function(k) k)
        for (i in 1:nrow(dict)){
            matches <- grep(dict$regex[i], sourcevar, perl=TRUE, ignore.case=TRUE, value=FALSE)
            destination_vector[matches] <- dict[i, destination]
            # Warning-related
            destination_list[matches] <- lapply(destination_list[matches], function(k) c(k, dict[i, destination]))
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
