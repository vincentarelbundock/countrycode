
# Country codes

## Convert a single name or code

Load library:

``` r
library(countrycode)
```

Convert single country codes:

``` r
## ISO to Correlates of War
countrycode('DZA', origin = 'iso3c', destination = 'cown') 
```

    [1] 615

``` r
## English to ISO
countrycode('Albania', origin = 'country.name', destination = 'iso3c') 
```

    [1] "ALB"

``` r
## German or Italian to Arabic
countrycode(c('Algerien', 'Albanien'), origin = 'country.name.de', destination = 'un.name.ar') 
```

    [1] "الجزائر" "ألبانيا"

``` r
countrycode(c('Moldavia', 'Stati Uniti'), origin = 'country.name.it', destination = 'un.name.ar') 
```

    [1] "جمهورية مولدوفا"            "الولايات المتحدة الأمريكية"

## Convert a vector of country codes

``` r
cowcodes <- c("ALG", "ALB", "UKG", "CAN", "USA")
countrycode(cowcodes, origin = "cowc", destination = "iso3c")
```

    [1] "DZA" "ALB" "GBR" "CAN" "USA"

Generate vectors and 2 data frames without a common id (i.e. can’t merge
the 2 df):

``` r
isocodes <- c(12,8,826,124,840)
var1     <- sample(1:500,5)
var2     <- sample(1:500,5)
df1      <- data.frame(cowcodes,var1)
df2      <- data.frame(isocodes,var2)
```

Inspect the data:

``` r
df1
```

      cowcodes var1
    1      ALG  255
    2      ALB  329
    3      UKG  256
    4      CAN  289
    5      USA   72

``` r
df2
```

      isocodes var2
    1       12  304
    2        8  465
    3      826  270
    4      124   59
    5      840   84

Create a common variable with the iso3c code in each data frame, merge
the data, and create a country identifier:

``` r
df1$iso3c   <- countrycode(df1$cowcodes, origin = "cowc", destination = "iso3c")
df2$iso3c   <- countrycode(df2$isocodes, origin = "iso3n", destination = "iso3c")
df3         <- merge(df1,df2,id="iso3c")
df3$country <- countrycode(df3$iso3c, origin = "iso3c", destination = "country.name")
df3
```

      iso3c cowcodes var1 isocodes var2        country
    1   ALB      ALB  329        8  465        Albania
    2   CAN      CAN  289      124   59         Canada
    3   DZA      ALG  255       12  304        Algeria
    4   GBR      UKG  256      826  270 United Kingdom
    5   USA      USA   72      840   84  United States

## Flags

`countrycode` can convert country names and codes to unicode flags. For
example, we can use the `gt` package to draw a table with countries and
their corresponding flags:

``` r
library(gt)
library(countrycode)

Countries <- c('Canada', 'Germany', 'Thailand', 'Algeria', 'Eritrea')
Flags <- countrycode(Countries, 'country.name', 'unicode.symbol')
dat <- data.frame(Countries, Flags)
gt(dat)
```

