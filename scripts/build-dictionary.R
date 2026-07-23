project_dir <- here::here()
setwd(project_dir)

dictionary_dir <- file.path(project_dir, "dictionary")
package_data_dir <- file.path(project_dir, "r", "data")
python_data_dir <- file.path(project_dir, "python", "countrycode", "data")

source(file.path(dictionary_dir, "utilities.R"))


##################
#  availability  #
##################

scrapers <- Sys.glob(file.path(dictionary_dir, "get_*.R"))
datasets <- Sys.glob(file.path(dictionary_dir, "data_*.csv"))
datasets <- setdiff(
  datasets,
  file.path(
    dictionary_dir,
    c("data_regex.csv", "data_small_countries.csv", "data_telephone.csv")
  )
)

# missing scrapers and datasets
tokens_datasets <- str_replace_all(datasets, '.*data_|.csv', '')
tokens_scrapers <- str_replace_all(scrapers, '.*get_|.R', '')
tokens_scrapers <- setdiff(
  tokens_scrapers,
  c("countryname_dict", "small_countries", "telephone", "vdem")
)

if (length(setdiff(tokens_scrapers, tokens_datasets)) > 0) {
  msg <- paste(setdiff(tokens_scrapers, tokens_datasets), collapse = ', ')
  msg <- paste('Missing datasets:', msg)
  stop(msg)
}

if (length(setdiff(tokens_datasets, tokens_scrapers)) > 0) {
  msg <- paste(setdiff(tokens_datasets, tokens_scrapers), collapse = ', ')
  msg <- paste('Missing scrapers:', msg)
  warning(msg)
}


###############
#  load data  #
###############

dat <- list()
dat$regex <- read_csv(
  file.path(dictionary_dir, "data_regex.csv"),
  col_types = cols(),
  progress = FALSE
)

message("Load:")
for (i in seq_along(datasets)) {
  message("  ", tokens_datasets[i])
  tmp <- read_csv(
    datasets[i],
    col_types = cols(),
    na = "",
    progress = FALSE
  ) %>%
    mutate(
      country = utf8::utf8_encode(country),
      country.name.en.regex = CountryToRegex(country)
    ) %>%
    select(-country)
  SanityCheck(tmp)
  dat[[tokens_datasets[i]]] <- tmp
}

# Expand the canonical small-country event history into country-year rows.
source(file.path(dictionary_dir, "get_small_countries.R"))
tmp <- out %>%
  mutate(country.name.en.regex = CountryToRegex(country)) %>%
  select(-country)
SanityCheck(tmp)
dat$small_countries <- tmp

# Normalize the canonical ITU telephone source into country-level codes.
source(file.path(dictionary_dir, "get_telephone.R"))
tmp <- telephone %>%
  mutate(country.name.en.regex = CountryToRegex(country)) %>%
  select(-country)
SanityCheck(tmp)
dat$telephone <- tmp

# Apply V-Dem name and territorial adjustments to the reduced source.
source(file.path(dictionary_dir, "get_vdem.R"))
tmp <- vdem %>%
  mutate(country.name.en.regex = CountryToRegex(country)) %>%
  select(-country)
SanityCheck(tmp)
dat$vdem <- tmp

# Namibia iso2c is not missing
dat$iso$iso2c[dat$iso$iso.name.en == 'Namibia'] <- 'NA'


###################
#  cross-section  #
###################

idx <- sapply(dat, function(x) !'year' %in% names(x))
cs <- dat[idx] %>%
  reduce(left_join, by = 'country.name.en.regex')

# sanity check
SanityCheck(cs)
checkmate::assert_true(nrow(cs) > 250)
checkmate::assert_true(ncol(cs) > 50)


###########
#  panel  #
###########

idx <- sapply(dat, function(x) 'year' %in% names(x))
pan <- dat[idx]
pan <- lapply(pan, ExtendCoverage, last_year = 2020)

cou <- sapply(pan, function(x) x$country.name.en.regex) %>% unlist %>% unique
yea <- sapply(pan, function(x) x$year) %>% unlist %>% unique
yea <- min(yea):max(yea)
rec <- expand_grid(country.name.en.regex = cou, year = yea)
pan <- c(list(rec), pan) %>%
  purrr::reduce(left_join, by = c('country.name.en.regex', 'year'))

idx <- (pan[, 3:ncol(pan)] %>% is.na %>% rowSums) != (ncol(pan) - 2)
pan <- pan[idx, ]

###########
#  merge  #
###########

