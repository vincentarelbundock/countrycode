source(here::here('dictionary/utilities.R'))

get_file <- function(web) {
    tmp <- tempfile()
    download.file(web, tmp, quiet = TRUE)
    out <- read.csv(tmp) %>%
           setNames(tolower(names(.))) # normalize colnames
    unlink(tmp)
    return(out)
}

codes <- get_file('https://correlatesofwar.org/wp-content/uploads/COW-country-codes.csv')
panel <- get_file('https://correlatesofwar.org/wp-content/uploads/system2016.csv')

out <- full_join(codes, panel, by = c('ccode', 'stateabb'), relationship = "many-to-many") %>%
       mutate(country = statenme) %>%
       select(country, cowc = stateabb, cown = ccode, cow.name = statenme, year) %>%
       # overlapping years; pick one arbitrarily
       filter((year != 1990) | (cowc != 'GFR')) %>% # Germany vs. West Germany
       unique # duplicates in original files

out %>% write_csv('dictionary/data_cow.csv', na = "")

