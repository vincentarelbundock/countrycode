#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }

[[ -f zensical.toml ]] || fail "zensical.toml is missing"
[[ -f pyproject.toml ]] || fail "pyproject.toml is missing"
[[ -f uv.lock ]] || fail "uv.lock is missing"
[[ -f scripts/build-reference.R ]] || fail "scripts/build-reference.R is missing"
[[ -f scripts/build-articles.R ]] || fail "scripts/build-articles.R is missing"
[[ -f scripts/build-homepage.R ]] || fail "scripts/build-homepage.R is missing"
[[ -f scripts/build-website.R ]] || fail "scripts/build-website.R is missing"
[[ -f docs-src/assets/logo.png ]] || fail "The countrycode hex logo is missing"
[[ -f .github/workflows/zensical.yaml ]] || fail "Zensical workflow is missing"

grep -q 'file.path("r", "man")' scripts/build-reference.R || fail "R script does not enumerate r/man/*.Rd"
grep -q 'pkgsite::rd_to_qmd' scripts/build-reference.R || fail "R script does not call pkgsite::rd_to_qmd()"
grep -q 'pkgsite::index_to_qmd' scripts/build-reference.R || fail "R script does not create a reference index"
grep -q 'file.path("r", "README.md")' scripts/build-homepage.R || fail "R script does not use r/README.md as the homepage"
grep -q '"--to", "gfm"' scripts/build-reference.R || fail "R script does not render QMD to GFM with Quarto"
grep -q '\\.qmd' scripts/build-reference.R || fail "R script does not stage QMD files"
grep -q 'uv run zensical build' Makefile || fail "Makefile does not build with project-pinned Zensical"
grep -q 'Rscript scripts/build-website.R' Makefile || fail "Makefile does not generate website content"
grep -q 'docs_dir = "docs-src"' zensical.toml || fail "Zensical source directory is not docs-src/"
grep -q 'site_dir = "docs"' zensical.toml || fail "Zensical output directory is not docs/"
grep -q 'favicon = "assets/logo.png"' zensical.toml || fail "Zensical does not use the countrycode hex favicon"
grep -q 'logo = "assets/logo.png"' zensical.toml || fail "Zensical navbar does not use the countrycode hex logo"
grep -q 'repo_url = "https://github.com/vincentarelbundock/countrycode"' zensical.toml || fail "Zensical navbar does not link to the GitHub repository"
grep -q 'scheme = "default"' zensical.toml || fail "Zensical light palette is missing"
grep -q 'scheme = "slate"' zensical.toml || fail "Zensical dark palette is missing"
grep -q 'assets/logo.png' scripts/build-homepage.R || fail "Homepage does not use the countrycode hex logo"
grep -q '"Articles"' zensical.toml || fail "Zensical navigation does not include articles"
grep -q '"R" = "reference/r/index.md"' zensical.toml || fail "Zensical navigation does not include the R reference"
grep -q '"Python" = "reference/python.md"' zensical.toml || fail "Zensical navigation does not include the Python reference"
grep -q 'paths = \["python"\]' zensical.toml || fail "mkdocstrings does not search the Python package"
grep -q 'mkdocstrings-python' pyproject.toml || fail "Python API documentation dependency is missing"
[[ -f docs-src/reference/python.md ]] || fail "Python reference source is missing"
grep -q 'folder: docs' .github/workflows/zensical.yaml || fail "CI does not deploy docs/"
grep -q 'uv run --frozen zensical build' .github/workflows/zensical.yaml || fail "CI does not build with the frozen Zensical lockfile"
grep -q 'Rscript scripts/build-website.R' .github/workflows/zensical.yaml || fail "CI does not generate website content"
grep -q 'quarto-actions/setup' .github/workflows/zensical.yaml || fail "CI does not install Quarto"

printf 'Zensical site wiring checks passed.\n'
