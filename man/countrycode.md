

# Convert Country Codes

[**Source code**](https://github.com/vincentarelbundock/countrycode/tree/main/R/countrycode.R#L89)

## Description

Converts long country names into one of many different coding schemes.
Translates from one scheme to another. Converts country name or coding
scheme to the official short English country name. Creates a new
variable with the name of the continent or region to which each country
belongs.

## Usage

<pre><code class='language-R'>countrycode(
  sourcevar,
  origin,
  destination,
  warn = TRUE,
  nomatch = NA,
  custom_dict = NULL,
  custom_match = NULL,
  origin_regex = NULL
)
</code></pre>

## Arguments

<table>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="sourcevar">sourcevar</code>
</td>
<td>
Vector which contains the codes or country names to be converted
(character or factor)
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="origin">origin</code>
</td>
<td>
A string which identifies the coding scheme of origin (e.g.,
<code>“iso3c”</code>). See <code>codelist</code> for a list of available
codes.
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="destination">destination</code>
</td>
<td>
A string or vector of strings which identify the coding scheme of
destination (e.g., <code>“iso3c”</code> or <code>c(“cowc”,
“iso3c”)</code>). See <code>codelist</code> for a list of available
codes. When users supply a vector of destination codes, they are used
sequentially to fill in missing values not covered by the previous
destination code in the vector.
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="warn">warn</code>
</td>
<td>
Prints unique elements from sourcevar for which no match was found
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="nomatch">nomatch</code>
</td>
<td>
When countrycode fails to find a match for the code of origin, it
fills-in the destination vector with <code>nomatch</code>. The default
behavior is to fill non-matching codes with <code>NA</code>. If
<code>nomatch = NULL</code>, countrycode tries to use the origin vector
to fill-in missing values in the destination vector.
<code>nomatch</code> must be either <code>NULL</code>, of length 1, or
of the same length as <code>sourcevar</code>.
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="custom_dict">custom_dict</code>
</td>
<td>

A data frame which supplies a new dictionary to replace the built-in
country code dictionary. Each column contains a different code and must
include no duplicates. The data frame format should resemble
<code>codelist</code>. Users can pre-assign attributes to this custom
dictionary to affect behavior (see Examples section):

<ul>
<li>

"origin.regex" attribute: a character vector with the names of columns
containing regular expressions.

</li>
<li>

"origin.valid" attribute: a character vector with the names of columns
that are accepted as valid origin codes.

</li>
</ul>
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="custom_match">custom_match</code>
</td>
<td>
A named vector which supplies custom origin and destination matches that
will supercede any matching default result. The name of each element
will be used as the origin code, and the value of each element will be
used as the destination code.
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="origin_regex">origin_regex</code>
</td>
<td>
NULL or Logical: When using a custom dictionary, if TRUE then the origin
codes will be matched as regex, if FALSE they will be matched exactly.
When NULL, <code>countrycode</code> will behave as TRUE if the origin
name is in the <code>custom_dictionary</code>’s
<code>origin_regex</code> attribute, and FALSE otherwise. See examples
section below.
</td>
</tr>
</table>

## Note

For a complete description of available country codes and languages,
please see the documentation for the <code>codelist</code> conversion
dictionary.

Panel data (i.e., country-year) can pose particular problems when
converting codes. For instance, some countries like Vietnam or Serbia go
through political transitions that justify changing codes over time.
This can pose problems when using codes from organizations like CoW or
Polity IV, which produce codes in country-year format. Instead of
converting codes using <code>countrycode()</code>, we recommend that
users use the <code>codelist_panel</code> data.frame as a base into
which they can merge their other data. This data.frame includes most
relevant code, and is already "reconciled" to ensure that each political
unit is only represented by one row in any given year. From there, it is
just a matter of using <code>merge()</code> to combine different
datasets which use different codes.

## Examples

``` r
library("countrycode")

library(countrycode)

# ISO to Correlates of War
countrycode(c('USA', 'DZA'), origin = 'iso3c', destination = 'cown')
```

    [1]   2 615

``` r
# English to ISO
countrycode('Albania', origin = 'country.name', destination = 'iso3c')
```

    [1] "ALB"

``` r
# German to French
countrycode('Albanien', origin = 'country.name.de', destination = 'iso.name.fr')
```

    [1] "Albanie (l')"

``` r
# Using custom_match to supercede default codes
countrycode(c('United States', 'Algeria'), 'country.name', 'iso3c')
```

    [1] "USA" "DZA"

``` r
countrycode(c('United States', 'Algeria'), 'country.name', 'iso3c',
            custom_match = c('Algeria' = 'ALG'))
```

    [1] "USA" "ALG"

``` r
x <- c("canada", "antarctica")
countryname(x)
```

    [1] "Canada"     "Antarctica"

``` r
countryname(x, destination = "cowc", warn = FALSE)
```

    [1] "CAN" NA   

``` r
countryname(x, destination = "cowc", warn = FALSE, nomatch = x)
```

    [1] "CAN"        "antarctica"
