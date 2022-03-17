source(here::here('dictionary/utilities.R'))

url = 'https://stillmed.olympics.com/media/Document%20Library/OlympicOrg/Documents/National-Olympic-Committees/List-of-National-Olympic-Committees-in-IOC-Protocol-Order.pdf'

# Notes as of 2022-03-17:
# This document is linked from https://olympics.com/ioc/documents/olympic-movement/list-of-nocs
# Despite a description that it is from 2013-02-14, the PDF was actually authored on 2019-05-27.
# The earlier date must be incorrect, since the South Sudan NOC didn't exist.

ioc = url %>%
  pdftools::pdf_text() %>%
  str_split('\n\n') %>%
  purrr::flatten_chr() %>%
  str_extract('[A-Z]{3}\\s+.+?(?=\\s{2})') %>%
  str_squish() %>%
  as_tibble() %>%
  separate(value, c('ioc','country'), extra = "merge") %>%
  filter(!ioc %in% c(NA,"NOC","IOA","IOP","EOR")) %>%
  relocate(country) %>%
  arrange(country)

ioc %>% write_csv('dictionary/data_ioc.csv', na = "")
