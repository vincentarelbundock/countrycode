#' Country Code Translation Data Frame
#'
#' A data frame used internally by the \code{countrycode()} function.
#'
#' \itemize{
#'   \item ar5: IPCC's regional mapping used both in the Fifth Assessment Report
#'              (AR5) and for the Reference Concentration Pathways (RCP)
#'   \item continent: Continent as defined in the World Bank Development Indicators
#'   \item cowc: Correlates of War character
#'   \item cown: Correlates of War numeric
#'   \item eurocontrol_pru:  European Organisation for the Safety of Air Navigation
#'   \item eurocontrol_statfor:  European Organisation for the Safety of Air Navigation
#'   \item eurostat:  Eurostat
#'   \item eu28: Member states of the European Union (as of December 2015),
#'               without special territories
#'   \item fao: Food and Agriculture Organization of the United Nations numerical code
#'   \item fips104: FIPS 10-4 (Federal Information Processing Standard)
#'   \item icao: International Civil Aviation Organization
#'   \item icao_region: International Civil Aviation Organization (Region)
#'   \item imf: International Monetary Fund
#'   \item ioc: International Olympic Committee
#'   \item iso2c: ISO-2 character
#'   \item iso3c: ISO-3 character
#'   \item iso2n: ISO-2 numeric
#'   \item iso3n: ISO-3 numeric
#'   \item p4_ccode: Polity IV numeric country code
#'   \item p4_scode: Polity IV alpha country code
#'   \item region: Regions as defined in the World Bank Development Indicators
#'   \item un: United Nations numerical code
#'   \item wb: World Bank (very similar but not identical to iso3c)
#'   \item wb_api2c: World Bank API 2 character code
#'   \item wb_api3c: World Bank API 3 character code
#'   \item wvs: World Values Survey numeric code
#'   \item country.name: country name (English)
#'   \item country.name.en.regex: Regular expression used to convert English names to code
#'   \item country.name.ar: country name (Arabic)
#'   \item country.name.de: country name (German)
#'   \item country.name.de.regex: Regular expression used to convert German names to code
#'   \item country.name.es: country name (Spanish)
#'   \item country.name.fr: country name (French)
#'   \item country.name.ru: country name (Russian)
#'   \item country.name.zh: country name (Chinese)
#'
#' }
#'
#' @note To produce consistent conversion, some entries had to be removed from the
#'     conversion data frame. For example, the Correlates of War include 4 different
#'     codes to represent Western Germany. "countrycode" uses only one of them (CoW
#'     code 260 for all years). Similar choices were made in the cases of Korea,
#'     Yemen, Congo and Vietnam. Also, Namibia's iso2c code ("NA") can be understood
#'     as a missing observation (NA) by R.
#'
#'     Capitalized country names refer to the official short English names, as defined
#'     by the ISO organization. ISO does not publish official short English names for
#'     countries whose name is not capitalized in the the country.name vector. Continent
#'     and region information was taken from the UN website.
#'
#'     This is a (possibly incomplete) list of countries and codes that were dropped:
#'
#'     KOREA, REPUBLIC OF: cown 731 730, cowc PRK KOR
#'     YEMEN: cown 680 678, cowc YAR YPR
#'     GERMANY: cown 267 260 245, cowc BAV GFR BAD
#'     CONGO: cown 490, cowc 484
#'     VIET NAM: cown 816, cowc DRV
#' @docType data
#' @keywords datasets
#' @name countrycode_data
#' @usage countrycode_data
#' @format A data frame with 260 rows and 17 columns
NULL

