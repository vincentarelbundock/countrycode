source(here::here('dictionary/utilities.R'))

url <- "http://ksgleditsch.com/data/iisystem.dat"

gw <- readr::read_tsv(url,
                      col_names = c("gwn", "gwc", "country", "birth", "death"),
                      col_types = cols(gwn = readr::col_integer(),
                                       gwc = readr::col_character(),
                                       country = readr::col_character(),
                                       birth = readr::col_date(format = "%d:%m:%Y"),
                                       death = readr::col_date(format = "%d:%m:%Y")))
 
gw <- gw %>%
      filter(!gwc %in% c("TBT", "DRV"),
             death > as.Date("1945-09-02")) %>%
      group_by(gwn) %>%
      slice(which.max(death)) %>%
      ungroup() %>%
      mutate(country = replace(country, gwc == "CDI", "Cote d'Ivoire"),
             country = replace(country, gwc == "PRK", "North Korea"),
             country = replace(country, gwc == "RVN", "Vietnam")) %>%
      select(country, gwn, gwc)
 
gw %>% write_csv('dictionary/data_gw.csv')
