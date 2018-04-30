# vdem8.csv was extracted manually from pages 34 and 35 of the V-Dem Codebook
# v8 April 2018. 
source('dictionary/utilities.R')

get_vdem_cs = function() {
    out = read_csv('dictionary/vdem8_april2018.csv') %>%
          # Explicitly remove tricky countries. Clean this later.
          filter(Name != 'Vietnam, Republic of',
                 Name != 'Palestine/British Mandate',
                 Name != 'Palestine/Gaza',
                 Name != 'Palestine/West Bank',
                 Name != 'Somaliland',
                 Name != 'Saxe-Weimar-Eisenach') %>%
          mutate(regex = CountryToRegex(Name)) %>%
          select(country.name.en.regex = regex, vdem = ID)
    return(out)
}
