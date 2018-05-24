context('Usage of a custom dictionary')

test_that('custom dictionary without regex', {
    test_func <- function(iso3c_codes) countrycode(iso3c_codes, 'iso3c', 'country.name.en', custom_dict = codelist, warn = FALSE)
    expect_equal(test_func('CAN'), 'Canada')
    expect_equal(test_func(c('USA', 'CAN')), c('United States', 'Canada'))
    expect_equal(test_func(c('USA', 'CAN', 'XXX')), c('United States', 'Canada', NA))
})

test_that('custom dictionary with regex', {
    test_func <- function(countrynames) countrycode(countrynames, 'country.name.en.regex', 'iso3c', custom_dict = codelist, origin_regex = TRUE, warn = FALSE)
    expect_equal(test_func('West Germany'), 'DEU')
    expect_equal(test_func(c('U.S.A.', 'West Germany')), c('USA', 'DEU'))
    expect_equal(test_func(c('U.S.A.', 'West Germany', 'XXX')), c('USA', 'DEU', NA))
})

test_that('canadian provinces test', {
    dict <- data.frame('regex' = c('qu.bec', 'alberta', 'british.columbia'),
                       'abbreviation' = c('QC', 'AB', 'BC'),
                       'province' = c('Quebec', 'Alberta', 'British Columbia'),
                       stringsAsFactors = FALSE)
    expect_equal(countrycode('Québec', 'regex', 'abbreviation', custom_dict = dict, origin_regex = TRUE), 'QC')
    expect_equal(countrycode(c('Alberta', 'British Columbia'), 'regex', 'abbreviation', custom_dict = dict, origin_regex = TRUE), c('AB', 'BC'))
    expect_equal(countrycode('QC', 'abbreviation', 'province', custom_dict = dict), 'Quebec')
})
