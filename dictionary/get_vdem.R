source(here::here('dictionary/utilities.R'))

# Full V-Dem v16 source from the official vdemdata package:
# https://github.com/vdeminstitute/vdemdata
vdem <- readRDS("dictionary/data_vdem.rds") %>%
  select(country_name, country_id, year) %>%

  # TODO: Czechoslovakia vs. Czech Republic vs. Czechia
  mutate(
    country_name = case_when(
      (country_name == "Czechia") & (year < 1993) ~ "Czechoslovakia",
      TRUE ~ country_name
    )
  ) %>%

  # countrycode does not have separate regexes for the West Bank and Gaza
  filter(
    country_name != 'Palestine/West Bank',
    (year != 1948) | (country_name != 'Palestine/Gaza')
  ) %>%
  select(
    country = country_name,
    vdem.name = country_name,
    vdem = country_id,
    year
  )

# CountryToRegex(c("Republic of Vietnam", "Democratic Republic of Vietnam"))
