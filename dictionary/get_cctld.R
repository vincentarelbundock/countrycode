library(xml2)
library(rvest)
library(purrr)
library(dplyr)
library(countrycode)
library(readr)

url <- 'https://www.iana.org/domains/root/db'

dig_deeper <-
  function(.data) {
    country.name <- .data$country.name
    unmatched <- which(is.na(.data$country.name))

    country.name[unmatched] <-
      sapply(unmatched, function(i) {
        read_html(paste0(url, '/', sub('^\\.', '', .data$Domain[i]), '.html')) %>%
          html_node(xpath = '//*[@id="body"]/article/main/comment()[1]') %>%
          html_text() %>%
          str_match('(?<=designated for ).*(?=\\))')
      })

    # standardize country names to default countrycode$country.name
    country.name[unmatched] <-
      countrycode(country.name[unmatched], 'country.name', 'country.name',
                  warn = FALSE)

    country.name
  }

read_html(url) %>%
  html_table() %>%
  purrr::pluck(1) %>%
  as_tibble() %>%
  filter(Type == 'country-code') %>%  # only keep TLDs that are for countries
  filter(Encoding(Domain) != 'UTF-8') %>%  # don't keep TLD's that are in UTF-8
  filter(`TLD Manager` != 'Retired') %>%  # don't keep retired TLDs
  filter(Domain != '.eu') %>%  # don't keep the EU's TLD
  filter(Domain != '.su') %>%  # don't keep the obsolete TLD for Soviet Union
  filter(Domain != '.ac') %>%  # don't keep Ascension Island's TLD
  filter(!grepl('^Reserved', `TLD Manager`)) %>%  # don't keep reserved TLDs (.gb currently)
  mutate(country.name = countrycode(sub('^\\.', '', Domain),
                                    'iso2c', 'country.name', warn = FALSE)) %>%
  mutate(country = dig_deeper(.data)) %>%
  filter(!is.na(country)) %>%  # remove any unmatched TLDs (none currently)
  select(country, cctld = Domain) %>%
  write_csv('dictionary/data_cctld.csv', na = '')
