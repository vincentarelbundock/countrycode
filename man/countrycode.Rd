\name{countrycode}
\alias{countrycode}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Countrycode is a utility to convert country coding schemes}
\description{Converts long country names into one of seven different coding schemes; translates data from one scheme to another; converts country name or coding scheme to the official short English country name; creates a new variable with the name of the continent or region to which each country belongs. 
}
\usage{
countrycode(SOURCEVAR, ORIGIN, DESTINATION)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{SOURCEVAR}{Vector which contains the codes or country names to be converted}
  \item{ORIGIN}{Coding scheme of origin (between quotes "")}
  \item{DESTINATION}{Coding scheme of destination (between quotes "")}
}
\details{
Supports the following coding schemes: Correlates of War character, CoW-numeric, ISO3-character, ISO3-numeric, ISO2-character, IMF, FIPS 10-4, official English short country names (ISO), continent, region. 

The following strings can be used as arguments for ORIGIN or DESTINATION: "cowc", "cown", "iso3c", "iso3n", "iso2c", "imf", "fips104", "country.name". The following strings can be used as arguments for DESTINATION only:  "continent", "region"
}
\value{
	A vector of converted values of the same length as SOURCEVAR 
}
\note{
To produce consistent conversion, some entries had to be removed from the translation data frame. For example, the Correlates of War uses 4 different codes to represent Western Germany. "countrycode" uses only one of them (CoW code 255 for all years). Similar choices were made in the cases of Korea, Yemen, Congo and Vietnam. Also, Namibia's iso2c code ("NA") can be understood as a missing observation (NA) by R.

Capitalized country names refer to the official short English names, as defined by the ISO organization. ISO does not publish official short English names for countries whose name is not capitalized in the country.name vector.
}
\author{Vincent Arel-Bundock <varel@umich.edu>}
\examples{
### Usage example: 
codes.of.origin <- countrycode_data$cowc ## Vector of values to be converted

countrycode(codes.of.origin, "cowc", "iso3c")

### Please note the quotation marks around the 2nd and 3rd args
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ manip }

