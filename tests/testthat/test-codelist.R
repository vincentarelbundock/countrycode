
cs <- countrycode::codelist
pan <- countrycode::codelist_panel

dest <- c('year', 'ar5', 'continent', 'currency', 'eu28', 'eurocontrol_pru',
          'eurocontrol_statfor', 'icao', 'icao.region', 'iso4217c',
          'iso4217n','region', 'region23', 'un.region.name', 'un.region.code',
          'un.regionsub.name', 'un.regionsub.code', 'telephone',
          'un.regionintermediate.name', 'un.regionintermediate.code', 'unhcr.region')

##############
#  codelist  #
##############

context('codelist')

# class
test_that('codelist is a data.frame', {
    expect_true(inherits(cs, 'data.frame'))
})

# dimensions
test_that('codelist has (roughly) correct dimensions', {
    expect_gt(nrow(cs), 250)
    expect_lt(nrow(cs), 300)
    expect_gt(ncol(cs), 600)
    expect_lt(ncol(cs), 650)
})

# columns
cols <- c('country.name.en.regex', 'country.name.en', 'iso3c', 'cowc', 'p4c', 'vdem')
for (i in cols) {
    test_that(paste('codelist includes', i), {
        expect_true(i %in% colnames(cs))
    })
}

# missing
test_that('codelist missing values', {
    expect_false(any(is.na(cs$country.name.en.regex)))
    expect_false(any(is.na(cs$country.name.en)))
    expect_lt(mean(is.na(cs$iso3c)), .2)
    expect_lt(mean(is.na(cs$cowc)), .3)
    for (i in colnames(cs)) {
        expect_false(all(is.na(cs[[i]])))
    }
})

cols <- setdiff(colnames(cs), c('dhs', 'eu28', 'un.regionintermediate.name',
                                'un.regionintermediate.code'))
for (i in cols) {
    msg <- paste(i, 'has less than 50% missing observations')
    test_that(msg, {
        expect_lt(mean(is.na(cs[[i]])), .5)
    })
}


# duplicate
for (i in colnames(cs)) {
    if (!i %in% dest) {
        test_that(paste0('codelist$', i, ' has no duplicates'), {
            expect_equal(anyDuplicated(na.omit(cs[[i]])), 0)
         })
    }
}

# literal NAs
test_that('codelist has no literal "NA"s (except Namibia)', {
  cs_no_namibia <- subset(cs, country.name.en != 'Namibia')
  for (i in colnames(cs_no_namibia)) {
      expect_false(any(cs_no_namibia[[!!i]] == 'NA', na.rm = TRUE))
  }
})

###########
#  panel  #
###########

context('codelist_panel')

# class
test_that('codelist_panel is a data.frame', {
    expect_true(inherits(pan, 'data.frame'))
})

# dimensions
test_that('codelist_panel has (roughly) correct dimensions', {
    expect_gt(nrow(pan), 25000)
    expect_lt(nrow(pan), 30000)
    expect_gt(ncol(pan), 40)
    expect_lt(ncol(pan), 60)
})

# columns
cols <- c('country.name.en.regex', 'country.name.en', 'year', 'iso3c', 'cowc', 'p4c', 'vdem')
for (i in cols) {
    test_that(paste('codelist_panel includes', i), {
        expect_true(i %in% colnames(pan))
    })
}

# missing
test_that('codelist_panel missing values', {
    expect_false(any(is.na(pan$country.name.en.regex)))
    expect_false(any(is.na(pan$country.name.en)))
    expect_false(any(is.na(pan$year)))
    expect_lt(mean(is.na(pan$iso3c)), .1)
    expect_lt(mean(is.na(pan$cowc)), .45)
    for (i in colnames(pan)) {
        expect_false(all(is.na(pan[[i]])))
    }
})

cols <- setdiff(colnames(pan), c('dhs', 'eu28', 'un.regionintermediate.name',
                                 'un.regionintermediate.code'))
for (i in cols) {
    msg <- paste(i, 'has less than 50% missing observations')
    test_that(msg, {
        expect_lt(mean(is.na(pan[[i]])), .5)
    })
}

# duplicate
for (i in colnames(pan)) {
    if (!i %in% dest) {
        test_that(paste0('codelist_panel$', i, ' has no duplicates'), {
            idx <- pan[, c(i, 'year')]
            idx <- na.omit(idx)
            idx <- paste(idx[[1]], idx[[2]])
            expect_equal(anyDuplicated(idx), 0)
         })
    }
}

# literal NAs
test_that('codelist_panel has no literal "NA"s (except Namibia)', {
  pan_no_namibia <- subset(pan, country.name.en != 'Namibia')
  for (i in colnames(pan_no_namibia)) {
    expect_false(any(pan_no_namibia[[!!i]] == 'NA', na.rm = TRUE))
  }
})
