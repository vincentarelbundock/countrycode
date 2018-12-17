get_ecb = function() {
    # European Central Bank 
    # There are many bad country names in the ECB data, but these are excluded
    # explicitly because they produce duplicates when matched by regex.
    bad = c("Australian Oceania",
            "Australia, Oceania and other territories",
            "Central and South Africa countries",
            "EU 12 (fixed composition) including West Germany",
            "EU 12 (fixed composition) including West Germany as of 1 November 1993",
            "Euro area countries except Germany, France, Italy and Spain",
            "G20 (Argentina,Australia,Brazil,Canada,China,European Union,France,Germany,India,Indonesia,Italy,Japan,Mexico,Russia,Saudi Arabia,South Africa,South Korea,Turkey,United Kingdom,United States)",
            "Gaza and Jericho",
            "New Zealand Oceania",
            "Residual for BOP and IIP step 3 ECB needs (J2-DK-GB-SE-4A-D8-CH-CA-US-JP-C4-7Z)",
            "UNRWA (United Nations Relief and Works Agency for Palestine)",
            "West Germany")

    url <- 'http://a-sdw.ecb.europa.eu/datastructure.do?conceptMnemonic=REF_AREA&datasetinstanceid=122'
    ecb <-
      xml2::read_html(url) %>%
      rvest::html_node('#codeListTable') %>%
      rvest::html_table() %>%
      dplyr::select(ecb = `Code`, ecb.name = `Code Description`) %>%
      dplyr::mutate(ecb = dplyr::if_else(ecb.name == 'Namibia', 'NA', ecb), # Namibia != <NA>
                    country.name.en.regex = CountryToRegex(ecb.name, warn=FALSE)) %>%
      filter(!ecb.name %in% bad,
             !is.na(country.name.en.regex))

    return(ecb)
}
