library(pacman)
p_load(tidyverse, countrycode, janitor, tibble, dplyr, tidyr, readr, readxl,
       rvest, httr, jsonlite, zoo, purrr)
options(stringsAsFactors=FALSE)
#p_load(RSelenium)

# warn if not running in an UTF-8 locale
if (! l10n_info()$`UTF-8`) warning('Running in a non-UTF-8 locale!')

#' Use countrycode regexes as unique country IDs
custom_dict = readr::read_csv('dictionary/data_regex.csv', na = '') %>% 
              dplyr::select(country.name.en.regex, country.name.en.regex) 
CountryToRegex = function(x, warn=TRUE, custom_match = NULL) 
                 countrycode(x, 
                             'country.name.en.regex', 
                             'country.name.en.regex', 
                             custom_dict=custom_dict, 
                             origin_regex=TRUE, 
                             warn=warn,
                             custom_match = custom_match)

#' Download data from original web source 
LoadSource = function(src = 'world_bank') {
    # load get_function
    script_name = paste0('dictionary/get_', src, '.R')
    source(script_name) 
    # execute get_function
    function_name = paste0('get_', src)
    out = try({
              setTimeLimit(cpu = 30);
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
