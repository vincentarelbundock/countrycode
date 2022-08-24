source(here::here('dictionary/utilities.R'))

url <- 'http://www.systemicpeace.org/inscr/p5v2018.xls'

download.file(url, tmpxls <- tempfile(fileext = '.xls'), quiet = TRUE)
p5 <- read_excel(tmpxls) %>%
      select(p5n = ccode, 
             p5c = scode,
             country,
             year) %>%
      mutate(p5n = as.integer(p5n), 
             year = as.integer(year)) %>%
      # overlapping years; pick one arbitrarily
      filter((year != 1832) | (p5c != 'GCL'), # Gran Colombia vs. Colombia
             (year != 1861) | (p5c != 'SAR'), # Sardinia vs. Italy
             (year != 1993) | (p5c != 'ETI'), # Ethiopia
             (year != 2011) | (p5c != 'SDN'), # Sudan
             (year != 1976) | (p5c != 'DRV'), # Vietnam North vs. Vietnam
             (year != 1922) | (p5c != 'USR'), # USSR
             (year != 1991) | (p5c != 'YGS'), # Yugoslavia
             (year != 1945) | (p5c != 'GFR'), # Germany vs. West Germany
             (year != 1990) | (p5c != 'GFR')) # Germany vs. West Germany

p5 %>% write_csv('dictionary/data_polity5.csv', na = "")
