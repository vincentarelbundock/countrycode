

# Custom conversion functions

It is easy to to create alternative functions with different default
arguments and/or dictionaries. For example, we can create:

-   `name_to_iso3c` function that sets new defaults for the `origin` and
    `destination` arguments, and automatically converts country names to
    iso3c
-   `statecode` function to convert US state codes using a custom
    dictionary by default, that we download from the internet.

``` r
library(countrycode)

#################################
#  new function: name_to_iso3c  #
#################################

# Custom defaults
name_to_iso3c <- function(sourcevar,
                          origin = "country.name",
                          destination = "iso3c",
                          ...) {
  countrycode(sourcevar, origin = origin, destination = destination, ...)
}

name_to_iso3c(c("Algeria", "Canada"))
```

    [1] "DZA" "CAN"

``` r
#############################
#  new function: statecode  #
#############################

# Download dictionary
state_dict <- "https://raw.githubusercontent.com/vincentarelbundock/countrycode/main/data/custom_dictionaries/data_us_states.csv"
state_dict <- read.csv(state_dict)

# Identify regular expression origin codes
attr(state_dict, "origin_regex") <- "state.regex"

# Define a custom conversion function
statecode <- function(sourcevar,
                      origin = "state.regex",
                      destination = "abbreviation",
                      custom_dict = state_dict,
                      ...) {
    countrycode(sourcevar,
                origin = origin,
                destination = destination,
                custom_dict = custom_dict,
                ...)
}

# Voilà!
x <- c("Alabama", "New Mexico")
statecode(x, "state.regex", "abbreviation")
```

    [1] "AL" "NM"

``` r
x <- c("AL", "NM", "VT")
statecode(x, "abbreviation", "state")
```

    [1] "Alabama"    "New Mexico" "Vermont"   
