append_unique_id <- function(x) {
  for (i in seq_along(x)) {
    x[i] <- paste0("<", paste(sample(letters, 10), collapse = ""), ">", x[i])
  }
  x
}

# https://stackoverflow.com/questions/3318333/split-a-vector-into-chunks
chunk <- function(x, n) split(x, factor(sort(rank(x) %% n)))
