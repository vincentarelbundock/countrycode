#' Country Code Translation Data Frame
#'
#' A data frame with 273 observations on the following 23 variables.
#' Used internally by the \code{countrycode()} function.
#'
#' \itemize{
#'   \item country.name: Long country name
#'   \item cowc: Correlates of War character
#'   \item cown: Correlates of War numeric
#'   \item fao: Food and Agriculture Organization of the United Nations numerical code
#'   \item fips104: FIPS 10-4 (Federal Information Processing Standard)
#'   \item imf: International Monetary Fund
#'   \item iso2c: ISO-2 character
#'   \item iso3c: ISO-3 character
#'   \item iso2n: ISO-2 numeric
#'   \item iso3n: ISO-3 numeric
#'   \item un: United Nations numerical code
#'   \item wb: World Bank (very similar but not identical to iso3c)
#'   \item ioc: International Olympic Committee
#'   \item regex: Regular expression used to convert long names to code
#'   \item region: Regions as defined in the World Bank Development Indicators
#'   \item continent: Continent as defined in the World Bank Development Indicators
#'   \item eu28: Memberstates of the European Union (as of December 2015),
#'              without special territories
#'   \item ar5: IPCC's regional mapping used both in the Fifth Assessment Report
#'             (AR5) and for the Reference Concentration Pathways (RCP)
#'   \item un_name_en: official UN country name (English)
#'   \item un_name_fr: official UN country name (French)
#'   \item un_name_es: official UN country name (Spanish)
#'   \item un_name_ru: official UN country name (Russian)
#'   \item un_name_zh: official UN country name (Chinese)
#'   \item un_name_ar: official UN country name (Arabic)
#' }
#'
#' @note{
#' To produce consistent conversion, some entries had to be removed from the
#' conversion data frame. For example, the Correlates of War include 4 different
#' codes to represent Western Germany. "countrycode" uses only one of them (CoW
#' code 260 for all years). Similar choices were made in the cases of Korea,
#' Yemen, Congo and Vietnam. Also, Namibia's iso2c code ("NA") can be understood
#' as a missing observation (\code{NA}) by R.
#'
#' Capitalized country names refer to the official short English names, as defined
#' by the ISO organization. ISO does not publish official short English names for
#' countries whose name is not capitalized in the the country.name vector. Continent
#' and region information was taken from the UN website.
#'
#' This is a (possibly incomplete) list of countries and codes that were dropped:
#'
#' \itemize{
#'   \item KOREA, REPUBLIC OF: cown 731 730, cowc PRK KOR
#'   \item YEMEN: cown 680 678, cowc YAR YPR
#'   \item GERMANY: cown 267 260 245, cowc BAV GFR BAD
#'   \item CONGO: cown 490, cowc 484
#'   \item VIET NAM: cown 816, cowc DRV
#' }
#'
#' Official UN country names are taken directly from the UN website and conform
#' to the UNGEGN list of country names produced by its Working Group on Country
#' Names in August 2012 (see 'References'). Official UN country names exist for
#' 193 countries only.
#' }
#' @references{
#'   United Nations Group of Experts on Geographical Names (2012).
#'   \emph{UNGEGN List of Country Names}. Tenth United Nations Conference on
#'   the Standardization of Geographical Names. Ref. E/CONF.101/25.
#'   Available at \url{http://unstats.un.org/unsd/geoinfo/UNGEGN/wg1.html}.
#' }
#' @docType data
#' @keywords datasets
#' @name countrycode_data
#' @usage countrycode_data
#' @format A data frame with 273 rows and 23 columns
NULL

