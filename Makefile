.PHONY: help website

BOOK_DIR := book

help:  ## Display this help screen
	@echo -e "\033[1mAvailable commands:\033[0m\n"
	@grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' | sort

document:  ## document
	Rscript -e "devtools::document()"

check:  document ## check
	Rscript -e "devtools::check()"

install: document  ## install
	Rscript -e "devtools::install(dependencies = TRUE)"

test: install ## test
	Rscript -e "library(countrycode);devtools::test()"

website: install ## render vignettes and website
	Rscript -e "altdoc::render_docs(verbose = TRUE)"
	# rm -rf _quarto
	# rm -rf ~/Downloads/countrycode_website && cp -r docs ~/Downloads/countrycode_website
