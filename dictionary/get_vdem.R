# vdem8.csv was extracted manually from pages 34 and 35 of the V-Dem Codebook
# v8 April 2018. 
source('dictionary/utilities.R')

get_vdem = function() {

    dat = read_csv('dictionary/vdem8_april2018.csv') %>%
          # Explicitly remove tricky countries. Clean this later.
          filter(Name != 'Vietnam, Republic of',
                 Name != 'Palestine/British Mandate',
                 Name != 'Palestine/Gaza',
                 Name != 'Palestine/West Bank',
                 Name != 'Somaliland',
                 Name != 'Saxe-Weimar-Eisenach') %>%
          mutate(regex = CountryToRegex(Name)) %>%
          tidyr::separate(Coverage, into = c('start', 'end'), sep = '–')
    out = list()
    for (i in 1:nrow(dat)) {
        out[[i]] = data.frame('country.name.en.regex' = dat$regex[[i]],
                              'vdem' = dat$ID[[i]],
                              'year' = dat$start[[i]]:dat$end[[i]],
                              stringsAsFactors = FALSE)
    } 
    out = do.call('rbind', out)
    return(out)

}
