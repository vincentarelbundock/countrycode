

# Get Custom Dictionaries

[**Source code**](https://github.com/vincentarelbundock/countrycode/tree/main/R/get_dictionary.R#L19)

## Description

Download a custom dictionary to use in the <code>custom_dict</code>
argument of <code>countrycode()</code>

## Usage

<pre><code class='language-R'>get_dictionary(dictionary = NULL)
</code></pre>

## Arguments

<table>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="get_dictionary_:_dictionary">dictionary</code>
</td>
<td>
A character string that specifies the dictionary to be retrieved. It
must be one of "global_burden_of_disease", "ch_cantons", "us_states",
"exiobase3", "gtap10". If NULL, the function will print the list of
available dictionaries. Default is NULL.
</td>
</tr>
</table>

## Value

If a valid dictionary is specified, the function will return that
dictionary as a data.frame. If an invalid dictionary or no dictionary is
specified, the function will stop and throw an error message.

## Examples

``` r
library(countrycode)

cd <- get_dictionary("us_states")
countrycode::countrycode(c("MO", "MN"), origin = "state.abb", "state.name", custom_dict = cd)
```
