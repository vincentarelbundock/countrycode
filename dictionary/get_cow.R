source(here::here('dictionary/utilities.R'))

get_cow <- function() {

    get_file <- function(web) {
        tmp <- tempfile()
        download.file(web, tmp, quiet = TRUE)
        out <- read.csv(tmp) %>%
               setNames(tolower(names(.))) # normalize colnames
        unlink(tmp)
        return(out)
    }

    codes <- get_file('http://www.correlatesofwar.org/data-sets/cow-country-codes/cow-country-codes')
    panel <- get_file('http://www.correlatesofwar.org/data-sets/state-system-membership/system2016')

    out <- dplyr::full_join(codes, panel, by = c('ccode', 'stateabb')) %>%
           dplyr::mutate(country.name.en.regex = CountryToRegex(statenme)) %>%
           dplyr::select(country.name.en.regex, cowc = stateabb, cown = ccode, cow.name = statenme, year) %>%
           # overlapping years; pick one arbitrarily
           dplyr::filter((year != 1990) | (cowc != 'GFR')) %>% # Germany vs. West Germany
           unique # duplicates in original files

    return(out)

}

