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

regex_langs <- c("de", "en", "es", "fr", "it")
un_langs <- c("ar", "en", "es", "fr", "ru", "zh")

for (lang in regex_langs) {
  origin <- paste0("country.name.", lang)

  # All cldr columns (name, short, variant) for this language including xx_yy
  cldr_pattern <- paste0("^cldr\\.(name|short|variant)\\.", lang, "($|_)")
  cldr_cols <- grep(cldr_pattern, names(codelist), value = TRUE)

  for (col in cldr_cols) {
    test_that(paste(lang, "regex vs.", col), {
      result <- countrycode(codelist[[col]], origin, col)
      expect_equal(result, codelist[[col]])
    })
  }

  # UN names only for UN languages
  if (lang %in% un_langs) {
    un_col <- paste0("un.name.", lang)
    test_that(paste(lang, "regex vs.", un_col), {
      result <- countrycode(codelist[[un_col]], origin, un_col)
      expect_equal(result, codelist[[un_col]])
    })
  }
}
