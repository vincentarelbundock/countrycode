library(tidyverse)

unhcr_by_region <-
  jsonlite::fromJSON("https://api.unhcr.org/population/v1/regions")$items |>
  transmute(unhcr_region = name,
            data = map(id, \(x) jsonlite::fromJSON(glue::glue("https://api.unhcr.org/population/v1/countries?unhcr_region={x}"))$items)) |>
  unnest(data) |>
  select(country = name, unhcr = code, unhcr_region)

unhcr_no_region <-
  anti_join(jsonlite::fromJSON(glue::glue("https://api.unhcr.org/population/v1/countries"))$items,
            unhcr_by_region,
            by = c(code = "unhcr")) |>
  select(country = name, unhcr = code)

unhcr <-
  bind_rows(unhcr_by_region, unhcr_no_region) |>
  mutate(country = case_when(country == "Serbia and Kosovo: S/RES/1244 (1999)" ~ "Serbia",
                             country == "KOS" ~ "Kosovo",
                             .default = country),
         unhcr_region = case_when(country == "Kosovo" ~ "Europe",
                                  country == "South Georgia and the South Sandwich Islands" ~ "Europe",
                                  country == "Tibetan" ~ "Asia and the Pacific",
                                  .default = unhcr_region))

unhcr |> write_csv("dictionary/data_unhcr.csv", na = "")
