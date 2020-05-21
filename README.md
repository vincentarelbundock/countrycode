# R: countrycode

`countrycode` standardizes country names, converts them into ~40 different coding schemes, and assigns region descriptors. Scroll down for more details or visit the [countrycode CRAN page](http://cran.r-project.org/web/packages/countrycode/index.html)

If you use `countrycode` in your research, we would be very grateful if you could cite our paper:

> Arel-Bundock, Vincent, Nils Enevoldsen, and CJ Yetman, (2018). countrycode: An R package to convert country names and country codes. Journal of Open Source Software, 3(28), 848, https://doi.org/10.21105/joss.00848

[![DOI](http://joss.theoj.org/papers/10.21105/joss.00848/status.svg)](https://doi.org/10.21105/joss.00848)

[![Travis-CI Build Status](https://travis-ci.org/vincentarelbundock/countrycode.svg?branch=master)](https://travis-ci.org/vincentarelbundock/countrycode)

# Table of Contents

* [Why `countrycode`?](https://github.com/vincentarelbundock/countrycode#why-countrycode) 
* [Installation](https://github.com/vincentarelbundock/countrycode#installation) 
* [Supported codes](https://github.com/vincentarelbundock/countrycode#why-countrycode) 
* [Examples](https://github.com/vincentarelbundock/countrycode#examples) 
    - [Convert of a single name or code](https://github.com/vincentarelbundock/countrycode#convert-a-single-name-or-code) 
    - [Vectors and data.frames](https://github.com/vincentarelbundock/countrycode#vectors-and-data.frames) 
    - [Flags](https://github.com/vincentarelbundock/countrycode#flags) 
    - [Country names in 600+ different languages and formats](https://github.com/vincentarelbundock/countrycode#country-names-in-600-different-languages-and-formats) 
* [Extra](https://github.com/vincentarelbundock/countrycode#extra)
    - [`custom_dict`: Custom dictionaries and American states](https://github.com/vincentarelbundock/countrycode#custom_dict-custom-dictionaries-and-american-states) 
    - [`nomatch`: Fill in missing codes manually](https://github.com/vincentarelbundock/countrycode#nomatch-fill-in-missing-codes-manually) 
    - [`custom_match`: Override default values](https://github.com/vincentarelbundock/countrycode#custom_match-override-default-values) 
    - [`warn`: Silence warnings](https://github.com/vincentarelbundock/countrycode#warn-silence-warnings) 
* [Contributions](https://github.com/vincentarelbundock/countrycode#contributions) 

# Why `countrycode`?

### The Problem

Different data sources use different coding schemes to represent countries (e.g. CoW or ISO). This poses two main problems: (1) some of these coding schemes are less than intuitive, and (2) merging these data requires converting from one coding scheme to another, or from long country names to a coding scheme.

### The Solution

The `countrycode` function can convert to and from 40+ different country coding schemes, and to 600+ variants of country names in different languages and formats. It uses regular expressions to convert long country names (e.g. Sri Lanka) into any of those coding schemes or country names. It can create new variables with various regional groupings.

# Installation

From the R console, type: 

```r
install.packages("countrycode")``
```

To install the latest development version, you can use the `remotes` package:

```r
library(remotes)
install_github('vincentarelbundock/countrycode')
```

# Supported codes

To get an up-to-date list of supported country codes, install the package and type `?codelist`. These include:

* 600+ variants of country names in different languages and formats.
* AR5
* Continent and region identifiers.
* Correlates of War (numeric and character)
* European Central Bank
* Euro-control (aviation)
* Eurostat
* Federal Information Processing Standard (FIPS)
* Food and Agriculture Organization of the United Nations
* Global Administrative Unit Layers (GAUL)
* Geopolitical Entities, Names and Codes (GENC)
* Gleditsch & Ward (numeric and character)
* International Civil Aviation Organization
* International Monetary Fund
* International Olympic Committee
* ISO (2/3-character and numeric)
* Polity IV
* United Nations
* United Nations Procurement Division
* Varieties of Democracy
* World Bank
* World Values Survey
* Unicode symbols (flags)

# Examples

## Convert a single name or code

Load library:

```R
library(countrycode)
```

Convert single country codes:

```R
# ISO to Correlates of War
countrycode('DZA', origin = 'iso3c', destination = 'cown') 
[1]   615

# English to ISO
countrycode('Albania', origin = 'country.name', destination = 'iso3c') 
[1] "ALB"

# German to Arabic
countrycode(c('Algerien', 'Albanien'), origin = 'country.name.de', destination = 'un.name.ar') 
[1] "الجزائر" "ألبانيا"
```

## Convert a vector of country codes

```R
> cowcodes <- c("ALG", "ALB", "UKG", "CAN", "USA")
> countrycode(cowcodes, origin = "cowc", destination = "iso3c")
[1] "DZA" "ALB" "GBR" "CAN" "USA"
```

Generate vectors and 2 data frames without a common id (i.e. can't merge the 2 df):

```R
> isocodes <- c(12,8,826,124,840)
> var1     <- sample(1:500,5)
> var2     <- sample(1:500,5)
> df1      <- data.frame(cowcodes,var1)
> df2      <- data.frame(isocodes,var2)
```

Inspect the data:

```R
> df1
cowcodes var1
1      ALG   71
2      ALB  427
3      UKG  180
4      CAN   21
5      USA  383
> df2
isocodes var2
1       12  238
2        8  329
3      826  463
4      124  437
5      840   26
```

Create a common variable with the iso3c code in each data frame, merge the data, and create a country identifier:

```R
> df1$iso3c   <- countrycode(df1$cowcodes, origin = "cowc", destination = "iso3c")
> df2$iso3c   <- countrycode(df2$isocodes, origin = "iso3n", destination = "iso3c")
> df3         <- merge(df1,df2,id="iso3c")
> df3$country <- countrycode(df3$iso3c, origin = "iso3c", destination = "country.name")
> df3
iso3c cowcodes var1 isocodes var2        country
1   ALB      ALB  113        8  245        ALBANIA
2   CAN      CAN  373      124  197         CANADA
3   DZA      ALG  254       12  295        ALGERIA
4   GBR      UKG  351      826   57 UNITED KINGDOM
5   USA      USA  241      840   85  UNITED STATES
```

## Flags

`countrycode` can convert country names and codes to unicode flags. For example, we can use the `gt` package to draw a table with countries and their corresponding flags:

```r
library(gt)
library(countrycode)

Countries <- c('Canada', 'Germany', 'Thailand', 'Algeria', 'Eritrea')
Flags <- countrycode(Countries, 'country.name', 'unicode.symbol')
dat <- data.frame(Countries, Flags)
gt(dat)
```

Which produces this file: 

![](https://raw.githubusercontent.com/vincentarelbundock/countrycode/master/data/custom_dictionaries/flag_table.png)

Note that embedding unicode characters in `R` graphics is possible, but it can be tricky. If your output looks like `\U0001f1e6\U0001f1f6`, then you could try feeding it to this function: `utf8::utf8_print()`. That should cover a lot of cases without dipping into the complexity of graphics devices. As a rule of thumb, if your output looks like `□□□□` (boxes), things tend to get more complicated. In that case, you'll have to think about different output devices, file viewers, and/or file formats (e.g., 'SVG' or 'HTML').

Since inserting unicode symbols into `R` graphics is not a `countrycode`-specific issue, we won't be able to offer any more support than this. Good luck!

## Country names in 600+ different languages and formats

The Unicode organisation hosts the CLDR project, which publishes many variants of country names. For each language/culture locale, there is a full set of names, plus possible 'alt-short' or 'alt-variant' variations of specific country names.

```
> countrycode('United States of America', origin = 'country.name', destination = 'cldr.name.en')
> [1] "United States"
> countrycode('United States of America', origin = 'country.name', destination = 'cldr.short.en')
> [1] "US"
```

To see a full list of country name variants available, inspect this data.frame:

```
> head(countrycode::cldr_examples)
             Code                    Example
1    cldr.name.af   Franse Suidelike Gebiede
2   cldr.name.agq                         TF
3    cldr.name.ak                         TF
4    cldr.name.am           የፈረንሳይ ደቡባዊ ግዛቶች
5    cldr.name.ar الأقاليم الجنوبية الفرنسية
6 cldr.name.ar_ly الأقاليم الجنوبية الفرنسية
```

# Extra

## `custom_dict`: Custom dictionaries and American states

Since version 0.19, countrycode accepts user-supplied dictionaries via the ``custom_dict`` argument. These dictionaries will override the built-in country code dictionary. For example, the countrycode Github repository includes a dictionary of regexes and abbreviations to work with US state names.

Load the library and download the custom dictionary data.frame:

```
library(countrycode)
url = "https://raw.githubusercontent.com/vincentarelbundock/countrycode/master/data/custom_dictionaries/us_states.csv"
state_dict = read.csv(url, stringsAsFactors=FALSE)
```

Convert:

```
countrycode('State of Alabama', 
            origin = 'state', 
            destination = 'abbreviation', 
            custom_dict = state_dict,
            origin_regex = TRUE)
[1] "AL"
countrycode(c('MI', 'OH', 'Bad'), 'abbreviation', 'state', custom_dict=state_dict)
[1] "Michigan" "Ohio"     NA        
```

Note that if you use a custom dictionary with **country** codes, you could easily merge it into the ``countrycode::codelist`` or ``countrycode::codelist_panel`` to gain access to all other codes. 


## `nomatch`: Fill in missing codes manually

Use the `nomatch` argument to specify the value that `countrycode` inserts where no match was found:

```r
> countrycode(c('DZA', 'USA', '???'), origin = 'iso3c', destination = 'country.name', nomatch = 'BAD CODE')
> [1] "Algeria"       "United States" "BAD CODE"  
> countrycode(c('Canada', 'Fake country'), origin = 'country.name', destination = 'iso3c', nomatch = 'BAD')
> [1] "CAN" "BAD"
```

## `custom_match`: Override default values

Since version 0.19, `countrycode` accepts a user supplied named vector of custom 
matches via the `custom_match` argument. Any match pairs in the `custom_match` 
vector will supercede the default results of the command. This allows the user 
to convert to an available country code and make minor post-edits all at once. 
The names of the named vector are used as the origin code, and the values of the 
named vector are used as the destination code.

For example, Eurostat uses a modified version of iso2c, with Greece (EL instead 
of GR) and the UK (UK instead of GB) being the only differences. Getting a proper 
result converting to Eurostat is easy to achieve using the `iso2c` destination 
and the new `custom_match` argument. (Note: since version 0.19, `countrycode` 
also includes a `eurostat` origin/destination code, so while this is a good 
example, doing so for Eurostat is not necessary)

example: convert from country name to Eurostat code
```r
library(countrycode)
country_names <- c('Greece', 'United Kingdom', 'Germany', 'France')
custom_match <- c(Greece = 'EL', `United Kingdom` = 'UK')
countrycode(country_names, 
            origin = 'country.name', 
            destination = 'iso2c', 
            custom_match = custom_match)
```

example: convert from Eurostat code to country name
```r
library(eurostat)
library(countrycode)
df <- eurostat::get_eurostat("nama_10_lp_ulc")
custom_match <- c(EL = 'Greece', UK = 'United Kingdom')
countrycode(df$geo, origin = 'iso2c', destination = 'country.name', custom_match = custom_match)
```

## `warn`: Silence warnings

Use `warn = TRUE` to print out a list of source elements for which no match was found. When the source vector are long country names that need to be matched using regular expressions, there is always a risk that multiple regex will match a given string. When this is the case, `countrycode` assigns a value arbitrarily, but the `warn` argument allows the user to print a list of all strings that were matched many times.

# Contributions

## Adding a new code

New country codes are created by two files:

1. `dictionary/get_*.R` is an `R` script which can scrape the code from an original online source (e.g., `get_world_bank.R`). This scripts only side effect is that it writes a CSV file to the `dictionary` folder.
2. `dictionary/data_*.csv` is a CSV file with 1 column called `country`, which includes the English country name, and 1 or more columns named after the codes you want to add (e.g., `iso3c`, `un.name.en`, `continent`).

After creating those two files, you should:

* Run `dictionary/build.R`
* If the code is a valid origin code (i.e., no two countries share the same code), add it to the `valid_origin` vector in `R/countrycode.R`
* Add the new code name to the documentation in `R/codelist.R`
* Build the documentation using the devtools package: `devtools::document()`
* Add a bullet point to `NEWS.md` file.

If you need help with any of these steps, or if you just want to submit a CSV file, feel free to open an issue on Github or write an email to Vincent. I'll be happy to help you out!

## Custom dictionaries

The `countrycode` repository holds several custom dictionaries: https://github.com/vincentarelbundock/countrycode/tree/master/data/custom_dictionaries

To add your own custom dictionary, please make sure that:

1. You save a comma-separated CSV file that looks something like data/custom_dictionaries/us_states.csv
2. The custom dictionary has a unique purpose (not overlapping with existing custom dictionaries)
3. It uses UTF-8 encoding and conforms to RFC 4180 CSV standard (e.g. comma-delimited, etc.). 
    - `R` commands to produce such a file are shown below.
4. <NA>/blank fields are blank, not the string 'NA' (not RFC 4180, but important here because of Namibia)
5. It has concise, sensible, valid (in the R data frame sense) column header names

Using base write.csv:

```r
write.csv(custom_dict, 'custom_dict.csv', quote = TRUE, na = '', 
          row.names = FALSE, qmethod = 'double', fileEncoding = 'UTF-8')
```

Using `readr`:

```r
readr::write_csv(custom_dict, 'custom_dict.csv', na = '')
```
