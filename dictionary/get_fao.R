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
      "Bassas da India", "Gaza Strip", "Panama, Former Canal Zone")


fao <- readxl::read_excel(tmp_xlsx) %>% 
    dplyr::select(country = SNAME_EN,
                  fao = FAOSTAT_CODE,
                  #undp = UNDP_CODE, # United Nations Development Programme
                  gaul = GAUL_CODE) %>% # Global Administrative Unit Layers
    dplyr::mutate(fao = as.integer(fao),
                  gaul = as.integer(gaul),
                  country = ifelse(country == 'US Minor Is.', 'US Minor Outlying Islands', country)) %>% 
    dplyr::filter(!country %in% bad)

unlink(tmp_xlsx)

fao %>% write_csv('dictionary/data_fao.csv')
