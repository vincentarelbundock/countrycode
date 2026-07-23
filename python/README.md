# countrycode for Python

Convert country names and codes across more than 40 coding schemes and hundreds
of localized country-name fields.

```python
from countrycode import countrycode, countryname

countrycode(["Canada", "Algeria"], "country.name", "iso3c")
# ["CAN", "DZA"]

countryname(["Sverige", "ジンバブエ"], destination="iso3c")
# ["SWE", "ZWE"]
```

See the [project README](https://github.com/vincentarelbundock/countrycode)
for installation instructions, supported fields, data loaders, and custom
dictionaries.
