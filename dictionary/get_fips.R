get_fips = function() {
    url <- 'http://geonames.nga.mil/gns/html/Docs/GEOPOLITICAL_CODES.xls'

    filename <- tempfile(fileext = '.xls')
    download.file(url, filename, quiet = TRUE)
    sink('/dev/null')
    fips <- readxl::read_excel(filename, sheet = 'TABLE 1', skip = 2)
    sink()

    bad <- c('AKROTIRI SOVEREIGN BASE AREA', 'ASHMORE AND CARTIER ISLANDS', 'BAKER ISLAND', 
             'CLIPPERTON ISLAND', 'CORAL SEA ISLANDS', 'DHEKELIA SOVEREIGN BASE AREA', 
             'ETOROFU, HABOMAI, KUNASHIRI, AND SHIKOTAN ISLANDS', 'EUROPA ISLAND', 
             'GLORIOSO ISLANDS', 'HOWLAND ISLAND', 'JAN MAYEN', 'JARVIS ISLAND', 
             'JOHNSTON ATOLL', 'JUAN DE NOVA ISLAND', 'KINGMAN REEF', 'MIDWAY ISLANDS', 
             'NAVASSA ISLAND', 'PALMYRA ATOLL', 'PARACEL ISLANDS', 'SAINT MARTIN', 
             'SPRATLY ISLANDS', 'TROMELIN ISLAND', 'WAKE ISLAND', 'BASSAS DA INDIA', 'GAZA STRIP')

    fips <-
        fips %>%
        dplyr::select(fips = Code, fips.name = Name) %>% 
        dplyr::filter(!fips.name %in% bad) %>%
        # TODO: regex improvements
        dplyr::mutate(fips.name = if_else(fips.name == 'KOREA, NORTH', 'NORTH KOREA', fips.name)) %>%
        dplyr::mutate(country.name.en.regex = CountryToRegex(fips.name))
    return(fips)
}
