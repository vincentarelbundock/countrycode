# vdem8 does not allow direct download, so we can't scrape. Vincent extracted
# these data from the V-Dem v8 April 2018 CSV file.
source('dictionary/utilities.R')

get_vdem = function() {
    out = readRDS('dictionary/data_vdem_v8_april2018.rds') %>%
          # Explicitly remove tricky countries. Clean this later.
          filter(country_name != 'Democratic Republic of Vietnam',
                 country_name != 'Republic of Vietnam',
                 country_name != 'Somaliland',
                 country_name != 'Republic of Vietnam',
                 country_name != 'Palestine/British Mandate',
                 country_name != 'Palestine/Gaza',
                 country_name != 'Palestine/West Bank',
                 country_name != 'Saxe-Weimar-Eisenach') %>%
          mutate(country.name.en.regex = CountryToRegex(country_name)) %>%
          select(country.name.en.regex, vdem = country_id, year)
    return(out)
}
