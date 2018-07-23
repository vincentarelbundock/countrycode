# vdem8 does not allow direct download, so we can't scrape. Vincent extracted
# these data from the V-Dem v8 April 2018 CSV file.

get_vdem = function() {
    bad = c('Palestine/British Mandate', 'Palestine/West Bank', 'Palestine/Gaza')
    out = readRDS('dictionary/data_vdem_v8_april2018.rds') %>%
          dplyr::select(vdem.name = country_name, vdem = country_id) %>%
          dplyr::filter(!vdem.name %in% bad) %>%
          dplyr::mutate(country.name.en.regex = CountryToRegex(vdem.name)) %>%
          unique
    return(out)
}
