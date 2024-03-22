

# Convert country names in any language to another name or code

[**Source code**](https://github.com/vincentarelbundock/countrycode/tree/main/R/countryname.R#L30)

## Description

Converts long country names in any language to one of many different
country code schemes or country names. <code>countryname</code> does 2
passes on the data. First, it tries to detect variations of country
names in many languages extracted from the Unicode Common Locale Data
Repository. Second, it applies <code>countrycode</code>’s English
regexes to try to match the remaining cases. Because it does two passes,
<code>countryname</code> can sometimes produce ambiguous results, e.g.,
Saint Martin vs. Saint Martin (French Part). Users who need a "safer"
option can use: <code>countrycode(x, “country.name”,
“country.name”)</code> Note that the function works with non-ASCII
characters. Please see the Github page for examples.

## Usage

<pre><code class='language-R'>countryname(
  sourcevar,
  destination = "country.name.en",
  nomatch = NA,
  warn = TRUE
)
</code></pre>

## Arguments

<table>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="countryname_:_sourcevar">sourcevar</code>
</td>
<td>
Vector which contains the codes or country names to be converted
(character or factor)
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="countryname_:_destination">destination</code>
</td>
<td>
Coding scheme of destination (string such as "iso3c" enclosed in quotes
""): type <code>?codelist</code> for a list of available codes.
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="countryname_:_nomatch">nomatch</code>
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
<code id="countryname_:_warn">warn</code>
</td>
<td>
Prints unique elements from sourcevar for which no match was found
</td>
</tr>
</table>

## Examples

``` r
library(countrycode)

x <- c('Afaganisitani', 'Barbadas', 'Sverige', 'UK')
countryname(x)
countryname(x, destination = 'iso3c')
```
