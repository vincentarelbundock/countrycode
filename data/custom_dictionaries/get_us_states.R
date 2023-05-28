source(here("dictionary/utilities.R"))

tmp <- read.csv(here("data/custom_dictionaries/data_us_states.csv")) |>
    unique() |>
    select(state.name = state,
           state.abb = abbreviation,
           state.regex = state.regex)

attr(tmp, "origin_regex") <- "state.regex"
attr(tmp, "valid_origin") <- c("state.name", "state.abb", "state.regex")

saveRDS(tmp, here("data/custom_dictionaries/data_us_states.rds"))