library(pacman)
p_load(tidyverse, countrycode, janitor, tibble, dplyr, tidyr, readr, readxl,
       rvest, RSelenium, httr, jsonlite, zoo)
options(stringsAsFactors=FALSE)

# warn if not running in an UTF-8 locale
if (! l10n_info()$`UTF-8`) warning('Running in a non-UTF-8 locale!')

#' Use countrycode regexes as unique country IDs
custom_dict = read.csv('dictionary/data_static.csv', na = '') %>% 
              dplyr::select(country.name.en.regex, country.name.en.regex) 
CountryToRegex = function(x, warn=TRUE) countrycode(x, 
                                                    'country.name.en.regex', 
                                                    'country.name.en.regex', 
                                                    origin_regex = TRUE,
                                                    custom_dict = custom_dict,
                                                    warn=warn)

#' Download data from original web source 
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

#' Drop datasets that fail sanity checks
SanityCheck = function(data_list) {
    # Data.frame vs. try-error
    check = sapply(data_list, function(x) 'data.frame' %in% class(x))
    if (any(!check)) {
        warning('Failed to download or produce valid data.frame: ', 
                paste(names(data_list)[!check], collapse = ', '))
    }
    data_list = data_list[check] 

    # 50 rows
    check = sapply(data_list, function(x) nrow(x) >= 50)
    if (any(!check)) {
        warning('Fewer than 50 rows: ', 
                paste(names(data_list)[!check], collapse = ','))
    }
    data_list = data_list[check] 

    # 2 columns
    check = sapply(data_list, function(x) ncol(x) >= 2)
    if (any(!check)) {
        warning('Fewer than 2 columns: ', 
                paste(names(data_list)[!check], collapse = ','))
    }
    data_list = data_list[check] 

    # Merge ID
    check = sapply(data_list, function(x) 'country.name.en.regex' %in% colnames(x))
    if (any(!check)) {
        warning('Merge ID missing: ', 
                paste(names(data_list)[!check], collapse = ','))
    }
    data_list = data_list[check] 
    return(data_list)
}

