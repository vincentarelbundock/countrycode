R: countrycode
==============

`countrycode` standardizes country names, converts them into one of seven coding schemes, assigns region descriptors, and generates empty dyadic or country-year dataframes from the coding schemes. Scroll down for more details or visit the [countrycode CRAN page](http://cran.r-project.org/web/packages/countrycode/index.html)

Problem
-------

Different data sources use different coding schemes to represent countries (e.g. CoW or ISO). This poses two main problems: (1) some of these coding schemes are less than intuitive, and (2) merging these data requires converting from one coding scheme to another, or from long country names to a coding scheme.

Solution
--------

The countrycode function can convert to and from 7 different country coding schemes. It uses regular expressions to convert long country names (e.g. Sri Lanka) into any of those coding schemes, or into standardized country names (official short English). It can create new variables with the name of the continent and/or region to which each country belongs.

Supported country codes
-----------------------

Correlates of War character; CoW-numeric; ISO 3-character; ISO 3-numeric; ISO 2-character; International Monetary Fund; Euro-control (aviation); Food and Agriculture Organization of the United Nations; International Olympic Committee; International Civil Aviation Organization; IPCC, United Nations numeric; FIPS 10-4; official English short country names (ISO); country names in Arabic, Chinese, English, French, German, Russian, Spanish, continent; region.

Installation
------------

From the R console, type ``install.packages("countrycode")``

Examples
--------

Load library:

```R
> library(countrycode)
```

Convert single country codes:

```R
# ISO to Correlates of War
countrycode('DZA', 'iso3c', 'cown') 
[1]   615
# English to ISO
countrycode('Albania', 'country.name', 'iso3c') 
[1] "ALB"
# German to French
countrycode('Albanien', 'country.name.de', 'country.name.fr') 
[1] "Albanie"
```

Convert a vector of country codes

```R
> cowcodes <- c("ALG","ALB","UKG","CAN","USA")
> countrycode(cowcodes,"cowc","iso3c")
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
> df1$iso3c   <- countrycode(df1$cowcodes, "cowc", "iso3c")
> df2$iso3c   <- countrycode(df2$isocodes, "iso3n", "iso3c")
> df3         <- merge(df1,df2,id="iso3c")
> df3$country <- countrycode(df3$iso3c, "iso3c", "country.name")
> df3
iso3c cowcodes var1 isocodes var2        country
1   ALB      ALB  113        8  245        ALBANIA
2   CAN      CAN  373      124  197         CANADA
3   DZA      ALG  254       12  295        ALGERIA
4   GBR      UKG  351      826   57 UNITED KINGDOM
5   USA      USA  241      840   85  UNITED STATES
```

Custom country codes dictionaries
---------------------------------

Since version 0.19, countrycode accepts user supplied dictionaries via the ``custom_dict`` argument. For example, the countrycode Github repository includes a dictionary of regexes and abbreviations to work with US state names.

Load the library and download the custom dictionary data.frame:

```
library(countrycode)
url = "https://raw.githubusercontent.com/vincentarelbundock/countrycode/master/data/extra/us_states.csv"
state_dict = read.csv(url, stringsAsFactors=FALSE)
```

Convert:

```
countrycode('State of Alabama', 'state', 'abbreviation', 
            custom_dict=state_dict,
            origin_regex=TRUE)
[1] "AL"
countrycode(c('MI', 'OH', 'Bad'), 'abbreviation', 'state', custom_dict=state_dict)
[1] "Michigan" "Ohio"     NA        
```

Note that if you use a custom dictionary with **country** codes, you could easily merge it into the ``countrycode::countrycode_data`` to gain access to all other codes. 

Custom country match vector
---------------------------------

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
countrycode(country_names, 'country.name', 'iso2c', custom_match = custom_match)
```

example: convert from Eurostat code to country name
```r
library(eurostat)
library(countrycode)
df <- eurostat::get_eurostat("nama_10_lp_ulc")
custom_match <- c(EL = 'Greece', UK = 'United Kingdom')
countrycode(df$geo, 'iso2c', 'country.name', custom_match = custom_match)
```

Extra arguments
---------------

Use warn=TRUE to print out a list of source elements for which no match was found. When the source vector are long country names that need to be matched using regular expressions, there is always a risk that multiple regex will match a given string. When this is the case, `countrycode` assigns a value arbitrarily, but the `warn` argument allows the user to print a list of all strings that were matched many times.


