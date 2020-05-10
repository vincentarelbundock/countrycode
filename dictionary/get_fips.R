#source(here::here('dictionary/utilities.R'))

################################
#  download code fails on SSL  #
################################

#url <- 'http://geonames.nga.mil/gns/html/Docs/GEOPOLITICAL_CODES.xls'
#tmp <- curl_fetch_memory(url)
#filename <- tempfile(fileext = '.xls')
#download.file(url, filename, quiet = TRUE)
#sink('/dev/null')

#bad <- c('AKROTIRI SOVEREIGN BASE AREA', 'ASHMORE AND CARTIER ISLANDS', 'BAKER ISLAND', 
         #'CLIPPERTON ISLAND', 'CORAL SEA ISLANDS', 'DHEKELIA SOVEREIGN BASE AREA', 
         #'ETOROFU, HABOMAI, KUNASHIRI, AND SHIKOTAN ISLANDS', 'EUROPA ISLAND', 
         #'GLORIOSO ISLANDS', 'HOWLAND ISLAND', 'JAN MAYEN', 'JARVIS ISLAND', 
         #'JOHNSTON ATOLL', 'JUAN DE NOVA ISLAND', 'KINGMAN REEF', 'MIDWAY ISLANDS', 
         #'NAVASSA ISLAND', 'PALMYRA ATOLL', 'PARACEL ISLANDS', 'SAINT MARTIN', 
         #'SPRATLY ISLANDS', 'TROMELIN ISLAND', 'WAKE ISLAND', 'BASSAS DA INDIA', 'GAZA STRIP')

#out <- readxl::read_excel(filename, sheet = 'TABLE 1', skip = 2) %>%
       #select(fips = Code, country = Name) %>% 
       #filter(!country %in% bad)

#out %>% write_csv('dictionary/data_fips.csv')


