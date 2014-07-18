context('Special cases of regex')

iso3c_of <- function(name) countrycode(name, 'country.name', 'iso3c', warn = TRUE)
no_warn_iso3c_of <- function(name) countrycode(name, 'country.name', 'iso3c')
cowc_of <- function(name) countrycode(name, 'country.name', 'cowc', warn = TRUE)
no_warn_cowc_of <- function(name) countrycode(name, 'country.name', 'cowc')

test_that('accented characters are properly matched', {
    expect_that(iso3c_of('\u00C5land Islands'), equals('ALA'))
    expect_that(iso3c_of('Saint Barth\u00E9lemy'), equals('BLM'))
    expect_that(iso3c_of('C\u00F4te d\'Ivoire'), equals('CIV'))
    expect_that(iso3c_of('Cura\u00E7ao'), equals('CUW'))
    expect_that(iso3c_of('R\u00E9union'), equals('REU'))
    expect_that(iso3c_of('S\u00E3o Tom\u00E9 and Pr\u00EDncipe'), equals('STP'))
})

test_that('some official country names are properly matched', {
    expect_that(iso3c_of('democratic people\'s republic of korea'), equals('PRK'))
    expect_that(iso3c_of('republic of guinea'), equals('GIN'))
    expect_that(iso3c_of('hellenic republic'), equals('GRC'))
    expect_that(iso3c_of('united mexican states'), equals('MEX'))
    expect_that(iso3c_of('republic of the union of myanmar'), equals('MMR'))
    expect_that(iso3c_of('independent state of samoa'), equals('WSM'))
    expect_that(iso3c_of('republic of south sudan'), equals('SSD'))
    expect_that(iso3c_of('swiss confederation'), equals('CHE'))
})

test_that('some unofficial country names are properly matched', {
    expect_that(iso3c_of('dprk'), equals('PRK'))
    expect_that(iso3c_of('byelorussia'), equals('BLR'))
    expect_that(iso3c_of('british honduras'), equals('BLZ'))
    expect_that(iso3c_of('bechuanaland'), equals('BWA'))
    expect_that(iso3c_of('nyasaland'), equals('MWI'))
    expect_that(iso3c_of('british east africa'), equals('KEN'))
    expect_that(iso3c_of('east africa protectorate'), equals('KEN'))
    expect_that(iso3c_of('east pakistan'), equals('BGD'))
    expect_that(iso3c_of('chinese taipei'), equals('TWN'))
    expect_that(iso3c_of('taipei'), equals('TWN'))
})

test_that('former Soviet republics are properly matched', {
    expect_that(iso3c_of('russian soviet federative socialist republic'), equals('RUS'))
    expect_that(iso3c_of('ukrainian soviet socialist republic'), equals('UKR'))
    expect_that(iso3c_of('uzbek soviet socialist republic'), equals('UZB'))
    expect_that(iso3c_of('kazakh soviet socialist republic'), equals('KAZ'))
    expect_that(iso3c_of('byelorussian soviet socialist republic'), equals('BLR'))
    expect_that(iso3c_of('azerbaijan soviet socialist republic'), equals('AZE'))
    expect_that(iso3c_of('georgian soviet socialist republic'), equals('GEO'))
    expect_that(iso3c_of('tajik soviet socialist republic'), equals('TJK'))
    expect_that(iso3c_of('moldovian soviet socialist republic'), equals('MDA'))
    expect_that(iso3c_of('kirghiz soviet socialist republic'), equals('KGZ'))
    expect_that(iso3c_of('lithuanian soviet socialist republic'), equals('LTU'))
    expect_that(iso3c_of('turkmen soviet socialist republic'), equals('TKM'))
    expect_that(iso3c_of('armenian soviet socialist republic'), equals('ARM'))
    expect_that(iso3c_of('latvian soviet socialist republic'), equals('LVA'))
    expect_that(iso3c_of('estonian soviet socialist republic'), equals('EST'))
})

