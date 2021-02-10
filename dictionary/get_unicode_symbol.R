require(dplyr)
require(tibble)
require(purrr)
require(stringr)
require(httr)
require(xml2)
require(assertthat)

# This script creates Unicode region subtags as pairs of Regional Indicator Symbols. Region subtags represent regions,
# not flags. When composed of Regional Indicator Symbols, they are displayed as flags on most systems, but on Windows
# they are displayed as pairs of letters.
# https://en.wikipedia.org/wiki/Regional_Indicator_Symbol

# The location specified below lists valid Unicode region subtags. They are based on ISO 3166-1 alpha-2.
# https://unicode.org/reports/tr51/#Flags
# 'While the syntax of a well-formed emoji flag sequence is defined in ED-14, only valid sequences are displayed as flags
# by conformant implementations, where: The valid region sequences are specified by Unicode region subtags as defined in
# [CLDR], with idStatus=regular, deprecated, or macroregion. For macroregions, only UN and EU are valid.'
# idStatus='deprecated' isn't relevant for countrycode because they can be many-to-one.
# idStatus='macrocode' isn't relevant for countrycode because countrycode doesn't track supranational bodies.

tar.url <- 'https://github.com/unicode-org/cldr/archive/latest.tar.gz'
region.file <- 'cldr-latest/common/validity/region.xml'
xpath <- '/supplementalData/idValidity/id[@type="region"][@idStatus="regular"]'

# Exceptional reservations are valid, but aren't entities in countrycode, so track them for exclusion.
# TODO: This should not be hardcoded. Ideally it would have a scraper similar to get_iso.R.

exceptional.reservations <- c('AC','CP','DG','EA','IC','TA')

# Functions to expand string ranges
# https://www.unicode.org/reports/tr35/#String_Range

letter.pair.to.integer <- function(pair) (match(stringr::str_sub(pair, 1, 1), LETTERS) - 1) * 26 + match(stringr::str_sub(pair, 2, 2), LETTERS) - 1

integer.to.letter.pair <- function(int) paste0(LETTERS[int %/% 26 + 1], LETTERS[int %% 26 + 1])

string.range.expand <- function(string.range) {
    stringr::str_replace_all(string.range, '([:upper:])([:upper:])~([:upper:])', '\\1\\2:\\1\\3') %>%
    stringr::str_replace_all('([:upper:][:upper:])', function (x) {letter.pair.to.integer(x) %>% as.character()}) %>%
    stringr::str_split('[:space:]') %>%
    unlist() %>%
    purrr::map(~ parse(text=.x) %>% eval()) %>%
    unlist() %>%
    stringr::str_replace_all('([:digit:]+)', function (x) {as.integer(x) %>% integer.to.letter.pair()})
}

# Get valid regions

tarfile <- tempfile(fileext = '.tar.gz')
httr::GET(tar.url, httr::write_disk(tarfile))
utils::untar(tarfile, files = region.file, exdir = tempdir())
valid.regions <- xml2::read_xml(paste(tempdir(),region.file,sep='/')) %>%
  xml2::xml_find_first(xpath) %>%
  xml2::xml_text() %>%
  string.range.expand()

# Get ISO 3166-1 alpha-2 codes

iso <- read_csv('dictionary/data_iso.csv', col_types = cols(), progress = FALSE) %>%
  dplyr::mutate(iso2c = dplyr::if_else(country == 'Namibia', 'NA', iso2c))

# Check that all ISO 3166-1 alpha-2 codes in countrycode have the corresponding Unicode region subtag.

assertthat::assert_that(all(iso$iso2c %in% valid.regions))

# Associate regions with country names by comparing to ISO 3166-1 alpha-2.
# Note that Unicode CLDR assigns XK to Kosovo.

unicode.symbol <- iso  %>%
  dplyr::mutate(unicode.symbol = dplyr::if_else(iso2c %in% valid.regions, iso2c, NA_character_)) %>%
  tibble::add_row(unicode.symbol = 'XK', country = 'Kosovo')

# Check that all valid Unicode region subtags have been assigned in countrycode.

assertthat::assert_that(all(valid.regions %in% c(unicode.symbol$unicode.symbol,exceptional.reservations)))

# Express region subtags as Regional Indicator Symbols and generate the CSV.

unicode.symbol %>%
  rowwise %>%
  mutate(unicode.symbol = utf8ToInt(unicode.symbol) %>%
           `-`(65) %>% # Decimal 65 (Hex 41) is the Unicode codepoint for 'LATIN CAPITAL LETTER A'
           `+`(127462) %>% # Decimal 127462 (Hex 1F1E6) is the Unicode codepoint for 'REGIONAL INDICATOR SYMBOL LETTER A'
           intToUtf8) %>%
  dplyr::select(c('unicode.symbol','country')) %>%
  write_csv('dictionary/data_unicode_symbol.csv', na = "")
