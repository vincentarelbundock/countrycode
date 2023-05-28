source(here::here("dictionary/utilities.R"))

# This file cannot run automatically because the original files cannot be
# downloaded by R.
# To run this file, remove the comments and download the file
# CountryMappingDESIRE.xlsx from https://ntnu.app.box.com/v/EXIOBASEconcordances

## source(here::here("dictionary/utilities.R"))

## data <-
##   here("dictionary", "CountryMappingDESIRE.xlsx") %>%
##   read_excel(sheet = "CountryList")

## exiobase <-
##   data %>%
##   mutate(
##     Name = case_match(
##       Name,
##       "Heard and mc donald islands" ~ "Heard and mcdonald islands",
##       .default = Name
##     ),
##     country = countrycode(.data$Name,
##                           origin = "country.name",
##                           destination = "country.name",
##                           warn = FALSE)
##   )

## # Check missing countries
## exiobase %>%
##   filter(is.na(country)) %>%
##   select(Name)

## exiobase <-
##   exiobase %>%
##   filter(!is.na(country)) %>%
##   select(
##     country,
##     exiobase_code = `DESIRE code`,
##     exiobase_num = `DESIRE Number`
##   )

## write_csv(
##   exiobase,
##   here("dictionary", "data_exiobase3.csv"),
##   na = ""
## )


tmp <- read.csv(here("data/custom_dictionaries/data_exiobase3.csv")) |>
    unique() |>
    transform(country.name.en.regex = countrycode(country, "country.name", "country.name.en.regex")) |>
    select(country.name = country,
           country.name.en.regex,
           exiobase.num = exiobase_num,
           exiobase.cha = exiobase_code)
attr(tmp, "origin_regex") <- "country.name.en.regex"
attr(tmp, "valid_origin") <- "country.name.en.regex"

saveRDS(tmp, here("data/custom_dictionaries/data_exiobase3.rds"))
