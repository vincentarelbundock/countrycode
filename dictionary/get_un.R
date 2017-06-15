# This script will scrape the UN website for official country names in the six
# official languages of the United Nations (EN, FR, ES, RU, ZH, AR). Make sure
# to run it in a UTF-8 environment. -- FB 2016-03-22
# re-written by VAB 2016-12-28

get_un = function() {
    # Scrape UNGEGN official country names
    get_names = function(language){
        selector = 'div.collapsed.member-state-row > div.pull-left.flip > span'
        url = paste0('http://www.un.org/', language, '/member-states/')
        doc = url %>% xml2::read_html(.)
        countries = doc %>%
                    rvest::html_nodes(selector) %>% 
                    rvest::html_text(.)
        selector = 'div.collapsed.member-state-row > div.pull-left.flip > div > div'
        flags = doc %>% 
                rvest::html_nodes(selector) %>%
                rvest::html_attr('class') %>%
                gsub('.*flags-', '', .)
        out = data.frame(toupper(flags), countries)
        colnames(out) = c('iso2c', language)
        return(out)
    }
    un_official_languages = c('en', 'fr', 'es', 'ru', 'zh', 'ar')
    un = lapply(un_official_languages, get_names)
    un = Reduce(full_join, un)

    for(i in 2:ncol(un)){
        un[, i] = gsub('\\*$', '', un[, i])
    }
    colnames(un)[2:ncol(un)] = paste('un.name.', colnames(un)[2:ncol(un)], sep='')

    un_names = un %>%
               # misspelled in original source
               dplyr::mutate(un.name.es = ifelse(un.name.es == 'Trinidad yTobago', 'Trinidad y Tobago', un.name.es),  
                             country.name.en.regex = CountryToRegex(un.name.en)) %>%
               dplyr::select(-iso2c)
    return(un_names)
}
