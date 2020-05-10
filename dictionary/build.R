setwd(here::here())
source('dictionary/utilities.R')


##################
#  availability  #
##################

scrapers <- Sys.glob('dictionary/get_*.R')
datasets <- Sys.glob('dictionary/data_*.csv')
datasets <- datasets[datasets != 'dictionary/data_regex.csv']

# missing scrapers and datasets
tokens_datasets <- str_replace_all(datasets, '.*data_|.csv', '')
tokens_scrapers <- str_replace_all(scrapers, '.*get_|.R', '')

if (length(setdiff(tokens_scrapers, tokens_datasets)) > 0) {
    msg <- paste(setdiff(tokens_scrapers, tokens_datasets), collapse = ', ')
    msg <- paste('Missing datasets:', msg)
    stop(msg)
}

if (length(setdiff(tokens_datasets, tokens_scrapers)) > 0) {
    msg <- paste(setdiff(tokens_datasets, tokens_scrapers), collapse = ', ')
    msg <- paste('Missing scrapers:', msg)
    warning(msg)
}


###############
#  load data  #
###############

dat <- list()
dat$regex <- read_csv('dictionary/data_regex.csv', col_types = cols(), progress = FALSE)

message('Load:')
for (i in seq_along(datasets)) {
    message('  ', tokens_datasets[i])
    tmp <- read_csv(datasets[i], col_types = cols(), progress = FALSE) %>%
           mutate(country.name.en.regex = CountryToRegex(country)) %>%
           select(-country)
    SanityCheck(tmp)
    dat[[tokens_datasets[i]]] <- tmp
}

# Namibia iso2c is not missing
dat$iso$iso2c[dat$iso$iso.name.en == 'Namibia'] <- 'NA'


###################
#  cross-section  #
###################

idx <- sapply(dat, function(x) !'year' %in% names(x))
cs <- dat[idx] %>% 
      reduce(left_join, by = 'country.name.en.regex')

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
priority <- c('cldr.name.en', 'iso.name.en', 'un.name.en', 'cow.name',
              'p4.name', 'vdem.name', 'country.name.en')
cs$country.name <-  NA
for (i in priority) {
    cs$country.name <- ifelse(is.na(cs$country.name), cs[[i]], cs$country.name)
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
       arrange(country.name.en, year) %>%
       select(country.name.en, year, order(names(.))) %>%
       select(-matches('cldr|name$|iso.name|un.name'))

idx1 <- sort(grep('cldr', colnames(cs), value = TRUE))
idx2 <- sort(setdiff(colnames(cs), idx1))

cs <- cs[, c(idx2, idx1)] %>%
      arrange(country.name.en)


##########
#  utf8  #
##########

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


###########
##  save  #
###########

codelist <- cs
codelist_panel <- pan

save(codelist, file = 'data/codelist.rda', compress = 'xz', version = 2)
save(codelist_panel, file = 'data/codelist_panel.rda', compress = 'xz', version = 2)

