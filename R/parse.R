parse_api = function(stem, country, api = 'google') {
    if (api == 'dstk') {
	    stem = "http://www.datasciencetoolkit.org/maps/api/geocode/json?&address="
    } else {
        stem = "http://maps.google.com/maps/api/geocode/json?address="
    }
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

parse_regex <- function(origin_vector, dict, warn) {
    
    # convert to factor to speed-up
    if (!is.factor(origin_vector)) {
        origin_factor <- factor(origin_vector)
    } else {
        origin_factor <- origin_vector
    }
    origin_levels <- levels(origin_factor)

    # find matching strings for each regex
    match_matrix <- matrix(NA, nrow = length(origin_levels), ncol = nrow(dict))
    for (i in 1:ncol(match_matrix)) { # for each regex
        idx <- grepl(dict[i, 1], origin_levels, perl = TRUE, ignore.case = TRUE)
        match_matrix[, i] <- ifelse(idx, dict[[2]][i], NA)
    }

    # bad matches 
    idx <- rowSums(!is.na(match_matrix)) # how many matches per origin string?

    if (any(idx == 0)) { # no match
        match_matrix[idx == 0, ] = NA
        msg <- paste(unique(sort(origin_levels[idx == 0])), collapse = '; ')
        msg <- paste0('The following strings were not matched (NAs inserted): ', msg)
        if (warn) warning(msg)
    }

    if (any(idx > 1)) { # multi match
        match_matrix[idx > 1, ] = NA
        msg <- paste(unique(sort(origin_levels[idx > 1])), collapse = '; ')
        msg <- paste0('The following strings were matched multiple times (NAs inserted): ', msg)
        if (warn) warning(msg)
    }

    # keep non-NA match    
    f <- function(x) sort(x, na.last = FALSE)[length(x)] 
    matches <- apply(match_matrix, 1, f)

    # replace matches in destination vector
    destination_vector <- unname(matches[as.numeric(origin_factor)])

    # output
    return(destination_vector)

}
