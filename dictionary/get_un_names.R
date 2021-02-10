# This script will scrape the UN website for official country names in the six
# official languages of the United Nations (EN, FR, ES, RU, ZH, AR). Make sure
# to run it in a UTF-8 environment. -- FB 2016-03-22
# re-written by VAB 2016-12-28

source(here::here('dictionary/utilities.R'))

# Scrape UNGEGN official country names
get_names <- function(language){
    selector <- 'div.collapsed.member-state-row > div.pull-left.flip > span'
    url <- paste0('http://www.un.org/', language, '/member-states/')
    doc <- url %>% xml2::read_html(.)
    countries <- doc %>%
                 rvest::html_nodes(selector) %>% 
                 rvest::html_text(.)
    selector <- 'div.collapsed.member-state-row > div.pull-left.flip > div > div'
    flags <- doc %>% 
             rvest::html_nodes(selector) %>%
             rvest::html_attr('class') %>%
             gsub('.*flags-', '', .)
    out <- data.frame(toupper(flags), countries)
    colnames(out) <- c('iso2c', language)
    return(out)
}

un <- c('en', 'fr', 'es', 'ru', 'zh', 'ar') %>%
      map(get_names) %>%
      reduce(full_join, by = 'iso2c') %>%
      mutate_at(vars(2:ncol(.)), .funs = list(~ str_replace(., '\\*$', ''))) %>%
      select(-iso2c) %>%
      setNames(paste0('un.name.', names(.))) %>%
      mutate(country = un.name.en,
             # misspelled in original source
             un.name.es = ifelse(un.name.es == 'Trinidad yTobago', 'Trinidad y Tobago', un.name.es))

un %>% write_csv('dictionary/data_un_names.csv', na = "")
