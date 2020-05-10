source(here::here('dictionary/utilities.R'))

bad <- c("New Zealand Oceania", "Australia, Oceania and other territories", "Australian Oceania",
         "Palestinian Territory, Occupied", "West Germany", "Gaza and Jericho",
         "Central and South Africa countries",
         "EU 12 (fixed composition) including West Germany as of 1 November 1993")

url <- 'http://a-sdw.ecb.europa.eu/datastructure.do?conceptMnemonic=REF_AREA&datasetinstanceid=122'
ecb <- xml2::read_html(url) %>%
       rvest::html_node('#codeListTable') %>%
       rvest::html_table() %>%
       select(country = `Code Description`, ecb = `Code`) %>%
       # There are many bad country names in the ECB data. These are excluded
       # implicitly, but this is a hack and could potentially be improved. 
       filter(!country %in% bad,
              !is.na(CountryToRegex(country, warn = FALSE))) %>% 
       mutate(ecb = if_else(country == 'Namibia', 'NA', ecb))

ecb %>% write_csv('dictionary/data_ecb.csv')
