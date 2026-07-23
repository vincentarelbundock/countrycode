#!/usr/bin/env Rscript

local({

if (!requireNamespace("pkgsite", quietly = TRUE)) {
    stop("The 'pkgsite' package is required. Install it with install.packages('pkgsite').")
}

quarto <- Sys.which("quarto")
if (!nzchar(quarto)) {
    stop("The Quarto CLI is required to render pkgsite QMD files to GFM.")
}

build_dir <- "build"
qmd_dir <- file.path(build_dir, "pkgsite-reference")
reference_dir <- file.path("docs-src", "reference", "r")
dir.create(qmd_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(reference_dir, recursive = TRUE, showWarnings = FALSE)

# R reference pages previously lived directly in docs-src/reference/. Remove
# those generated files while preserving the hand-written Python reference.
legacy_reference_dir <- file.path("docs-src", "reference")
legacy_reference_files <- list.files(
    legacy_reference_dir,
    pattern = "\\.md$",
    full.names = TRUE
)
unlink(setdiff(legacy_reference_files, file.path(legacy_reference_dir, "python.md")))

cleanup_staging <- function() {
    unlink(qmd_dir, recursive = TRUE)
    if (
        dir.exists(build_dir) &&
        !length(list.files(build_dir, all.files = TRUE, no.. = TRUE))
    ) {
        unlink(build_dir, recursive = TRUE)
    }
}
on.exit(cleanup_staging(), add = TRUE)

# Remove stale generated sources and pages so deleted Rd topics cannot survive.
unlink(list.files(qmd_dir, pattern = "\\.qmd$", full.names = TRUE))
unlink(list.files(reference_dir, pattern = "\\.md$", full.names = TRUE))

render_gfm <- function(input) {
    status <- system2(
        quarto,
        c(
            "render",
            normalizePath(input, mustWork = TRUE),
            "--to", "gfm",
            "--output-dir", normalizePath(reference_dir, mustWork = TRUE),
            "--quiet"
        )
    )
    if (!identical(status, 0L)) {
        stop("Quarto failed to render ", input, " to GFM")
    }
}

rd_files <- sort(list.files(file.path("r", "man"), pattern = "\\.Rd$", full.names = TRUE))
if (!length(rd_files)) {
    stop("No r/man/*.Rd files found")
}

qmd_files <- character()
for (rd_file in rd_files) {
    page <- pkgsite::rd_to_qmd(
        path = rd_file,
        pkg = "r",
        examples = FALSE,
        not_run_examples = FALSE
    )

    # pkgsite returns NULL for internal-only topics.
    if (is.null(page)) {
        next
    }

    output <- file.path(
        qmd_dir,
        paste0(tools::file_path_sans_ext(basename(rd_file)), ".qmd")
    )
    writeLines(page, output, useBytes = TRUE)
    qmd_files <- c(qmd_files, output)
}

index_qmd <- file.path(qmd_dir, "index.qmd")
writeLines(pkgsite::index_to_qmd(pkg = "r"), index_qmd, useBytes = TRUE)
qmd_files <- c(index_qmd, qmd_files)

for (qmd_file in qmd_files) {
    render_gfm(qmd_file)
}

# Quarto normally rewrites QMD links for GFM. Normalize any literal suffixes
# retained by templates or raw Markdown so Zensical never receives .qmd links.
md_files <- list.files(reference_dir, pattern = "\\.md$", full.names = TRUE)
for (md_file in md_files) {
    lines <- readLines(md_file, warn = FALSE)
    lines <- gsub("\\.qmd(?=([#?)[:space:]]|$))", ".md", lines, perl = TRUE)
    writeLines(lines, md_file, useBytes = TRUE)
}

message(
    "Converted ", length(qmd_files) - 1L, " of ", length(rd_files),
    " Rd files via QMD to GFM in ", reference_dir
)

})
