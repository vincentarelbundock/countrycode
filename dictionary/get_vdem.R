source(here::here('dictionary/utilities.R'))

get_vdem <- function() {

    vdem <- readRDS('dictionary/data_vdem_v8_april2018.rds') %>%
            # TODO: Improve regex
            dplyr::filter(country_name != 'Democratic Republic of Vietnam',
            country_name != 'Republic of Vietnam') %>%
            # TODO: Czechoslovakia vs. Czech Republic vs. Czechia
            dplyr::mutate(country_name = ifelse((country_name == 'Czech Republic') & (year < 1993), 
                                                 'Czechoslovakia', country_name)) %>% 
            # convert country names
            dplyr::mutate(country.name.en.regex = CountryToRegex(country_name)) %>%
            # countrycode does not have separate regexes for the West Bank and Gaza
            dplyr::filter(country_name != 'Palestine/West Bank',
                          (year != 1948) | (country_name != 'Palestine/Gaza')) %>%
            dplyr::select(country.name.en.regex, vdem.name = country_name, vdem = country_id, year)

    return(vdem)

}
