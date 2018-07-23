# single variable maps
maps = list()
for (d in dat) {
    for (code in setdiff(colnames(d), 'country.name.en.regex')) {
        maps[[code]] = d[, c('country.name.en.regex', code)]
	    maps[[code]] = na.omit(unique(maps[[code]]))
	}
}

# sanity check: no dups
dups = list()
for (n in names(maps)) {
    dup = maps[[n]][[n]]
    dup = dup[duplicated(dup)]
    if (length(dup) > 0) {
		stop(paste('Duplicate codes in ', n))
    }
}

# many-to-one requires different maps
maps_origin = maps_destination = maps
drop_dups = function(variable, dups) {
    out = maps_destination[[variable]]
    out = out[!out[[variable]] %in% dups, ]
    return(out)
}
maps_destination$cowc = drop_dups('cowc', 'KOR')
maps_destination$cown = drop_dups('cown', 730)
maps_destination$cow.name = drop_dups('cow.name', 'Korea')
maps_destination$p4n = drop_dups('p4n', c(625, 730, 769, 529, 345))
maps_destination$p4c = drop_dups('p4c', c('SUD', 'KOR', 'PKS', 'ETI', 'YGS'))
maps_destination$p4.name = drop_dups('p4.name', c('Sudan-North', 'Korea'))

# merge origin and destination maps
valid_origin = c("cowc", "cown", "ecb", "eurostat", "fao", "fips", "gaul",
"genc2c", "genc3c", "genc3n", "imf", "ioc", "iso2c", "iso3c", "iso3n", "p4c",
"p4nj", "un", "un_m49", "unpd", "vdem", "wb", "wb_api2c", "wb_api3c", "wvs",
"country.name.en.regex", "country.name.de.regex")
maps = list()
for (orig in intersect(valid_origin, names(maps_origin))) {
    cat(orig, '\n')
    maps[[orig]] = maps_destination %>% 
                   purrr::map(~ merge(maps_origin[[orig]], .)) %>%
                   purrr::map(na.omit) %>%
                   purrr::map(unique) 
}

# drop useless columsn
for (o in names(maps)) {
    for (d in names(maps[[o]])) {
        maps[[o]][[d]] = maps[[o]][[d]][, c(o, d)]
    }
}

# sanity checks: many-to-one cannot have duplicate origin codes
for (o in names(maps)) { # loop over origin codes
    for (d in names(maps[[o]])) { # loop over destination codes
        dup = anyDuplicated(maps[[o]][[d]][, o])
        if (dup > 0) {
            stop(paste('duplicated origin code(s) in', o, ':', d))
        }
    }
}

# codelist
codelist = maps_destination %>% 
           purrr::reduce(dplyr::full_join, by = 'country.name.en.regex')

# save to file
codelist_map = maps
saveRDS(dat, 'data/backup.rds', compress = 'xz')
save(codelist, file = 'data/codelist.rda', compress = 'xz')
save(codelist_map, file = 'data/codelist_map.rda', compress = 'xz')
