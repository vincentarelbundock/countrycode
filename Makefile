.PHONY: help website reference articles dictionary \
	r-document r-check r-install r-test r-build \
	py-install py-test py-lint py-coverage py-build py-publish

help:  ## Display this help screen
	@echo -e "\033[1mAvailable commands:\033[0m\n"
	@grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' | sort

dictionary: ## dictionary
	Rscript scripts/build-dictionary.R
	cd python && uv run --all-extras python ../scripts/build-dictionary.py

r-document:  ## generate R package documentation
	Rscript -e "devtools::document('r')"

r-check: r-document ## check the R package
	Rscript -e "devtools::check('r')"

r-install: r-document  ## install the R package
	Rscript -e "devtools::install('r', dependencies = TRUE)"

r-test: r-install ## run the R test suite
	Rscript -e "library(countrycode);devtools::test('r')"

r-build: ## build the R package with the root README
	@set -eu; cp README.md r/README.md; trap 'rm -f r/README.md' EXIT INT TERM; R CMD build r

reference: ## convert man/*.Rd to Markdown with pkgsite
	Rscript scripts/build-reference.R

articles: ## convert docs-src/vignettes/*.qmd to Markdown
	Rscript scripts/build-articles.R

website: ## build the Zensical website
	Rscript scripts/build-website.R
	uv run zensical build

py-install: ## install the Python package in its uv environment
	cd python && uv pip install .

py-test: py-install ## run the Python test suite
	cd python && uv run --all-extras pytest

py-lint: ## lint and check formatting for the Python package
	cd python && uv run --all-extras ruff check countrycode tests
	cd python && uv run --all-extras ruff format --check countrycode tests

py-coverage: py-install ## run Python tests with coverage
	cd python && uv run --all-extras pytest --cov=countrycode --cov-report=term-missing --cov-report=html tests

py-build: ## build the Python package with the root README
	@set -eu; cp README.md python/README.md; trap 'rm -f python/README.md' EXIT INT TERM; (cd python && uv build)

py-publish: py-build ## publish the Python package
	cd python && uv publish
