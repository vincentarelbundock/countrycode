source(here::here('dictionary/utilities.R'))

get_polity4 <- function() {

    url <- 'http://www.systemicpeace.org/inscr/p4v2015.xls'

    download.file(url, tmpxls <- tempfile(fileext = '.xls'), quiet = TRUE)
    p4 <- readxl::read_excel(tmpxls) %>%
          dplyr::select(p4n = ccode, 
                        p4c = scode,
                        p4.name = country,
                        year) %>%
          dplyr::mutate(p4n = as.integer(p4n), year = as.integer(year),
                        country.name.en.regex = CountryToRegex(p4.name)) %>%
          # overlapping years; pick one arbitrarily
          dplyr::filter((year != 1832) | (p4c != 'GCL'), # Gran Colombia vs. Colombia
                        (year != 1861) | (p4c != 'SAR'), # Sardinia vs. Italy
                        (year != 1993) | (p4c != 'ETI'), # Ethiopia
                        (year != 2011) | (p4c != 'SDN'), # Sudan
                        (year != 1976) | (p4c != 'DRV'), # Vietnam North vs. Vietnam
                        (year != 1922) | (p4c != 'USR'), # USSR
                        (year != 1991) | (p4c != 'YGS'), # Yugoslavia
                        (year != 1945) | (p4c != 'GFR'), # Germany vs. West Germany
                        (year != 1990) | (p4c != 'GFR'), # Germany vs. West Germany
                        ) 

      return(p4)

}
