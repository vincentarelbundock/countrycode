#import "/.calepin/calepin.typ" as calepin
#show: calepin.document

#set document(title: [Country names])

#metadata((
  title: "Country names",
  summary: "countryname() converts country names written in any language to another name or code.",
)) <website-metadata>

#calepin.setup(
  echo: true,
  eval: true,
  results: "verbatim",
)

#title()

The function `countryname` tries to convert country names from any language. For example:

```r
library(countrycode)
x <- c('ジンバブエ', 'Afeganistãu', 'Barbadas', 'Sverige', 'UK',
       'il-Georgia tan-Nofsinhar u l-Gżejjer Sandwich tan-Nofsinhar')

countryname(x)

countryname(x, 'iso3c')
```
