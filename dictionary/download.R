# Source: TRUE -- web source has priority. FALSE -- backup source has priority. 
src = c('regex' = TRUE, # regex must always be true
        'cldr' = FALSE,
        'cow' = TRUE,
        'ecb' = TRUE,
        'eurostat' = TRUE,
        'fao' = TRUE,
        'fips' = TRUE,
        'genc' = TRUE,
        'ioc' = TRUE,
        'iso' = FALSE,
        'polity4' = TRUE,
        'un' = TRUE,
        'un_names' = FALSE,
        'unpd' = FALSE,
        'vdem' = TRUE,
        'world_bank' = TRUE,
        'world_bank_api' = TRUE,
        'wvs' = TRUE)

# Load from internet
dat = lapply(names(src)[src], LoadSource)
names(dat) = names(src)[src]

# Load from local backup
bak = readRDS('data/backup.rds')
for (n in setdiff(names(bak), names(dat))) {
    dat[[n]] = bak[[n]]
}

# TODO: delete this hack -- Remove extraneous datasets from backup
dat = dat[names(dat) %in% names(src)]
