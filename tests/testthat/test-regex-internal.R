context('Internal validity of regex')

iso3c_of <- function(name) countrycode(name, 'country.name', 'iso3c')

test_that('all country names with iso3c codes are matched exactly once', {
    name <- subset(codelist, !is.na(iso3c))$country.name.en
    iso3c_from_name <- countrycode(name, 'country.name', 'iso3c', warn = TRUE)
    expect_warning(iso3c_from_name, NA)
})

test_that('iso3c-to-country.name-to-iso3c is internally consistent', {
    for(iso3c_original in codelist$iso3c){
        if(!is.na(iso3c_original)){
            name <- countrycode(iso3c_original, 'iso3c', 'country.name')
            iso3c_result <- countrycode(name, 'country.name', 'iso3c')
            expect_equal(iso3c_result, iso3c_original)
        }
    }
})

test_that("Italian regex vs. CLDR", {
    x <- countrycode(codelist$cldr.name.it, "country.name.it", "cldr.name.it")
    expect_equal(x, codelist$cldr.name.it)
})

test_that("French regex vs. CLDR", {
    x <- countrycode(codelist$cldr.name.fr, "country.name.fr", "cldr.name.fr")
    expect_equal(x, codelist$cldr.name.fr)
})