test_that('some common abbreviations are properly matched', {
    expect_that(iso3c_of('u.s.'), equals('USA'))
    expect_that(iso3c_of('u.s.a.'), equals('USA'))
    expect_that(iso3c_of('u.k.'), equals('GBR'))
    expect_that(iso3c_of('fyrom'), equals('MKD'))
    expect_that(iso3c_of('united arab em.'), equals('ARE'))
    expect_that(no_warn_iso3c_of('united arab republic'), equals(NA_character_)) # Doesn't have in iso3c
    expect_that(iso3c_of('emirates'), equals('ARE'))
    expect_that(iso3c_of('uae'), equals('ARE'))
    expect_that(iso3c_of('u.a.e.'), equals('ARE'))
})

test_that('the Netherlands Antilles are all matched correctly', {
    expect_that(iso3c_of('netherlands antilles'), equals('ANT'))                                  # A former country
    expect_that(iso3c_of('dutch antilles'), equals('ANT'))                                        # A former country
    expect_that(no_warn_iso3c_of('dutch caribbean'), equals(NA_character_))                        # The meaning of this unit is ambiguous
    
    expect_that(iso3c_of('aruba'), equals('ABW'))                                                 # A country of the Netherlands
    
    expect_that(iso3c_of('cura\u00E7ao'), equals('CUW'))                                          # A country of the Netherlands
    
    expect_that(iso3c_of('sint maarten'), equals('SXM'))                                          # A country of the Netherlands
    expect_that(iso3c_of('collectivity of saint martin'), equals('MAF'))                          # A French overseas collectivity
    expect_that(iso3c_of('saint martin (french part)'), equals('MAF'))                            # A French overseas collectivity
    expect_that(no_warn_iso3c_of('saint martin'), equals(NA_character_))                           # The meaning of this unit is ambiguous
    expect_that(no_warn_iso3c_of('st. martin'), equals(NA_character_))                             # The meaning of this unit is ambiguous
    expect_that(no_warn_iso3c_of('saint-martin'), equals(NA_character_))                           # An island, not a political entity
    expect_that(no_warn_iso3c_of('St-Martin / Sint Maarten'), equals(NA_character_))               # An island, not a political entity
    expect_that(no_warn_iso3c_of('St-Martin / St-Maarten'), equals(NA_character_))                 # An island, not a political entity
    expect_that(no_warn_iso3c_of('St. Martin and St. Maarten'), equals(NA_character_))             # An island, not a political entity
    expect_that(no_warn_iso3c_of('St Maarten – St Martin'), equals(NA_character_))                 # An island, not a political entity
        
    expect_that(iso3c_of('bonaire, saba, and sint eustatius'), equals('BES'))                     # Municipalities of the Netherlands
    expect_that(iso3c_of('bes islands'), equals('BES'))                                           # Municipalities of the Netherlands
    expect_that(iso3c_of('caribbean netherlands'), equals('BES'))                                 # Municipalities of the Netherlands
    
    expect_that(no_warn_iso3c_of('greater antilles'), equals(NA_character_))                       # Not a political entity
    expect_that(no_warn_iso3c_of('lesser antilles'), equals(NA_character_))                        # Not a political entity
    expect_that(no_warn_iso3c_of('abc islands'), equals(NA_character_))                            # Not a political entity
    expect_that(no_warn_iso3c_of('leeward islands'), equals(NA_character_))                        # Not a political entity
    expect_that(no_warn_iso3c_of('leeward antilles'), equals(NA_character_))                       # Not a political entity
    expect_that(no_warn_iso3c_of('aruba, bonaire, and curaçao'), equals(NA_character_))            # Not a political entity
    expect_that(no_warn_iso3c_of('sss islands'), equals(NA_character_))                            # Not a political entity
    expect_that(no_warn_iso3c_of('windward islands'), equals(NA_character_))                       # Not a political entity
    expect_that(no_warn_iso3c_of('sint maarten, saba, and sint eustatius'), equals(NA_character_)) # Not a political entity
})

