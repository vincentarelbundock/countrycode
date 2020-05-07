get_dhs = function() {
    url = 'https://api.dhsprogram.com/rest/dhs/countries?select=DHS_CountryCode,CountryName&f=json'
    dhs = jsonlite::fromJSON(url)[['Data']] %>%
        dplyr::select(CountryName, DHS_CountryCode) %>%
        dplyr::mutate(country.name.en.regex = CountryToRegex(CountryName)) %>%
        dplyr::select(-CountryName)
    return(dhs)
}
