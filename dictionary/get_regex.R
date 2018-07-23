# This script loads static codes and regexes

get_regex <- function() {
    out = readr::read_csv('dictionary/data_regex.csv')
    return(out)
}
