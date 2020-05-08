setwd(here::here())
source('dictionary/utilities.R')

# Merge
idx <- read.csv('dictionary/data_static.csv', na = '')$country.name.en.regex
yea = c(p4$year, cow$year, vdem$year) 
yea = min(yea):max(yea)
rec = expand.grid('country.name.en.regex' = idx,
                  'year' = yea,
                  stringsAsFactors = FALSE)
dat = list(rec, p4, cow, vdem) %>%
      purrr::reduce(dplyr::left_join, by = c('year', 'country.name.en.regex'))

# Remove countries which are not recorded by V-Dem, CoW, or Polity
dat = dat %>% 
      dplyr::filter(!is.na(cow.name) | !is.na(p4.name) | !is.na(vdem.name))

########################################
#  extend time coverage all in one go  #
########################################



# Save 
dat = dat %>% dplyr::arrange(country.name.en.regex, year)
readr::write_csv(dat, 'dictionary/data_panel.csv', na = '')
