get_world_bank = function() {
#    url <- 'http://databank.worldbank.org/data/AjaxDownload/FileDownloadHandler.ashx?filename=Data_Extract_From_World_Development_Indicators_Metadata.xlsx&filetype=METADATA&language=en'

    #filename <- tempfile(fileext = '.xlsx')
    #download.file(url, filename, quiet = TRUE)
    #wb <- readxl::read_excel(filename, sheet = 'Country - Metadata')

    #bad <- c('Channel Islands',  # not recognized states in countryyear
             #'Virgin Islands')
    #wb <-
        #wb %>%
        #dplyr::filter(!is.na(Region)) %>%  # remove aggregates
        #dplyr::select(wb = Code, wb.name = `Short Name`) %>% 
        #dplyr::filter(!wb.name %in% bad) %>%
        ## TODO: regex improvements
        #dplyr::mutate(wb.name = if_else(wb.name == 'Micronesia', 'Federated States of Micronesia', wb.name)) %>%
        #dplyr::mutate(country.name.en.regex = CountryToRegex(wb.name))

#    return(wb)

    return(NULL) # this function is broken; only returns 39 rows
}
