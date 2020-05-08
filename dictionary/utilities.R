###########
#  setup  #
###########
library(here)
library(janitor)
library(readxl)
library(rvest)
library(RSelenium)
library(checkmate)
library(httr)
library(jsonlite)
library(zoo)
library(countrycode)
library(tidyverse)
options(stringsAsFactors=FALSE)
setwd(here::here())

#############################
#  unique IDs with regexes  #
#############################
custom_dict = read.csv('dictionary/data_static.csv', na = '', stringsAsFactors = FALSE) %>% 
              dplyr::select(country.name.en.regex, country.name.en.regex) 

CountryToRegex = function(x, warn=TRUE) countrycode(x, 
                                                    'country.name.en.regex', 
                                                    'country.name.en.regex', 
                                                    origin_regex = TRUE,
                                                    custom_dict = custom_dict,
                                                    warn=warn)

###############################
#  download from web sources  #
###############################
LoadSource = function(src = 'world_bank') {
    # load get_function
    script_name = paste0('dictionary/get_', src, '.R')
    source(script_name) 
    # execute get_function
    function_name = paste0('get_', src)
    out = try({
              setTimeLimit(cpu = 120);
              eval(parse(text = function_name))()
              }, silent = TRUE)
    # output as data.frame with meta-data attributes
    if ('data.frame' %in% class(out)) {
        out = data.frame(out)
        attr(out, 'source') = src
        attr(out, 'retrieved') = Sys.time()
    }
    return(out)
}

# Hack to artificially extend the temporal coverage of panel datasets using the
# last available year
ExtendCoverage = function(dat, last_year = 2020) {
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

    # duplicate indices
    if ('year' %in% colnames(dataset)) { # panel
        idx <- paste(dataset[['country.name.en.regex']], dataset[['year']]) 
        checkmate::assert_true(anyDuplicated(idx) == 0)
    } else { # cross-section
        checkmate::assert_true(anyDuplicated(dataset[['country.name.en.regex']]) == 0)
    }

}
