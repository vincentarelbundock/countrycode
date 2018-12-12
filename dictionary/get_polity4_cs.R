get_polity4_cs = function() {
    out = read.csv('dictionary/data_panel.csv', na.strings = '') %>%
          dplyr::arrange(country.name.en.regex, year) %>%
          dplyr::group_by(country.name.en.regex) %>%
          dplyr::summarize(p4c = dplyr::last(na.omit(p4c)),
                           p4n = dplyr::last(na.omit(p4n)),
                           p4.name = dplyr::last(na.omit(p4.name)))
    return(out)
}
