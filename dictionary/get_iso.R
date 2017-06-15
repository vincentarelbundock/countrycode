get_iso = function() {
    url <- 'https://www.iso.org/obp/ui/#search/code/'

    rD <- wdman::phantomjs(verbose = FALSE)
    remDr <- RSelenium::remoteDriver(browserName = 'phantomjs', port = 4567L)

    remDr$open(silent = TRUE)
    remDr$navigate(url)
    Sys.sleep(3)

    option <- remDr$findElement('css selector', '.v-select-select option:nth-of-type(8)')
    option$clickElement()
    Sys.sleep(3)

    tbl_html <- remDr$getPageSource()[[1]]

    remDr$close()
    rD$stop()
    
    iso <-
      tbl_html %>%
      xml2::read_html() %>%
      rvest::html_node('table.v-table-table') %>%
      rvest::html_table() %>%
      dplyr::mutate(X3 = dplyr::if_else(X1 == 'Namibia', 'NA', X3)) %>%
      dplyr::rename(iso.name.en = X1, iso.name.fr = X2, iso2c = X3, iso3c = X4, iso3n = X5) %>%
      dplyr::mutate(country.name.en.regex = CountryToRegex(iso.name.en))

    return(iso)
}
