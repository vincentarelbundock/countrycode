

# Country names

The function `countryname` tries to convert country names from any
language. For example:

``` r
library(countrycode)
x <- c('ジンバブエ', 'Afeganistãu',  'Barbadas', 'Sverige', 'UK',  
       'il-Georgia tan-Nofsinhar u l-Gżejjer Sandwich tan-Nofsinhar')

countryname(x)
```

    [1] "Zimbabwe"                              
    [2] "Afghanistan"                           
    [3] "Barbados"                              
    [4] "Sweden"                                
    [5] "United Kingdom"                        
    [6] "South Georgia & South Sandwich Islands"

``` r
countryname(x, 'iso3c')
```

    [1] "ZWE" "AFG" "BRB" "SWE" "GBR" "SGS"
