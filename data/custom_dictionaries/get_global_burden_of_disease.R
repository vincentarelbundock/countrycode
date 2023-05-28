source(here("dictionary/utilities.R"))

tmp <- read.csv(here("data/custom_dictionaries/data_global_burden_of_disease.csv")) |>
    unique() |>
    transform(country.name.en.regex = countrycode(country.name, "country.name", "country.name.en.regex")) |>
    select(country.name,
           country.name.en.regex,
           gbd.region = gbd_region,
           gbd.superregion = gbd_superregion)

attr(tmp, "origin_regex") <- "country.name.en.regex"
attr(tmp, "valid_origin") <- "country.name.en.regex"

saveRDS(tmp, here("data/custom_dictionaries/data_global_burden_of_disease.rds"))