countrycode<-function (SOURCEVAR, ORIGIN, DESTINATION){
	origin.codes<-c("cowc", "cown", "fips04", "imf", "iso2c", "iso3c", "iso3n", "country.name")
	destination.codes<-c("region", "continent", "cowc", "cown", "fips04", "imf", "iso2c", "iso3c", "iso3n", "country.name")
	if ((ORIGIN %in% origin.codes)==FALSE){
		stop(paste("Origin code, ", ORIGIN, ", not supported.", sep=""))
	}
	if ((DESTINATION %in% destination.codes)==FALSE){
		stop(paste("Destination code, ", DESTINATION, ", not supported.", sep=""))
	}
	if (ORIGIN != "country.name"){
		matches<-match(SOURCEVAR, countrycode_data[, ORIGIN])
		destination.vector<-countrycode_data[matches, DESTINATION]
		destination.vector[is.na(SOURCEVAR)==TRUE]<-NA
	}else{
		# Prepare destination.vector
		destination.vector<-NULL
		for (z in 1:length(SOURCEVAR)){destination.vector<-c(NA,destination.vector)}
		# For each regex in the database -> find matches
		for (i in 1:nrow(countrycode_data)){
			Origin_code <- countrycode_data$regex[i]
			Destination_code <- countrycode_data[i,DESTINATION]
			matches <- as.vector(grep(Origin_code, as.vector(SOURCEVAR), perl = TRUE, ignore.case = TRUE, value = FALSE))
			# For each match -> replace in target vector
			for (j in matches) {
				destination.vector[j] <- Destination_code
			}
		}
	}
	return(destination.vector)
}