source(here::here('dictionary/utilities.R'))

automatic <- WDI(country = "all", start = 2016, end = 2016, extra = TRUE) %>%
             filter(region != 'Aggregates') %>%
             select(country, region) %>%
             drop_na %>% 
             unique

# "East Asia & Pacific"
# "Europe & Central Asia"
# "Latin America & Caribbean"
# "Middle East & North Africa" 
# "North America"
# "South Asia"
# "Sub-Saharan Africa"
# manual changes 
manual <- tribble(
~country,                               ~region,
"Åland Islands",                                "Europe & Central Asia",
"Anguilla",                                     "Latin America & Caribbean",
"Antarctica",                                   NA,
"Austria-Hungary",                              "Europe & Central Asia",
"Baden",                                        "Europe & Central Asia",
"Bavaria",                                      "Europe & Central Asia",
"Bonaire, Sint Eustatius and Saba",             "Latin America & Caribbean",
"Bouvet Island",                                NA,
"British Indian Ocean Territory",               NA,
"Brunswick",                                    "Europe & Central Asia",
"Christmas Island",                             "East Asia & Pacific",
"Cocos (Keeling) Islands",                      "East Asia & Pacific",
"Cook Islands",                                 "East Asia & Pacific",
"Czechoslovakia",                               "Europe & Central Asia",
"Falkland Islands (Malvinas)",                  "Latin America & Caribbean",
"French Guiana",                                "Latin America & Caribbean",
"French Southern Territories",                  NA,
"German Democratic Republic",                   "Europe & Central Asia",
"Guadeloupe",                                   "Latin America & Caribbean",
"Guernsey",                                     "Europe & Central Asia",
"Hamburg",                                      "Europe & Central Asia",
"Hanover",                                      "Europe & Central Asia",
"Heard Island and McDonald Islands",            "East Asia & Pacific",
"Hesse Electoral",                              "Europe & Central Asia",
"Hesse Grand Ducal",                            "Europe & Central Asia",
"Hesse-Darmstadt",                              "Europe & Central Asia",
"Hesse-Kassel",                                 "Europe & Central Asia",
"Holy See (Vatican City State)",                "Europe & Central Asia",
"Jersey",                                       "Europe & Central Asia",
"Martinique",                                   "Latin America & Caribbean",
"Mayotte",                                      NA,
"Mecklenburg Schwerin",                         "Europe & Central Asia",
"Modena",                                       "Europe & Central Asia",
"Montserrat",                                   "Latin America & Caribbean",
"Nassau",                                       "Latin America & Caribbean",
"Netherlands Antilles",                         "Latin America & Caribbean",
"Niue",                                         "East Asia & Pacific",
"Norfolk Island",                               "East Asia & Pacific",
"Oldenburg",                                    "Europe & Central Asia",
"Orange Free State",                            NA,
"Parma",                                        "Europe & Central Asia",
"Piedmont-Sardinia",                            "Europe & Central Asia",
"Pitcairn",                                     "East Asia & Pacific",
"Prussia",                                      "Europe & Central Asia",
"Reunion",                                      NA,
"Saint Barthelemy",                             "Latin America & Caribbean",
"Saint Helena, Ascension and Tristan da Cunha", NA,
"Saint Pierre and Miquelon",                    'North America',
"Sardinia",                                     "Europe & Central Asia",
"Saxe-Weimar-Eisenach",                         "Europe & Central Asia",
"Saxony",                                       "Europe & Central Asia",
"Serbia and Montenegro",                        "Europe & Central Asia",
"Somaliland",                                   "Sub-Saharan Africa",
"South Georgia and the South Sandwich Islands", "East Asia & Pacific",
"Svalbard and Jan Mayen",                       NA,
"Taiwan, Province of China",                    "East Asia & Pacific",
"The former Yugoslav Republic of Macedonia",    "Europe & Central Asia",
"Tokelau",                                      "East Asia & Pacific",
"Tuscany",                                      "Europe & Central Asia",
"Two Sicilies",                                 "Europe & Central Asia",
"United Arab Republic",                         "Middle East & North Africa",
"United Province CA",                           NA,
"United States Minor Outlying Islands",         NA,
"Republic of Vietnam",                          "East Asia & Pacific",
"Wallis and Futuna",                            NA,
"Western Sahara",                               NA,
"Wuerttemburg",                                 "Europe & Central Asia",
"Wurtemberg",                                   "Europe & Central Asia",
"Yemen Arab Republic",                          "Middle East & North Africa",
"Yemen People's Republic",                      "Middle East & North Africa",
"Yugoslavia",                                   "Europe & Central Asia",
"Zanzibar",                                     "Sub-Saharan Africa") %>% 
drop_na



a <- CountryToRegex(automatic$country)
b <- CountryToRegex(manual$country)
manual <- manual[!b %in% a,]

out <- bind_rows(automatic, manual)

out %>%  write_csv('dictionary/data_world_bank_region.csv')

