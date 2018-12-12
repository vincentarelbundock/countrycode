# vdem8.csv was extracted manually from pages 34 and 35 of the V-Dem Codebook
# v8 April 2018. 
get_vdem_cs = function() {
    out = read.csv('dictionary/data_panel.csv', na.strings = '') %>%
          dplyr::arrange(country.name.en.regex, year) %>%
          dplyr::group_by(country.name.en.regex) %>%
          dplyr::summarize(vdem = dplyr::last(na.omit(vdem)),
                           vdem.name = dplyr::last(na.omit(vdem.name)))
    return(out)
}
