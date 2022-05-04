# country code 1.4.0

* Detect French country names using regular expressions: `origin = "country.name.fr"` (Thanks to Samuel Meichtry)
* Detect Italian country names using regular expressions: `origin = "country.name.it"` (Thanks to Samuel Meichtry)

# countrycode 1.3.1

* New code: unhcr

# countrycode 1.3.0

* destination argument accepts a vector of strings and tries one after the other
* countryname(warn=TRUE) by default
* better class checks
* countryname defaults to `country.name.en` for missing country names (nomatch=NULL)
* Vietnam: better regex and support for vdem
* Namibia fixes: eurostat, genc2c, wb_api2c, ecb
* Various regex improvements
* Congo French disambiguation

# countrycode 1.2.0

* New 'countryname' function converts country names from any language (thanks to @davidsjoberg)
* New `guess_field` function guesses which code a vector uses
* Bug in dict build inserted NA in region variable (Thanks to M. Pascariu)
* Added region23 with the old, more granular regions
* Added unicode.symbol, which converts to emoji flags
* Added ISO 4217 currency name, alpha, and numeric codes
* Added UN region codes and names
* Added IANA ccTLD codes
* Improved various regexes

# countrycode 1.1.3 

* Added Demographic and Health Surveys (thanks to @mcooper)

# countrycode 1.1.2 

* Updated World Bank regions with manual additions

# countrycode 1.1.1 

* Bug: Typo prevented users for using "p4n" as origin code
* Fixed bad icao.region codes (Thanks to @espinielli)
* Added country name "United Arab Republic" and its regex (Thanks to Gina Reynolds)
* Added SOM to wb code (Thanks to Fabian Besche)
* Added Vietnam to codelist_panel

# countrycode 1.1.0 

* Gleditsch and Ward codes (Thanks to Altaf Ali)
* V-Dem 8 country codes (panel and cross-section)
* Fixed Netherlands Antilles test (ANT code retired by ISO)
* codelist_panel now excludes years where a country didn't exist
* Scraping function for UN M49 codes. (Thanks to @cjyetman and @emilBeBri)
* `nomatch = NULL` now works as expected when sourcvar is a factor (#192 thanks to @jhuovari for reporting)

# countrycode 1.0.0 

* Huge thanks to @cjyetman for his incredible work on this major release!
* Country-Year (panel) conversion dictionary
* Dictionary built from original sources
* Liechtenstein should not be in eu28
* Russia eurocontrol region fix
* CLRD country names

# countrycode 0.19.1 

* Move to Semantic Versioning 2.0.0
  http://semver.org/#semantic-versioning-specification-semver
* Fixed North Korea regex and added tests
* Fixed Sudan iso3n code
* Removed lookbehind from Ireland regex for javascript compatibility (request by plotly)
* Added nomatch argument

# countrycode 0.19 

New features

* "custom_dict" argument allows user-supplied dictionary data.frames
* "custom_match" argument allows a user-supplied named vector of custom
  origin->destination matches that will supercede any matching values in the
  default result (issue #107) (Thanks to @cjyetman)
* German, French, Spanish, Russian, Chinese, and Arabic country names as destination codes
* German regular expression to convert from German names to codes. (Thanks to @sumtxt)
* Aviation codes (Thanks to Enrico Spinielli)
* ar5 and eu28 (Thanks to Niklas Roming)
* eurostat (Thanks to @cjyetman)
* 2 and 3 character codes for the World Bank API: wb_api2c and wb_api3c (Thanks to @cjyetman)
* alpha and numeric codes for Polity IV: p4_scode and p4_ccode (Thanks to @cjyetman)
* World Values Survey numeric code (Thanks to @cjyetman)

Regex fixes and improvements:

* Improved regex for Ireland and United States of America (Thanks to @cjyetman)
* D.R. Congo (found in WVS) matches Democratic Republic of the Congo (Thanks to @cjyetman)
* Southern Africa
* Federated States of Micronesia
* Republic of China == Taiwan (Thanks to Nils Enevoldsen)
* Martinique (Thanks to Martyn Plummer)
* Tahiti country name string converts to French Polynesia

Misc:

* Major speed-up in regex conversion by using factors (Thanks to @cjyetman)
* when more than one match is found for a given string, <NA> is returned rather
  than arbitrarily choosing the last match found (Thanks to @cjyetman)
* updated tests to new testthat convention (Thanks to @cjyetman)
* English country names are now official UN versions
* Better docs, examples, and README
* Taiwan FAO code is 214 (Thanks to Matthieu Stigler)

# countrycode 0.18 

* Nils Enevoldsen did wonderful work refactoring most of the regex in the dictionary.
* Nils also added a bunch of tests. Thanks!
* Added Tokelau

# countrycode 0.17 

* Added International Olympic Committee codes (Thanks to Devon Meunier)
* Bug: fips04 -> fips104 (Thanks to Florian Hollenbach)
* Complete FIPS104 codes (Thanks to Andy Halterman)
* Generic code name validity check (Thanks to Stefan Zeugner)
* Fixed IMF codes (Thanks to Stefan Zeugner)
* Regex fix to work better with Database of Political Insitutions (Thanks to Christopher Gandrud)
* Avoids confusion with Eq Guinea (Thanks to Christopher Gandrud)

# countrycode 0.16 

* Bug: NA cowc -> ABW (Thanks to Jon Mellon)

# countrycode 0.15 

* Regex fixes
    - Guinea
    - West Bank
    - Kitts / Christopher
    - Georgia / India
    - Mali
    - Sudan nigeria
    - Belgium
    - Korea Somalia
    - Oman

# countrycode 0.14 

* sint maarten typo

# countrycode 0.13 

* add sint maartin & curacao (thanks johnb30)

# countrycode 0.12 

* Missing wb codes filled-in using iso3c
* Added South Sudan
* Thanks to Rod Alence!

# countrycode 0.11 

* Vietnam cown
* Regexes:
    - Dominica / Dominican Republic
    - New Zealand / Aland

# countrycode 0.10 

* De-duplicate Sudan
* Niger vs. Nigeria regex

# countrycode 0.9 

* Fixed regexes: Mali, Korea, Oman, Dominica

# countrycode 0.8 

* Added World Bank (wb) country codes. Very similar, but slightly different from iso3c.

# countrycode 0.7

* Removed useless functions countrycode.nomatch and countryframe
* Fixed 2 Congo-related problems
* Added option for countrycode() to report codes for which no match was found
* Moved documentation to roxygen2
* Fixed Trinidad Tobago regex
* Added UN and FAO country codes



