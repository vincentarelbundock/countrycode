get_polity4_cs = function(){
    source('dictionary/get_polity4.R')
    p4 = get_polity4()
    cs = p4 %>% 
         dplyr::arrange(country.name.en.regex, year) %>%
         dplyr::select(-year) %>% 
         dplyr::group_by(country.name.en.regex) %>%
         dplyr::do(tail(., 1)) %>% # assumes proper sorting
         dplyr::mutate(p4n = ifelse(p4.name == 'Yugoslavia', NA, p4n), # tricky time series issues; use panel version of the dictionary
                       p4n = ifelse(p4.name == 'Vietnam North', NA, p4n))
         return(cs)
}