# merge last panel observation into cs
tmp <- pan %>%
  arrange(country.name.en.regex, year) %>%
  group_by(country.name.en.regex) %>%
  mutate_at(vars(-group_cols()), zoo::na.locf, na.rm = FALSE) %>%
  filter(year %in% max(year)) %>%
  # arbitrary choices
  mutate(
    p5n = ifelse(p4.name %in% 'Prussia', NA, p5n),
    p5c = ifelse(p4.name %in% 'Prussia', NA, p5c),
    p5n = ifelse(p4.name %in% 'Serbia and Montenegro', NA, p5n),
    p5c = ifelse(p4.name %in% 'Serbia and Montenegro', NA, p5c),
    p4n = ifelse(p4.name %in% 'Prussia', NA, p4n),
    p4c = ifelse(p4.name %in% 'Prussia', NA, p4c),
    p4n = ifelse(p4.name %in% 'Serbia and Montenegro', NA, p4n),
    p4c = ifelse(p4.name %in% 'Serbia and Montenegro', NA, p4c),
    vdem = ifelse(vdem.name %in% 'Czechoslovakia', NA, vdem)
  )

cs <- cs %>%
  left_join(tmp, by = 'country.name.en.regex') %>%
  select(-year)

# english names with priority
priority <- c(
  'cldr.name.en',
  'iso.name.en',
  'un.name.en',
  'cow.name',
  'p4.name',
  'vdem.name',
  'country.name.en'
)
cs$country.name <- NA
for (i in priority) {
  cs$country.name <- ifelse(is.na(cs$country.name), cs[[i]], cs$country.name)
}
cs$country.name.en <- cs$country.name
cs$country.name <- NULL

# merge cs into pan
idx <- c('country.name.en.regex', setdiff(colnames(cs), colnames(pan)))
pan <- pan %>%
  left_join(cs[, idx], by = 'country.name.en.regex') %>%
  select(-matches('name$|cldr'))


###########
#  clean  #
###########

idx <- c('country.name.en.regex', setdiff(colnames(cs), colnames(pan)))

pan <- pan %>%
  arrange(country.name.en, year) %>%
  select(country.name.en, year, order(names(.))) %>%
  select(-matches('cldr|name$|iso.name|un.name'))

idx1 <- sort(grep('cldr', colnames(cs), value = TRUE))
idx2 <- sort(setdiff(colnames(cs), idx1))

cs <- cs[, c(idx2, idx1)] %>%
  arrange(country.name.en)


##########
#  utf8  #
##########

for (col in colnames(cs)[sapply(cs, class) == 'character']) {
  if (!all(na.omit(stringi::stri_enc_mark(cs[[col]])) == 'ASCII')) {
    cs[[col]] <- enc2utf8(cs[[col]])
  }
}

for (col in colnames(pan)[sapply(pan, class) == 'character']) {
  if (!all(na.omit(stringi::stri_enc_mark(pan[[col]])) == 'ASCII')) {
    pan[[col]] <- enc2utf8(pan[[col]])
  }
}


###########
##  save  #
###########

codelist <- cs
codelist_panel <- pan

save(
  codelist,
  file = file.path(package_data_dir, "codelist.rda"),
  compress = "xz",
  version = 2
)
save(
  codelist_panel,
  file = file.path(package_data_dir, "codelist_panel.rda"),
  compress = "xz",
  version = 2
)

# These uncompressed files are better for seeing diffs in version control
codelist_without_cldr <- codelist %>% select(-starts_with('cldr'))
codelist_panel_without_cldr <- codelist_panel %>% select(-starts_with('cldr'))

write_csv(
  codelist_without_cldr,
  file.path(dictionary_dir, "codelist_without_cldr.csv"),
  na = ""
)
write_csv(
  codelist_panel_without_cldr,
  file.path(dictionary_dir, "codelist_panel_without_cldr.csv"),
  na = ""
)

# Keep the Python package's compressed CSV synchronized with the R dictionary.
dir.create(python_data_dir, recursive = TRUE, showWarnings = FALSE)
write_csv(
  codelist,
  gzfile(file.path(python_data_dir, "codelist.csv.gz")),
  na = ""
)
write_csv(
  codelist_panel,
  gzfile(file.path(python_data_dir, "codelist_panel.csv.gz")),
  na = ""
)

# Supplementary datasets used by Python's countryname() and data loaders.
load(file.path(package_data_dir, "countryname_dict.rda"))
load(file.path(package_data_dir, "cldr_examples.rda"))
write_csv(
  countryname_dict,
  gzfile(file.path(python_data_dir, "countryname_dict.csv.gz")),
  na = ""
)
write_csv(
  cldr_examples,
  gzfile(file.path(python_data_dir, "cldr_examples.csv.gz")),
  na = ""
)
