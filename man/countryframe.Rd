\name{countryframe}
\alias{countryframe}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{ Generate data frames from any of the coding schemes }
\description{
countryframe can generate data frames of three types: (1) undirected dyad-year observations, (2) directed dyad-year observations, (3) country-year observations.
}
\usage{
countryframe(TYPE, CODE, YEARS)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{TYPE}{ Either "undirected.dyads", "directed.dyads", or "country.years" }
  \item{CODE}{ One of the 7 coding schemes supported by the countrycode function }
  \item{YEARS}{ A range of years for which you want to generate individual rows }
}
\value{
Data frame
}

\author{ Vincent Arel-Bundock <varel@umich.edu>}
\examples{
## Usage example
countryframe("country.years", "iso3c", c(1998:2002))
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.

