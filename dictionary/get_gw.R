get_gw = function(){

  url = "http://ksgleditsch.com/data/iisystem.dat"

  gw = readr::read_tsv(url,
                       col_names = c("gwn", "gwc", "country", "birth", "death"),
                       col_types = readr::cols(
                         gwn = readr::col_integer(),
                         gwc = readr::col_character(),
                         country = readr::col_character(),
                         birth = readr::col_date(format = "%d:%m:%Y"),
                         death = readr::col_date(format = "%d:%m:%Y")
                       ))

  gw = gw %>%
    dplyr::filter(
      !gwc %in% c("TBT", "DRV"),
      death > as.Date("1945-09-02")
    ) %>%
    dplyr::group_by(gwn) %>%
    dplyr::slice(which.max(death)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      country = replace(country, gwc == "CDI", "Cote d'Ivoire"),
      country = replace(country, gwc == "PRK", "North Korea"),
      country = replace(country, gwc == "RVN", "Vietnam"),
      country.name.en.regex = CountryToRegex(country)
    ) %>%
    dplyr::select(gwn, gwc, country.name.en.regex)

  return(gw)
}
