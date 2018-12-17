get_polity4_cs = function() {
    out = read.csv('dictionary/data_panel.csv', na.strings = '') %>%
          dplyr::arrange(country.name.en.regex, year) %>%
          dplyr::group_by(country.name.en.regex) %>%
          dplyr::summarize(p4c = dplyr::last(na.omit(p4c)),
                           p4n = dplyr::last(na.omit(p4n)),
                           p4.name = dplyr::last(na.omit(p4.name)),
                           year = dplyr::last(na.omit(year))) %>% # need year for next step
          dplyr::group_by(p4c) %>% # same p4c code but different p4.name produces 2 regex matches (e.g., Prussia-Germany)
          dplyr::summarize(p4n = dplyr::last(na.omit(p4n)),
                           p4.name = dplyr::last(na.omit(p4.name)),
                           country.name.en.regex = dplyr::last(na.omit(country.name.en.regex)))
    return(out)
}
