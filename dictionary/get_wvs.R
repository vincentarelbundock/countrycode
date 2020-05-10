source(here::here('dictionary/utilities.R'))

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
wvs <- readxl::read_excel('tmp.xls', sheet = 'Codebook', skip = 3)
sink()
unlink('tmp.xls')

bad <- c("East Germany", "West Germany", "SrpSka Republic", "Bosnia",
         "Cyprus (T)", "Tambov", "Moscow", "Basque Country", "Andalusia",
         "Galicia", "North Ireland", "Valencia", "Serbian Bosnia",
         "Missing; Unknown", "Not asked in survey", "Not applicable", 
         "No answer", "Don't know")


cntrytxt <- wvs$CATEGORIES[grepl('^S003$', wvs$VARIABLE)]

wvs <- readr::read_delim(cntrytxt, delim = ':', col_names = F) %>%
       rename(country = X2, wvs = X1) %>%
       filter(!country %in% bad)

wvs %>% write_csv('dictionary/data_wvs.csv')

