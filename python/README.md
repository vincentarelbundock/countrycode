# Polars DataFrame examples


Warning: This is *alpha* software.

# `countrycode` for Python

`countrycode` standardizes country names, converts them into ~40
different coding schemes, and assigns region descriptors.

Convert country names to and from 9 country code schemes.

- Bugs & Development:
  https://github.com/vincentarelbundock/countrycode/issues
- Pypi: https://pypi.python.org/pypi/countrycode
- [Vincent’s webpage](https://arelbundock.com)

This is a Python port of [the `countrycode` package for
R.](https://vincentarelbundock.github.io/countrycode)

## The Problem

Different data sources use different coding schemes to represent
countries (e.g. CoW or ISO). This poses two main problems: (1) some of
these coding schemes are less than intuitive, and (2) merging these data
requires converting from one coding scheme to another, or from long
country names to a coding scheme.

## The Solution

The `countrycode` function can convert to and from 40+ different country
coding schemes, and to 600+ variants of country names in different
languages and formats. It uses regular expressions to convert long
country names (e.g. Sri Lanka) into any of those coding schemes or
country names. It can create new variables with various regional
groupings.

## Supported codes

See the section at the very end of this README for a full list of
supported codes and languages. These include:

- 600+ variants of country names in different languages and formats.
- AR5
- Continent and region identifiers.
- Correlates of War (numeric and character)
- European Central Bank
- [EUROCONTROL](https://www.eurocontrol.int) - The European Organisation
  for the Safety of Air Navigation
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
- And more…

# Installation

From `pypi`:

``` python
pip install countrycode
```

Latest version from Gitub:

``` sh
git clone https://github.com/vincentarelbundock/countrycode
cd countrycode/python
pip install .
```

# Usage

``` python
import polars as pl
from countrycode import countrycode

countrycode([12, 124], origin = "iso3n", destination = "cldr.short.fr")
```

    ['Algérie', 'Canada']

``` python
countrycode(['canada', 'United States', 'alGeria'], origin = "country.name.en.regex", destination = "iso3c")
```

    ['CAN', 'USA', 'DZA']

``` python
countrycode(pl.Series(['DZA', 'CAN', 'USA']), origin = "iso3c", destination = "cldr.short.fr")
```

<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (3,)</small>

|           |
|-----------|
| str       |
| "Algérie" |
| "Canada"  |
| "É.-U."   |

</div>

``` python
countrycode(['DZA', 'CAN', 'USA'], origin = "iso3c", destination = "iso3n")
```

    [12, 124, 840]

``` python
countrycode(12, origin = "iso3n", destination = "cldr.short.de") 
```

    'Algerien'

``` python
countrycode(["Democratic Republic of Vietnam", "Algeria"], origin = "country.name.en.regex", destination = "iso3c")
```

    ['VNM', 'DZA']

``` python
countrycode(["Algerien"], origin = "country.name.de", destination = "iso3c")
```

    ['DZA']

When working inside a Polars pipeline, you can enrich a DataFrame by
calling `countrycode` directly on a column. `map_batches` keeps the
computation lazy-friendly:

``` python
import polars as pl
from countrycode import countrycode

df = pl.DataFrame(
    {
        "name": ["France", "Germany"],
    }
)

df.with_columns(
    pl.col("name")
      .map_batches(lambda s: countrycode(s, "country.name", "iso3c"), return_dtype=pl.String)
      .alias("iso3c")
)
```

<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (2, 2)</small>

| name      | iso3c |
|-----------|-------|
| str       | str   |
| "France"  | "FRA" |
| "Germany" | "DEU" |

</div>

If you already have a `Series` (e.g., after materializing a lazy query),
you can also pass it to `countrycode` directly and attach the result as
a new column:

``` python
df.with_columns(
    countrycode(df["name"], "country.name", "iso3c").alias("iso3c")
)
```

<div><style>
.dataframe > thead > tr,
.dataframe > tbody > tr {
  text-align: right;
  white-space: pre-wrap;
}
</style>
<small>shape: (2, 2)</small>

| name      | iso3c |
|-----------|-------|
| str       | str   |
| "France"  | "FRA" |
| "Germany" | "DEU" |

</div>

# Supported codes: Full list

``` python
from countrycode import codelist
", ".join(codelist.keys())
```

    'ar5, cctld, continent, country.name.de, country.name.de.regex, country.name.en, country.name.en.regex, country.name.fr, country.name.fr.regex, country.name.it, country.name.it.regex, cow.name, cowc, cown, currency, dhs, ecb, eu28, eurocontrol_pru, eurocontrol_statfor, eurostat, fao, fips, gaul, genc2c, genc3c, genc3n, gwc, gwn, icao.region, imf, ioc, iso.name.en, iso.name.fr, iso2c, iso3c, iso3n, iso4217c, iso4217n, p4.name, p4c, p4n, p5c, p5n, region, region23, un, un.name.ar, un.name.en, un.name.es, un.name.fr, un.name.ru, un.name.zh, un.region.code, un.region.name, un.regionintermediate.code, un.regionintermediate.name, un.regionsub.code, un.regionsub.name, unhcr, unhcr.region, unicode.symbol, unpd, vdem, vdem.name, wb, wb_api2c, wb_api3c, wvs, cldr.name.af, cldr.name.agq, cldr.name.ak, cldr.name.am, cldr.name.ar, cldr.name.ar_ly, cldr.name.ar_sa, cldr.name.as, cldr.name.asa, cldr.name.ast, cldr.name.az, cldr.name.az_cyrl, cldr.name.bas, cldr.name.be, cldr.name.bem, cldr.name.bez, cldr.name.bg, cldr.name.bm, cldr.name.bn, cldr.name.bo, cldr.name.br, cldr.name.brx, cldr.name.bs, cldr.name.bs_cyrl, cldr.name.ca, cldr.name.ccp, cldr.name.ce, cldr.name.ceb, cldr.name.cgg, cldr.name.chr, cldr.name.ckb, cldr.name.cs, cldr.name.cu, cldr.name.cy, cldr.name.da, cldr.name.dav, cldr.name.de, cldr.name.de_at, cldr.name.de_ch, cldr.name.dje, cldr.name.dsb, cldr.name.dua, cldr.name.dyo, cldr.name.dz, cldr.name.ee, cldr.name.el, cldr.name.en, cldr.name.en_001, cldr.name.en_au, cldr.name.eo, cldr.name.es, cldr.name.es_419, cldr.name.es_ar, cldr.name.es_cl, cldr.name.es_mx, cldr.name.es_us, cldr.name.et, cldr.name.eu, cldr.name.ewo, cldr.name.fa, cldr.name.fa_af, cldr.name.ff, cldr.name.fi, cldr.name.fil, cldr.name.fo, cldr.name.fr, cldr.name.fr_be, cldr.name.fr_ca, cldr.name.fur, cldr.name.fy, cldr.name.ga, cldr.name.gd, cldr.name.gl, cldr.name.gsw, cldr.name.gu, cldr.name.gv, cldr.name.ha, cldr.name.haw, cldr.name.he, cldr.name.hi, cldr.name.hr, cldr.name.hsb, cldr.name.hu, cldr.name.hy, cldr.name.ia, cldr.name.id, cldr.name.ig, cldr.name.ii, cldr.name.is, cldr.name.it, cldr.name.ja, cldr.name.jgo, cldr.name.jv, cldr.name.ka, cldr.name.kab, cldr.name.kam, cldr.name.kde, cldr.name.kea, cldr.name.khq, cldr.name.ki, cldr.name.kk, cldr.name.kkj, cldr.name.kl, cldr.name.kln, cldr.name.km, cldr.name.kn, cldr.name.ko, cldr.name.ko_kp, cldr.name.kok, cldr.name.ks, cldr.name.ksb, cldr.name.ksf, cldr.name.ksh, cldr.name.ku, cldr.name.kw, cldr.name.ky, cldr.name.lag, cldr.name.lb, cldr.name.lg, cldr.name.lkt, cldr.name.ln, cldr.name.lo, cldr.name.lrc, cldr.name.lt, cldr.name.lu, cldr.name.luo, cldr.name.luy, cldr.name.lv, cldr.name.mas, cldr.name.mer, cldr.name.mfe, cldr.name.mg, cldr.name.mgh, cldr.name.mgo, cldr.name.mi, cldr.name.mk, cldr.name.ml, cldr.name.mn, cldr.name.mr, cldr.name.ms, cldr.name.mt, cldr.name.mua, cldr.name.my, cldr.name.mzn, cldr.name.naq, cldr.name.nb, cldr.name.nd, cldr.name.ne, cldr.name.nl, cldr.name.nmg, cldr.name.nn, cldr.name.nnh, cldr.name.nus, cldr.name.nyn, cldr.name.om, cldr.name.or, cldr.name.os, cldr.name.pa, cldr.name.pa_arab, cldr.name.pl, cldr.name.ps, cldr.name.ps_pk, cldr.name.pt, cldr.name.pt_ao, cldr.name.qu, cldr.name.rm, cldr.name.rn, cldr.name.ro, cldr.name.ro_md, cldr.name.rof, cldr.name.ru, cldr.name.ru_ua, cldr.name.rw, cldr.name.sah, cldr.name.sbp, cldr.name.sd, cldr.name.se, cldr.name.se_fi, cldr.name.seh, cldr.name.sg, cldr.name.shi, cldr.name.shi_latn, cldr.name.si, cldr.name.sk, cldr.name.sl, cldr.name.smn, cldr.name.sn, cldr.name.so, cldr.name.sq, cldr.name.sr, cldr.name.sr_cyrl_ba, cldr.name.sr_cyrl_me, cldr.name.sr_cyrl_xk, cldr.name.sr_latn, cldr.name.sr_latn_ba, cldr.name.sr_latn_me, cldr.name.sr_latn_xk, cldr.name.sv, cldr.name.sw, cldr.name.sw_cd, cldr.name.sw_ke, cldr.name.ta, cldr.name.te, cldr.name.teo, cldr.name.tg, cldr.name.th, cldr.name.ti, cldr.name.tk, cldr.name.to, cldr.name.tr, cldr.name.tt, cldr.name.twq, cldr.name.tzm, cldr.name.ug, cldr.name.uk, cldr.name.ur, cldr.name.ur_in, cldr.name.uz, cldr.name.uz_arab, cldr.name.uz_cyrl, cldr.name.vai, cldr.name.vai_latn, cldr.name.vi, cldr.name.wae, cldr.name.wo, cldr.name.xh, cldr.name.xog, cldr.name.yav, cldr.name.yi, cldr.name.yo, cldr.name.yo_bj, cldr.name.yue, cldr.name.yue_hans, cldr.name.zgh, cldr.name.zh, cldr.name.zh_hant, cldr.name.zh_hant_hk, cldr.name.zu, cldr.short.af, cldr.short.am, cldr.short.ar, cldr.short.ar_ly, cldr.short.ar_sa, cldr.short.as, cldr.short.ast, cldr.short.az, cldr.short.az_cyrl, cldr.short.be, cldr.short.bg, cldr.short.bn, cldr.short.br, cldr.short.bs, cldr.short.bs_cyrl, cldr.short.ca, cldr.short.ccp, cldr.short.ce, cldr.short.ceb, cldr.short.chr, cldr.short.ckb, cldr.short.cs, cldr.short.cy, cldr.short.da, cldr.short.de, cldr.short.de_at, cldr.short.de_ch, cldr.short.dsb, cldr.short.dz, cldr.short.ee, cldr.short.el, cldr.short.en, cldr.short.en_001, cldr.short.en_au, cldr.short.es, cldr.short.es_419, cldr.short.es_ar, cldr.short.es_cl, cldr.short.es_mx, cldr.short.es_us, cldr.short.et, cldr.short.eu, cldr.short.fa, cldr.short.fa_af, cldr.short.fi, cldr.short.fil, cldr.short.fo, cldr.short.fr, cldr.short.fr_be, cldr.short.fr_ca, cldr.short.fur, cldr.short.fy, cldr.short.ga, cldr.short.gd, cldr.short.gl, cldr.short.gsw, cldr.short.gu, cldr.short.he, cldr.short.hi, cldr.short.hr, cldr.short.hsb, cldr.short.hu, cldr.short.hy, cldr.short.ia, cldr.short.id, cldr.short.ig, cldr.short.is, cldr.short.it, cldr.short.ja, cldr.short.jv, cldr.short.ka, cldr.short.kea, cldr.short.kk, cldr.short.km, cldr.short.kn, cldr.short.ko, cldr.short.ko_kp, cldr.short.kok, cldr.short.ksh, cldr.short.ku, cldr.short.ky, cldr.short.lb, cldr.short.lo, cldr.short.lt, cldr.short.lv, cldr.short.mk, cldr.short.ml, cldr.short.mn, cldr.short.mr, cldr.short.ms, cldr.short.mt, cldr.short.my, cldr.short.mzn, cldr.short.nb, cldr.short.ne, cldr.short.nl, cldr.short.nn, cldr.short.or, cldr.short.pa, cldr.short.pl, cldr.short.ps, cldr.short.ps_pk, cldr.short.pt, cldr.short.pt_ao, cldr.short.ro, cldr.short.ro_md, cldr.short.ru, cldr.short.ru_ua, cldr.short.sah, cldr.short.sd, cldr.short.se, cldr.short.se_fi, cldr.short.si, cldr.short.sk, cldr.short.sl, cldr.short.smn, cldr.short.so, cldr.short.sq, cldr.short.sr, cldr.short.sr_cyrl_ba, cldr.short.sr_cyrl_me, cldr.short.sr_cyrl_xk, cldr.short.sr_latn, cldr.short.sr_latn_ba, cldr.short.sr_latn_me, cldr.short.sr_latn_xk, cldr.short.sv, cldr.short.sw, cldr.short.sw_cd, cldr.short.sw_ke, cldr.short.ta, cldr.short.te, cldr.short.tg, cldr.short.th, cldr.short.ti, cldr.short.tk, cldr.short.to, cldr.short.tr, cldr.short.tt, cldr.short.ug, cldr.short.uk, cldr.short.ur, cldr.short.ur_in, cldr.short.uz, cldr.short.uz_cyrl, cldr.short.vai, cldr.short.vi, cldr.short.wae, cldr.short.wo, cldr.short.yi, cldr.short.yo, cldr.short.yo_bj, cldr.short.yue, cldr.short.yue_hans, cldr.short.zh, cldr.short.zh_hant, cldr.short.zh_hant_hk, cldr.short.zu, cldr.variant.af, cldr.variant.am, cldr.variant.ar, cldr.variant.ar_ae, cldr.variant.ar_ly, cldr.variant.ar_sa, cldr.variant.as, cldr.variant.ast, cldr.variant.az, cldr.variant.az_cyrl, cldr.variant.be, cldr.variant.bg, cldr.variant.bn, cldr.variant.bn_in, cldr.variant.br, cldr.variant.bs, cldr.variant.bs_cyrl, cldr.variant.ca, cldr.variant.ccp, cldr.variant.ce, cldr.variant.ceb, cldr.variant.chr, cldr.variant.ckb, cldr.variant.cs, cldr.variant.cy, cldr.variant.da, cldr.variant.de, cldr.variant.de_at, cldr.variant.de_ch, cldr.variant.dsb, cldr.variant.dz, cldr.variant.ee, cldr.variant.el, cldr.variant.en, cldr.variant.en_001, cldr.variant.en_au, cldr.variant.es, cldr.variant.es_419, cldr.variant.es_ar, cldr.variant.es_cl, cldr.variant.es_mx, cldr.variant.es_us, cldr.variant.et, cldr.variant.eu, cldr.variant.fa, cldr.variant.fa_af, cldr.variant.fi, cldr.variant.fil, cldr.variant.fo, cldr.variant.fr, cldr.variant.fr_be, cldr.variant.fr_ca, cldr.variant.fur, cldr.variant.fy, cldr.variant.ga, cldr.variant.gd, cldr.variant.gl, cldr.variant.gu, cldr.variant.ha, cldr.variant.he, cldr.variant.hi, cldr.variant.hr, cldr.variant.hsb, cldr.variant.hu, cldr.variant.hy, cldr.variant.ia, cldr.variant.id, cldr.variant.ig, cldr.variant.is, cldr.variant.it, cldr.variant.ja, cldr.variant.jv, cldr.variant.ka, cldr.variant.kea, cldr.variant.kk, cldr.variant.km, cldr.variant.kn, cldr.variant.ko, cldr.variant.ko_kp, cldr.variant.kok, cldr.variant.ksh, cldr.variant.ku, cldr.variant.ky, cldr.variant.lb, cldr.variant.ln, cldr.variant.lo, cldr.variant.lt, cldr.variant.lv, cldr.variant.mk, cldr.variant.ml, cldr.variant.mn, cldr.variant.mr, cldr.variant.ms, cldr.variant.mt, cldr.variant.my, cldr.variant.mzn, cldr.variant.nb, cldr.variant.ne, cldr.variant.nl, cldr.variant.nn, cldr.variant.or, cldr.variant.pa, cldr.variant.pl, cldr.variant.ps, cldr.variant.ps_pk, cldr.variant.pt, cldr.variant.pt_ao, cldr.variant.qu, cldr.variant.ro, cldr.variant.ro_md, cldr.variant.ru, cldr.variant.ru_ua, cldr.variant.sd, cldr.variant.se_fi, cldr.variant.si, cldr.variant.sk, cldr.variant.sl, cldr.variant.smn, cldr.variant.so, cldr.variant.sq, cldr.variant.sr, cldr.variant.sr_cyrl_ba, cldr.variant.sr_cyrl_me, cldr.variant.sr_cyrl_xk, cldr.variant.sr_latn, cldr.variant.sr_latn_ba, cldr.variant.sr_latn_me, cldr.variant.sr_latn_xk, cldr.variant.sv, cldr.variant.sw, cldr.variant.sw_cd, cldr.variant.sw_ke, cldr.variant.ta, cldr.variant.te, cldr.variant.tg, cldr.variant.th, cldr.variant.ti, cldr.variant.tk, cldr.variant.to, cldr.variant.tr, cldr.variant.tt, cldr.variant.ug, cldr.variant.uk, cldr.variant.ur, cldr.variant.ur_in, cldr.variant.uz, cldr.variant.uz_cyrl, cldr.variant.vi, cldr.variant.wae, cldr.variant.wo, cldr.variant.yi, cldr.variant.yo, cldr.variant.yo_bj, cldr.variant.yue, cldr.variant.yue_hans, cldr.variant.zh, cldr.variant.zh_hant, cldr.variant.zh_hant_hk, cldr.variant.zu'