![gt_flags](https://github.com/vincentarelbundock/countrycode/assets/987057/c0c29aa3-0aab-4274-af80-1ae3efc89203.png)

Note that embedding unicode characters in `R` graphics is possible, but
it can be tricky. If your output looks like `\U0001f1e6\U0001f1f6`, then
you could try feeding it to this function: `utf8::utf8_print()`. That
should cover a lot of cases without dipping into the complexity of
graphics devices. As a rule of thumb, if your output looks like `□□□□`
(boxes), things tend to get more complicated. In that case, you’ll have
to think about different output devices, file viewers, and/or file
formats (e.g., ‘SVG’ or ‘HTML’).

Since inserting unicode symbols into `R` graphics is not a
`countrycode`-specific issue, we won’t be able to offer any more support
than this. Good luck!

## Country names in 600+ different languages and formats

The Unicode organisation hosts the CLDR project, which publishes many
variants of country names. For each language/culture locale, there is a
full set of names, plus possible ‘alt-short’ or ‘alt-variant’ variations
of specific country names.

``` r
countrycode('United States of America', origin = 'country.name', destination = 'cldr.name.en')
```

    [1] "United States"

``` r
countrycode('United States of America', origin = 'country.name', destination = 'cldr.short.en')
```

    [1] "US"

To see a full list of country name variants available, inspect this
data.frame:

``` r
head(countrycode::cldr_examples)
```

                 Code                    Example
    1   cldr.name.agq                         TF
    2    cldr.name.ak                         TF
    3    cldr.name.am           የፈረንሳይ ደቡባዊ ግዛቶች
    4    cldr.name.ar الأقاليم الجنوبية الفرنسية
    5 cldr.name.ar_ly الأقاليم الجنوبية الفرنسية
    6 cldr.name.ar_sa الأقاليم الجنوبية الفرنسية

## Custom dictionaries and cross-walks: `get_dictionary()` and `custom_dict`

The `custom_dict` argument accepts data frame which can be used as
custom dictionaries to create “crosswalks” between arbitrary entities
(non-countries). You can create your own dictionaries (see examples
below) or use one of the dictionaries already hosted on the
`countrycode` Github repository. The current list of available
dictionaries can be seen by calling:

``` r
get_dictionary()
```

    Available dictionaries: ch_cantons, exiobase3, global_burden_of_disease, gtap10, us_states

You can download a dictionary and see available fields with:

``` r
cd <- get_dictionary("us_states")
head(cd)
```

      state.name state.abb    state.regex
    1    Alabama        AL    .*alabama.*
    2     Alaska        AK     .*alaska.*
    3    Arizona        AZ    .*arizona.*
    4   Arkansas        AR   .*arkansas.*
    5 California        CA .*california.*
    6   Colorado        CO   .*colorado.*

Now we can use the dictionary for conversions:

``` r
st <- c("Arkansas", "Quebec", "Tennessee")
countrycode(st, "state.regex", "state.abb", custom_dict = cd)
```

    Warning: Some values were not matched unambiguously: Quebec

    [1] "AR" NA   "TN"

``` r
countrycode(c("MN", "MA", "MO"), "state.abb", "state.name", custom_dict = cd)
```

    [1] "Minnesota"     "Massachusetts" "Missouri"     

Here’s an example with the GTAP dataset:

``` r
cd <- get_dictionary("gtap10")
countrycode("Christmas Island", "country.name.en.regex", "gtap.cha", custom_dict = cd)
```

    [1] "AUS"

### `custom_dict`: the `ISOcodes` package

`countrycode` already supports ISO4217 (currencies) and ISO3166 (country
codes). The `ISOcodes` package supplies other codes, including ISO15924
(language writing systems), ISO639 (languages), and ISO8859 (computer
character encodings). Users can convert those codes using
`countrycode`’s `custom_dict` argument.

For example, the `ISOcodes::ISO_639_2` dataframe includes 4 columns:
`Alpha_3_B`, `Alpha_3_T`, `Alpha_2`, and `Name`. We can convert language
names like this:

``` r
countrycode('abk', 'Alpha_3_B', 'Name', custom_dict = ISOcodes::ISO_639_2)
```

    [1] "Abkhazian"

The `ISOcodes::ISO_8859` dataset is a 3-dimensional array where the
second dimension represents the character encoding. We take the subset
of `ISO_8859_1` codes and convert the dict to a dataframe for use in
`countrycode`’s `custom_dict` argument:

``` r
library(ISOcodes)
dict <- ISOcodes::ISO_8859[, 'ISO_8859_1', ]
dict <- data.frame(dict)
```

The resulting dataframe has 3 columns: `Code`, `Name`, `Character`. We
convert the code `0x00fd` like this:

``` r
countrycode("0x00fd", "Code", "Name", custom_dict = dict)
```

    [1] "LATIN SMALL LETTER Y WITH ACUTE"

``` r
countrycode("0x00fd", "Code", "Character", custom_dict = dict)
```

    [1] "ý"

## `destination`: Fallback codes

Some destination codes not cover all the relevant countries. For
example, “SRB” is included in the `iso3c` code but *not* in the `cowc`
code. Some users may want to use `cowc` but to fill in missing entries
with `iso3c` codes. We can do this by feeding a vector of code names to
the `destination` argument. `countrycode` will then try one after the
other.

For example,

``` r
x <- c("Algeria", "Serbia")

countrycode(x, "country.name", "cowc")
```

    Warning: Some values were not matched unambiguously: Serbia

    [1] "ALG" NA   

``` r
countrycode(x, "country.name", "iso3c")
```

    [1] "DZA" "SRB"

``` r
countrycode(x, "country.name", c("cowc", "iso3c"))
```

    Warning: Some values were not matched unambiguously: Serbia

    [1] "ALG" "SRB"

## `nomatch`: Fill in missing codes manually

Use the `nomatch` argument to specify the value that `countrycode`
inserts where no match was found:

``` r
countrycode(c('DZA', 'USA', '???'), origin = 'iso3c', destination = 'country.name', nomatch = 'BAD CODE')
```

    [1] "Algeria"       "United States" "BAD CODE"     

``` r
countrycode(c('Canada', 'Fake country'), origin = 'country.name', destination = 'iso3c', nomatch = 'BAD')
```

    [1] "CAN" "BAD"

## `custom_match`: Override default values

`countrycode` accepts a user supplied named vector of custom matches via
the `custom_match` argument. Any match pairs in the `custom_match`
vector will supercede the default results of the command. This allows
the user to convert to an available country code and make minor
post-edits all at once. The names of the named vector are used as the
origin code, and the values of the named vector are used as the
destination code.

For example, Eurostat uses a modified version of iso2c, with Greece (EL
instead of GR) and the UK (UK instead of GB) being the only differences.
Getting a proper result converting to Eurostat is easy to achieve using
the `iso2c` destination and the new `custom_match` argument. (Note:
since version 0.19, `countrycode` also includes a `eurostat`
origin/destination code, so while this is a good example, doing so for
Eurostat is not necessary)

Example: convert from country name to Eurostat code

``` r
library(countrycode)
country_names <- c('Greece', 'United Kingdom', 'Germany', 'France')
custom_match <- c(Greece = 'EL', `United Kingdom` = 'UK')
countrycode(country_names, 
            origin = 'country.name', 
            destination = 'iso2c', 
            custom_match = custom_match)
```

    [1] "EL" "UK" "DE" "FR"

Example: convert from Eurostat code to country name

``` r
library(eurostat)
library(countrycode)
df <- eurostat::get_eurostat("nama_10_lp_ulc")
custom_match <- c(EL = 'Greece', UK = 'United Kingdom')
countrycode(df$geo, origin = 'iso2c', destination = 'country.name', custom_match = custom_match) |>
    head()
```

    Warning: Some values were not matched unambiguously: EA, EA12, EA19, EA20, EU15, EU27_2020, EU28, XK

    [1] "Austria"     "Belgium"     "Bulgaria"    "Switzerland" "Cyprus"     
    [6] "Czechia"    

## `warn`: Silence warnings

Use `warn = TRUE` to print out a list of source elements for which no
match was found. When the source vector are long country names that need
to be matched using regular expressions, there is always a risk that
multiple regex will match a given string. When this is the case,
`countrycode` assigns a value arbitrarily, but the `warn` argument
allows the user to print a list of all strings that were matched many
times.
