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
##     country = countrycode(.data$Name,
##                           origin = "country.name",
##                           destination = "country.name",
##                           warn = FALSE)
##   ) %>%
##   filter(!is.na(country)) %>%
##   select(
##     country,
##     exiobase_code = "DESIRE code",
##     exiobase_num = "DESIRE Number"
##   )

## write_csv(
##   exiobase,
##   here("dictionary", "data_exiobase3.csv"),
##   na = ""
## )
