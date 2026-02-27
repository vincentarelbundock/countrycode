context('Special cases of regex')

iso3c_of <- function(name) countrycode(name, 'country.name', 'iso3c', warn = TRUE)
no_warn_iso3c_of <- function(name) countrycode(name, 'country.name', 'iso3c', warn = FALSE)
cowc_of <- function(name) countrycode(name, 'country.name', 'cowc', warn = TRUE)
no_warn_cowc_of <- function(name) countrycode(name, 'country.name', 'cowc', warn = FALSE)


test_that('names that should return NA', {
    expect_equal(no_warn_iso3c_of('ROC'), NA_character_)   # Could be Taiwan or Congo
    expect_equal(no_warn_iso3c_of('united arab republic'), NA_character_) # Doesn't have in iso3c
    expect_equal(no_warn_iso3c_of('Southern Africa'), NA_character_)
    expect_equal(no_warn_cowc_of('democratic republic of yemen'), NA_character_)
})


test_that("Guyana", {
    expect_equal(no_warn_iso3c_of("Guiana"), NA_character_) # Guiana is ambiguous in English
})


test_that('accented characters are properly matched', {
    expect_equal(iso3c_of('\u00C5land Islands'), 'ALA')
    expect_equal(iso3c_of('Saint Barth\u00E9lemy'), 'BLM')
    expect_equal(iso3c_of('C\u00F4te d\'Ivoire'), 'CIV')
    expect_equal(iso3c_of('Cura\u00E7ao'), 'CUW')
    expect_equal(iso3c_of('R\u00E9union'), 'REU')
    expect_equal(iso3c_of('S\u00E3o Tom\u00E9 and Pr\u00EDncipe'), 'STP')
})


test_that('some official country names are properly matched', {
    expect_equal(iso3c_of('democratic people\'s republic of korea'), 'PRK')
    expect_equal(iso3c_of('republic of guinea'), 'GIN')
    expect_equal(iso3c_of('hellenic republic'), 'GRC')
    expect_equal(iso3c_of('united mexican states'), 'MEX')
    expect_equal(iso3c_of('republic of the union of myanmar'), 'MMR')
    expect_equal(iso3c_of('independent state of samoa'), 'WSM')
    expect_equal(iso3c_of('republic of south sudan'), 'SSD')
    expect_equal(iso3c_of('swiss confederation'), 'CHE')
})


test_that('some unofficial country names are properly matched', {
    expect_equal(iso3c_of('dprk'), 'PRK')
    expect_equal(iso3c_of('byelorussia'), 'BLR')
    expect_equal(iso3c_of('british honduras'), 'BLZ')
    expect_equal(iso3c_of('bechuanaland'), 'BWA')
    expect_equal(iso3c_of('nyasaland'), 'MWI')
    expect_equal(iso3c_of('british east africa'), 'KEN')
    expect_equal(iso3c_of('east africa protectorate'), 'KEN')
    expect_equal(iso3c_of('east pakistan'), 'BGD')
    expect_equal(iso3c_of('chinese taipei'), 'TWN')
    expect_equal(iso3c_of('taipei'), 'TWN')
})


test_that('former Soviet republics are properly matched', {
    expect_equal(iso3c_of('russian soviet federative socialist republic'), 'RUS')
    expect_equal(iso3c_of('ukrainian soviet socialist republic'), 'UKR')
    expect_equal(iso3c_of('uzbek soviet socialist republic'), 'UZB')
    expect_equal(iso3c_of('kazakh soviet socialist republic'), 'KAZ')
    expect_equal(iso3c_of('byelorussian soviet socialist republic'), 'BLR')
    expect_equal(iso3c_of('azerbaijan soviet socialist republic'), 'AZE')
    expect_equal(iso3c_of('georgian soviet socialist republic'), 'GEO')
    expect_equal(iso3c_of('tajik soviet socialist republic'), 'TJK')
    expect_equal(iso3c_of('moldovian soviet socialist republic'), 'MDA')
    expect_equal(iso3c_of('kirghiz soviet socialist republic'), 'KGZ')
    expect_equal(iso3c_of('lithuanian soviet socialist republic'), 'LTU')
    expect_equal(iso3c_of('turkmen soviet socialist republic'), 'TKM')
    expect_equal(iso3c_of('armenian soviet socialist republic'), 'ARM')
    expect_equal(iso3c_of('latvian soviet socialist republic'), 'LVA')
    expect_equal(iso3c_of('estonian soviet socialist republic'), 'EST')
})


