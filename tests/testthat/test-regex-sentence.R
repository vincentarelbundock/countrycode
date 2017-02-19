context('Use of regexes in sentences')

f = function(k) gsub('COUNTRY', k, 'The governement of COUNTRY was reelected.')
origin = countrycode::countrycode_data$country.name.en
sentence = sapply(origin, f)
target = countrycode(sentence, 'country.name', 'country.name')
problems = origin[is.na(target)]

test_that('countrycode can catch countries in the middle of a sentence', {
    expect_equal(length(problems), 0)
})

test_that('sentence with two matches returns NA',{
    expect_equal(countrycode('report from Canada and the United States.', 'country.name', 'country.name'), NA_character_)
})

test_that('sentence with a single match',{
    expect_equal(countrycode('report from Canada.', 'country.name', 'country.name'), 'Canada')
})

test_that('known issues with previous versions of countrycode',{
    # http://stackoverflow.com/questions/42235490/from-string-to-regex-to-new-string
    expect_equal(countrycode('Stuff happens in North Korea', 'country.name', 'iso3c'), 'PRK')
    expect_equal(countrycode('I heard that Ireland is beautiful.', 'country.name', 'iso3c'), 'IRL')
    expect_equal(countrycode('   Ireland    ', 'country.name', 'iso3c'), 'IRL')
})
