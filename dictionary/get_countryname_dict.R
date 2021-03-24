source(here::here('dictionary/utilities.R'))

clean_string <- function(x) {
    out <- x %>%
           str_remove_all("\\[.*|\\(.*") %>%
           str_replace_all('’', "'") %>%
           utf8_format() %>%
           str_trim()
    return(out)
}

ambiguous <- c('the Holy Land', 'Nigeri', 'Virgin Islands', 'Виргин аралдары',
               'Виргинийн гӀайренаш', 'Виргинские о-ва', "ﻞﺗﻮﻧی", 'Iberia',
               'Indien', 'Thule', 'Micronesia', 'Saint Martin') %>%
             clean_string

# countrycode::codelist reshape
dat <- codelist %>%
       select(countryname = country.name.en, matches('name')) %>%
       select(-matches('region|regex')) %>%
       pivot_longer(-countryname, values_to = 'alternative') %>%
       select(countryname, alternative) %>%
       mutate_all(clean_string) %>%
       filter(!countryname %in% c('Micronesia', 'Saint Martin')) %>%
       mutate(countryname = countrycode(countryname, 'country.name', 'country.name.en')) %>%
       filter(nchar(alternative) > 4,
              !alternative %in% ambiguous,
              !countryname %in% ambiguous,
              !duplicated(alternative), # "لتونی"matches both Latvia and Lithuania!?!
              (countryname != 'North Korea') | (alternative != 'Corée'),
              (countryname != 'North Korea') | (alternative != 'Korea'),
              (countryname != 'Serbia') | (alternative != 'Serbia and Montenegro'),
              (countryname != 'United States') | (alternative != 'Columbia'),
              (countryname != 'Germany') | (alternative != 'German Democratic Republic'),
              (countryname != 'Serbia') | (alternative != 'Yugoslavia'),
              (countryname != 'Guinea-Bissau') | (alternative != 'Guinea'),
              !alternative %in% ambiguous) %>%
       drop_na %>%
       distinct

# and or &
a <- dat
b <- dat %>% mutate(alternative = str_replace(alternative, ' and ', ' & '))
dat <- bind_rows(a, b) %>%
       arrange(countryname, alternative) %>%
       distinct %>%
       rename(country.name.en = countryname,
              country.name.alt = alternative)

# save to file
countryname_dict <- data.frame(dat)
save(countryname_dict, file = 'data/countryname_dict.rda', compress='xz', version=2)