test_that('the Netherlands Antilles are all matched correctly', {
    # The codes for the Netherlands Antilles are deleted from ISO 3166-1 and
    # transitionally reserved for a period of 50 years:
    # https://www.iso.org/news/2010/12/Ref1383.html
    expect_equal(no_warn_iso3c_of('netherlands antilles'), NA_character_)                   # A former country
    expect_equal(no_warn_iso3c_of('dutch antilles'), NA_character_)                         # A former country
    expect_equal(no_warn_iso3c_of('dutch caribbean'), NA_character_)                        # The meaning of this unit is ambiguous
    expect_equal(iso3c_of('aruba'), 'ABW')                                                  # A country of the Netherlands
    expect_equal(iso3c_of('curaçao'), 'CUW')                                                # A country of the Netherlands
    expect_equal(iso3c_of('sint maarten'), 'SXM')                                           # A country of the Netherlands
    expect_equal(iso3c_of('collectivity of saint martin'), 'MAF')                           # A French overseas collectivity
    expect_equal(iso3c_of('saint martin (french part)'), 'MAF')                             # A French overseas collectivity
    expect_equal(no_warn_iso3c_of('saint martin'), NA_character_)                           # The meaning of this unit is ambiguous
    expect_equal(no_warn_iso3c_of('st. martin'), NA_character_)                             # The meaning of this unit is ambiguous
    expect_equal(no_warn_iso3c_of('saint-martin'), NA_character_)                           # An island, not a political entity
    expect_equal(no_warn_iso3c_of('St-Martin / Sint Maarten'), NA_character_)               # An island, not a political entity
    expect_equal(no_warn_iso3c_of('St-Martin / St-Maarten'), NA_character_)                 # An island, not a political entity
    expect_equal(no_warn_iso3c_of('St. Martin and St. Maarten'), NA_character_)             # An island, not a political entity
    expect_equal(no_warn_iso3c_of('St Maarten – St Martin'), NA_character_)                 # An island, not a political entity
    expect_equal(iso3c_of('bonaire, saba, and sint eustatius'), 'BES')                      # Municipalities of the Netherlands
    expect_equal(iso3c_of('bes islands'), 'BES')                                            # Municipalities of the Netherlands
    expect_equal(iso3c_of('caribbean netherlands'), 'BES')                                  # Municipalities of the Netherlands
    expect_equal(no_warn_iso3c_of('greater antilles'), NA_character_)                       # Not a political entity
    expect_equal(no_warn_iso3c_of('lesser antilles'), NA_character_)                        # Not a political entity
    expect_equal(no_warn_iso3c_of('abc islands'), NA_character_)                            # Not a political entity
    expect_equal(no_warn_iso3c_of('leeward islands'), NA_character_)                        # Not a political entity
    expect_equal(no_warn_iso3c_of('leeward antilles'), NA_character_)                       # Not a political entity
    expect_equal(no_warn_iso3c_of('aruba, bonaire, and curaçao'), NA_character_)            # Not a political entity
    expect_equal(no_warn_iso3c_of('sss islands'), NA_character_)                            # Not a political entity
    expect_equal(no_warn_iso3c_of('windward islands'), NA_character_)                       # Not a political entity
    expect_equal(no_warn_iso3c_of('sint maarten, saba, and sint eustatius'), NA_character_) # Not a political entity
})


test_that('some old and colonial names are matched', {
    expect_equal(iso3c_of('gold coast'), 'GHA')
    expect_equal(iso3c_of('upper volta'), 'BFA')
    expect_equal(iso3c_of('portuguese guinea'), 'GNB')
    expect_equal(iso3c_of('basutoland'), 'LSO')
    expect_equal(iso3c_of('northern rhodesia'), 'ZMB')
    expect_equal(iso3c_of('southern rhodesia'), 'ZWE')
    expect_equal(iso3c_of('rhodesia'), 'ZWE')
    expect_equal(iso3c_of('the argentine'), 'ARG')
    expect_equal(iso3c_of('dutch guiana'), 'SUR')
    expect_equal(iso3c_of('bohemia'), 'CZE')
    expect_equal(iso3c_of('czechia'), 'CZE')
    expect_equal(iso3c_of('french republic'), 'FRA')
    expect_equal(iso3c_of('gaul'), 'FRA')
    expect_equal(iso3c_of('hellas'), 'GRC')
    expect_equal(iso3c_of('bessarabia'), 'MDA')
    expect_equal(iso3c_of('bassarabia'), 'MDA')
    expect_equal(iso3c_of('rumania'), 'ROU')
    expect_equal(iso3c_of('roumania'), 'ROU')
    expect_equal(iso3c_of('mesopotamia'), 'IRQ')
    expect_equal(iso3c_of('trucial states'), 'OMN')
    expect_equal(iso3c_of('formosa'), 'TWN')
    expect_equal(iso3c_of('new hebrides'), 'VUT')
})


