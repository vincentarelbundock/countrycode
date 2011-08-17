`countrycode.nomatch` <-
function(ORIGIN, DESTINATION){
symmetric_vectors <- countrycode_data[c(ORIGIN, DESTINATION)]
symmetric_vectors <- cbind(symmetric_vectors, countrycode_data$country.name)
symmetric_vectors <- symmetric_vectors[which (is.na(symmetric_vectors[ORIGIN])==TRUE | is.na(symmetric_vectors[DESTINATION])==TRUE ),]
symmetric_vectors
}

