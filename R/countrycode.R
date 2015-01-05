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
    # Exclude wikipedia based country names from acceptable origin codes
    ### names_to_exclude <- names(read.csv("data/wiki_names.csv"))[-1] # country.name NOT to exclude, that is why [-1]
    # had to split these in two to successfully create vectors
    names_to_exclude1 <- c("country.name.english", "country.name.achinese", "country.name.afrikaans", "country.name.albanian", "country.name.alemannisch", "country.name.amharic", "country.name.arabic", "country.name.aragonese", "country.name.aramaic", "country.name.armenian", "country.name.assamese", "country.name.asturian", "country.name.azerbaijani", "country.name.bashkir", "country.name.basque", "country.name.bavarian", "country.name.belarusian", "country.name.bengali", "country.name.bikol.central", "country.name.bishnupuriya.manipuri", "country.name.bosnian", "country.name.breton", "country.name.buginese", "country.name.bulgarian", "country.name.burmese", "country.name.cantonese", "country.name.catalan", "country.name.cebuano", "country.name.chavacano.de.zamboanga", "country.name.chechen", "country.name.chinese", "country.name.chinese.min.nan", "country.name.chuvash", "country.name.classical.chinese", "country.name.colognian", "country.name.cornish", "country.name.corsican", "country.name.crimean.turkish", "country.name.croatian", "country.name.czech", "country.name.danish", "country.name.divehi", "country.name.dutch", "country.name.dzongkha", "country.name.eastern.mari", "country.name.egyptian.spoken.arabic", "country.name.english.wikipedia", "country.name.esperanto", "country.name.estonian", "country.name.extremaduran", "country.name.faroese", "country.name.fiji.hindi", "country.name.finnish", "country.name.franco-provençal", "country.name.french", "country.name.friulian", "country.name.gagauz", "country.name.galician", "country.name.georgian", "country.name.german", "country.name.gothic", "country.name.greek", "country.name.guarani", "country.name.gujarati", "country.name.haitian", "country.name.hakka", "country.name.hausa", "country.name.hawaiian", "country.name.hebrew", "country.name.hindi", "country.name.hungarian", "country.name.icelandic", "country.name.ido", "country.name.iloko", "country.name.indonesian", "country.name.interlingua", "country.name.interlingue", "country.name.irish", "country.name.italian", "country.name.japanese", "country.name.javanese", "country.name.kabardian", "country.name.kabyle", "country.name.kalaallisut", "country.name.kalmyk", "country.name.kannada", "country.name.karachay-balkar", "country.name.kara-kalpak", "country.name.kashubian", "country.name.kazakh", "country.name.khmer", "country.name.kikuyu", "country.name.kinyarwanda", "country.name.komi", "country.name.korean", "country.name.kurdish", "country.name.kyrgyz", "country.name.latin", "country.name.latvian", "country.name.lezghian")
    names_to_exclude2 <- c("country.name.ligurian", "country.name.limburgish", "country.name.lingala", "country.name.lithuanian", "country.name.lojban", "country.name.lombard", "country.name.lower.sorbian", "country.name.low.german", "country.name.low.saxon.netherlands", "country.name.luxembourgish", "country.name.macedonian", "country.name.malagasy", "country.name.malay", "country.name.malayalam", "country.name.maltese", "country.name.manx", "country.name.maori", "country.name.marathi", "country.name.minangkabau", "country.name.mingrelian", "country.name.mirandese", "country.name.moksha", "country.name.mongolian", "country.name.nāhuatl", "country.name.nauru", "country.name.nepali", "country.name.newari", "country.name.norfuk.pitkern", "country.name.northern.frisian", "country.name.northern.sami", "country.name.norwegian.bokmål", "country.name.norwegian.nynorsk", "country.name.novial", "country.name.occitan", "country.name.old.english", "country.name.oriya", "country.name.oromo", "country.name.ossetic", "country.name.pampanga", "country.name.pangasinan", "country.name.papiamento", "country.name.pashto", "country.name.pennsylvania.german", "country.name.persian", "country.name.piedmontese", "country.name.polish", "country.name.portuguese", "country.name.punjabi", "country.name.quechua", "country.name.romanian", "country.name.romansh", "country.name.russian", "country.name.rusyn", "country.name.sakha", "country.name.samogitian", "country.name.sanskrit", "country.name.saterland.frisian", "country.name.scots", "country.name.scottish.gaelic", "country.name.serbian", "country.name.serbo-croatian", "country.name.shona", "country.name.sicilian", "country.name.silesian", "country.name.simple.english", "country.name.sindhi", "country.name.sinhala", "country.name.slovak", "country.name.slovenian", "country.name.somali", "country.name.sorani.kurdish", "country.name.spanish", "country.name.sundanese", "country.name.swahili", "country.name.swati", "country.name.swedish", "country.name.tagalog", "country.name.tajik", "country.name.tamil", "country.name.tarandíne", "country.name.tatar", "country.name.telugu", "country.name.tetum", "country.name.thai", "country.name.tibetan", "country.name.turkish", "country.name.turkmen", "country.name.udmurt", "country.name.ukrainian", "country.name.upper.sorbian", "country.name.urdu", "country.name.uyghur", "country.name.uzbek", "country.name.venetian", "country.name.veps", "country.name.vietnamese", "country.name.volapük", "country.name.võro", "country.name.waray", "country.name.welsh", "country.name.western.frisian", "country.name.western.punjabi", "country.name.west.flemish", "country.name.wolof", "country.name.wu", "country.name.yiddish", "country.name.yoruba", "country.name.zazaki", "country.name.zeeuws", "country.name.zulu", "country.name.беларуская.тарашкевіца", "country.name.буряад", "country.name.молдовеняскэ", "country.name.भोजपुरी")
    origin_codes <- names(countrycode::countrycode_data)[!(names(countrycode::countrycode_data) %in% c("continent","region","regex",names_to_exclude1,names_to_exclude2))] 
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
