# This script will scrape the UN website for official country names in the six
# official languages of the United Nations (EN, FR, ES, RU, ZH, AR). Make sure
# to run it in a UTF-8 environment. -- FB 2016-03-22
# re-written by VAB 2016-12-28

source(here::here('dictionary/utilities.R'))

# Scrape UNGEGN official country names
get_names <- function(language){
    selector <- 'div.country > div.card-body > h2'
    url <- paste0('https://www.un.org/', language, '/about-us/member-states')
    doc <- url %>% xml2::read_html(.)
    countries <- doc %>%
                 rvest::html_elements(selector) %>%
                 rvest::html_text(.) %>%
                 str_squish()
    selector <- 'div.country > div.card-body > div.flag-container > div.flags'
    flags <- doc %>%
             rvest::html_elements(selector) %>%
             rvest::html_attr('class') %>%
             gsub('.*flags-', '', .)
    out <- data.frame(toupper(flags), countries)
    colnames(out) <- c('iso2c', language)
    return(out)
}

get_names_alt <- function(language){
  selector <- 'div.memberstatelist > div.panel-group > div.panel > div.collapse > div.panel-body > table > tbody > tr > td:nth-child(2)'
  url <- paste0('https://www.un.org/', language, '/about-us/member-states')
  doc <- url %>% xml2::read_html(.)
  countries <- doc %>%
               rvest::html_elements(selector) %>%
               rvest::html_text(.) %>%
               str_squish()
  selector <- 'div.memberstatelist > div.panel-group > div.panel > div.collapse > div.panel-body > table > tbody > tr > td:nth-child(1) > div.flag-container > div.flags'
  flags <- doc %>%
           rvest::html_elements(selector) %>%
           rvest::html_attr('class') %>%
           gsub('.*flags-', '', .)
  out <- data.frame(toupper(flags), countries)
  colnames(out) <- c('iso2c', language)
  return(out)
}

un_alt <- get_names_alt('ar')

un <- c('en', 'fr', 'es', 'ru', 'zh') %>%
      map(get_names) %>%
      reduce(full_join, by = 'iso2c') %>%
      full_join(un_alt, by = 'iso2c') %>%
      mutate_at(vars(2:ncol(.)), .funs = list(~ str_replace(., '\\*$', ''))) %>%
      select(-iso2c) %>%
      setNames(paste0('un.name.', names(.))) %>%
      mutate(country = un.name.en,
             # missing in original source
             un.name.ar = ifelse(is.na(un.name.ar) & un.name.en == "Costa Rica", 'كوستاريكا', un.name.ar))

un %>% write_csv('dictionary/data_un_names.csv', na = "")
