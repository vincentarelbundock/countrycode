library(devtools)
document()

colClasses <- c(cown = 'integer', fao = 'integer', imf = 'integer',
                iso3n = 'integer', un = 'integer')

dat <- read.csv('data/countrycode_data.csv', stringsAsFactors = FALSE,
                na.strings = '', encoding = 'UTF-8', fileEncoding = 'UTF-8',
                row.names = NULL, colClasses = colClasses)

# check that numeric codes were imported as 'integer' class
intCols <- c('cown', 'fao', 'imf', 'iso3n', 'un')
if (!all(sapply(dat[, intCols], class) == 'integer'))
  warning('some numeric code columns are not classed as integer')

# check that iso2c for Namibia is 'NA' (string) not NA
if (is.na(dat$iso2c[dat$country.name.en == 'Namibia']))
  warning('iso2c is <NA> instead of a string "NA"')

# check that a string was properly encoded as UTF-8 (if true, assume rest were also)
if (Encoding(dat$country.name.ar[dat$country.name.en == 'Afghanistan']) != 'UTF-8')
  warning('UTF-8 encoding may not have been set on strings where necessary')

# check that row names are "automatic", not explicitly set (negative number means automatic)
if (.row_names_info(dat) > -1) warning('row names have been set manually')

countrycode_data <- dat

save(countrycode_data, file = 'data/countrycode_data.rda')
