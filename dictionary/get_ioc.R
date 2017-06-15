get_ioc = function() {
    url = 'https://www.olympic.org/national-olympic-committees'
    doc = url %>% xml2::read_html(.)
    ioc.name = doc %>% 
               rvest::html_nodes('div.box > a') %>% 
               rvest::html_text(.) %>% 
               trimws
    ioc = doc %>% 
          rvest::html_nodes('div.box > a > div > div')  %>% 
          rvest::html_attr('class') %>%
          gsub('flag90 ', '', .) %>%
          toupper 
    ioc = data.frame(ioc, ioc.name) %>%
          dplyr::filter(ioc.name != 'Virgin Islands, US') %>%
          dplyr::mutate(ioc.name = ifelse(ioc.name == 'Brésil', 'Brazil', ioc.name),
                        ioc.name = ifelse(ioc.name == 'Éthiopie', 'Ethiopia', ioc.name)) %>%
          dplyr::mutate(country.name.en.regex = CountryToRegex(ioc.name))
    return(ioc)
}
