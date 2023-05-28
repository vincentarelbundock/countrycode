###########
#  setup  #
###########
pkgs <- c(
  "here",
  "conflicted",
  "janitor",
  "readxl",
  "utf8",
  "xml2",
  "rvest",
  "RSelenium",
  "assertr",
  "checkmate",
  "httr",
  "jsonlite",
  "lubridate",
  "WDI",
  "pdftools",
  "zoo",
  "countrycode",
  "tidyverse"
)
sapply(pkgs, require, character.only = TRUE, quiet = TRUE)

options(stringsAsFactors = FALSE)
setwd(here::here())
conflict_prefer('filter', 'dplyr')
conflict_prefer('select', 'dplyr')

#############################
#  unique IDs with regexes  #
#############################
custom_dict <- read.csv('dictionary/data_regex.csv', na = '', stringsAsFactors = FALSE) %>%
               dplyr::select(country.name.en.regex, country.name.en.regex)

CountryToRegex <- function(x, warn=TRUE) countrycode(x,
                                                     'country.name.en.regex',
                                                     'country.name.en.regex',
                                                     origin_regex = TRUE,
                                                     custom_dict = custom_dict,
                                                     warn=warn)


# Hack to artificially extend the temporal coverage of panel datasets using the
# last available year
ExtendCoverage = function(dat, last_year = as.numeric(format(Sys.Date(), "%Y"))) {
    out = dat
    tmp = dat %>%
          dplyr::filter(year == max(year))
    for (y in base::setdiff(2000:last_year, dat$year)) {
        tmp$year = y
        out = rbind(out, tmp)
    }
    return(out)
}

###################
#  sanity checks  #
###################

if (! l10n_info()$`UTF-8`) warning('Running in a non-UTF-8 locale!')

SanityCheck <- function(dataset) {

    # is a data.frame-like object
    checkmate::assert_true(inherits(dataset, 'data.frame'))

    # unique identifier: country.name.en.regex
    checkmate::assert_true('country.name.en.regex' %in% colnames(dataset))

    # minimum number of rows and columns
    checkmate::assert_numeric(nrow(dataset), lower = 50)
    checkmate::assert_numeric(ncol(dataset), lower = 2)

    # missing indices
    if ('year' %in% colnames(dataset)) { # panel
        checkmate::assert_false(any(is.na(dataset[['year']])))
    }
    checkmate::assert_false(any(is.na(dataset[['country.name.en.regex']])))

    # duplicate indices
    if ('year' %in% colnames(dataset)) { # panel
        idx <- paste(dataset[['country.name.en.regex']], dataset[['year']])
        checkmate::assert_true(anyDuplicated(idx) == 0)
    } else { # cross-section
        checkmate::assert_true(anyDuplicated(dataset[['country.name.en.regex']]) == 0)
    }

}
