countrycode_data = read.csv('~/repo/pycountrycode/countrycode/data/countrycode_data.csv', stringsAsFactors=FALSE, na.strings='')
colnames(countrycode_data)[1] = 'country.name'
countrycode_data$iso2c[countrycode_data$country.name=='Namibia'] = 'NA'
save(countrycode_data, file='~/repo/countrycode/data/countrycode_data.rda')
