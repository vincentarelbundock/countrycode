context('Internal validity of regex')

iso3c_of <- function(name) countrycode(name, 'country.name', 'iso3c')

test_that('all country names with iso3c codes are matched exactly once', {
    name <- subset(countrycode_data, !is.na(iso3c))$country.name
    iso3c_from_name <- countrycode(name, 'country.name', 'iso3c', warn = TRUE)
    
    expect_that(iso3c_from_name, not(gives_warning()))
})

test_that('iso3c-to-country.name-to-iso3c is internally consistent', {    
    for(iso3c_original in countrycode_data$iso3c){
        if(!is.na(iso3c_original)){
            name <- countrycode(iso3c_original, 'iso3c', 'country.name')
            iso3c_result <- countrycode(name, 'country.name', 'iso3c')
            expect_that(iso3c_result, equals(iso3c_original))
        }
    }
})