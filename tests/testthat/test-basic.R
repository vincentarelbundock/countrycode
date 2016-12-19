context('Basic conversions')

test_that('valid iso3c to country.name works', {
    name_of <- function(iso3c_code) countrycode(iso3c_code, 'iso3c', 'country.name')

    expect_equal(name_of('CAN'), 'Canada')
    expect_equal(name_of(c('USA', 'CAN')), c('United States', 'Canada'))
})

test_that('invalid iso3c to country.name returns NA', {
    name_of <- function(iso3c_code) countrycode(iso3c_code, 'iso3c', 'country.name')

    expect_equal(name_of(NA), NA_character_)
    expect_equal(name_of('BAD'), NA_character_)
    expect_equal(name_of(c('BAD', 'BLA', 'CAN')), c(NA_character_, NA_character_, 'Canada'))
})

test_that('invalid cowc to iso3c returns NA', {
    iso3c_of <- function(cowc_code) countrycode(cowc_code, 'cowc', 'iso3c')

    expect_equal(iso3c_of(NA), NA_character_)
})

test_that('warn=TRUE gives warnings, but does not break conversion', {
    iso2c_of <- function(cowc_code) countrycode(cowc_code, 'cowc', 'iso2c', warn=TRUE)

    expect_warning(val <- iso2c_of('BLA'), 'not matched')
    expect_equal(val, NA_character_)

    expect_warning(val <- iso2c_of(c('ALG', 'USA')), NA)
    expect_equal(val, c('DZ','US'))

    expect_warning(val <- iso2c_of(c('BLA', 'USA')), 'not matched')
    expect_equal(val, c(NA_character_,'US'))
})

test_that('warn=FALSE does not give warnings', {
    iso2c_of <- function(cowc_code) countrycode(cowc_code, 'cowc', 'iso2c', warn=FALSE)

    expect_warning(iso2c_of('BLA'), NA)
    expect_warning(iso2c_of(c('BLA', 'USA')), NA)
})

code_names <- names(countrycode_data)[!names(countrycode_data) %in% c('regex', 'continent', 'region')]

code_dups = code_names[!code_names %in% c('eu28', 'ar5')]
for(code_name in code_dups){
    code_list <- countrycode_data[, code_name]
    dupes <- code_list[duplicated(code_list, incomparables=NA)]
    dupes <- toString(dupes)
    test_that(paste('there are zero duplicate', code_name, 'code values'), {
        expect_equal(dupes, '')
    })
}
