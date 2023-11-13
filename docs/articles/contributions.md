
# Contributions

## Adding a new code

New country codes are created by two files:

1.  `dictionary/get_*.R` is an `R` script which can scrape the code from
    an original online source (e.g., `get_world_bank.R`). This scripts
    only side effect is that it writes a CSV file to the `dictionary`
    folder.
2.  `dictionary/data_*.csv` is a CSV file with 1 column called
    `country`, which includes the English country name, and 1 or more
    columns named after the codes you want to add (e.g., `iso3c`,
    `un.name.en`, `continent`).

After creating those two files, you should:

-   Run `dictionary/build.R`
-   If the code is a valid origin code (i.e., no two countries share the
    same code), add it to the `valid_origin` vector in `R/countrycode.R`
-   Add the new code name to the documentation in `R/codelist.R`
-   Build the documentation using the devtools package:
    `devtools::document()`
-   Add a bullet point to `NEWS.md` file.

If you need help with any of these steps, or if you just want to submit
a CSV file, feel free to open an issue on Github or write an email to
Vincent. I’ll be happy to help you out!

## Custom dictionaries

The `countrycode` repository holds several custom dictionaries:
https://github.com/vincentarelbundock/countrycode/tree/master/data/custom_dictionaries

To add your own custom dictionary, please make sure that:

1.  You save a comma-separated CSV file that looks something like
    data/custom_dictionaries/data_us_states.csv
2.  The custom dictionary has a unique purpose (not overlapping with
    existing custom dictionaries)
3.  It uses UTF-8 encoding and conforms to RFC 4180 CSV standard
    (e.g. comma-delimited, etc.).
    -   `R` commands to produce such a file are shown below.
4.  <NA>/blank fields are blank, not the string ‘NA’ (not RFC 4180, but
    important here because of Namibia)
5.  It has concise, sensible, valid (in the R data frame sense) column
    header names

Using base write.csv:

``` r
write.csv(custom_dict, 'custom_dict.csv', quote = TRUE, na = '', 
          row.names = FALSE, qmethod = 'double', fileEncoding = 'UTF-8')
```

Using `readr`:

``` r
readr::write_csv(custom_dict, 'custom_dict.csv', na = '')
```

## Custom dictionary attributes

When using custom dictionaries, it is often useful to give “meta”
information to `countrycode` so that it knows how to use certain codes.
To do this, we can set attributes of the dictionary. In this example, we
download a dictionary of US state codes. Then, we identify a column of
regular expressions using the `origin_regex` attribute, and we identify
the valid origin codes using the `origin_valid` attribute.

``` r
library(countrycode)

state_dict <- "https://raw.githubusercontent.com/vincentarelbundock/countrycode/main/data/custom_dictionaries/data_us_states.csv"
state_dict <- read.csv(state_dict)

attr(state_dict, "origin_regex") <- "state.regex"
attr(state_dict, "origin_valid") <- c("state.regex", "abbreviation")

countrycode("Alabama", "state.regex", "abbreviation", custom_dict = state_dict)
```

    [1] "AL"

``` r
countrycode("AL", "abbreviation", "state", custom_dict = state_dict)
```

    [1] "Alabama"

``` r
countrycode("Alabama", "state", "abbreviation", custom_dict = state_dict)
```

    Error in countrycode("Alabama", "state", "abbreviation", custom_dict = state_dict): The `origin` argument must be a string of length 1 equal to one of these values: state.regex, abbreviation.
