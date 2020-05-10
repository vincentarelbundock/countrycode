source(here::here('dictionary/utilities.R'))

m49 <- read_html("https://unstats.un.org/unsd/methodology/m49/") %>%
       html_nodes("#ENG_COUNTRIES table") %>%
       html_table() %>%
       .[[1]] %>%
       select(country = `Country or Area`,
              un = `M49 code`) %>%
       filter(country != 'Sark')

m49 %>% write_csv('dictionary/data_un.csv')
