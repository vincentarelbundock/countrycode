source(here::here('dictionary/utilities.R'))

url <- "http://ksgleditsch.com/data/iisystem.dat"

gw <- readr::read_tsv(url,
                      locale = locale(encoding = "windows-1252"),
                      col_names = c("gwn", "gwc", "country", "birth", "death"),
                      col_types = cols(gwn = readr::col_integer(),
                                       gwc = readr::col_character(),
                                       country = readr::col_character(),
                                       birth = readr::col_date(format = "%d:%m:%Y"),
                                       death = readr::col_date(format = "%d:%m:%Y")))


# gw |> filter(country %like% "Korea")

gw <- gw %>%
    # pre-processing to avoid regex ambiguity
    mutate(
        country = gsub(" \\(Prussia\\)", "", country),
        country = gsub(" \\(Annam.*", "", country)
    ) %>%
    # ambiguous or not covered
    filter(!gwc %in% c("TBT", "DRV", "HSD", "HSE", "WRT", "UPC", "TRA")) %>% 
    mutate(idx = 1:n()) |>
    group_by(idx) |>
    mutate(panel = list(year(birth):year(death))) %>%
    ungroup() |>
    unnest(panel) |> 
    select(-idx, -birth, -death) |>
    rename(year = panel) |>
    # arbitrary
    filter((year != 1830) | (gwc != 'COL')) |> # Gran Colombia vs. Colombia
    mutate(country = utf8::utf8_encode(country))

gw %>% write_csv('dictionary/data_gw.csv', na = "")

