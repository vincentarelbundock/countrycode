# This script will scrape the UN website for official country names in the six
# official languages of the United Nations (EN, FR, ES, RU, ZH, AR). Make sure
# to run it in a UTF-8 environment. -- FB 2016-03-22
# completely re-written by VAB 2016-12-28
library(dplyr)
library(rvest)
options(stringsAsFactors=FALSE)

# UNGEGN official country names
get_names = function(language){
    selector = 'div.collapsed.member-state-row > div.pull-left.flip > span'
    url = paste('http://www.un.org/', language, '/member-states/', sep='')
    doc = url %>% read_html
    countries = doc %>%
                html_nodes(selector) %>% 
                html_text
    selector = 'div.collapsed.member-state-row > div.pull-left.flip > div > div'
    flags = doc %>% 
            html_nodes(selector) %>%
            html_attr('class') %>%
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
colnames(un)[2:ncol(un)] = paste('country.name.', colnames(un)[2:ncol(un)], sep='')

write.csv(un, 'un_country_names.csv', row.names=FALSE)
