#!/usr/bin/env Rscript

# Generate the Typst reference pages consumed by the Calepin website.
#
#   docs-src/reference/r/*.typ       from r/man/*.Rd
#   docs-src/reference/python/*.typ  from python/countrycode/*.py
#
# Both are rendered by the typst-doc CLI, which emits plain Typst. This script
# adds the `<website-metadata>` front matter Calepin reads for navigation, and
# replaces typst-doc's `#include`-based index with a linked one.

local({
  typst_doc <- Sys.which("typst-doc")
  if (!nzchar(typst_doc)) {
    stop(
      "The 'typst-doc' executable is required. Install it from ",
      "https://github.com/vincentarelbundock/typst-doc.",
      call. = FALSE
    )
  }
  typst_doc <- unname(typst_doc)

  # Typst markup escapes punctuation with a backslash. Metadata values are
  # plain strings, so they need those escapes removed.
  unescape_typst <- function(x) gsub("\\\\(.)", "\\1", x, perl = TRUE)

  quote_typst <- function(x) {
    paste0('"', gsub('(["\\\\])', "\\\\\\1", x, perl = TRUE), '"')
  }

  # typst-doc opens every page with `= <title> <label>`, where the label is the
  # topic name. That line is the only page metadata this script needs.
  read_topic <- function(path) {
    lines <- readLines(path, warn = FALSE)
    heading <- if (length(lines)) lines[[1]] else ""
    matched <- regmatches(heading, regexec("^= (.*) <([^>]+)>\\s*$", heading))[[1]]
    if (length(matched) != 3L) {
      stop("Unexpected first line in ", path, ": ", heading)
    }
    list(
      file = tools::file_path_sans_ext(basename(path)),
      path = path,
      title = matched[[2]],
      name = matched[[3]]
    )
  }

  # Usage synopses and `\dontrun` examples are illustrations, not a notebook.
  # Calepin executes every fenced R or Python block it finds, so reference pages
  # have to turn evaluation off explicitly.
  no_eval <- c(
    '#import "/.calepin/calepin.typ" as calepin',
    "#show: calepin.document",
    "",
    "#calepin.setup(eval: false, echo: true)",
    ""
  )

  add_front_matter <- function(topic, label) {
    writeLines(
      c(
        no_eval,
        paste0("#set document(title: [", topic$title, "])"),
        "",
        "#metadata((",
        paste0("  title: ", quote_typst(label), ","),
        paste0("  summary: ", quote_typst(unescape_typst(topic$title)), ","),
        ")) <website-metadata>",
        "",
        readLines(topic$path, warn = FALSE)
      ),
      topic$path,
      useBytes = TRUE
    )
  }

  write_index <- function(dir, title, summary, topics, labels) {
    lines <- c(
      paste0("#set document(title: [", title, "])"),
      "",
      "#metadata((",
      '  title: "Overview",',
      paste0("  summary: ", quote_typst(summary), ","),
      ")) <website-metadata>",
      "",
      "#title()",
      ""
    )
    for (i in seq_along(topics)) {
      lines <- c(
        lines,
        paste0(
          "/ #link(",
          quote_typst(paste0(topics[[i]]$file, ".typ")),
          ")[`",
          labels[[i]],
          "`]: ",
          topics[[i]]$title
        )
      )
    }
    writeLines(lines, file.path(dir, "index.typ"), useBytes = TRUE)
  }

  render <- function(input, dir) {
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
    # Remove stale pages so deleted topics cannot survive a rebuild.
    unlink(list.files(dir, pattern = "\\.typ$", full.names = TRUE))

    status <- system2(typst_doc, c(shQuote(input), "--split", "-o", shQuote(dir)))
    if (!identical(status, 0L)) {
      stop("typst-doc failed on ", input)
    }

    # typst-doc's index is a list of `#include`s for a single joined document.
    # A website wants one page per topic and a linked index instead.
    unlink(file.path(dir, "index.typ"))

    files <- list.files(dir, pattern = "\\.typ$", full.names = TRUE)
    if (!length(files)) {
      stop("typst-doc produced no pages from ", input)
    }
    lapply(files, read_topic)
  }

  ## ------------------------------------------------------------------ R ----

  r_dir <- file.path("docs-src", "reference", "r")
  r_topics <- render(file.path("r", "man"), r_dir)
  r_topics <- r_topics[order(vapply(r_topics, function(x) x$name, ""))]
  r_labels <- vapply(r_topics, function(x) x$name, "")

  for (i in seq_along(r_topics)) {
    add_front_matter(r_topics[[i]], r_labels[[i]])
  }
  write_index(
    r_dir,
    "R reference",
    "Every documented object in the countrycode R package.",
    r_topics,
    r_labels
  )

  ## ------------------------------------------------------------- Python ----

  py_dir <- file.path("docs-src", "reference", "python")
  py_topics <- render(file.path("python", "countrycode"), py_dir)

  # typst-doc names Python topics `<module>.<definition>`, and gives each module
  # docstring a topic of its own. A bare module summary is not a reference page,
  # so keep only the definitions.
  is_definition <- grepl(".", vapply(py_topics, function(x) x$name, ""), fixed = TRUE)
  for (topic in py_topics[!is_definition]) {
    unlink(topic$path)
  }
  py_topics <- py_topics[is_definition]
  if (!length(py_topics)) {
    stop("typst-doc found no documented definitions in python/countrycode")
  }

  # Navigation shows the bare object name; the page heading keeps its summary.
  py_labels <- sub("^.*\\.", "", vapply(py_topics, function(x) x$name, ""))
  py_topics <- py_topics[order(py_labels)]
  py_labels <- sort(py_labels)

  for (i in seq_along(py_topics)) {
    add_front_matter(py_topics[[i]], py_labels[[i]])
  }
  write_index(
    py_dir,
    "Python reference",
    "Every documented function in the countrycode Python package.",
    py_topics,
    py_labels
  )

  message(
    "Wrote ",
    length(r_topics),
    " R reference pages to ",
    r_dir,
    " and ",
    length(py_topics),
    " Python reference pages to ",
    py_dir
  )
})
