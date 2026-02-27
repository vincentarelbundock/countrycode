source(here::here('dictionary/utilities.R'))

bad <- c("Gaza and Jericho") # Collides with State of Palestine

url <- 'https://data-api.ecb.europa.eu/service/codelist/ECB/CL_AREA?detail=full'
ns <- c(str = "http://www.sdmx.org/resources/sdmxml/schemas/v2_1/structure",
        com = "http://www.sdmx.org/resources/sdmxml/schemas/v2_1/common"
        )
doc <- xml2::read_xml(url)
codes <- xml2::xml_find_all(doc, ".//str:Code", ns)
ecb <- tibble(country = xml2::xml_text(xml2::xml_find_first(codes, "com:Name", ns)),
              ecb     = xml2::xml_attr(codes, "id")
              ) %>%
       # There are many bad country names in the ECB data. These are excluded
       # implicitly, but this is a hack and could potentially be improved.
       filter(grepl("^[[:upper:]]{2}$", ecb)) %>%
       filter(!country %in% bad) %>%
       mutate(ecb = if_else(country == 'Namibia', 'NA', ecb))

ecb %>% write_csv('dictionary/data_ecb.csv', na = "")
