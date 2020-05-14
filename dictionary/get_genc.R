# Check https://geonames.nga.mil/gns/html/countrycodes.html quarterly for the latest XLSX url
url <- 'http://geonames.nga.mil/gns/html/docs/GENC_ED3U12_GEC_XWALK.xlsx'

# Uses DoD Root CA 3, which I don't have in my root certificate store
httr::set_config(config(ssl_verifypeer = 0L))

httr::GET(url, write_disk(filename, overwrite=TRUE))
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
    dplyr::select(country = Name, genc2c = `2-character Code`,
                  genc3c = `3-character Code`, genc3n = `Numeric Code`, ) %>%
    dplyr::filter(!country %in% bad)

genc %>% write_csv('dictionary/data_genc.csv')
