get_polity4 = function(){
    url = 'http://www.systemicpeace.org/inscr/p4v2015.xls'
    download.file(url, tmpxls <- tempfile(fileext = '.xls'), quiet = TRUE)
    p4 = readxl::read_excel(tmpxls) %>%
         dplyr::select(p4n = ccode, 
                       p4c = scode,
                       p4.name = country,
                       year) %>%
         dplyr::mutate(p4n = as.integer(p4n), year = as.integer(year)) %>% 
         # See Brenton Kenkel's Github https://github.com/brentonk/merge-cow-polity
         dplyr::filter(# overlapping years; pick one arbitrarily
                       (year != 1832) | (p4c != 'GCL'), # Gran Colombia vs. Colombia
                       (year != 1861) | (p4c != 'SAR'), # Sardinia vs. Italy
                       (year != 1993) | (p4c != 'ETI'), # Ethiopia
                       (year != 2011) | (p4c != 'SDN'), # Sudan
                       (year != 1976) | (p4c != 'DRV'), # Vietnam
                       (year != 1922) | (p4c != 'USR'), # USSR
                       (year != 1991) | (p4c != 'YGS'), # Yugoslavia
                       (!year %in% c(1945, 1990)) | (p4c != 'GFR'), # Germany
                       # TODO: regex improvements
                       p4.name != 'Orange Free State',
                       p4.name != 'Prussia',
                       p4.name != 'Sardinia',
                       p4.name != 'Serbia and Montenegro',
                       p4.name != 'United Province CA'
                      ) %>% 
         dplyr::mutate(p4n = if_else(p4n == 324, 325L, p4n), # Sardinia
                       p4n = if_else(p4n %in% c(342, 347), 342L, p4n), # Serbia
                       p4n = if_else(p4n == 341, 347L, p4n), # Montenegro -> Serbia Montenegro
                       p4n = if_else(p4n == 348, 341L, p4n), # Kosovo
                       p4n = if_else(p4n == 364, 365L, p4n), # USSR
                       p4n = if_else(p4n == 626, 625L, p4n), # Sudan
                       p4n = if_else(p4n == 525, 626L, p4n), # South Sudan
                       p4n = if_else(p4n == 769, 770L, p4n), # Pakistan
                       p4n = if_else(p4n == 818, 816L, p4n), # Vietnam
                       p4n = if_else(p4n == 529, 530L, p4n), # Ethiopia
                       # TODO: regex improvements
                       p4.name = if_else(p4.name == 'Germany East', 'East Germany', p4.name),
                       p4.name = if_else(p4.name == 'Germany West', 'Germany', p4.name),
                       country.name.en.regex = CountryToRegex(p4.name),
                       country.name.en.regex = if_else(p4.name == 'Vietnam North', 'democratic.republic.of.vietnam', country.name.en.regex)) %>%
         dplyr::arrange(p4c, year)

    return(p4)
}
