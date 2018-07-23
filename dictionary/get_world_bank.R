get_world_bank = function() {

bad <- 
    c("Arab World",
    "Caribbean small states",
    "Central Europe and the Baltics",
    "Early-demographic dividend",
    "East Asia & Pacific",
    "East Asia & Pacific (excluding high income)",
    "East Asia & Pacific (IDA & IBRD)",
    "Economy",
    "Euro area",
    "Europe & Central Asia",
    "Europe & Central Asia (excluding high income)",
    "Europe & Central Asia (IDA & IBRD)",
    "European Union",
    "Fragile and conflict affected situations",
    "Heavily indebted poor countries (HIPC)",
    "High income",
    "IBRD only",
    "IDA & IBRD total",
    "IDA blend",
    "IDA only",
    "IDA total",
    "Late-demographic dividend",
    "Latin America & Caribbean",
    "Latin America & Caribbean (excluding high income)",
    "Latin America & Caribbean (IDA & IBRD)",
    "Least developed countries: UN classification",
    "Low & middle income",
    "Low income",
    "Lower middle income",
    "Middle East & North Africa",
    "Middle East & North Africa (excluding high income)",
    "Middle East & North Africa (IDA & IBRD)",
    "Middle income",
    "North America",
    "OECD members",
    "Other small states",
    "Pacific island small states",
    "Post-demographic dividend",
    "Pre-demographic dividend",
    "Small states",
    "South Asia",
    "South Asia (IDA & IBRD)",
    "Sub-Saharan Africa",
    "Sub-Saharan Africa (excluding high income)",
    "Sub-Saharan Africa (IDA & IBRD)",
    "Upper middle income",
    "World",
    "x")

    url <- 'http://databank.worldbank.org/data/download/site-content/CLASS.xls'

    filename <- tempfile(fileext = '.xls')
    download.file(url, filename, quiet = TRUE)

    wb <- readxl::read_excel(filename) %>%
          dplyr::select(3:4) %>%
          setNames(c('wb.name', 'wb')) %>%
          dplyr::filter(!wb.name %in% bad) %>%
          dplyr::mutate(country.name.en.regex = CountryToRegex(wb.name, warn = TRUE)) %>%
          dplyr::select(country.name.en.regex, wb, wb.name) %>%
          na.omit

    return(wb)
}
