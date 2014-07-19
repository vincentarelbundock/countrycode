context('Basic conversions')

test_that('valid iso3c to country.name works', {
    name_of <- function(iso3c_code) countrycode(iso3c_code, 'iso3c', 'country.name')
    
    expect_that(name_of('CAN'), equals('Canada'))
    expect_that(name_of(c('USA', 'CAN')), equals(c('United States', 'Canada')))
})

test_that('invalid iso3c to country.name returns NA', {
    name_of <- function(iso3c_code) countrycode(iso3c_code, 'iso3c', 'country.name')
    
    expect_that(name_of(NA), equals(NA_character_))
    expect_that(name_of('BAD'), equals(NA_character_))
    expect_that(name_of(c('BAD', 'BLA', 'CAN')), equals(c(NA_character_, NA_character_, 'Canada')))
})

test_that('invalid cowc to iso3c returns NA', {
    iso3c_of <- function(cowc_code) countrycode(cowc_code, 'cowc', 'iso3c')
    
    expect_that(iso3c_of(NA), equals(NA_character_))
})

test_that('warn=TRUE gives warnings, but does not break conversion', {
    iso2c_of <- function(cowc_code) countrycode(cowc_code, 'cowc', 'iso2c', warn=TRUE)
    
    expect_that(val <- iso2c_of('BLA'), gives_warning('not matched'))
    expect_that(val, equals(NA_character_))
    
    expect_that(val <- iso2c_of(c('ALG', 'USA')), not(gives_warning()))
    expect_that(val, equals(c('DZ','US')))
    
    expect_that(val <- iso2c_of(c('BLA', 'USA')), gives_warning('not matched'))
    expect_that(val, equals(c(NA_character_,'US')))
})

test_that('warn=FALSE does not give warnings', {
    iso2c_of <- function(cowc_code) countrycode(cowc_code, 'cowc', 'iso2c', warn=FALSE)
    
    expect_that(iso2c_of('BLA'), not(gives_warning()))
    expect_that(iso2c_of(c('BLA', 'USA')), not(gives_warning()))
})

code_names <- names(countrycode_data)[names(countrycode_data) != c('regex', 'continent', 'region')]

for(code_name in code_names){
    code_list <- countrycode_data[, code_name]
    dupes <- code_list[duplicated(code_list, incomparables=NA)]
    dupes <- toString(dupes)
    test_that(paste('there are zero duplicate', code_name, 'code values'), {
        expect_that(dupes, equals(''))
    })
}