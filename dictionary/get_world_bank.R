get_world_bank = function() {
    url <- 'http://databank.worldbank.org/data/download/site-content/CLASS.xls'

    filename <- tempfile(fileext = '.xls')
    download.file(url, filename, quiet = TRUE)

    wb <- readxl::read_excel(filename) %>%
          dplyr::select(3:4) %>%
          setNames(c('wb.name', 'wb')) %>%
          dplyr::mutate(country.name.en.regex = CountryToRegex(wb.name, warn = FALSE)) %>%
          dplyr::select(country.name.en.regex, wb, wb.name) %>%
          na.omit

    return(wb)
}
