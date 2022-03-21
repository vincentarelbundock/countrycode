source(here::here('dictionary/utilities.R'))

tmp <- tempfile(fileext = '.json')
url <- 'http://api.worldbank.org/V2/en/countries/?format=json&per_page=2000'
download.file(url, tmp, quiet = TRUE)

wb_api <- fromJSON(tmp, flatten = T)[[2]] %>%
          filter(region.value != 'Aggregates') %>%
          select(country = name, wb_api2c = iso2Code, wb_api3c = id)

wb_api %>% write_csv('dictionary/data_world_bank_api.csv', na = "")
