# This script will get the most recently released version of the CLDR full JSON
# set of localized country names and variants

get_cldr <- function() {
    # warn if not running in an UTF-8 locale
    if (! l10n_info()$`UTF-8`) warning('Running in a non-UTF-8 locale!')
    
    # load necessary packages
    require(tibble)
    require(tidyr)
    require(dplyr)
    require(jsonlite)
    require(httr)
    
    # get the zip URL for the most recent release and download to a temp file
    full_url <- 'https://api.github.com/repos/unicode-cldr/cldr-localenames-full/releases/latest'
    full_zip_url <- jsonlite::fromJSON(full_url)$zipball_url
    zipfile <- tempfile(fileext = '.zip')
    httr::GET(full_zip_url, httr::write_disk(zipfile))#, httr::progress())
    utils::flush.console() # workaround bug in httr
    
    # unzip only the files named 'territories.json'
    filelist <- utils::unzip(zipfile, list = T)
    filelist <- filelist$Name[grep('/territories.json$', filelist$Name)]
    filelist <- utils::unzip(zipfile, files = filelist, overwrite = T, 
                             exdir = tempdir())
    
    # build a list of data frames for each 'territories.json' file and merge
    get_names <- function(filelist) {
        #pb <- txtProgressBar(max = length(filelist), style = 3)
        langlist <- 
            lapply(seq_along(filelist), function(i) {
                file <- filelist[[i]]
                langId <- gsub('-', '_', rev(strsplit(file, '/')[[1]])[2]) # 2nd to last part of filepath
                lang <- jsonlite::fromJSON(file)
                lang <- lang[[1]][[1]]$localeDisplayNames$territories
                lang <- 
                    tibble::tibble(code = names(lang), name = unlist(lang)) %>% 
                    tidyr::separate(code, c('iso2c', 'variant'), sep = '-alt-', extra = 'merge', fill = 'right') %>% 
                    dplyr::mutate(variant = if_else(is.na(variant), 'cldr.name', paste0('cldr.', variant))) %>% 
                    tidyr::spread(variant, name) %>% 
                    dplyr::mutate_at(vars(-iso2c, -cldr.name), funs(if_else(is.na(.), cldr.name, .)))
                names(lang)[-1] <- paste0(names(lang)[-1], '.', langId)
                #setTxtProgressBar(pb, i)
                return(lang)
            })
        #close(pb)
        return(langlist)
    }
    cldr <- get_names(filelist)
    cldr <- Reduce(function(x, y) dplyr::full_join(x, y, by = 'iso2c'), cldr)
        
    # prepare
    bad <- c("Ascension Island", "Clipperton Island", "Diego Garcia", 
          "Ceuta & Melilla", "European Union", "Eurozone", "Micronesia", 
          "Canary Islands", "St. Martin", "Outlying Oceania", "Tristan da Cunha", 
          "U.S. Outlying Islands", "United Nations", "Unknown Region",
          "Pseudo-Accents", "Pseudo-Bidi")
    cldr <- 
        cldr %>% 
        dplyr::filter(! nchar(iso2c) > 2) %>% # remove rows with 3 digit codes
        dplyr::filter(! cldr.name.en %in% bad) %>%  # remove 'bad' countries
        dplyr::mutate(country.name.en.regex = CountryToRegex(cldr.name.en)) %>% 
        dplyr::select(-iso2c) %>%
        dplyr::select(country.name.en.regex, order(names(.))) # sort columns -- needed for duplication removal

    # remove duplicated columns
    cldr <- cldr[!duplicated(as.list(cldr))]

    # weird cases with no matching regexes
    clrd = cldr[!cldr$cldr.name.af %in% c('XA', 'XB'),]

    # codes to lower-case
    colnames(cldr) = tolower(colnames(cldr))
    
    # remove temp files
    unlink(filelist)
    unlink(zipfile)
    
    # Save examples data.frame
    k = cldr %>% 
        dplyr::filter(cldr.name.en == 'French Southern Territories')  %>%
        t %>%
        cbind(row.names(.), .) %>%
        data.frame %>% 
        setNames(c('Code', 'Example'))
    k = k[2:nrow(k),]
    row.names(k) = NULL
    cldr_examples = k
    save(cldr_examples, file = 'data/cldr_examples.rda')

    # Output
    return(cldr)
}
