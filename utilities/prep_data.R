library(devtools)
document()

dat = read.csv('data/countrycode_data.csv', stringsAsFactors=FALSE, na.strings=c(''))
dat$iso2c[dat$country.name.en=='Namibia'] = 'NA'
cn = grep('country.name', colnames(dat))
for(n in cn){
    dat[, n] = iconv(dat[, n], to='UTF-8')
}
num = c('cown', 'fao', 'imf', 'iso3n', 'un')
for(n in num){
    dat[, n] = as.numeric(dat[, n])
}
countrycode_data = dat
row.names(countrycode_data) = NULL

save(countrycode_data, file='data/countrycode_data.rda')
