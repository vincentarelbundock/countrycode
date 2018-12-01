# ICAO data collected manually by @espinelli
# https://github.com/vincentarelbundock/countrycode/pull/200

get_icao <- function() {
    # I don't think we have entries for these units, so we exclude them explicitly
    bad1 = 
    c("Ascension Island (United Kingdom)", "Bonaire (Netherlands)", 
      "Canary Islands (Spain)", "French Antilles (France)", 
      "Hawaii (United States)", "Johnston Island (United States)", 
      "Line Islands (United States)", "Saba (Netherlands)", 
      "Sint Eustatius (Netherlands)", "Wake Island (United States)")
    # The current regex engine does not match these strings, so we exclude them
    # explicitly in hope that the regex engine will improve over time and match
    # some of those
    bad2 = 
    c("American Samoa (United States)", "Anguilla (United Kingdom)", 
      "Aruba (Netherlands)", "Bermuda (United Kingdom)", "British Indian Ocean Territory (United Kingdom)", 
      "British Virgin Islands (United Kingdom)", "Cayman Islands (United Kingdom)", 
      "Curaçao (Netherlands)", "Falkland Islands (Malvinas) (United Kingdom)", 
      "French Guiana (France)", "French Polynesia (France)", "Gibraltar (United Kingdom)", 
      "Greenland (Denmark)", "Montserrat (United Kingdom)", "New Caledonia (France)", 
      "Niue (New Zealand)", "Northern Mariana Islands (United States)", 
      "Puerto Rico (United States)", "Réunion (France)", "Saint-Pierre-et-Miquelon (France)", 
      "Sint Maarten (Netherlands)", "Turks and Caicos Islands (United Kingdom)", 
      "Virgin Islands (United States)")
    out = readr::read_csv('dictionary/data_icao.csv') %>%
          dplyr::filter(!icao.name %in% bad1,
                        !icao.name %in% bad2) %>%
          dplyr::mutate(country.name.en.regex = CountryToRegex(icao.name))
    return(out)
}
