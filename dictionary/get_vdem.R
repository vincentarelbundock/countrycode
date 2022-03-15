source(here::here('dictionary/utilities.R'))

# readRDS("~/countrycode/dictionary/data_raw/V-Dem-CY-Core-v12.rds") %>%
#   arrange(country_text_id,year) %>%
#   select(country_name,country_id,year) %>%
#   saveRDS(vdem, file = "~/countrycode/dictionary/data_raw/data_vdem_v12_march2022.rds", version = 2, compress = "xz")

vdem <- readRDS('dictionary/data_raw/data_vdem_v12_march2022.rds') %>%

  # TODO: Czechoslovakia vs. Czech Republic vs. Czechia
  mutate(country_name = ifelse((country_name == "Czech Republic") &
                               (year < 1993),
                               "Czechoslovakia",
                               country_name)) %>%

  # countrycode does not have separate regexes for the West Bank and Gaza
  filter(country_name != 'Palestine/West Bank',
         (year != 1948) | (country_name != 'Palestine/Gaza')) %>%
  select(country = country_name,
         vdem.name = country_name, vdem = country_id, year)

vdem %>% write_csv('dictionary/data_vdem.csv', na = "")


CountryToRegex(c("Republic of Vietnam", "Democratic Republic of Vietnam"))
