source(here::here('dictionary/utilities.R'))

url <- 'http://databank.worldbank.org/data/download/site-content/CLASS.xls'

filename <- tempfile(fileext = '.xls')
download.file(url, filename, quiet = TRUE)

not_countries <- c("Arab World", "Caribbean small states", "Central Europe and the Baltics", "Early-demographic dividend", "East Asia & Pacific", "East Asia & Pacific (excluding high income)", "East Asia & Pacific (IDA & IBRD)", "Euro area", "Europe & Central Asia", "Europe & Central Asia (excluding high income)", "Europe & Central Asia (IDA & IBRD)", "European Union", "Fragile and conflict affected situations", "Heavily indebted poor countries (HIPC)", "High income", "IBRD only", "IDA & IBRD total", "IDA blend", "IDA only", "IDA total", "Late-demographic dividend", "Latin America & Caribbean", "Latin America & Caribbean (excluding high income)", "Latin America & Caribbean (IDA & IBRD)", "Least developed countries: UN classification", "Low & middle income", "Low income", "Lower middle income", "Middle East & North Africa", "Middle East & North Africa (excluding high income)", "Middle East & North Africa (IDA & IBRD)", "Middle income", "North America", "OECD members", "Other small states", "Pacific island small states", "Post-demographic dividend", "Pre-demographic dividend", "Small states", "South Asia", "South Asia (IDA & IBRD)", "Sub-Saharan Africa", "Sub-Saharan Africa (excluding high income)", "Sub-Saharan Africa (IDA & IBRD)", "Upper middle income", "World")

# weird read_excel call to silence warnings
wb <- read_excel(filename, skip = 6, col_names = letters[1:9]) %>%
      select(3:4) %>%
      setNames(c('country', 'wb')) %>%
      filter(!country %in% not_countries,
             !is.na(wb)) 

wb %>% write_csv('dictionary/data_world_bank.csv')
