source(here::here('dictionary/utilities.R'))

url <- 'https://api.dhsprogram.com/rest/dhs/countries?select=DHS_CountryCode,CountryName&f=json'
dhs <- jsonlite::fromJSON(url)[['Data']] %>%
       select(country = CountryName, dhs = DHS_CountryCode) %>%
       filter(dhs != 'OS')

dhs %>% write_csv('dictionary/data_dhs.csv', na = "")
