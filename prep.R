library(devtools)
document()

countrycode_data = read.csv('data/countrycode_data.csv', stringsAsFactors=FALSE, na.strings='')
colnames(countrycode_data)[1] = 'country.name'
countrycode_data$iso2c[countrycode_data$country.name=='Namibia'] = 'NA'

# ---------------------------
# One way to merge new names
wiki_names = read.csv('data/wiki_names.csv', stringsAsFactors=FALSE, na.strings='')
countrycode_data_new <- merge(countrycode_data,wiki_names,by="country.name",all.x=TRUE)
countrycode_data_new$country.name.english <- NULL
countrycode_data <- countrycode_data_new
# ---------------------------

countrycode_data$regex = iconv(countrycode_data$regex, to='UTF-8')
save(countrycode_data, file='data/countrycode_data.rda')


