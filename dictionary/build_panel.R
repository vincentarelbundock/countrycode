setwd(here::here())
source('dictionary/utilities.R')

# Polity4
url = 'http://www.systemicpeace.org/inscr/p4v2015.xls'
download.file(url, tmpxls <- tempfile(fileext = '.xls'), quiet = TRUE)
p4 = readxl::read_excel(tmpxls) %>%
     dplyr::select(p4n = ccode, 
                   p4c = scode,
                   p4.name = country,
                   year) %>%
     dplyr::mutate(p4n = as.integer(p4n), year = as.integer(year),
                   country.name.en.regex = CountryToRegex(p4.name)) 

# Correlates of War
url = 'http://www.correlatesofwar.org/data-sets/cow-country-codes/cow-country-codes'
tmp = tempfile()
download.file(url, tmp, quiet = TRUE)
codes_raw = read.csv(tmp)
unlink(tmp)
url = 'http://www.correlatesofwar.org/data-sets/state-system-membership/system2016'
tmp = tempfile()
download.file(url, tmp, quiet = TRUE)
cow_raw = read.csv(tmp)
unlink(tmp)

codes = codes_raw %>%
        dplyr::rename(cowc=StateAbb,
                      cown=CCode,
                      cow.name=StateNme) %>%
        # there are dups in the original file
        unique 

cow = cow_raw %>%
      dplyr::rename(cowc=stateabb, cown=ccode) %>%
      dplyr::left_join(codes, by = c('cowc', 'cown')) %>% 
      dplyr::select(cowc, cown, cow.name, year) %>%
      dplyr::mutate(country.name.en.regex = CountryToRegex(cow.name))

# V-Dem
vdem = readRDS('dictionary/data_vdem_v8_april2018.rds') %>%
       # TODO: Improve regex
       dplyr::filter(country_name != 'Democratic Republic of Vietnam',
                     country_name != 'Republic of Vietnam') %>%
       # TODO: Czechoslovakia vs. Czech Republic vs. Czechia
       dplyr::mutate(country_name = ifelse((country_name == 'Czech Republic') & (year < 1993), 
                                        'Czechoslovakia', country_name)) %>% 
       # convert country names
       dplyr::mutate(country.name.en.regex = CountryToRegex(country_name)) %>%
       dplyr::select(country.name.en.regex, vdem.name = country_name, vdem = country_id, year)

# Hack to artificially extend the temporal coverage of panel datasets using the
# last available year
extend_coverage = function(dat, last_year = 2019) {
    out = dat
    tmp = dat %>% 
          dplyr::filter(year == max(year))
    for (y in base::setdiff(2000:last_year, dat$year)) {
        tmp$year = y
        out = rbind(out, tmp)
    }
    return(out)
}
p4 = extend_coverage(p4)
cow = extend_coverage(cow)
vdem = extend_coverage(vdem)

# Hard choices
p4 = p4 %>%
         dplyr::filter(# overlapping years; pick one arbitrarily
                      (year != 1832) | (p4c != 'GCL'), # Gran Colombia vs. Colombia
                      (year != 1861) | (p4c != 'SAR'), # Sardinia vs. Italy
                      (year != 1993) | (p4c != 'ETI'), # Ethiopia
                      (year != 2011) | (p4c != 'SDN'), # Sudan
                      (year != 1976) | (p4c != 'DRV'), # Vietnam North vs. Vietnam
                      (year != 1922) | (p4c != 'USR'), # USSR
                      (year != 1991) | (p4c != 'YGS'), # Yugoslavia
                      (year != 1945) | (p4c != 'GFR'), # Germany vs. West Germany
                      (year != 1990) | (p4c != 'GFR'), # Germany vs. West Germany
                      ) 
cow = cow %>%
      dplyr::filter(# overlapping years; pick one arbitrarily
                    (year != 1990) | (cowc != 'GFR') # Germany vs. West Germany
                    )
vdem = vdem %>%
       dplyr::filter(# countrycode does not have separate regexes for the West Bank and Gaza
                     vdem.name != 'Palestine/West Bank',
                     (year != 1948) | (vdem.name != 'Palestine/Gaza')
                     )

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

# Add small countries not covered by V-Dem, CoW, or Polity
small = read.csv('dictionary/data_small_countries.csv', na.strings = '') %>%
        dplyr::mutate(end = ifelse(is.na(end), max(dat$year), end),
                      country.name.en.regex = CountryToRegex(country)) %>%
        dplyr::select(country.name.en.regex, start, end) %>%
        dplyr::filter(!country.name.en.regex %in% dat$country.name.en.regex) %>% # avoid duplicates
        na.omit # TODO: Most for Aland Islands problem
small = lapply(1:nrow(small), function(i) 
                              data.frame('country.name.en.regex' = small$country.name.en.regex[i],
                                         'year' = small$start[i]:small$end[i]))
dat = dplyr::bind_rows(c(list(dat), small))

# Sanity check
variables <- colnames(dat)[colnames(dat) != 'year']
for (v in variables) {
    tmp <-  dat[, c(v, 'year')]
    tmp <- na.omit(tmp)
    bad <- nrow(tmp) != nrow(unique(tmp))
    if (bad) {
        stop('Duplicate country-year observations.')
    }
}

# Save 
dat = dat %>% dplyr::arrange(country.name.en.regex, year)
readr::write_csv(dat, 'dictionary/data_panel.csv', na = '')
