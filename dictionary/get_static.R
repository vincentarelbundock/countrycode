# This script loads static codes and regexes

get_static <- function() {
    out = readr::read_csv('data/dictionary_static.csv')
    return(out)
}
