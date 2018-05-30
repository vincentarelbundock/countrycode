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
        'un_names' = FALSE,
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
panel = dat[panel_only]

# Hack: Extend time coverage of panel data
extend = function(x) {
    years = setdiff(2010:lubridate::year(Sys.Date()), x$year)
    if (length(years) == 0) {
        out = x
    } else {
        tmp = data.frame(year = years)
        out = x %>% 
              filter(year == max(year)) %>% 
              select(-year) %>% 
              merge(tmp) %>%
              select(colnames(x)) %>%
              rbind(x, .)
    }
    return(out)
}
panel = lapply(panel, extend)

# Panel merge into a rectangular data.frame
rec = expand.grid('country.name.en.regex' = dat$static$country.name.en.regex,
                  'year' = unique(unlist(lapply(panel, function(x) x$year))),
                  stringsAsFactors = FALSE)
panel = c(list(rec), panel)
panel = Reduce(dplyr::left_join, panel) %>%
        dplyr::left_join(cs[, !grepl('^cow|^p4|^vdem', colnames(cs))])

# Drop inexistent country-years from the panel
tmp = read_csv('dictionary/data_small_countries.csv') %>%
      mutate(end = ifelse(is.na(end), lubridate::year(Sys.Date()), end))
panel$exists = FALSE
for (i in 1:nrow(tmp)) {
    panel$exists = if_else((panel$iso3c == tmp$iso3c[[i]]) & (panel$year %in% tmp$start[[i]]:tmp$end[[i]]),
                           true = TRUE, false = panel$exists, missing = panel$exists)
}
panel$exists = ifelse(!is.na(panel$cowc), TRUE, panel$exists)
panel$exists = ifelse(!is.na(panel$p4c), TRUE, panel$exists)
panel$exists = ifelse(!is.na(panel$vdem), TRUE, panel$exists)
panel = panel %>% 
        filter(exists) %>%
        select(-exists)
     
# English names with priority ordering
priority = c('cldr.name.en', 'iso.name.en', 'un.name.en', 'cow.name', 'p4.name', 'vdem.name', 'country.name.en')
panel$country.name = NA
cs$country.name = NA
for (i in priority) {
    panel$country.name = ifelse(is.na(panel$country.name), panel[, i], panel$country.name)
    cs$country.name = ifelse(is.na(cs$country.name), cs[, i], cs$country.name)
}
panel$country.name.en = panel$country.name
cs$country.name.en = cs$country.name
panel$country.name = NULL
cs$country.name = NULL

# Panel: English names
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
panel = cbind(a, b) %>%
        arrange(cowc, cown, iso3c, iso3n, p4c, vdem, year)

# Save files
codelist = cs
codelist_panel = panel
saveRDS(dat, 'data/backup.rds', compress = 'xz')
save(codelist, file = 'data/codelist.rda', compress = 'xz')
save(codelist_panel, file = 'data/codelist_panel.rda', compress = 'xz')
