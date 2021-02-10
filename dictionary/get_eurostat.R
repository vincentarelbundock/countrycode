source(here::here('dictionary/utilities.R'))

tmp = tempfile()
url = 'http://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?sort=1&file=dic%2Fen%2Fgeo.dic'
download.file(url, tmp, quiet = TRUE)
eurostat = readr::read_tsv(tmp, col_names = F, col_types = cols(), na = "")

bad_code = c('EU', 'EA')
bad_name = c("Clipperton (FR)",
             "Euro area (EA11-2000, EA12-2006, EA13-2007, EA15-2008, EA16-2010, EA17-2013, EA18-2014, EA19)",
             "European Union (EU6-1972, EU9-1980, EU10-1985, EU12-1994, EU15-2004, EU25-2006, EU27-2013, EU28)",
             "Franc Zone",
             "France (metropolitan)",
             "Investment Facility",
             "Tibet (under the administration of China)")

eurostat = eurostat %>%
           dplyr::rename(eurostat = X1, country = X2) %>%
           dplyr::filter(nchar(eurostat) == 2, # only 2 character codes are countries
                         !is.na(eurostat),
                         !country %in% bad_name,
                         !eurostat %in% bad_code
                         ) %>%  # remove lines without data
           dplyr::mutate(country = ifelse(country == 'China (including Hong Kong)', 'China', country), # regex issue
                         country = ifelse(country == 'China including Hong Kong', 'China', country)) %>%  # regex issue
           dplyr::arrange(eurostat)

eurostat %>% write_csv('dictionary/data_eurostat.csv')
