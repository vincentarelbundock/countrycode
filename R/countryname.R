#' Convert country names in any language to another name or code
#'
#' Converts long country names in any language to one of many different country
#' code schemes or country names. `countryname` does 2 passes on the data.
#' First, it tries to detect variations of country names in many languages
#' extracted from the Unicode Common Locale Data Repository. Second, it applies
#' `countrycode`'s English regexes to try to match the remaining cases. Because
#' it does two passes, `countryname` can sometimes produce ambiguous results,
#' e.g., Saint Martin vs. Saint Martin (French Part). Users who need a "safer"
#' option can use: `countrycode(x, "country.name", "country.name")` Note that
#' the function works with non-ASCII characters. Please see the Github page for
#' examples.
#'
#' @param sourcevar Vector which contains the codes or country names to be
#' converted (character or factor)
#' @param destination Coding scheme of destination (string such as "iso3c"
#' enclosed in quotes ""): type `?codelist` for a list of
#' available codes.
#' @param warn Prints unique elements from sourcevar for which no match was found
#'
#' @export
#' @aliases countryname
#' @examples
#' \dontrun{
#' x <- c('Afaganisitani', 'Barbadas', 'Sverige', 'UK')
#' countryname(x)
#' countryname(x, destination = 'iso3c')
#' }
#'
countryname <- function(sourcevar, destination = 'cldr.short.en', warn = TRUE) {
    
    out <- countrycode(sourcevar = sourcevar,
                       origin = 'country.name.alt',
                       destination = 'country.name.en',
                       custom_dict = countrycode::countryname_dict,
                       warn = FALSE)
    
    idx <- is.na(out)
    out[idx] <- countrycode(sourcevar = sourcevar[idx], 
                            origin = 'country.name.en', 
                            destination = 'country.name.en', 
                            warn = warn)
    
    if (destination != 'country.name.en') {
      # Issue 309: in the second pass we can use the origin vector for NAs, but only if origin and destination are of the same type.
      if (identical(class(out), class(countrycode::codelist[[destination]]))) {
          nm <- NULL
      } else {
          nm <- NA
      }
      out <- countrycode(sourcevar = out,
                         origin = 'country.name.en', 
                         destination = destination,
                         custom_dict = countrycode::codelist, 
                         nomatch = nm,
                         warn = warn)
    }
    
    return(out)
}

