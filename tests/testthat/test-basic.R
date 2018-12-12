context('Basic conversions')

test_that('valid iso3c to country.name works', {
    name_of <- function(iso3c_code) countrycode(iso3c_code, 'iso3c', 'country.name')
    expect_equal(name_of('CAN'), 'Canada')
    expect_equal(name_of(c('USA', 'CAN')), c('United States', 'Canada'))
})

test_that('invalid iso3c to country.name returns NA', {
    name_of <- function(iso3c_code) countrycode(iso3c_code, 'iso3c', 'country.name', warn = FALSE)
    expect_equal(name_of('BAD'), NA_character_)
    expect_equal(name_of(c('BAD', 'BLA', 'CAN')), c(NA_character_, NA_character_, 'Canada'))
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

allow_duplicates = c('ar5', 'continent', 'eu28', 'eurocontrol_pru',
                     'eurocontrol_statfor', 'icao', 'icao.region', 'region') 
cn = colnames(codelist)[!colnames(codelist) %in% allow_duplicates]
for(code_name in cn){
    code_list <- codelist[, code_name]
    code_list <- na.omit(code_list)
    dupes <- code_list[duplicated(code_list)]
    dupes <- toString(dupes)
    test_that(paste('there are zero duplicate', code_name, 'code values'), {
        expect_equal(dupes, '')
    })
}
