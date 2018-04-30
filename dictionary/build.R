source('dictionary/utilities.R')

# Source: TRUE -- web source has priority. FALSE -- backup source has priority. 
src = c('cldr' = FALSE,
        'cow' = FALSE,
        'cow_cs' = FALSE,
        'ecb' = FALSE,
        'eurostat' = FALSE,
        'fao' = FALSE,
        'fips' = FALSE,
        'genc' = FALSE,
        'ioc' = FALSE,
        'iso' = FALSE,
        'polity4' = FALSE,
        'polity4_cs' = FALSE,
        'un' = FALSE,
        'unpd' = FALSE,
        'vdem' = TRUE,
        'vdem_cs' = TRUE,
        'world_bank' = FALSE,
        'world_bank_api' = FALSE,
        'wvs' = FALSE)
src = c('static' = TRUE, src) # static must always be true
panel_only = c('cow', 'polity4', 'vdem')
crosssection_only = c('cow_cs', 'polity4_cs', 'vdem_cs')

# Flip toggle back to TRUE if dataset is not available in backup
bak = readRDS('data/backup.rds')
src[!names(src) %in% names(bak)] = TRUE

# Download
dat = lapply(names(src)[src], LoadSource)
names(dat) = names(src)[src]

# Sanity checks (drop datasets that fail)
dat = SanityCheck(dat)

# Overwrite from backup if src toggle is FALSE and dataset is already stored in backup file
for (n in names(src)[!src]) {
    if (n %in% names(bak)) {
        cat('Loading', n, 'from backup.\n')
        dat[[n]] = bak[[n]]
    }
}

# Sanity check: duplicate merge id
for (n in names(dat)) {
    if ('year' %in% colnames(dat[[n]])) {
        idx = paste(dat[[n]]$country.name.en.regex, dat[[n]]$year)
    } else {
        idx = dat[[n]]$country.name.en.regex
    }
    if (any(duplicated(idx))) {
        stop('Dataset ', n, ' includes duplicate country (or country-year) indices.')
    }
}

# Cross-section
cs = Reduce(dplyr::left_join, dat[!names(dat) %in% panel_only])

# Panel
rec = expand.grid('country.name.en.regex' = dat$static$country.name.en.regex,
                  'year' = 1800:2017,
                  stringsAsFactors = FALSE)
panel = c(list(rec), dat[panel_only])
panel = Reduce(dplyr::left_join, panel) %>%
        dplyr::left_join(cs[, !grepl('^cow|^p4', colnames(cs))])
     
# English names: Priority ordering
priority = c('cldr.name.en', 'iso.name.en', 'un.name.en', 'cow.name', 'p4.name', 'country.name.en')

# English names: Panel
tmp = rep(NA, nrow(panel))
for (i in priority) {
    tmp = ifelse(is.na(tmp), panel[, i], tmp)
}
panel$country.name.en = tmp

# English names: Cross-sectional
tmp = rep(NA, nrow(cs))
for (i in priority) {
    tmp = ifelse(is.na(tmp), cs[, i], tmp)
}
cs$country.name.en = tmp

# Clean-up
sort_col = function(x) { # cldr columns at the end
    x = x[, sort(colnames(x))]
    idx = grepl('^cldr', colnames(x))
    x = cbind(x[, !idx], x[, idx])
    return(x)
}
cs = sort_col(cs)
panel = sort_col(panel)

# Exclude name columns for panel to save space
a = panel %>% dplyr::select(country.name.en, year)
b = panel %>% dplyr::select(-matches('cldr|name|regex|year'))
panel = cbind(a, b)

# Save files
codelist = cs
codelist_panel = panel
saveRDS(dat, 'data/backup.rds', compress = 'xz')
save(codelist, file = 'data/codelist.rda', compress = 'xz')
save(codelist_panel, file = 'data/codelist_panel.rda', compress = 'xz')
