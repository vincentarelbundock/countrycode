#' Country Code Translation Data Frame (Cross-Sectional)
#'
#' A data frame used internally by the [countrycode()] function. `countrycode` can use any valid code as destination, but only some codes can be used as origin.
#'
#' ## Origin and Destination
#'
#' - `ccTLD`: IANA country code top-level domain
#' - `country.name`: country name (English)
#' - `country.name.de`: country name (German)
#' - `cowc`: Correlates of War character
#' - `cown`: Correlates of War numeric
#' - `dhs`: Demographic and Health Surveys Program
#' - `ecb`: European Central Bank
#' - `eurostat`:  Eurostat
#' - `fao`: Food and Agriculture Organization of the United Nations numerical code
#' - `fips`: FIPS 10-4 (Federal Information Processing Standard)
#' - `gaul`: Global Administrative Unit Layers
#' - `genc2c`: GENC 2-letter code
#' - `genc3c`: GENC 3-letter code
#' - `genc3n`: GENC numeric code
#' - `gwc`: Gleditsch & Ward character
#' - `gwn`: Gleditsch & Ward numeric
#' - `imf`: International Monetary Fund
#' - `ioc`: International Olympic Committee
#' - `iso2c`: ISO-2 character
#' - `iso3c`: ISO-3 character
#' - `iso3n`: ISO-3 numeric
#' - `p4n`: Polity IV numeric country code
#' - `p4c`: Polity IV character country code
#' - `un`: United Nations M49 numeric codes
#' - `unicode.symbol`: Region subtag (often displayed as emoji flag)
#' - `unpd`: United Nations Procurement Division
#' - `vdem`: Varieties of Democracy (V-Dem version 8, April 2018)
#' - `wb`: World Bank (very similar but not identical to iso3c)
#' - `wvs`: World Values Survey numeric code
#'
#' ## Destination only
#'
#' - `ar5`: IPCC's regional mapping used both in the Fifth Assessment Report
#'              (AR5) and for the Reference Concentration Pathways (RCP)
#' - `continent`: Continent as defined in the World Bank Development Indicators
#' - `cow.name`: Correlates of War country name
#' - `currency`: ISO 4217 currency name
#' - `eurocontrol_pru`:  European Organisation for the Safety of Air Navigation
#' - `eurocontrol_statfor`:  European Organisation for the Safety of Air Navigation
#' - `eu28`: Member states of the European Union (as of December 2015),
#'               without special territories
#' - `icao.region`: International Civil Aviation Organization region
#' - `iso.name.en`: ISO English short name
#' - `iso.name.fr`: ISO French short name
#' - `iso4217c`: ISO 4217 currency alphabetic code
#' - `iso4217n`: ISO 4217 currency numeric code
#' - `p4.name`: Polity IV country name
#' - `region`: 7 Regions as defined in the World Bank Development Indicators
#' - `region23`: 23 Regions as used to be in the World Bank Development Indicators (legacy)
#' - `un.name.ar`: United Nations Arabic country name
#' - `un.name.en`: United Nations English country name
#' - `un.name.es`: United Nations Spanish country name
#' - `un.name.fr`: United Nations French country name
#' - `un.name.ru`: United Nations Russian country name
#' - `un.name.zh`: United Nations Chinese country name
#' - `un.region.name`: United Nations region name
#' - `un.region.code`: United Nations region code
#' - `un.regionintermediate.name`: United Nations intermediate region name
#' - `un.regionintermediate.code`: United Nations intermediate region code
#' - `un.regionsub.name`: United Nations sub-region name
#' - `un.regionsub.code`: United Nations sub-region code
#' - `wvs.name`: World Values Survey numeric code country name
#' - `cldr.*`: 600+ country name variants from the UNICODE CLDR project.
#'   Inspect the [`cldr_examples`][countrycode::cldr_examples] data.frame for a full list of
#'   available country names and examples.
#'
#' @note The Correlates of War (cow) and Polity 4 (p4) project produce codes in
#' country year format. Some countries go through political transitions that
#' justify changing codes over time. When building a purely cross-sectional
#' conversion dictionary, this forces us to make arbitrary choices with respect
#' to some entities (e.g., Western Germany, Vietnam, Serbia). `countrycode`
#' includes a reconciled dataset in panel format,
#' [`codelist_panel`][countrycode::codelist_panel]. Instead of converting code, we recommend
#' that users dealing with panel data "left-merge" their data into this panel
#' dictionary.
#'
#' @docType data
#' @keywords datasets
#' @name codelist
#' @format A data frame with codes as columns.
NULL
