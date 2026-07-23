#' Guess the code/name of a vector
#'
#' Users sometimes do not know what kind of code or field their data contain.
#' This function tries to guess by comparing the similarity between a
#' user-supplied vector and all the codes included in the `countrycode`
#' dictionary.
#'
#' @param codes a vector of country codes or country names
#' @param min_similarity the function returns all field names where over than
#' `min_similarity`% of codes are shared between the supplied vector and the
#' `countrycode` dictionary.
#'
#' @export
#' @examples
#' # Guess ISO codes
#' guess_field(c('DZA', 'CAN', 'DEU'))
#'
#' # Guess country names
#' guess_field(c('Guinea','Iran','Russia','North Korea',rep('Ivory Coast',50),'Scotland'))
guess_field <- function(codes, min_similarity = 80) {
  if (!mode(codes) %in% c('character', 'numeric')) {
    stop('sourcevar must be a character or numeric vector. This error often arises when users pass a tibble (e.g., from dplyr) instead of a column vector from a data.frame (i.e., my_tbl[, 2] vs. my_df[, 2] vs. my_tbl[[2]]). This can also happen when `sourcevar` is entirely composed of `NA`, which `R` treats as entries of class logical.')
  }

  x <- unique(codes)

  match_percentage <-
    sapply(countrycode::codelist, function(code) {
      sum(x %in% code) / length(x) * 100
    })

  match_percentage <- match_percentage[match_percentage >= min_similarity]

  match_percentage <- match_percentage[order(match_percentage, decreasing = TRUE)]

  data.frame(code = names(match_percentage),
             percent_of_unique_matched = match_percentage,
             stringsAsFactors = FALSE)
}
