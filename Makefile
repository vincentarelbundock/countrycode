clean:
	R CMD BATCH prep.R
	rm -f *out
