#import "/.calepin/calepin.typ" as calepin
#show: calepin.document

// The snippets below install packages and show expected output inline. They
// are illustrations, not a notebook: Calepin must not run them.
#calepin.setup(eval: false, echo: true)

#set document(title: [countrycode for R and Python])

#metadata((
  layout: "layouts/site-landing.html",
  title: "Home",
  summary: "countrycode converts country names and country codes across more than 40 coding schemes and 600 country-name variants, in R and in Python.",
)) <website-metadata>

#let hero() = calepin.elements.target(
  html: () => html.elem("section", attrs: (class: "landing-hero"))[
    #html.elem("img", attrs: (
      src: calepin.url("/assets/countrycode.svg"),
      alt: "countrycode",
      class: "landing-hero-wordmark",
    ))[]
    #html.elem("h2")[Convert country names and codes, in R and Python]
    #html.elem("p", attrs: (class: "landing-hero-copy"))[
      One shared dictionary, more than 40 coding schemes, and 600 country-name
      variants in dozens of languages.
    ]
    #html.elem("div", attrs: (class: "landing-command-row"))[
      #html.elem("code", "install.packages(\"countrycode\")")
      #html.elem("code", "pip install countrycode")
    ]
  ],
  paged: () => align(center)[
    #image("/assets/countrycode.svg", width: 70%, alt: "countrycode logo")
    #v(0.5em)
    #text(size: 1.3em, weight: "bold")[Convert country names and codes, in R and Python]
  ],
)

#hero()

= Why

Different data sources code countries differently (CoW, ISO, and dozens more). Some schemes are less than intuitive, and merging data across them means converting from one scheme to another, or from long country names to a scheme.

`countrycode()` does that conversion from a dictionary shared by the R and Python packages. Regular-expression matching handles long country names such as "Sri Lanka," and destination fields include regional groupings.

If you use `countrycode` in your research, we would be very grateful if you could cite our paper:

#quote(block: true)[
  Arel-Bundock, Vincent, Nils Enevoldsen, and CJ Yetman, (2018). countrycode: An R package to convert country names and country codes. _Journal of Open Source Software_, 3(28), 848, #link("https://doi.org/10.21105/joss.00848").
]

= Install

Released versions come from CRAN and PyPI:

```r
install.packages("countrycode")
```

```sh
pip install countrycode
```

Development versions come from this monorepo:

```r
remotes::install_github("vincentarelbundock/countrycode/r")
```

```sh
pip install "countrycode @ git+https://github.com/vincentarelbundock/countrycode.git#subdirectory=python"
```

= Usage

```r
library(countrycode)

countrycode(
  c("Canada", "Algeria"),
  origin = "country.name",
  destination = "iso3c"
)
#> [1] "CAN" "DZA"
```

```python
from countrycode import countrycode

countrycode(
    ["Canada", "Algeria"],
    origin="country.name",
    destination="iso3c",
)
# ['CAN', 'DZA']
```

Python also provides the higher-level helpers available in R:

```python
from countrycode import countryname, guess_field

# Detect country names without first specifying their language.
countryname(["Sverige", "ジンバブエ"], destination="iso3c")
# ['SWE', 'ZWE']

# Identify a column's likely coding scheme.
guess_field(["DZA", "CAN", "DEU"])
```

`countrycode()` supports unmatched-value replacement, warnings, custom overrides, explicit regular-expression matching, and fallback destinations:

```python
countrycode(
    ["Serbia", "Atlantis"],
    origin="country.name",
    destination=["cowc", "iso3c"],
    nomatch="Unknown",
)
# ['SRB', 'Unknown']
```

= Codes

The R package documents the fields at `?codelist`. In Python, inspect them with `codelist.keys()`:

```python
from countrycode import codelist

codelist.keys()
```

Country-year codes and the multilingual name dictionary are loaded on demand:

```python
from countrycode import load_codelist_panel, load_countryname_dict

panel = load_codelist_panel()
names = load_countryname_dict()
```

Maintained custom dictionaries can be downloaded with `get_dictionary()`:

```python
from countrycode import get_dictionary

states = get_dictionary("us_states")
countrycode("MO", "state.abb", "state.name", custom_dict=states)
# 'Missouri'
```

Supported fields include:

- 600+ variants of country names in different languages and formats.
- Telephone
- AR5
- Continent and region identifiers.
- Correlates of War (numeric and character)
- European Central Bank
- #link("https://www.eurocontrol.int")[EUROCONTROL] --- The European Organisation for the Safety of Air Navigation
- Eurostat
- Federal Information Processing Standard (FIPS)
- Food and Agriculture Organization of the United Nations
- Global Administrative Unit Layers (GAUL)
- Geopolitical Entities, Names and Codes (GENC)
- Gleditsch & Ward (numeric and character)
- International Civil Aviation Organization
- International Monetary Fund
- International Olympic Committee
- ISO (2/3-character and numeric)
- Polity IV
- United Nations
- United Nations Procurement Division
- Varieties of Democracy
- World Bank
- World Values Survey
- Unicode symbols (flags)

= Cite

#link("https://doi.org/10.21105/joss.00848")[JOSS] ·
#link("https://cran.r-project.org/package=countrycode")[CRAN] ·
#link("https://pypi.org/project/countrycode/")[PyPI] ·
#link("https://github.com/vincentarelbundock/countrycode")[GitHub]
