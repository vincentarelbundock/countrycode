library(devtools)
library(dplyr)
library(magrittr)
document()

countrycode_data = tbl_df(read.csv('data/countrycode_data.csv', stringsAsFactors=FALSE, na.strings=''))
aviation_data = tbl_df(read.csv('data/aviation_data.csv', stringsAsFactors=FALSE, na.strings=''))
countrycode_data %<>%
  full_join(aviation_data, by = "country_name") %>%
  rename(country.name = country_name)

# colnames(countrycode_data)[1] = 'country.name'
countrycode_data$iso2c[countrycode_data$country.name=='Namibia'] = 'NA'
countrycode_data$regex = iconv(countrycode_data$regex, to='UTF-8')
devtools::use_data(countrycode_data, overwrite = TRUE)
