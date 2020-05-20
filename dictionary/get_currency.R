library(readxl)
library(dplyr)
library(countrycode)
library(readr)

url <- 'https://www.currency-iso.org/dam/downloads/lists/list_one.xls'
download.file(url, tmpxls <- tempfile(fileext = '.xls'), quiet = TRUE)

read_excel(tmpxls, skip = 3) %>%
  filter(is.na(Fund)) %>%  # filter out "fund" currencies
  filter(!is.na(`Alphabetic Code`)) %>%   # filter out rows with no currency code (currently Antartica, Palestine, South Georgia)
  mutate(country = countrycode(ENTITY, 'country.name', 'country.name', warn = FALSE)) %>%
  filter(!is.na(country)) %>%   # filter out unmatched countries (currently e.g. EU, IMF, ZZ08_Gold, etc.)
  # filter out some currencies for countries that have more than one
  filter(!(country == "Bhutan" & Currency == "Indian Rupee")) %>%
  filter(!(country == "Cuba" & Currency == "Peso Convertible")) %>%
  filter(!(country == "El Salvador" & Currency == "El Salvador Colon")) %>%
  filter(!(country == "Haiti" & Currency == "US Dollar")) %>%
  filter(!(country == "Lesotho" & Currency == "Rand")) %>%
  filter(!(country == "Namibia" & Currency == "Rand")) %>%
  filter(!(country == "Panama" & Currency == "US Dollar")) %>%
  filter(!(country == "Uruguay" & Currency == "Unidad Previsional")) %>%
  mutate(`Numeric Code` = as.numeric(`Numeric Code`)) %>%
  select(country, currency = Currency, iso4217c = `Alphabetic Code`,
         iso4217n = `Numeric Code`) %>%
  assertr::assert(is_uniq, country) %>%
  assertr::assert(not_na, country, currency, iso4217c, iso4217n) %>%
  write_csv('dictionary/data_currency.csv', na = '')

unlink(tmpxls)