test_that('Micronesia is not Federated States of Micronesia', {
    # bare ambiguous label → NA in all language origins, and warn is emitted
    expect_warning(iso3c_of('Micronesia'), regexp = 'not matched')
    expect_equal(no_warn_iso3c_of('Micronesia'), NA_character_)
    expect_equal(countrycode('Mikronesien', 'country.name.de', 'iso3c', warn = FALSE), NA_character_)
    expect_equal(countrycode('Micron\u00e9sie', 'country.name.fr', 'iso3c', warn = FALSE), NA_character_)
    expect_equal(countrycode('Micronesia', 'country.name.it', 'iso3c', warn = FALSE), NA_character_)
    # unambiguous full English names → FSM
    expect_equal(iso3c_of('Federated States of Micronesia'), 'FSM')
    expect_equal(iso3c_of('Micronesia, Federated States of'), 'FSM')
    expect_equal(iso3c_of('Micronesia (Federated States of)'), 'FSM')
    # FS abbreviation forms (EN origin) → FSM
    expect_equal(iso3c_of('FS Micronesia'), 'FSM')
    expect_equal(iso3c_of('F.S. Micronesia'), 'FSM')
    expect_equal(iso3c_of('F S Micronesia'), 'FSM')
    # German: qualified forms → FSM, FS abbreviation → FSM
    expect_equal(countrycode('F\u00f6derierte Staaten von Mikronesien', 'country.name.de', 'iso3c'), 'FSM')
    expect_equal(countrycode('Mikronesien (F\u00f6derierte Staaten von)', 'country.name.de', 'iso3c'), 'FSM')
    expect_equal(countrycode('FS Mikronesien', 'country.name.de', 'iso3c'), 'FSM')
    expect_equal(countrycode('F.S. Mikronesien', 'country.name.de', 'iso3c'), 'FSM')
    # French: qualified forms → FSM, FS abbreviation → FSM
    expect_equal(countrycode('Micron\u00e9sie (\u00c9tats f\u00e9d\u00e9r\u00e9s de)', 'country.name.fr', 'iso3c'), 'FSM')
    expect_equal(countrycode('\u00c9tats f\u00e9d\u00e9r\u00e9s de Micron\u00e9sie', 'country.name.fr', 'iso3c'), 'FSM')
    expect_equal(countrycode('FS Micron\u00e9sie', 'country.name.fr', 'iso3c'), 'FSM')
    # Italian: qualified forms → FSM, FS abbreviation → FSM
    expect_equal(countrycode('Stati Federati di Micronesia', 'country.name.it', 'iso3c'), 'FSM')
    expect_equal(countrycode('Micronesia (Stati Federati di)', 'country.name.it', 'iso3c'), 'FSM')
    expect_equal(countrycode('FS Micronesia', 'country.name.it', 'iso3c'), 'FSM')
})


test_that('Northern Ireland is not Ireland (Issue #313)', {
    # Republic of Ireland
    expect_equal(iso3c_of('Ireland'), 'IRL')

    # Abbreviated and reordered Northern Ireland forms -> United Kingdom
    expect_equal(iso3c_of('Northern Ireland'), 'GBR')
    expect_equal(iso3c_of('North Ireland'), 'GBR')
    expect_equal(iso3c_of('N Ireland'), 'GBR')
    expect_equal(iso3c_of('N. Ireland'), 'GBR')
    expect_equal(iso3c_of('Ireland (Northern)'), 'GBR')
    expect_equal(iso3c_of('Ireland (North)'), 'GBR')
    expect_equal(iso3c_of('Ireland (N)'), 'GBR')
    expect_equal(iso3c_of('Ireland (N.)'), 'GBR')
    expect_equal(iso3c_of('Ireland, Northern'), 'GBR')
    expect_equal(iso3c_of('Ireland, North'), 'GBR')
    expect_equal(iso3c_of('Ireland, N.'), 'GBR')
    expect_equal(iso3c_of('Ireland, N'), 'GBR')
    expect_equal(iso3c_of('in the north of Ireland'), 'GBR')
})


test_that('East and West Germany are disambiguated', {
    # Basic Germany forms map to modern Germany / FRG
    expect_equal(iso3c_of('Germany'), 'DEU')
    expect_equal(cowc_of('Germany'), 'GMY')
    expect_equal(iso3c_of('Federal Republic of Germany'), 'DEU')
    expect_equal(cowc_of('Federal Republic of Germany'), 'GMY')

    # Historical East Germany (GDR) is identified by explicit east + germany forms
    expect_equal(cowc_of('East Germany'), 'GDR')
    expect_equal(cowc_of('Germany East'), 'GDR')

    # West Germany maps to Germany / FRG depending on destination code
    expect_equal(iso3c_of('West Germany'), 'DEU')
    expect_equal(iso3c_of('Germany West'), 'DEU')
    expect_equal(cowc_of('West Germany'), 'GMY')
    expect_equal(cowc_of('Germany West'), 'GMY')

    # Word boundaries avoid treating regional labels as the former GDR
    expect_equal(iso3c_of('Eastern Germany'), 'DEU')
    expect_equal(cowc_of('Eastern Germany'), 'GMY')
})


test_that('leading and trailing whitespace does not interfere', {
    expect_equal(cowc_of(' Republic of Vietnam'), 'RVN')
    expect_equal(cowc_of('\tUnited States'), 'USA')
   expect_equal(cowc_of('Republic of Vietnam '), 'RVN')
    expect_equal(cowc_of('United States\t'), 'USA')
})
