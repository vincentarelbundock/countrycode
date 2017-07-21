parse_api = function(stem, country) {
	sane = all(c('RJSONIO', 'RCurl') %in% row.names(installed.packages()))
	if (!sane) {
		stop('The RJSONIO and RCurl packages must be installed to parse
			  countries using online APIs (Google or DSTK).')
	}
	url = utils::URLencode(paste0(stem, country))
	dat = RJSONIO::fromJSON(url, simplify = TRUE)
	if (dat$status == 'OK') {
		out = dat$results[[1]]$address_components[[1]]$long_name
	} else {
		out = NA
		warning(paste('Failed to parse country name using the Data Science Tool Kit: ', country, '\n'))
	}
	return(out)
}

parse_google = function(country = 'United Starts of American') {
    stem = "http://maps.google.com/maps/api/geocode/json?address="
	out = parse_api(stem, country)
	return(out)
}

parse_dstk = function(country = 'United Starts of American') {
	stem = "http://www.datasciencetoolkit.org/maps/api/geocode/json?&address="
	out = parse_api(stem, country)
	return(out)
}
