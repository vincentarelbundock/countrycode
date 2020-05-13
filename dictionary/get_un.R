source(here::here('dictionary/utilities.R'))

url <- 'https://unstats.un.org/unsd/methodology/m49/overview/'
selector <- '#downloadTableEN'

m49 <- read_html(url) %>%
       html_nodes(selector) %>%
       html_table(header=T) %>%
       .[[1]] %>%
       select(country = `Country or Area`,
              un = `M49 Code`,
              un.region.name = `Region Name`,
              un.region.code = `Region Code`,
              un.regionsub.name = `Sub-region Name`,
              un.regionsub.code = `Sub-region Code`,
              un.regionintermediate.name = `Intermediate Region Name`,
              un.regionintermediate.code = `Intermediate Region Code`) %>%
       filter(country != 'Sark')

m49 %>% write_csv('dictionary/data_un.csv')
