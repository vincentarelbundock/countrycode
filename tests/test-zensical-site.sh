#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }

[[ -f zensical.toml ]] || fail "zensical.toml is missing"
[[ -f pyproject.toml ]] || fail "pyproject.toml is missing"
[[ -f uv.lock ]] || fail "uv.lock is missing"
[[ -f scripts/build-reference.R ]] || fail "scripts/build-reference.R is missing"
[[ -f .github/workflows/zensical.yaml ]] || fail "Zensical workflow is missing"

grep -q 'list.files("man"' scripts/build-reference.R || fail "R script does not enumerate man/*.Rd"
grep -q 'pkgsite::rd_to_qmd' scripts/build-reference.R || fail "R script does not call pkgsite::rd_to_qmd()"
grep -q 'pkgsite::index_to_qmd' scripts/build-reference.R || fail "R script does not create a reference index"
grep -q '"--to", "gfm"' scripts/build-reference.R || fail "R script does not render QMD to GFM with Quarto"
grep -q '\\.qmd' scripts/build-reference.R || fail "R script does not stage QMD files"
grep -q 'uv run zensical build' Makefile || fail "Makefile does not build with project-pinned Zensical"
grep -q 'Rscript scripts/build-reference.R' Makefile || fail "Makefile does not generate reference Markdown"
grep -q 'uv run --frozen zensical build' .github/workflows/zensical.yaml || fail "CI does not build with the frozen Zensical lockfile"
grep -q 'Rscript scripts/build-reference.R' .github/workflows/zensical.yaml || fail "CI does not generate reference Markdown"
grep -q 'quarto-actions/setup' .github/workflows/zensical.yaml || fail "CI does not install Quarto"

printf 'Zensical site wiring checks passed.\n'
