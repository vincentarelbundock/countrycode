get_wvs = function() {

    # Download
    sink('/dev/null') # hack to suppress irritating/uninformative messages
    httr::VERB(verb = "GET", url = "http://www.worldvaluessurvey.org/wvsdc/CO00001/F00003843_WVS_EVS_Integrated_Dictionary_Codebook_v_2014_09_22.xls",
               httr::add_headers(Host = "www.worldvaluessurvey.org",
                                 `User-Agent` = "curl",
                                 Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                                 `Accept-Language` = "en-US,en;q=0.5",
                                 Referer = "http://www.worldvaluessurvey.org/AJDocumentationSmpl.jsp",
                                 Connection = "keep-alive",
                                 `Upgrade-Insecure-Requests` = "1"),
               httr::write_disk('tmp.xls', overwrite = T)
         )

    # Read
    wvs <- suppressWarnings(readxl::read_excel('tmp.xls', sheet = 'Codebook', skip = 3))
    sink()
    unlink('tmp.xls')
    cntrytxt <- wvs$CATEGORIES[grepl('^S003$', wvs$VARIABLE)]
    wvs <- readr::read_delim(cntrytxt, delim = ':', col_names = F)

    # Clean 
    wvs <- wvs %>%
           dplyr::rename(wvs = X1, wvs.name = X2) %>%
           dplyr::filter(wvs >= 0, # negative numbers are for missings
                         #wvs.name != 'D.R. Congo',
                         wvs.name != 'Andalusia',
                         wvs.name != 'North Ireland',
                         wvs.name != 'Cyprus (T)',
                         wvs.name != 'Basque Country',
                         wvs.name != 'Galicia',
                         wvs.name != 'Moscow',
                         wvs.name != 'Serbia and Montenegro',
                         wvs.name != 'Serbian Bosnia',
                         wvs.name != 'SrpSka Republic',
                         wvs.name != 'West Germany',
                         wvs.name != 'East Germany',
                         wvs.name != 'Tambov',
                         wvs.name != 'Valencia',
                         wvs != 914) %>% # Bosnia duplicate
           dplyr::mutate(country.name.en.regex = CountryToRegex(wvs.name))

    return(wvs)
}
