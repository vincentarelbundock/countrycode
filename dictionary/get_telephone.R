source(here::here('dictionary/utilities.R'))

# ITU-T E.164 country codes for telecommunication
# Source: https://www.itu.int/dms_pub/itu-t/opb/sp/T-SP-E.164D-11-2011-MSW-E.doc

telephone <- read_csv('dictionary/data_raw/data_telephone.csv',
                      col_types = cols(),
                      progress = FALSE) %>%
  rename(country = country.name) %>%
  mutate(
    country = if_else(str_detect(country, '^Cura'), 'Curacao', country),
    country = recode(
      country,
      "Diego Garcia" = "British Indian Ocean Territory",
      "Greenland (Denmark)" = "Greenland",
      "Somali Democratic Republic" = "Somalia"
    )
  ) %>%
  # ITU combines Mayotte/Reunion in a single entry (code 262).
  filter(country != 'French Departments and Territories in the Indian Ocean') %>%
  bind_rows(
    tibble(country = 'Mayotte', telephone = 262),
    tibble(country = 'Reunion', telephone = 262)
  ) %>%
  # Keep one country-level code when the source lists multiple entries.
  filter(
    country != 'Australian External Territories',
    !(country == 'Saint Helena, Ascension and Tristan da Cunha' & telephone == 247),
    !(country == 'Vatican City State' & telephone == 379)
  ) %>%
  mutate(telephone = as.integer(telephone)) %>%
  arrange(country)

telephone %>% write_csv('dictionary/data_telephone.csv', na = "")
