setwd(here::here())
source('dictionary/utilities.R')

###############
#  load data  #
###############
from_backup <- c(
    'cow_cs',
    'dhs',
    'ecb',
    'eurostat',
    'fao',
    'fips',
    'genc',
    'gw',
    'ioc',
    'icao',
    'iso',
    'polity4_cs',
    'un',
    'un_names',
    'vdem_cs',
    'world_bank',
    'world_bank_api',
    'world_bank_region',
    'wvs'
)

from_source <- c(
    'static' # static must always come from source
) 

from_panel <- c(
    'cow',
    'polity4',
    'small_countries',
    'vdem'
)

# 'unpd' web source is dead; moved to data_static.csv

backup <- readRDS('data/backup.rds')

# sanity check: missing datasets
sanity <- setdiff(from_backup, names(backup))
if (length(sanity) > 0) { 
    msg <- paste('The following data sources are not available in the backup file:', sanity)
    stop(msg)
}

dat <- list()

for (i in from_source) {
    dat[[i]] <- LoadSource(i)
}

for (i in from_backup) {
    dat[[i]] <- backup[[i]]
}

###################
#  sanity checks  #
###################

sapply(dat, SanityCheck)

###################
#  cross section  #
###################

# merge
cs <- purrr::reduce(dat, dplyr::left_join, by = 'country.name.en.regex')

# English names with priority ordering
priority <- c('cldr.name.en', 'iso.name.en', 'un.name.en', 'cow.name', 'p4.name', 'vdem.name', 'country.name.en')
cs$country.name <-  NA
for (i in priority) {
    cs$country.name <- ifelse(is.na(cs$country.name), cs[, i], cs$country.name)
}
cs$country.name.en <- cs$country.name
cs$country.name <- NULL

###########
#  panel  #
###########

tmp <- cs %>% dplyr::select(-dplyr::matches('cldr|p4|cow|vdem'))
panel <- read.csv('dictionary/data_panel.csv', na.strings = '') %>%
         dplyr::left_join(tmp, by = 'country.name.en.regex')

# Clean-up
sort_col = function(x) { # cldr columns at the end
    x = x[, sort(colnames(x))]
    idx = grepl('^cldr', colnames(x))
    x = cbind(x[, !idx], x[, idx])
    return(x)
}
cs = sort_col(cs)
panel = panel %>% select(country.name.en, year, order(names(.)))

# Sanity check: duplicates
idx = paste(panel$country.name.en, panel$year)
if (anyDuplicated(idx)) {
    stop('Duplicate country year observations in panel dataset')
}
if (anyDuplicated(cs$country.name.en)) {
    stop('Duplicate country observations in cross-sectional dataset')
}

# Encoding: convert to UTF-8 if there are non-ASCII characters
for (col in colnames(cs)[sapply(cs, class) == 'character']) {
    if (!all(na.omit(stringi::stri_enc_mark(cs[[col]])) == 'ASCII')) {
        cs[[col]] <- enc2utf8(cs[[col]])
    }
}
for (col in colnames(panel)[sapply(panel, class) == 'character']) {
    if (!all(na.omit(stringi::stri_enc_mark(panel[[col]])) == 'ASCII')) {
        panel[[col]] <- enc2utf8(panel[[col]])
    }
}

# Save files
codelist = cs
codelist_panel = panel
saveRDS(dat, 'data/backup.rds', compress = 'xz', version = 2)
save(codelist, file = 'data/codelist.rda', compress = 'xz', version = 2)
save(codelist_panel, file = 'data/codelist_panel.rda', compress = 'xz', version = 2)
