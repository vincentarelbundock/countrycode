# countrycode

`countrycode` is an R package that standardizes country names, converts between country coding schemes, and assigns region descriptors.

## Installation

```r
install.packages("countrycode")
```

Install the development version from GitHub:

```r
remotes::install_github("vincentarelbundock/countrycode")
```

## Quick start

```r
library(countrycode)

countrycode(c("Canada", "United States"), "country.name", "iso3c")
countrycode(c("CAN", "USA"), "iso3c", "country.name")
```

See the [reference documentation](reference/index.md) for all exported topics and the [project repository](https://github.com/vincentarelbundock/countrycode) for source code and contribution information.
