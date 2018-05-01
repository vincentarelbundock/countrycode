# vdem8.csv was extracted manually from pages 34 and 35 of the V-Dem Codebook
# v8 April 2018. 
source('dictionary/utilities.R')

get_vdem_cs = function() {
    source('dictionary/get_vdem.R')
    out = get_vdem() %>%
          select(country.name.en.regex, vdem) %>%
          unique
    return(out)
}
