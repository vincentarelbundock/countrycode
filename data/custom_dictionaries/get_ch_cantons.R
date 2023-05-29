source(here::here("dictionary/utilities.R"))

tmp <- read.csv(here("data/custom_dictionaries/data_ch_cantons.csv")) |>
    unique() |>
    rename(canton.abb = abbreviation)
attr(tmp, "origin_regex") <- "canton.name.regex"
attr(tmp, "valid_origin") <- colnames(tmp)

saveRDS(tmp, here("data/custom_dictionaries/data_ch_cantons.rds"))
