source(here::here('dictionary/utilities.R'))

url <- 'http://www.systemicpeace.org/inscr/p4v2015.xls'

download.file(url, tmpxls <- tempfile(fileext = '.xls'), quiet = TRUE)
p4 <- read_excel(tmpxls) %>%
      select(p4n = ccode, 
             p4c = scode,
             p4.name = country,
             year) %>%
      mutate(country = p4.name,
             p4n = as.integer(p4n), 
             year = as.integer(year)) %>%
      # overlapping years; pick one arbitrarily
      filter((year != 1832) | (p4c != 'GCL'), # Gran Colombia vs. Colombia
             (year != 1861) | (p4c != 'SAR'), # Sardinia vs. Italy
             (year != 1993) | (p4c != 'ETI'), # Ethiopia
             (year != 2011) | (p4c != 'SDN'), # Sudan
             (year != 1976) | (p4c != 'DRV'), # Vietnam North vs. Vietnam
             (year != 1922) | (p4c != 'USR'), # USSR
             (year != 1991) | (p4c != 'YGS'), # Yugoslavia
             (year != 1945) | (p4c != 'GFR'), # Germany vs. West Germany
             (year != 1990) | (p4c != 'GFR')) # Germany vs. West Germany

p4 %>% write_csv('dictionary/data_polity4.csv')
