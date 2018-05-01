get_cow = function() {

    # Download CoW codes and names
    url = 'http://www.correlatesofwar.org/data-sets/cow-country-codes/cow-country-codes'
    tmp = tempfile()
    download.file(url, tmp, quiet = TRUE)
    codes = readr::read_csv(tmp) %>%
            dplyr::rename(cowc=StateAbb,
                          cown=CCode,
                          cow.name=StateNme) %>%
            unique # there are dups in the original file
    unlink(tmp)

    # Download Country-year dataset (membership in state system)
    url = 'http://www.correlatesofwar.org/data-sets/state-system-membership/system2016'
    tmp = tempfile()
    download.file(url, tmp, quiet = TRUE)
    cow = readr::read_csv(tmp) %>% 
          dplyr::rename(cowc=stateabb, cown=ccode) %>%
          dplyr::left_join(codes) %>% 
          dplyr::select(cowc, cown, cow.name, year)
    unlink(tmp)

    # IMPORTANT/ARBITRARY CHOICES
    cow = cow %>% 
          dplyr::mutate(cow.name = ifelse(cow.name == 'German Federal Republic', 'Germany', cow.name),
                        cow.name = ifelse(cowc == 'RVN', 'Vietnam', cow.name),
                        country.name.en.regex = CountryToRegex(cow.name),
                        country.name.en.regex = ifelse(cowc == 'DRV', 'democratic.republic.of.vietnam', country.name.en.regex)) %>% 
          dplyr::filter((cowc != 'GFR') | (year != 1990)) %>% # date overlap
          dplyr::arrange(cowc, year) %>%
          dplyr::select(order(colnames(.))) %>%
          unique

    return(cow)
}
