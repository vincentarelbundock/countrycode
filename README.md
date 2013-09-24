Contributions
=============

If you would like to improve the country code dictionary, please modify the file held in this other repository: https://github.com/vincentarelbundock/pycountrycode/tree/master/countrycode/data

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

Correlates of War character, CoW-numeric, ISO3-character, ISO3-numeric, ISO2-character, IMF, Food and Agriculture Organization of the United Nations, United Nations numeric, FIPS 10-4, official English short country names (ISO), continent, region.

Extra arguments
---------------

Use warn=TRUE to print out a list of source elements for which no match was found. When the source vector are long country names that need to be matched using regular expressions, there is always a risk that multiple regex will match a given string. When this is the case, `countrycode` assigns a value arbitrarily, but the `warn` argument allows the user to print a list of all strings that were matched many times.

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
> countrycode(232,"cown","country.name")
[1] "ANDORRA"
> countrycode("United States","country.name","iso3c")
[1] "USA"
> countrycode("DZA","iso3c","cowc")
[1] "ALG"
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
> df1      <- as.data.frame(cbind(cowcodes,var1))
> df2      <- as.data.frame(cbind(isocodes,var2))
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
