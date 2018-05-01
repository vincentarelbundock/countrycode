get_cow_cs = function() {
    source('dictionary/get_cow.R')
    out = get_cow()
    cs = out %>% 
		 dplyr::arrange(country.name.en.regex, year) %>%
         dplyr::select(-year) %>% 
         dplyr::group_by(country.name.en.regex) %>%
         dplyr::do(tail(., 1)) 
    return(cs)
}
