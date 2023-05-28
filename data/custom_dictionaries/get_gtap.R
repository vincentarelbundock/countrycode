source(here::here("dictionary/utilities.R"))

# gtap_main <- 10 # Main GTAP version
# gtap_minor <- 1 # Minor GTAP version
# gtap_final <- 2 # 1 for pre-release and 2 for final release
# gtap_rc <- 1 # release candidate

# gtap_version <- paste0(gtap_main, ".", gtap_final, gtap_minor, gtap_rc)

# url <-
#   urltools::param_set(
#     "https://www.gtap.agecon.purdue.edu/databases/regions.aspx",
#     "version", gtap_version
#   )

# gtap <-
#   read_html(x = url) %>%
#   html_element(css = "table#Regions") %>%
#   html_table() %>%
#   separate_rows(
#     Description,
#     sep = " - "
#   ) %>%
#   rename(
#     gtap_num = Number,
#     gtap_code = Code,
#     country = Description
#   ) %>%
#   mutate(gtap_name = country[1], .by = gtap_num) %>%
#   distinct() %>%
#   filter(!(substr(gtap_code, start = 1, stop = 1) == "X" &
#              country == gtap_name)) %>%
#   mutate(
#     country = countrycode(country,
#                           origin = "country.name",
#                           destination = "country.name",
#                           warn = FALSE),
#     .keep = "unused"
#   ) %>%
#   select(country, gtap_num, gtap_code, gtap_name)

# write_csv(
#   gtap,
#   here("data/custom_dictionaries/data_gtap10.csv")
# )


# Convert to RDS dictionary with attributes
tmp = read.csv(here("data/custom_dictionaries/data_gtap10.csv")) |>
    unique() |>
    transform(country.name.en.regex = countrycode(country, "country.name", "country.name.en.regex")) |>
    select(country.name = country,
           country.name.en.regex,
           gtap.name = gtap_name,
           gtap.num = gtap_num,
           gtap.cha = gtap_code)
attr(tmp, "origin_regex") <- "country.name.en.regex"
attr(tmp, "valid_origin") <- "country.name.en.regex"

saveRDS(tmp, here("data/custom_dictionaries/data_gtap10.rds"))
