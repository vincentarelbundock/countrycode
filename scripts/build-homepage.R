#!/usr/bin/env Rscript

readme_file <- "README.md"
if (!file.exists(readme_file)) {
  stop("The R package README is missing: ", readme_file)
}

docs_src_dir <- "docs-src"
dir.create(docs_src_dir, recursive = TRUE, showWarnings = FALSE)

index <- readLines(readme_file, warn = FALSE)
index <- sub(
  "https://user-images.githubusercontent.com/987058/167296405-e7798ac8-03e7-444e-acaf-d99fc42d1c9e.png",
  "assets/logo.png",
  index,
  fixed = TRUE
)
writeLines(index, file.path(docs_src_dir, "index.md"), useBytes = TRUE)

message(
  "Copied homepage from ",
  readme_file,
  " to ",
  file.path(docs_src_dir, "index.md")
)
