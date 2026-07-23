.PHONY: help website reference dictionary

help:  ## Display this help screen
	@echo -e "\033[1mAvailable commands:\033[0m\n"
	@grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' | sort

dictionary: ## dictionary
	R CMD BATCH dictionary/build.R

document:  ## document
	Rscript -e "devtools::document()"

check:  document ## check
	Rscript -e "devtools::check()"

install: document  ## install
	Rscript -e "devtools::install(dependencies = TRUE)"

test: install ## test
	Rscript -e "library(countrycode);devtools::test()"

reference: ## convert man/*.Rd to Markdown with pkgsite
	Rscript scripts/build-reference.R

website: reference ## build the Zensical website
	uv run zensical build
