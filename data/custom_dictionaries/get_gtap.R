source(here::here("dictionary/utilities.R"))

gtap_versions <- 6:11

## #' Scrap country mapping for GTAP
## #' @param gtap_main integer indicating main GTAP version
## #' @param gtap_final integer with values 1 for pre-release and 2 (default) for
## #' final release
## #' @param gtap_minor integer indicating GTAP minor version (default to 1)
## #' @param gtap_rc integer indicating GTAP release candidate (default to 1)
## #' @return a data.frame with the mapping
## get_gtap_mapping <- function(gtap_main, gtap_final = 2, gtap_minor = 1,
##                              gtap_rc = 1) {
##   gtap_version <- str_glue("{gtap_main}.{gtap_final}{gtap_minor}{gtap_rc}")

##   url <-
##     urltools::param_set(
##       "https://www.gtap.agecon.purdue.edu/databases/regions.aspx",
##       "version", gtap_version
##     )

##   gtap <-
##     read_html(x = url) |>
##     html_element(css = "table#Regions") |>
##     html_table() |>
##     separate_rows(
##       Description,
##       sep = " - "
##     ) |>
##     rename(
##       gtap_num = Number,
##       gtap_code = Code,
##       country = Description
##     ) |>
##     mutate(gtap_name = country[1], .by = gtap_num) |>
##     distinct() |>
##     filter(!(substr(gtap_code, start = 1, stop = 1) == "X" &
##                country == gtap_name)) |>
##     mutate(
##       country = countrycode(country,
##                             origin = "country.name",
##                             destination = "country.name",
##                             warn = FALSE),
##       .keep = "unused"
##     ) |>
##     select(country, gtap_num, gtap_code, gtap_name)

##   return(gtap)
## }

## gtap_versions |>
##   walk(\(version)
##        get_gtap_mapping(version) |>
##          write_csv(
##            here(str_glue("data/custom_dictionaries/data_gtap{version}.csv"))
##          )
##       )

# Convert to RDS dictionary with attributes
gtap_versions |>
  walk(function(version) {
    tmp <-
      read.csv(
        here(str_glue("data/custom_dictionaries/data_gtap{version}.csv"))
      ) |>
      unique() |>
      transform(
        country.name.en.regex = countrycode(
          country,
          "country.name",
          "country.name.en.regex"
        )) |>
      select(country.name = country,
             country.name.en.regex,
             gtap.name = gtap_name,
             gtap.num = gtap_num,
             gtap.cha = gtap_code)
    attr(tmp, "origin_regex") <- "country.name.en.regex"
    attr(tmp, "valid_origin") <- "country.name.en.regex"

    saveRDS(tmp,
            here(str_glue("data/custom_dictionaries/data_gtap{version}.rds")))
  })
