# Shared R/Python test fixtures

These YAML files define implementation-neutral behavior executed by both the
testthat and pytest suites:

- `name-variations.yaml`: canonical names mapped to accepted variations.
- `conversions.yaml`: nested `origin → destination → source: expected`
  mappings.
- `name-nonmatches.yaml`: nested `origin → destination → sources` lists.
- `countryname.yaml`: nested `destination → source: expected` mappings.

YAML supplies native integer and null types without extra schema fields.

Keep language-specific integration tests—such as R factors and tibbles or
Pandas and Polars metadata—in their native suites.
