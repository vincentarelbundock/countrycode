get_genc = function() {
    url <- 'http://geonames.nga.mil/gns/html/docs/GENC_ED3U5_GEC_XWALK.xlsx'

    filename <- tempfile(fileext = '.xlsx')
    download.file(url, filename, quiet = TRUE)
    genc <- readxl::read_excel(filename, sheet = 'Codes_for_GE_Names', skip = 2)

    bad <- c('AKROTIRI', 'ASHMORE AND CARTIER ISLANDS', 'BAKER ISLAND', 
             'CLIPPERTON ISLAND', 'CORAL SEA ISLANDS', 'DHEKELIA', 'DIEGO GARCIA', 
             'ENTITY 1', 'ENTITY 2', 'ENTITY 3', 'ENTITY 4', 'ENTITY 5', 'ENTITY 6', 
             'EUROPA ISLAND', 'GLORIOSO ISLANDS', 'GUANTANAMO BAY NAVAL BASE', 
             'HOWLAND ISLAND', 'JAN MAYEN', 'JARVIS ISLAND', 'JOHNSTON ATOLL', 
             'JUAN DE NOVA ISLAND', 'KINGMAN REEF', 'MIDWAY ISLANDS', 
             'NAVASSA ISLAND', 'PALMYRA ATOLL', 'PARACEL ISLANDS', 'SAINT MARTIN', 
             'SPRATLY ISLANDS', 'TROMELIN ISLAND', 'UNKNOWN', 'WAKE ISLAND', 'BASSAS DA INDIA', 'GAZA STRIP')
    genc <-
        genc %>%
        dplyr::select(genc3c = `3-character Code`, genc2c = `2-character Code`, 
                      genc3n = `Numeric Code`, genc.name = Name) %>% 
        dplyr::filter(!genc.name %in% bad) %>%
        # TODO: regex improvements
        dplyr::mutate(genc.name = if_else(genc.name == 'KOREA, NORTH', 'NORTH KOREA', genc.name)) %>%
        dplyr::mutate(genc.name = if_else(genc.name == 'UXBEKISTAN', 'UZBEKISTAN', genc.name)) %>%
        dplyr::mutate(country.name.en.regex = CountryToRegex(genc.name))

    return(genc)
}
