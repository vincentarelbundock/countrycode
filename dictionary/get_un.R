get_un <- function() {
    library(xml2)
    library(rvest)
    m49 <- read_html("https://unstats.un.org/unsd/methodology/m49/")
    m49 <- html_nodes(m49, "#ENG_COUNTRIES table")
    m49 <- html_table(m49)[[1]]
    names(m49) <- c("country.name", "un", "iso3c")
    m49 <- m49[m49$iso3c != "",]
    m49$country.name = ifelse(m49$country.name == 'Åland Islands', 'Aland Islands', m49$country.name)
    m49$country.name.en.regex <- CountryToRegex(m49$country.name)
    out <- m49[, c('country.name.en.regex', 'un')]
    return(out)
}
