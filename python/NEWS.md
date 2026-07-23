# Changelog

## Development

* Updated the built-in country-code dictionary and synchronized its CSV and pickle representations with the R package.
* Bring `countrycode()` behavior in line with the R package: warnings,
  `nomatch`, `custom_match`, `origin_regex`, fallback destinations,
  ambiguity detection, case-insensitive built-in codes, and Spanish names.
* Add `countryname()`, `guess_field()`, and `get_dictionary()`.
* Add on-demand loaders for `codelist_panel`, `countryname_dict`, and
  `cldr_examples`.
* Preserve Pandas Series metadata and support Pandas custom dictionaries.
* Remove the unused Jupyter development dependency.
* Replace the Python-specific pickle dictionary with a compressed, portable
  CSV representation for all packaged datasets.

## 0.6.0

* Adds support for custom country code dictionaries in countrycode(). Users can now supply either a dictionary object or a path to a .pickle file via the new `custom_dict` argument to override the built-in conversion table when performing code and name translations. Thanks to @MelchiorReihlen for contribution #17.

## 0.5.0

* Missing values in `codelist` are `None` rather than empty string "".
* poetry -> uv

## 0.4.0

* Drop `polars` and `pandas` dependencies.

## 0.3.0

10 years later! (June 2023)

A new version of `countrycode` for Python using the latest conversion dictionary supplied by the `countrycode` package for R.

* Over 40 different codes supported.
* Conversion to 600 different types of country names in 60+ different languages.
* Regular expressions to convert English, Italian, German, and French country names.
* More comprehensive test suite.

This is still alpha software. Please report bugs and feature requests on Github: https://github.com/vincentarelbundock/countrycode/issues

## 0.2.0

June 2013
