get_cow_cs = function() {
    out = read.csv('dictionary/data_panel.csv', na.strings = '') %>%
          dplyr::arrange(country.name.en.regex, year) %>%
          dplyr::group_by(country.name.en.regex) %>%
          dplyr::summarize(cowc = dplyr::last(na.omit(cowc)),
                           cown = dplyr::last(na.omit(cown)),
                           cow.name = dplyr::last(na.omit(cow.name)))
    return(out)
}
