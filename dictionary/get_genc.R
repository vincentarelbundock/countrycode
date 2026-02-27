source(here::here("dictionary/utilities.R"))

# Check https://geonames.nga.mil/gns/html/countrycodes.html quarterly for the latest XLSX url
url <- 'https://geonames.nga.mil/geonames/GNSSearch/GNSDocs/xlsdocs/GENC_ED3U17_GEC_XWALK.xlsx'

# Uses DoD Root CA 3, which I don't have in my root certificate store
httr::set_config(config(ssl_verifypeer = 0L))

tmp <- tempfile()
httr::GET(url, write_disk(tmp, overwrite=TRUE))
genc <- readxl::read_excel(tmp, sheet = 'Codes_for_GE_Names', skip = 2)

bad <- c('AKROTIRI', 'ASHMORE AND CARTIER ISLANDS', 'BAKER ISLAND', 'CLIPPERTON ISLAND', 'CORAL SEA ISLANDS', 'DHEKELIA', 'DIEGO GARCIA', 'ENTITY 1', 'ENTITY 2', 'ENTITY 3', 'ENTITY 4', 'ENTITY 5', 'ENTITY 6', 'EUROPA ISLAND', 'GLORIOSO ISLANDS', 'GUANTANAMO BAY NAVAL BASE', 'HOWLAND ISLAND', 'JAN MAYEN', 'JARVIS ISLAND', 'JOHNSTON ATOLL', 'JUAN DE NOVA ISLAND', 'KINGMAN REEF', 'MIDWAY ISLANDS', 'NAVASSA ISLAND', 'PALMYRA ATOLL', 'PARACEL ISLANDS', 'SAINT MARTIN', 'SPRATLY ISLANDS', 'TROMELIN ISLAND', 'UNKNOWN', 'WAKE ISLAND', 'BASSAS DA INDIA', 'GAZA STRIP', "ABU MUSA AND TUNB ISLANDS", "ABYEI", "AKSAI CHIN AND OTHER AREAS", "CONEJO ISLAND", "CORISCO BAY ISLANDS", "DOUMEIRA ISLANDS", "DRAMANA AND SHAKHATOE", "GEYSER REEF", "HANS ISLAND", "HEIPETHES ISLANDS", "KALAPANI", "KOALOU / KOUROU", "MINERVA REEFS", "PARSLEY ISLAND", "SAPODILLA CAYES", "SIACHEN", "BRAZILIAN ISLAND", "CONGO RIVER ISLANDS")

genc <-
    genc %>%
    dplyr::select(country = Name, genc2c = `2-character Code`,
                  genc3c = `3-character Code`, genc3n = `Numeric Code`, ) %>%
    dplyr::filter(!country %in% bad)

# sanity checks
checkmate::assert_true("NA" == genc$genc2c[tolower(genc$country) == "namibia"])

# write
genc %>% write_csv('dictionary/data_genc.csv', na = "")
