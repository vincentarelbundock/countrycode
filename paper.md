---
title: 'countrycode: An R package to convert country names and country codes'
tags:
  - R
  - CRAN
  - social science
  - country names
  - country codes
  - geography
authors:
  - name: Vincent Arel-Bundock
    orcid: 0000-0003-2042-7063
    affiliation: 1
  - name: Nils Enevoldsen
    orcid: 0000-0001-7195-4117
    affiliation: 2
  - name: CJ Yetman
    orcid: 0000-0001-5099-9500
    affiliation: 3
affiliations:
  - name: Université de Montréal
    index: 1
  - name: Massachussetts Institute of Technology
    index: 2
  - name: Hertie School of Governance
    index: 3
date: 23 July 2018
bibliography: paper.bib
---

# Summary

International organizations, statistical agencies, and research labs use different codes to represent countries. For example, the ISO standard code for Algeria is "DZA", but Eurostat uses "DZ", the International Civil Aviation Organization uses "DA", the Correlates of War project uses "ALG", and the International Monetary Fund uses "612". When researchers merge and analyze data from several sources, incompatible country codes can be a major source of frustration.

The ``countrycode`` package for ``R`` alleviates this problem by making four main contributions. First, it allows bidirectional conversion between more than 30 country code schemes. Second, it includes a set of well-tested regular expressions which can be used to convert long-form English or German country names into country codes. Third, ``countrycode`` can convert codes into the names of countries in almost any spoken language. Finally, the package allows users to define custom dictionaries to facilitate the conversion of other identifiers (e.g., provinces or cities).

These functions can support a variety of scientific activities. For instance, ``countrycode`` has been used to draw maps [@Coe2018]; to acquire data from sources like the US Census Bureau [@Wal2018] or the World Bank [@Are2018]; to extract historical weather data from online APIs [@Shu2018]; and to process bird sightings records [@StrMilHoc2018]. In our own practice as researchers, ``countrycode`` has proven to be an invaluable tool to merge datasets produced by organizations which use different country identifiers. 

# Examples

```r
library(countrycode)
 
# ISO codes to Correlates of War codes
countrycode(c('DZA', 'USA'), 
            origin = 'iso3c', destination = 'cowc')
[1] "ALG" "USA"

# English names to GENC3 codes
countrycode(c('Antigua and Barbuda', 'Russia'), 
            origin = 'country.name', destination = 'genc3c')
[1] "ATG" "RUS"

# ISO codes to long-form Chinese names
countrycode(c('VUT', 'CAN'), 
            origin = 'iso3c', destination = 'un.name.zh')
[1] "瓦努阿图" "加拿大"
```

# Acknowledgements

We acknowledge contributions from Andrew Collier, Christopher Gandrud, \@grasshoppermouse, Anh Le, Bastiaan Quast, Étienne Tétreault-Pinard.

# References
