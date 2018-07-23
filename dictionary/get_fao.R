get_fao = function() {
    url <- 'http://www.fao.org/fileadmin/user_upload/countryprofiles/Excel/AllTerritoriesValidCurrentYear.xlsx'
    tmp_xlsx <- tempfile(fileext = '.xlsx')
    download.file(url, tmp_xlsx, quiet = TRUE)
    
    bad <- 
        c("A&N Islands", "Arunachal Pradesh", "Ashmore and Cartier Islands", 
          "Baker Island", "Bird Island", "Canary Islands", "Canton and Enderbury Islands", 
          "Channel Islands", "Clipperton Island", "Coral Sea Islands Territory", 
          "Dhekelia and Akrotiri SBAs", "Diego Garcia", "England and Wales", 
          "Europa Island", "Glorioso Islands", "Golan Heights", "Greater Antilles", 
          "Hala'ib triangle", "Howland Island", "Ilemi triangle", "Jammu Kashmir", 
          "Jarvis Island", "Johnston Island", "Juan de Nova Island", "Kerguelen Islands", 
          "Kingman Reef", "Kuril Islands", "Liancourt Rocks", "Ma'tan al-Sarra", 
          "Madeira Islands", "Marion Island", "Midway Island", "Navassa Island", 
          "Palmyra Atoll", "Paracel Islands", "Prince Edward Island", "Ross Dependency", 
          "Scarborough Reef", "Senkaku Islands", "Spratly Islands", "Tromelin Island", 
          "Wake Island", "West Papua", "The West Bank", "Occupied Palestinian Territory", 
          "Bassas da India", "Gaza Strip", "Panama, Former Canal Zone", "Åland Islands")

    
    fao <- readxl::read_excel(tmp_xlsx) %>% 
        dplyr::select(fao.name = SNAME_EN,
                      fao = FAOSTAT_CODE,
                      #undp = UNDP_CODE, # United Nations Development Programme
                      gaul = GAUL_CODE) %>% # Global Administrative Unit Layers
        dplyr::mutate(fao = as.integer(fao),
                      gaul = as.integer(gaul),
                      fao.name = ifelse(fao.name == 'US Minor Is.', 
                                        'US Minor Outlying Islands', 
                                        fao.name)) %>% 
        dplyr::filter(!fao.name %in% bad) %>% 
        dplyr::mutate(country.name.en.regex = CountryToRegex(fao.name))
    
    unlink(tmp_xlsx)
    return(fao)
}

# get_fao = function() {
#     tmp <- tempfile()
#     url <- 'http://www.fao.org/countryprofiles/iso3list/en/'
#     download.file(url, tmp, quiet = TRUE)
# 
#     fao <- xml2::read_html(tmp) %>%
#            rvest::html_node('table') %>%
#            rvest::html_table() %>%
#            dplyr::select(fao.name = `Short name`,
#                          fao = FAOSTAT,
#                          undp = UNDP, # United Nations Development Programme
#                          gaul = GAUL) %>% # Global Administrative Unit Layers
#            dplyr::filter(fao.name != 'BASSAS DA INDIA', 
#                          fao.name != 'GAZA STRIP'
#                          ) %>%
#            dplyr::mutate(country.name.en.regex = CountryToRegex(fao.name))
#     return(fao)
# }
