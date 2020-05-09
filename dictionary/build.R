setwd(here::here())
source('dictionary/utilities.R')


###############
#  load data  #
###############

from_backup <- c(
    'cldr',
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
    'un',
    'un_names',
    'world_bank',
    'world_bank_api',
    'world_bank_region',
    'wvs'
)

from_source <- c(
    'cow',
    'polity4',
    'small_countries',
    'vdem'
) 


# 'unpd' web source is dead; moved to data_static.csv

backup <- readRDS('dictionary/data_backup.rds')

# sanity check: missing datasets
sanity <- setdiff(from_backup, names(backup))
if (length(sanity) > 0) { 
    msg <- paste('The following data sources are not available in the backup file:', sanity)
    stop(msg)
}

dat <- list()

dat[['static']] <- LoadSource('static')

for (i in from_source) {
    dat[[i]] <- LoadSource(i)
}

for (i in from_backup) {
    dat[[i]] <- backup[[i]]
}


###################
#  sanity checks  #
###################

all(sapply(dat, SanityCheck))

# overwrite backup
for (i in from_source) {
    backup[[i]] <- dat[[i]]
}


###################
#  cross-section  #
###################

idx <- sapply(dat, function(x) !'year' %in% names(x))
cs <- dat[idx] %>% reduce(left_join, by = 'country.name.en.regex')

# sanity check
SanityCheck(cs)
checkmate::assert_true(nrow(cs) > 250)
checkmate::assert_true(ncol(cs) > 50)


###########
#  panel  #
###########

idx <- sapply(dat, function(x) 'year' %in% names(x))
pan <- dat[idx]
pan <- lapply(pan, ExtendCoverage, last_year = 2020)

cou <- sapply(pan, function(x) x$country.name.en.regex) %>% unlist %>% unique
yea <- sapply(pan, function(x) x$year) %>% unlist %>% unique
yea <- min(yea):max(yea)
rec <- expand_grid(country.name.en.regex = cou,
                   year = yea)
pan <- c(list(rec), pan) %>%
       purrr::reduce(left_join, by = c('country.name.en.regex', 'year'))

idx <- (pan[, 3:ncol(pan)] %>% is.na %>% rowSums) != (ncol(pan) - 2)
pan <- pan[idx,]

###########
#  merge  #
###########

# merge last panel observation into cs
tmp <- pan %>%
       arrange(country.name.en.regex, year) %>%
       group_by(country.name.en.regex) %>%
       mutate_at(vars(-group_cols()), na.locf, na.rm = FALSE) %>% 
       filter(year == max(year)) %>%
       # arbitrary choices
       mutate(p4n = ifelse(p4.name == 'Prussia', NA, p4n),
              p4c = ifelse(p4.name == 'Prussia', NA, p4c),
              p4n = ifelse(p4.name == 'Serbia and Montenegro', NA, p4n),
              p4c = ifelse(p4.name == 'Serbia and Montenegro', NA, p4c),
              vdem = ifelse(vdem.name == 'Czechoslovakia', NA, vdem))

cs <- cs %>% 
      left_join(tmp, by = 'country.name.en.regex') %>%
      select(-year)

# english names with priority
priority <- c('cldr.name.en', 'iso.name.en', 'un.name.en', 'cow.name', 'p4.name', 'vdem.name', 'country.name.en')
cs$country.name <-  NA
for (i in priority) {
    cs$country.name <- ifelse(is.na(cs$country.name), cs[, i], cs$country.name)
}
cs$country.name.en <- cs$country.name
cs$country.name <- NULL

# merge cs into pan
idx <- c('country.name.en.regex', setdiff(colnames(cs), colnames(pan)))
pan <- pan %>% 
       left_join(cs[, idx], by = 'country.name.en.regex') %>%
       select(-matches('name$|cldr'))


###########
#  clean  #
###########

idx <- c('country.name.en.regex', setdiff(colnames(cs), colnames(pan)))
pan <- pan %>%
       left_join(cs[, idx], by = 'country.name.en.regex') %>%
       select(country.name.en, year, order(names(.))) %>%
       select(-matches('cldr|name$|iso.name|un.name')) %>%
       arrange(country.name.en, year)

idx1 <- sort(grep('cldr', colnames(cs), value = TRUE))
idx2 <- sort(setdiff(colnames(cs), idx1))

cs <- cs[, c(idx1, idx2)] %>%
      arrange(country.name.en)


############
#  sanity  #
############

# Encoding: convert to UTF-8 if there are non-ASCII characters
for (col in colnames(cs)[sapply(cs, class) == 'character']) {
    if (!all(na.omit(stringi::stri_enc_mark(cs[[col]])) == 'ASCII')) {
        cs[[col]] <- enc2utf8(cs[[col]])
    }
}

for (col in colnames(pan)[sapply(pan, class) == 'character']) {
    if (!all(na.omit(stringi::stri_enc_mark(pan[[col]])) == 'ASCII')) {
        pan[[col]] <- enc2utf8(pan[[col]])
    }
}

SanityCheck(cs)
SanityCheck(pan)


###########
##  save  #
###########

codelist <- cs
codelist_panel <- pan

saveRDS(dat, 'dictionary/data_backup.rds', compress = 'xz', version = 2)
save(codelist, file = 'data/codelist.rda', compress = 'xz', version = 2)
save(codelist_panel, file = 'data/codelist_panel.rda', compress = 'xz', version = 2)

