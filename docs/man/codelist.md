
# codelist

Country Code Translation Data Frame (Cross-Sectional)

## Description

A data frame used internally by the <code>countrycode()</code> function.
<code>countrycode</code> can use any valid code as destination, but only
some codes can be used as origin.

## Format

A data frame with codes as columns.

## Details

<h4>
Origin and Destination
</h4>
<ul>
<li>

<code>cctld</code>: IANA country code top-level domain

</li>
<li>

<code>country.name</code>: country name (English)

</li>
<li>

<code>country.name.de</code>: country name (German)

</li>
<li>

<code>country.name.fr</code>: country name (French)

</li>
<li>

<code>country.name.it</code>: country name (Italian)

</li>
<li>

<code>cowc</code>: Correlates of War character

</li>
<li>

<code>cown</code>: Correlates of War numeric

</li>
<li>

<code>dhs</code>: Demographic and Health Surveys Program

</li>
<li>

<code>ecb</code>: European Central Bank

</li>
<li>

<code>eurostat</code>: Eurostat

</li>
<li>

<code>fao</code>: Food and Agriculture Organization of the United
Nations numerical code

</li>
<li>

<code>fips</code>: FIPS 10-4 (Federal Information Processing Standard)

</li>
<li>

<code>gaul</code>: Global Administrative Unit Layers

</li>
<li>

<code>genc2c</code>: GENC 2-letter code

</li>
<li>

<code>genc3c</code>: GENC 3-letter code

</li>
<li>

<code>genc3n</code>: GENC numeric code

</li>
<li>

<code>gwc</code>: Gleditsch & Ward character

</li>
<li>

<code>gwn</code>: Gleditsch & Ward numeric

</li>
<li>

<code>imf</code>: International Monetary Fund

</li>
<li>

<code>ioc</code>: International Olympic Committee

</li>
<li>

<code>iso2c</code>: ISO-2 character

</li>
<li>

<code>iso3c</code>: ISO-3 character

</li>
<li>

<code>iso3n</code>: ISO-3 numeric

</li>
<li>

<code>p5n</code>: Polity V numeric country code

</li>
<li>

<code>p5c</code>: Polity V character country code

</li>
<li>

<code>p4n</code>: Polity IV numeric country code

</li>
<li>

<code>p4c</code>: Polity IV character country code

</li>
<li>

<code>un</code>: United Nations M49 numeric codes

</li>
<li>

<code>unicode.symbol</code>: Region subtag (often displayed as emoji
flag)

</li>
<li>

<code>unhcr</code>: United Nations High Commissioner for Refugees

</li>
<li>

<code>unpd</code>: United Nations Procurement Division

</li>
<li>

<code>vdem</code>: Varieties of Democracy (V-Dem version 8, April 2018)

</li>
<li>

<code>wb</code>: World Bank (very similar but not identical to iso3c)

</li>
<li>

<code>wvs</code>: World Values Survey numeric code

</li>
</ul>
<h4>
Destination only
</h4>
<ul>
<li>

`cldr.*`: 600+ country name variants from the UNICODE CLDR project
(e.g., "cldr.short.en"). Inspect the <code>cldr_examples</code>
data.frame for a full list of available country names and examples.

</li>
<li>

<code>ar5</code>: IPCC’s regional mapping used both in the Fifth
Assessment Report (AR5) and for the Reference Concentration Pathways
(RCP)

</li>
<li>

<code>continent</code>: Continent as defined in the World Bank
Development Indicators

</li>
<li>

<code>cow.name</code>: Correlates of War country name

</li>
<li>

<code>currency</code>: ISO 4217 currency name

</li>
<li>

<code>eurocontrol_pru</code>: European Organisation for the Safety of
Air Navigation

</li>
<li>

<code>eurocontrol_statfor</code>: European Organisation for the Safety
of Air Navigation

</li>
<li>

<code>eu28</code>: Member states of the European Union (as of December
2015), without special territories

</li>
<li>

<code>icao.region</code>: International Civil Aviation Organization
region

</li>
<li>

<code>iso.name.en</code>: ISO English short name

</li>
<li>

<code>iso.name.fr</code>: ISO French short name

</li>
<li>

<code>iso4217c</code>: ISO 4217 currency alphabetic code

</li>
<li>

<code>iso4217n</code>: ISO 4217 currency numeric code

</li>
<li>

<code>p4.name</code>: Polity IV country name

</li>
<li>

<code>region</code>: 7 Regions as defined in the World Bank Development
Indicators

</li>
<li>

<code>region23</code>: 23 Regions as used to be in the World Bank
Development Indicators (legacy)

</li>
<li>

<code>un.name.ar</code>: United Nations Arabic country name

</li>
<li>

<code>un.name.en</code>: United Nations English country name

</li>
<li>

<code>un.name.es</code>: United Nations Spanish country name

</li>
<li>

<code>un.name.fr</code>: United Nations French country name

</li>
<li>

<code>un.name.ru</code>: United Nations Russian country name

</li>
<li>

<code>un.name.zh</code>: United Nations Chinese country name

</li>
<li>

<code>un.region.name</code>: United Nations region name

</li>
<li>

<code>un.region.code</code>: United Nations region code

</li>
<li>

<code>un.regionintermediate.name</code>: United Nations intermediate
region name

</li>
<li>

<code>un.regionintermediate.code</code>: United Nations intermediate
region code

</li>
<li>

<code>un.regionsub.name</code>: United Nations sub-region name

</li>
<li>

<code>un.regionsub.code</code>: United Nations sub-region code

</li>
<li>

<code>unhcr.region</code>: United Nations High Commissioner for Refugees
region name

</li>
<li>

<code>wvs.name</code>: World Values Survey numeric code country name

</li>
</ul>

## Note

The Correlates of War (cow) and Polity 4 (p4) project produce codes in
country year format. Some countries go through political transitions
that justify changing codes over time. When building a purely
cross-sectional conversion dictionary, this forces us to make arbitrary
choices with respect to some entities (e.g., Western Germany, Vietnam,
Serbia). <code>countrycode</code> includes a reconciled dataset in panel
format, <code>codelist_panel</code>. Instead of converting code, we
recommend that users dealing with panel data "left-merge" their data
into this panel dictionary.
