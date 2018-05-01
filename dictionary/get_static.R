# This script loads static codes and regexes

get_static <- function() {
    out = readr::read_csv('dictionary/data_static.csv')
    return(out)
}
