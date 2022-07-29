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
      mutate_at(vars(2:ncol(.)), .funs = list(~ str_replace(., '\\*', ''))) %>%
      select(-iso2c) %>%
      setNames(paste0('un.name.', names(.))) %>%
      mutate(# Bolivia
             un.name.zh = ifelse(un.name.zh == '多民族玻利维亚国',
                                 '玻利维亚 (多民族国)',
                                 un.name.zh),
             # Cabo Verde
             un.name.fr = ifelse(un.name.fr == 'Cabo Verde (République de)',
                                 'Cabo Verde',
                                 un.name.fr),
             un.name.ar = ifelse(un.name.ar == 'الرأس الأخضر', 
                                 'كابو فيردي',
                                 un.name.ar),
             # Congo
             un.name.zh = ifelse(un.name.zh == '刚果（布）',
                                 '刚果',
                                 un.name.zh),
             # Costa Rica
             un.name.ar = ifelse(un.name.en == 'Costa Rica',
                                 'كوستاريكا',
                                 un.name.ar),
             # Côte d’Ivoire
             un.name.en = ifelse(un.name.en == 'Côte D\'Ivoire',
                                 'Côte d’Ivoire',
                                 un.name.en),
             un.name.es = ifelse(un.name.es == 'Côte D\'Ivoire',
                                 'Côte d’Ivoire',
                                 un.name.es),
             un.name.ru = ifelse(un.name.ru == 'Кот-д\'Ивуар',
                                 'Кот-д’Ивуар',
                                 un.name.ru),
             # Czechia
             un.name.en = ifelse(un.name.en == 'Czech Republic',
                                 'Czechia',
                                 un.name.en),
             un.name.fr = ifelse(un.name.fr == 'République tchèque',
                                 'Tchéquie',
                                 un.name.fr),
             un.name.es = ifelse(un.name.es == 'República Checa',
                                 'Chequia',
                                 un.name.es),
             un.name.ru = ifelse(un.name.ru == 'Чешская Республика',
                                 'Чеxия',
                                 un.name.ru),
             un.name.ar = ifelse(un.name.ar == 'الجمهورية التشيكية',
                                 'تشيكيا', # I think
                                 un.name.ar),
             # DPRK
             un.name.en = ifelse(un.name.en == 'Democratic People\'s Republic of Korea',
                                 'Democratic People’s Republic of Korea',
                                 un.name.en),
             # Gambia
             un.name.en = ifelse(un.name.en == 'Gambia (Republic of The)',
                                 'Gambia',
                                 un.name.en),
             un.name.fr = ifelse(un.name.fr == 'Gambie (République de)',
                                 'Gambie',
                                 un.name.fr),
             un.name.es = ifelse(un.name.es == 'Gambia (República de)',
                                 'Gambia',
                                 un.name.es),
             # Guinea-Bissau
             un.name.en = ifelse(un.name.en == 'Guinea Bissau',
                                 'Guinea-Bissau',
                                 un.name.en),
             un.name.es = ifelse(un.name.es == 'Guinea Bissau',
                                 'Guinea-Bissau',
                                 un.name.es),
             # Iran
             un.name.fr = ifelse(un.name.fr == 'Iran (République islamique d\')',
                                 'Iran (République islamique d’)',
                                 un.name.fr),
             un.name.zh = ifelse(un.name.zh == '伊朗伊斯兰共和国',
                                 '伊朗（伊斯兰共和国）',
                                 un.name.zh),
             # Micronesia
             un.name.zh = ifelse(un.name.zh == '密克罗尼西亚联邦',
                                 '密克罗尼西亚 (联邦)',
                                 un.name.zh),
             # Niger
             un.name.es = ifelse(un.name.es == 'Niger',
                                 'Níger',
                                 un.name.es),
             # North Macedonia
             un.name.ar = ifelse(un.name.ar == 'جمهورية مقدونيا الشمالية',
                                 'مقدونيا الشمالية',
                                 un.name.ar),
             # South Sudan
             un.name.ar = ifelse(un.name.ar == 'جمهورية جنوب السودان',
                                 'جنوب السودان',
                                 un.name.ar),
             # Timor-Leste
             un.name.ar = ifelse(un.name.ar == 'تيمور- ليشتي',
                                 'تيمور-ليشتي',
                                 un.name.ar),

             # See discussion: https://github.com/vincentarelbundock/countrycode/issues/299
             # # Trinidad and Tobago
             # un.name.es = ifelse(un.name.es == 'Trinidad y Tabago',
             #                     'Trinidad y Tobago',
             #                     un.name.es),
             # United Kingdom
             un.name.fr = ifelse(un.name.fr == 'Royaume-Uni de Grande-Bretagne et d\'Irlande du Nord',
                                 'Royaume-Uni de Grande-Bretagne et d’Irlande du Nord',
                                 un.name.fr),
             # United States
             un.name.fr = ifelse(un.name.fr == 'États-Unis d\'Amérique',
                                 'États-Unis d’Amérique',
                                 un.name.fr),
             # Venezuela
             un.name.en = ifelse(un.name.en == 'Venezuela, Bolivarian Republic of',
                                 'Venezuela (Bolivarian Republic of)',
                                 un.name.en),
             un.name.zh = ifelse(un.name.zh == '委内瑞拉玻利瓦尔共和国',
                                 '委内瑞拉（玻利瓦尔共和国）',
                                 un.name.zh),
             # Add country column
             country = un.name.en,
             )

