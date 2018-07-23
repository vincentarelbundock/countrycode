get_world_bank_api = function() {

    # Download
    tmp <- tempfile(fileext = '.json')
    url <- 'http://api.worldbank.org/en/countries/?format=json&per_page=2000'
    download.file(url, tmp, quiet = TRUE)

    # Clean
    bad = c('Channel Islands', 
            'Virgin Islands (U.S.)')
    wb_api <- 
        jsonlite::fromJSON(tmp, flatten = T)[[2]] %>%
        dplyr::filter(region.value != 'Aggregates',
                      !name %in% bad) %>%
        dplyr::select(wb_api2c = iso2Code, wb_api3c = id, wb_api.name = name) %>%
        dplyr::mutate(country.name.en.regex = CountryToRegex(wb_api.name))

    return(wb_api)
}