test_that('the two Congos are distinguished', {
    expect_that(iso3c_of('republic of congo'), equals('COG'))
    expect_that(iso3c_of('republic of the congo'), equals('COG'))
    expect_that(iso3c_of('congo, republic of the'), equals('COG'))
    expect_that(iso3c_of('congo, republic'), equals('COG'))
    expect_that(iso3c_of('congo, rep.'), equals('COG'))
    expect_that(iso3c_of('congo-brazzaville'), equals('COG'))
    expect_that(iso3c_of('french congo'), equals('COG'))
    expect_that(no_warn_iso3c_of('ROC'), equals(NA_character_))   # Could be Taiwan or Congo
    
    expect_that(iso3c_of('democratic republic of the congo'), equals('COD'))
    expect_that(iso3c_of('congo, democratic republic of the'), equals('COD'))
    expect_that(iso3c_of('dem rep of the congo'), equals('COD'))
    expect_that(iso3c_of('the democratic republic of congo'), equals('COD'))
    expect_that(iso3c_of('congo, dem. rep.'), equals('COD'))
    expect_that(iso3c_of('dr congo'), equals('COD'))
    expect_that(iso3c_of('drc'), equals('COD'))
    expect_that(iso3c_of('droc'), equals('COD'))
    expect_that(iso3c_of('rdc'), equals('COD'))
    expect_that(iso3c_of('congo-kinshasa'), equals('COD'))
    expect_that(iso3c_of('congo-zaire'), equals('COD'))
    expect_that(iso3c_of('zaire'), equals('COD'))
    expect_that(iso3c_of('belgian congo'), equals('COD'))
    expect_that(iso3c_of('republic of the congo-l\u00E9opoldville'), equals('COD'))
    expect_that(iso3c_of('congo free state'), equals('COD'))
})

test_that('the four Yemens are distinguished', {
    expect_that(cowc_of('yemen'), equals('YEM'))
    expect_that(cowc_of('republic of yemen'), equals('YEM'))
    
    expect_that(cowc_of('yemen arab republic'), equals('YAR'))
    expect_that(cowc_of('north yemen'), equals('YAR'))
    expect_that(cowc_of('yemen (sana\'a)'), equals('YAR'))
    
    expect_that(cowc_of('yemen people\'s republic'), equals('YPR'))
    expect_that(cowc_of('people\'s democratic republic of yemen'), equals('YPR'))
    expect_that(cowc_of('south yemen'), equals('YPR'))
    expect_that(cowc_of('democratic yemen'), equals('YPR'))
    expect_that(cowc_of('yemen (aden)'), equals('YPR'))
    
    expect_that(no_warn_cowc_of('democratic republic of yemen'), equals(NA_character_))
})

test_that('some old and colonial names are matched', {
    expect_that(iso3c_of('gold coast'), equals('GHA'))
    expect_that(iso3c_of('upper volta'), equals('BFA'))
    expect_that(iso3c_of('portuguese guinea'), equals('GNB'))
    expect_that(iso3c_of('basutoland'), equals('LSO'))
    expect_that(iso3c_of('northern rhodesia'), equals('ZMB'))
    expect_that(iso3c_of('southern rhodesia'), equals('ZWE'))
    expect_that(iso3c_of('rhodesia'), equals('ZWE'))
    expect_that(iso3c_of('the argentine'), equals('ARG'))
    expect_that(iso3c_of('dutch guiana'), equals('SUR'))
    expect_that(iso3c_of('bohemia'), equals('CZE'))
    expect_that(iso3c_of('czechia'), equals('CZE'))
    expect_that(iso3c_of('french republic'), equals('FRA'))
    expect_that(iso3c_of('gaul'), equals('FRA'))
    expect_that(iso3c_of('hellas'), equals('GRC'))
    expect_that(iso3c_of('bessarabia'), equals('MDA'))
    expect_that(iso3c_of('bassarabia'), equals('MDA'))
    expect_that(iso3c_of('rumania'), equals('ROU'))
    expect_that(iso3c_of('roumania'), equals('ROU'))
    expect_that(iso3c_of('mesopotamia'), equals('IRQ'))
    expect_that(iso3c_of('trucial states'), equals('OMN'))
    expect_that(iso3c_of('formosa'), equals('TWN'))
    expect_that(iso3c_of('new hebrides'), equals('VUT'))
})