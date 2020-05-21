source(here::here('dictionary/utilities.R'))

# This script will get the most recently released version of the CLDR full JSON
# set of localized country names and variants

# warn if not running in an UTF-8 locale
if (! l10n_info()$`UTF-8`) warning('Running in a non-UTF-8 locale!')

##############
#  download  #
##############

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

###########
#  parse  #
###########

get_names <- function(filename) {
    langId <- gsub('-', '_', rev(strsplit(filename, '/')[[1]])[2]) # 2nd to last part of filepath
    lang <- jsonlite::fromJSON(filename)
    lang <- lang[[1]][[1]]$localeDisplayNames$territories
    lang <- tibble(code = names(lang), name = unlist(lang)) %>% 
            separate(code, c('iso2c', 'variant'), sep = '-alt-', extra = 'merge', fill = 'right') %>% 
            mutate(variant = if_else(is.na(variant), 'cldr.name', paste0('cldr.', variant))) %>% 
            spread(variant, name) %>% 
            mutate_at(vars(-iso2c, -cldr.name), .funs = list(~ if_else(is.na(.), cldr.name, .)))
    names(lang)[-1] <- paste0(names(lang)[-1], '.', langId)
    return(lang)
}

cldr <- map(filelist, get_names) %>%
        reduce(full_join, by = 'iso2c')

unlink(filelist)
unlink(zipfile)


#######################
#  clean and combine  #
#######################

bad <- c("Ascension Island", "Clipperton Island", "Diego Garcia", 
         "Ceuta & Melilla", "European Union", "Eurozone", "Micronesia", 
         "Canary Islands", "St. Martin", "Outlying Oceania", "Tristan da Cunha", 
         "U.S. Outlying Islands", "United Nations", "Unknown Region",
         "Pseudo-Accents", "Pseudo-Bidi")

cldr <- cldr %>%
        filter(!nchar(iso2c) > 2, # remove rows with 3 digit codes
               !cldr.name.en %in% bad,  # remove 'bad' countries
               !cldr.name.af %in% c('XA', 'XB')) %>% # weird no matching regex
        select(-iso2c) %>%
        setNames(tolower(names(.)))

# duplicate column names
if (anyDuplicated(colnames(cldr)) > 0) stop('duplicated column names')

# duplicated column content
cldr <- cldr %>% select(order(names(.)))
cldr <- cldr[!duplicated(as.list(cldr))]


########################
#  example data.frame  #
########################

# Save examples data.frame
k = cldr %>% 
    filter(cldr.name.en == 'French Southern Territories')  %>%
    t %>%
    cbind(row.names(.), .) %>%
    data.frame %>% 
    setNames(c('Code', 'Example'))
k = k[2:nrow(k),]
row.names(k) = NULL
cldr_examples = k
save(cldr_examples, file = 'data/cldr_examples.rda', compress='xz', version=2)


##########
#  save  #
##########

cldr %>% mutate(country = cldr.name.en) %>%
         write_csv('dictionary/data_cldr.csv')
