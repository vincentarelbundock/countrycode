# This script will scrape the UN website for official country names in the six
# official languages of the United Nations (EN, FR, ES, RU, ZH, AR). Make sure
# to run it in a UTF-8 environment. -- FB 2016-03-22

library(dplyr)
library(readr)
library(rvest)
library(stringr)

#' Clean spaces
str_space <- function(x) {

  gsub("(\\\\r|\\\\n|\\n|\\\\t|\\s)+", " ", x)

}

#' Get country names (based on UNGEGN official country names)
get_names <- function(x) {

  read_html(str_c("http://www.un.org/", x, "/members/")) %>%
    html_nodes(".countryname") %>%
    html_text %>%
    str_space %>%
    str_replace("\\*", "") %>%
    str_trim

}

#' Get country links (best candidates as cross-language unique identifiers)
get_links <- function(x) {

  read_html(str_c("http://www.un.org/", x, "/members/")) %>%
    html_nodes(xpath = "//li[@class='countryname']/a[contains(@href, 'mission')]") %>%
    html_attr("href") %>%
    str_space %>%
    str_replace("(.*)/members/missions/(.*)\\.htm(.*)", "\\2")

}

if (!file.exists("un_names.csv")) {

  # English
  un <- data_frame(
    un_name_en = get_names("en"),
    un_link = get_links("en")
  )

  # French
  un <- full_join(
    un,
    data_frame(
      un_name_fr = get_names("fr"),
      un_link = get_links("fr")
    ),
    by = "un_link"
  )

  # Spanish
  un <- full_join(
    un,
    data_frame(
      un_name_es = get_names("es"),
      un_link = get_links("es")
    ),
    by = "un_link"
  )

  # Russian
  un <- full_join(
    un,
    data_frame(
      un_name_ru = get_names("ru"),
      un_link = get_links("ru")
    ),
    by = "un_link"
  )

  # Chinese (fixing the missing link for South Sudan)
  un <- full_join(
    un,
    rbind(
      data_frame(
        un_name_zh = get_names("zh")[ get_names("zh") != "南苏丹" ],
        un_link = get_links("zh")
      ),
      data_frame(
        un_name_zh = "南苏丹",
        un_link = "southsudan"
      )
    ),
    by = "un_link"
  )

  # Arabic (fixing 3 mismatches)
  un <- full_join(
    un,
    data_frame(
      un_name_ar = get_names("ar"),
      un_link = get_links("ar")
    ) %>%
      mutate(
        un_link = ifelse(un_link == "equatorialguinea", "eqguinea", un_link),
        un_link = ifelse(un_link == "vanuato", "vanuatu", un_link),
        un_link = ifelse(un_link == "nicaragwa", "nicaragua", un_link)
      ),
    by = "un_link"
  )

  # Sanity check: Found all UN members (as of 2016-03-21)
  stopifnot(nrow(un) == 193)

  # Encoding issue (extra nonbreakable space in string)
  un$un_name_en[ un$un_link == "southsudan" ] = "South Sudan"

  # Encoding issue (UTF-8 quote in string)
  un$un_name_en[ un$un_link == "lao" ] = "Lao People's Democratic Republic"

  # Export UN names
  write_csv(select(un, -un_link), "un_names.csv")

}

un = read_csv("un_names.csv")

# create variable that matches countrycode_data$country_name
un$cty = str_replace(un$un_name_en, "(.*)\\s\\((.*)\\)$", "\\1, \\2")
un$cty[ un$cty == "Côte D'Ivoire" ] = "Cote d'Ivoire"
un$cty[ un$cty == "Democratic People's Republic of Korea" ] = "Korea, Democratic People's Republic of"
un$cty[ un$cty == "Democratic Republic of the Congo" ] = "Congo, the Democratic Republic of the"
un$cty[ un$cty == "Guinea Bissau" ] = "Guinea-Bissau"
un$cty[ un$cty == "Republic of Korea" ] = "Korea, Republic of" # match South Korea to ROK (instead of KOR)
un$cty[ un$cty == "Republic of Moldova" ] = "Moldova, Republic of"
un$cty[ un$cty == "The former Yugoslav Republic of Macedonia" ] = "Macedonia, the former Yugoslav Republic of"
un$cty[ un$cty == "United Kingdom of Great Britain and Northern Ireland" ] = "United Kingdom"
un$cty[ un$cty == "United Republic of Tanzania" ] = "Tanzania, United Republic of"
un$cty[ un$cty == "United States of America" ] = "United States"

write_csv(
  full_join(
    read_csv("data/countrycode_data.csv"),
    rename(un, country_name = cty),
    by = "country_name"
  ),
  "countrycode_data.csv"
)

# Sanity check: all UN countries have been matched to a countrycode country
stopifnot(nrow(read_csv("countrycode_data.csv")) ==
            nrow(read_csv("data/countrycode_data.csv")))

# Fix encodings
countrycode_data <- as.data.frame(read_csv("countrycode_data_un.csv"))

Encoding(countrycode_data$un_name_en) = "UTF-8" # required by "Côte D'Ivoire"
countrycode_data$un_name_en <- iconv(countrycode_data$un_name_en, to = "UTF-8")
Encoding(countrycode_data$un_name_fr) = "UTF-8"
countrycode_data$un_name_fr <- iconv(countrycode_data$un_name_fr, to = "UTF-8")
Encoding(countrycode_data$un_name_es) = "UTF-8"
countrycode_data$un_name_es <- iconv(countrycode_data$un_name_es, to = "UTF-8")
Encoding(countrycode_data$un_name_ru) = "UTF-8"
countrycode_data$un_name_ru <- iconv(countrycode_data$un_name_ru, to = "UTF-8")
Encoding(countrycode_data$un_name_zh) = "UTF-8"
countrycode_data$un_name_zh <- iconv(countrycode_data$un_name_zh, to = "UTF-8")
Encoding(countrycode_data$un_name_ar) = "UTF-8"
countrycode_data$un_name_ar <- iconv(countrycode_data$un_name_ar, to = "UTF-8")

save(countrycode_data, file = "countrycode_data_un.rda")

# mv countrycode_data_un.csv data/countrycode_data_un.csv
# mv countrycode_data_un.rda data/countrycode_data_un.rda
