# countrycode for R and Python

<img src="https://user-images.githubusercontent.com/987058/167296405-e7798ac8-03e7-444e-acaf-d99fc42d1c9e.png" align="right" alt="" width="125" />

<!-- badges: start -->

[![DOI](http://joss.theoj.org/papers/10.21105/joss.00848/status.svg)](https://doi.org/10.21105/joss.00848)
<a href = "https://vincentarelbundock.github.io/countrycode" target = "_blank"><img src="https://img.shields.io/static/v1?label=Website&message=Visit&color=blue"></a>
[![R](https://img.shields.io/badge/R-CRAN-276DC3)](https://cran.r-project.org/package=countrycode)
[![Python](https://img.shields.io/badge/Python-PyPI-3776AB)](https://pypi.org/project/countrycode/)
<a href = "https://vincentarelbundock.github.io/countrycode" target = "_blank"><img src="http://cranlogs.r-pkg.org/badges/grand-total/countrycode"></a>
<!-- badges: end -->

`countrycode` is available for both R and Python. The two packages share
the same country-code dictionary and convert country names and codes
across more than 40 coding schemes and 600 country-name variants.

If you use `countrycode` in your research, we would be very grateful if
you could cite our paper:

> Arel-Bundock, Vincent, Nils Enevoldsen, and CJ Yetman, (2018).
> countrycode: An R package to convert country names and country codes.
> Journal of Open Source Software, 3(28), 848,
> <https://doi.org/10.21105/joss.00848>

## Why `countrycode`?

### The Problem

Different data sources use different coding schemes to represent
countries (e.g. CoW or ISO). This poses two main problems: (1) some of
these coding schemes are less than intuitive, and (2) merging these data
requires converting from one coding scheme to another, or from long
country names to a coding scheme.

### The Solution

The R and Python packages provide a `countrycode()` function backed by a
shared dictionary. It converts between more than 40 country coding
schemes and 600 country-name variants in different languages and
formats. Regular-expression matching supports conversion from long
country names such as “Sri Lanka,” and destination fields include
regional groupings.

## Installation

### R

Install the released package from CRAN:

``` r
install.packages("countrycode")
```

Install the development version from this monorepo:

``` r
remotes::install_github("vincentarelbundock/countrycode/r")
```

### Python

Install the released package from PyPI:

``` sh
pip install countrycode
```

Install the development version from this monorepo:

``` sh
pip install "countrycode @ git+https://github.com/vincentarelbundock/countrycode.git#subdirectory=python"
```

## Usage

### R

``` r
library(countrycode)

countrycode(
  c("Canada", "Algeria"),
  origin = "country.name",
  destination = "iso3c"
)
#> [1] "CAN" "DZA"
```

### Python

``` python
from countrycode import countrycode

countrycode(
    ["Canada", "Algeria"],
    origin="country.name",
    destination="iso3c",
)
# ['CAN', 'DZA']
```

## Supported codes

The R package documents the fields at `?codelist`. In Python, inspect
them with `codelist.keys()`:

``` python
from countrycode import codelist

codelist.keys()
```

Supported fields include:

- 600+ variants of country names in different languages and formats.
- Telephone
- AR5
- Continent and region identifiers.
- Correlates of War (numeric and character)
- European Central Bank
- [EUROCONTROL](https://www.eurocontrol.int) - The European Organisation
  for the Safety of Air Navigation
- Eurostat
- Federal Information Processing Standard (FIPS)
- Food and Agriculture Organization of the United Nations
- Global Administrative Unit Layers (GAUL)
- Geopolitical Entities, Names and Codes (GENC)
- Gleditsch & Ward (numeric and character)
- International Civil Aviation Organization
- International Monetary Fund
- International Olympic Committee
- ISO (2/3-character and numeric)
- Polity IV
- United Nations
- United Nations Procurement Division
- Varieties of Democracy
- World Bank
- World Values Survey
- Unicode symbols (flags)
