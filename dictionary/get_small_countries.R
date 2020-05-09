source(here::here('dictionary/utilities.R'))

# small countries not covered by V-Dem, CoW, or Polity
# manually collected by the package maintainers

get_small_countries <- function() {

    idx <- read.csv('dictionary/data_small_countries.csv', na.strings = '') %>%
           dplyr::mutate(end = replace_na(end, 2020))

    rec <- expand_grid(iso3c = idx$iso3c,
                       year = min(idx$start):2020) %>%
           left_join(idx[, c('iso3c', 'country')], by = 'iso3c') %>%
           mutate(country.name.en.regex = CountryToRegex(country))

    for (i in 1:nrow(idx)) {
        rec <- rec %>% filter((iso3c != idx$iso3c[i]) |
                              ((year >= idx$start[i]) & (year <= idx$end[i])))
    }

    out <- rec %>%
           select(country.name.en.regex, year)

    return(out)

}
