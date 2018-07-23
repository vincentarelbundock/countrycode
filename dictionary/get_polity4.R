get_polity4 = function(){
    url = 'http://www.systemicpeace.org/inscr/p4v2015.xls'
    download.file(url, tmpxls <- tempfile(fileext = '.xls'), quiet = TRUE)
    p4 = readxl::read_excel(tmpxls) %>%
         dplyr::select(p4n = ccode, 
                       p4c = scode,
                       p4.name = country) %>%
         unique %>%
         dplyr::filter(p4.name != 'United Province CA') %>%
         dplyr::mutate(p4n = as.integer(p4n),
                       p4.name = if_else(p4.name == 'Germany East', 'East Germany', p4.name),
                       p4.name = if_else(p4.name == 'Germany West', 'German Federal Republic', p4.name),
                       p4.name = if_else(p4.name == 'Vietnam North', 'Democratic Republic of Vietnam', p4.name),
                       p4.name = if_else(p4.name == 'Vietnam South', 'Republic of Vietnam', p4.name),
                       p4.name = if_else(p4.name == 'Vietnam South', 'Republic of Vietnam', p4.name),
                       p4n = ifelse(p4.name == 'Prussia', NA, p4n),
                       p4c = ifelse(p4.name == 'Prussia', NA, p4c),
                       p4n = ifelse((p4.name == 'Yugoslavia') & (p4n == 347), NA, p4n),
                       p4c = ifelse((p4.name == 'Yugoslavia') & (p4c == 'YGS'), NA, p4c),
                       country.name.en.regex = CountryToRegex(p4.name))
    return(p4)
}
