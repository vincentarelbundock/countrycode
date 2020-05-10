source(here::here('dictionary/utilities.R'))

url = 'https://www.olympic.org/national-olympic-committees'
doc = url %>% xml2::read_html(.)
country = doc %>% 
          rvest::html_nodes('div.box > a') %>% 
          rvest::html_text(.) %>% 
          trimws

ioc = doc %>% 
      rvest::html_nodes('div.box > a > div > div')  %>% 
      rvest::html_attr('class') %>%
      gsub('flag90 ', '', .) %>%
      toupper 

ioc = data.frame(country, ioc) %>%
      filter(country != 'Virgin Islands, US') %>%
      mutate(country = ifelse(country == 'Brésil', 'Brazil', country),
             country = ifelse(country == 'Éthiopie', 'Ethiopia', country),
             country = ifelse(country == 'Dominique', 'Dominica', country))

ioc %>% write_csv('dictionary/data_ioc.csv')