un %>% write_csv('dictionary/data_un_names.csv', na = '')

# Scratchwork that (badly) gets this information from the PDF published by the United Nations Group of Experts On
# Geographical Names. PDFs are hard to scrape, so this code doesn't actually work, and requires manual cleanup.
# It may be useful if PDF scraping improves or if we attempt another round of manual fixes to the UN website in
# the future.

# pdf <- 'dictionary/data_raw/GEGN.2_2021_CRP130_4c_WG_Country_Names_rev2.pdf'
#
# pdf %>%
#   pdftools::pdf_text() %>%
#   str_split('\n\n+') %>%
#   purrr::flatten_chr() %>%
#   str_trim() %>%
#   str_remove_all('\n') %>%
#   as_tibble() %>%
#   slice(24:n()) %>%
#   separate(value, c('c1','un.name','c3'), sep = '[[:blank:]]{3,}', extra = 'merge') %>%
#   filter(!is.na(c1)) %>%
#   filter(!row_number() %in% c(991,1451)) %>%
#   mutate(junk = cumsum(str_detect(c1, '^National Official')) - cumsum(str_detect(c1, '^UN Official'))) %>%
#   filter(!junk) %>%
#   select(-junk) %>%
#   filter(c1 != 'UN Official') %>%
#   filter(c1 %in% c('English','French','Spanish','Russian','Chinese','Arabic') | str_detect(c1,'^[[:upper:]]{2}$')) %>%
#   extract(c1, c('iso2c','lang'), '^([[:upper:]]{2}$)?(.*)') %>%
#   mutate(iso2c = na_if(iso2c,'')) %>%
#   mutate(iso2c = str_to_lower(iso2c)) %>%
#   fill(iso2c) %>%
#   mutate(lang = case_when(lang == 'English' ~ 'en',
#                           lang == 'French' ~ 'fr',
#                           lang == 'Spanish' ~ 'es',
#                           lang == 'Russian' ~ 'ru',
#                           lang == 'Chinese' ~ 'zh',
#                           lang == 'Arabic' ~ 'ar')) %>%
#   filter(!is.na(lang)) %>%
#   select(-c3) %>%
#   pivot_wider(names_from = lang, values_from = un.name, names_prefix = 'un.name.') %>%
#   mutate(un.name.ar = str_remove_all(un.name.ar, '\u202B'),
#          un.name.ar = str_remove_all(un.name.ar, '\u202C'),
#          across(starts_with('un.name.'), ~ str_remove(.x, ' \\(.*'))) %>%
#   select(-iso2c) %>%
#   relocate(un.name.ru, .after = un.name.es) %>%
#   mutate(country = un.name.en) %>%
#   arrange(country) %>%
#   write_csv('dictionary/data_un_names.csv', na = '')

