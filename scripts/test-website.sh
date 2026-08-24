#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }

[[ -f docs-src/calepin.toml ]] || fail "docs-src/calepin.toml is missing"
[[ -f docs-src/index.typ ]] || fail "The homepage source is missing"
[[ -f docs-src/assets/logo.png ]] || fail "The countrycode hex logo is missing"
[[ -f scripts/build-reference.R ]] || fail "scripts/build-reference.R is missing"

for article in countrycode countryname custom contributions; do
  [[ -f "docs-src/articles/${article}.typ" ]] || fail "Article ${article}.typ is missing"
done

grep -q 'Sys.which("typst-doc")' scripts/build-reference.R || fail "Reference script does not use typst-doc"
grep -q 'file.path("r", "man")' scripts/build-reference.R || fail "Reference script does not read r/man/*.Rd"
grep -q 'file.path("python", "countrycode")' scripts/build-reference.R || fail "Reference script does not read the Python package"
grep -q 'eval: false' scripts/build-reference.R || fail "Reference pages must not execute their usage and example blocks"

grep -q 'calepin compile docs-src docs' Makefile || fail "Makefile does not build the site with Calepin"
grep -q 'Rscript scripts/build-reference.R' Makefile || fail "Makefile does not generate the reference pages"

grep -q 'logo = "assets/logo.png"' docs-src/calepin.toml || fail "Site does not use the countrycode hex logo"
grep -q 'favicon = "assets/logo.png"' docs-src/calepin.toml || fail "Site does not use the countrycode hex favicon"
grep -q 'https://github.com/vincentarelbundock/countrycode' docs-src/calepin.toml || fail "Site does not link to the GitHub repository"
grep -q 'base-url = "https://vincentarelbundock.github.io/countrycode"' docs-src/calepin.toml || fail "Site base URL is wrong"
grep -q 'target = "reference/r/index.typ"' docs-src/calepin.toml || fail "Navigation does not include the R reference"
grep -q 'target = "reference/python/index.typ"' docs-src/calepin.toml || fail "Navigation does not include the Python reference"

printf 'Calepin site wiring checks passed.\n'
