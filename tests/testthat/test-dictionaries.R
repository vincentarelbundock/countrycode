# Note: The panel test takes a while
context('Duplicate entries in the dictionaries')

# Duplicates allowed in these codes
destination_codes = c('ar5', 'continent', 'eu28', 'eurocontrol_pru',
                      'eurocontrol_statfor', 'icao', 'icao.region',
                      'region')

# Load data
cs = countrycode::codelist
panel = countrycode::codelist_panel

# Cross-section
test_that('no duplicated entries in the cross-sectional dictionary (required for one-to-one mapping)', {
    destination_codes = c('ar5', 'continent', 'eu28', 'eurocontrol_pru',
                          'eurocontrol_statfor', 'icao', 'icao.region',
                          'region')
    f = function(x) any(duplicated(na.omit(x)))
    dup = apply(cs, 2, f)
    dup = sort(names(dup[dup]))
    duplicate_codes = dup[!dup %in% destination_codes]
    expect_length(duplicate_codes, 0)
    if (length(duplicate_codes) > 0) {
        cat('\nDuplicated cross-section entries in:', paste(duplicate_codes, collapse = ', '), '\n')
    }
})

# Panel
test_that('no duplicated country-year observations in the panel dictionary', {
    codes = colnames(panel)[!colnames(panel) %in% destination_codes]
    codes = codes[codes != 'year']
    duplicate_codes = character()
    for (code in codes) {
        idx = !is.na(panel[, code])
        idx = paste(panel[idx, code], panel[idx, 'year'])
        if (any(duplicated(idx))) {
            duplicate_codes = c(duplicate_codes, code)
        }
    }
    expect_length(duplicate_codes, 0)
    if (length(duplicate_codes) > 0) {
        cat('\nDuplicated panel entries in:', paste(duplicate_codes, collapse = ', '), '\n')
    }
})
