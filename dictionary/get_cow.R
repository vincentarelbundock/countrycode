get_cow = function() {
    # Download CoW codes and names
    url = 'http://www.correlatesofwar.org/data-sets/cow-country-codes/cow-country-codes'
    tmp = tempfile()
    download.file(url, tmp, quiet = TRUE)
    cm = c('Republic of Vietnam' = 'republic.of.vietnam')
    cow = readr::read_csv(tmp) %>%
          dplyr::rename(cowc=StateAbb,
                       cown=CCode,
                        cow.name=StateNme) %>%
          unique %>% # there are dups in the original file
          dplyr::mutate(country.name.en.regex = CountryToRegex(cow.name, custom_match = cm))
    unlink(tmp)
    return(cow)
}
