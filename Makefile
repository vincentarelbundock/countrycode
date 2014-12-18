clean:
	R CMD BATCH prep.R
	rm -f data/countrycode_data.csv
	rm -f README.md
	rm -f prep.R
	rm -f prep.Rout
	rm -rf tests
	rm -f Makefile
