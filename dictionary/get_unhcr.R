library(tidyverse)

unhcr_by_region <-
  jsonlite::fromJSON("https://api.unhcr.org/population/v1/regions")$items |>
  transmute(
    unhcr.region = name,
    data = map(id, \(x) {
      jsonlite::fromJSON(glue::glue(
        "https://api.unhcr.org/population/v1/countries?unhcr_region={x}"
      ))$items
    })
  ) |>
  unnest(data) |>
  # placeholder codes with no real name (e.g. CRB, CUR just echo their own
  # code back as the name) are not real countries and have no population data
  filter(name != code) |>
  select(country = name, unhcr = code, unhcr.region)

unhcr_no_region <-
  anti_join(
    jsonlite::fromJSON(glue::glue(
      "https://api.unhcr.org/population/v1/countries"
    ))$items,
    unhcr_by_region,
    by = c(code = "unhcr")
  ) |>
  filter(name != code) |>
  select(country = name, unhcr = code)

unhcr <-
  bind_rows(unhcr_by_region, unhcr_no_region) |>
  mutate(
    country = case_when(
      country == "Serbia and Kosovo: S/RES/1244 (1999)" ~ "Serbia",
      .default = country
    ),
    unhcr.region = case_when(
      country == "South Georgia and the South Sandwich Islands" ~ "Europe",
      country == "Tibetan" ~ "Asia and the Pacific",
      .default = unhcr.region
    )
  )

# UNHCR stopped publishing a separate code for Kosovo (previously "KOS"); it is
# now folded into a single "Serbia and Kosovo: S/RES/1244 (1999)" entry coded
# as Serbia. Keep the last-known Kosovo code as a manual entry.
if (!"Kosovo" %in% unhcr$country) {
  unhcr <- bind_rows(
    unhcr,
    tibble(country = "Kosovo", unhcr = "KOS", unhcr.region = "Europe")
  )
}

unhcr <- unhcr |> arrange(country)

unhcr |> write_csv("dictionary/data_unhcr.csv", na = "")
