get_unpd = function() {
    # Download
    url = 'https://esa.un.org/unpd/wpp/DVD/Files/4_Other%20Files/WPP2015_F01_LOCATIONS.XLS'
    download.file(url, 'tmp.xls', quiet = TRUE)

    # Read
    unpd <- readxl::read_excel('tmp.xls', range = 'Location!B17:G290')
    
    # Remove tmp file
    unlink('tmp.xls')

    # Clean
    bad = c('Other non-specified areas',
            'Channel Islands',
            'United States Virgin Islands')
    unpd <- unpd %>% 
            dplyr::filter(`Name` == 'Country/Area', # Location Type
                      !`Major area, region, country or area` %in% bad) %>%  # remove aggregates and other non-country types
            #mutate(name.fixed = if_else(`ISO3 Alpha-code` == 'TWN', 'Taiwan', name.fixed)) %>%  # Taiwan listed as "Other non-specified areas" in original
            dplyr::mutate(code = as.integer(code)) %>% # make country code integer rather than numeric
            dplyr::select(unpd.name = `Major area, region, country or area`, unpd = code) %>%
            dplyr::mutate(country.name.en.regex = CountryToRegex(unpd.name)) %>%
            dplyr::arrange(unpd.name)

    return(unpd)
}

