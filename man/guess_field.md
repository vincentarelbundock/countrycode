

# Guess the code/name of a vector

[**Source code**](https://github.com/vincentarelbundock/countrycode/tree/main/R/guess_field.R#L20)

## Description

Users sometimes do not know what kind of code or field their data
contain. This function tries to guess by comparing the similarity
between a user-supplied vector and all the codes included in the
<code>countrycode</code> dictionary.

## Usage

<pre><code class='language-R'>guess_field(codes, min_similarity = 80)
</code></pre>

## Arguments

<table>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="codes">codes</code>
</td>
<td>
a vector of country codes or country names
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="min_similarity">min_similarity</code>
</td>
<td>
the function returns all field names where over than
<code>min_similarity</code>% of codes are shared between the supplied
vector and the <code>countrycode</code> dictionary.
</td>
</tr>
</table>

## Examples

``` r
library("countrycode")

# Guess ISO codes
guess_field(c('DZA', 'CAN', 'DEU'))
```

                 code percent_of_unique_matched
    genc3c     genc3c                       100
    iso3c       iso3c                       100
    wb             wb                       100
    wb_api3c wb_api3c                       100

``` r
# Guess country names
guess_field(c('Guinea','Iran','Russia','North Korea',rep('Ivory Coast',50),'Scotland'))
```

                                       code percent_of_unique_matched
    cow.name                       cow.name                  83.33333
    vdem.name                     vdem.name                  83.33333
    cldr.variant.ceb       cldr.variant.ceb                  83.33333
    cldr.variant.en         cldr.variant.en                  83.33333
    cldr.variant.en_001 cldr.variant.en_001                  83.33333
    cldr.variant.en_au   cldr.variant.en_au                  83.33333
