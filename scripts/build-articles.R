#!/usr/bin/env Rscript

quarto <- Sys.which("quarto")
if (!nzchar(quarto)) {
    stop("The Quarto CLI is required to render vignettes to GFM.")
}

article_dir <- file.path("docs-src", "articles")
dir.create(article_dir, recursive = TRUE, showWarnings = FALSE)

# Remove stale pages so deleted vignettes cannot survive.
unlink(list.files(article_dir, pattern = "\\.md$", full.names = TRUE))

qmd_files <- sort(list.files(file.path("docs-src", "vignettes"), pattern = "\\.qmd$", full.names = TRUE))
if (!length(qmd_files)) {
    stop("No docs-src/vignettes/*.qmd files found")
}

for (qmd_file in qmd_files) {
    status <- system2(
        quarto,
        c(
            "render",
            normalizePath(qmd_file, mustWork = TRUE),
            "--to", "gfm",
            "--output-dir", normalizePath(article_dir, mustWork = TRUE)
        )
    )
    if (!identical(status, 0L)) {
        stop("Quarto failed to render ", qmd_file, " to GFM")
    }
}

# Rendering standalone QMD files can create this Quarto housekeeping file.
unlink(file.path("docs-src", "vignettes", ".gitignore"))

message("Converted ", length(qmd_files), " vignettes to GFM in ", article_dir)
