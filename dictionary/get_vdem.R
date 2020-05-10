source(here::here('dictionary/utilities.R'))

vdem <- readRDS('dictionary/data_raw/data_vdem_v8_april2018.rds') %>%

        # TODO: Improve regex
        filter(country_name != 'Democratic Republic of Vietnam', 
               country_name != 'Republic of Vietnam') %>%

        # TODO: Czechoslovakia vs. Czech Republic vs. Czechia
        mutate(country_name = ifelse((country_name == 'Czech Republic') & (year < 1993), 
               'Czechoslovakia', country_name)) %>% 

        # countrycode does not have separate regexes for the West Bank and Gaza
        filter(country_name != 'Palestine/West Bank',
               (year != 1948) | (country_name != 'Palestine/Gaza')) %>%
        select(country = country_name, vdem.name = country_name, vdem = country_id, year)

vdem %>% write_csv('dictionary/data_vdem.csv')
