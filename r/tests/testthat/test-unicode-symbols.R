context('Emoji flags')

test_that('converting to and from emoji works', {
    expect_equal(countrycode('Antarctica','country.name','unicode.symbol'), '🇦🇶')
    expect_equal(countrycode('🇦🇶','unicode.symbol','country.name'), 'Antarctica')
})

test_that('unicode.symbol-to-country.name-to-unicode.symbol is internally consistent', {
    for(unicode.symbol.original in codelist$unicode.symbol){
        if(!is.na(unicode.symbol.original)){
            name <- countrycode(unicode.symbol.original, 'unicode.symbol', 'country.name')
            unicode.symbol.result <- countrycode(name, 'country.name', 'unicode.symbol')
            expect_equal(unicode.symbol.result, unicode.symbol.original)
        }
    }
})
