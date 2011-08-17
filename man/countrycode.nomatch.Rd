\name{countrycode.nomatch}
\alias{countrycode.nomatch}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{The countrycode package cannot translate the returned codes}
\description{
 Returns the subset of countries for which a translation between the origin and destination formats cannot be completed successfully using the countrycode function
}
\usage{
countrycode.nomatch(ORIGIN, DESTINATION)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{ORIGIN}{Coding scheme of origin (between quotes "")}
  \item{DESTINATION}{Coding scheme of destination (between quotes "")}
}

\value{
Subset of countries for which a translation between the origin and destination formats cannot be completed successfully using the countrycode function
}

\author{
Vincent Arel-Bundock <varel@umich.edu>
}

\examples{
### Usage example:
countrycode.nomatch("cowc", "iso3c")

### Please note the quotation marks around both arguments
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.

