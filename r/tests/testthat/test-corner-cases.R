context('Corner cases')


test_that("Issue #258", {
  expect_equal(
    codelist_panel[
      codelist_panel$country.name.en == "Germany" & codelist_panel$year == 1900,
    ]$gwn,
    255,
    ignore_attr = TRUE
  )
  expect_equal(
    codelist_panel[
      grepl("Korea", codelist_panel$country.name.en) &
        codelist_panel$year == 1900,
    ]$gwn,
    730
  )
})

test_that("Issue #320: GW historical polities are present with expected ranges", {
  cs <- countrycode::codelist
  pan <- countrycode::codelist_panel

  expected <- data.frame(
    gwn = c(89, 563, 564, 711, 815),
    gwc = c("UPC", "TRA", "OFS", "TBT", "VNM"),
    start = c(1823, 1852, 1854, 1913, 1816),
    end = c(1839, 1910, 1910, 1950, 1893),
    stringsAsFactors = FALSE
  )

  for (i in seq_len(nrow(expected))) {
    rec <- expected[i, ]

    idx_pan <- which(pan$gwc == rec$gwc & pan$gwn == rec$gwn)
    pan_i <- pan[idx_pan, , drop = FALSE]
    expect_gt(nrow(pan_i), 0)
    if (nrow(pan_i) == 0) {
      next
    }
    expect_equal(min(pan_i$year), rec$start)
    expect_equal(max(pan_i$year), rec$end)

    idx_cs <- which(cs$gwc == rec$gwc & cs$gwn == rec$gwn)
    cs_i <- cs[idx_cs, , drop = FALSE]
    expect_equal(nrow(cs_i), 1)
  }
})

# Issue #364: custom_match should suppress duplicate-match warnings
test_that("custom_match suppresses duplicate-match warning (AC1)", {
  expect_no_warning(
    countrycode(
      c("china_hong_kong_sar", "china_macao_sar"),
      "country.name",
      "iso3c",
      custom_match = c(
        "china_hong_kong_sar" = "HKG",
        "china_macao_sar" = "MAC"
      )
    )
  )
})

test_that("custom_match returns correct values for HK/Macau (AC1)", {
  expect_equal(
    suppressWarnings(countrycode(
      c("china_hong_kong_sar", "china_macao_sar"),
      "country.name",
      "iso3c",
      custom_match = c(
        "china_hong_kong_sar" = "HKG",
        "china_macao_sar" = "MAC"
      )
    )),
    c("HKG", "MAC")
  )
})

test_that("without custom_match HK/Macau still warn (AC2)", {
  expect_warning(
    countrycode(
      c("china_hong_kong_sar", "china_macao_sar"),
      "country.name",
      "iso3c"
    ),
    "matched more than once"
  )
})

test_that("partial custom_match warns only for non-overridden value (AC3)", {
  w <- tryCatch(
    countrycode(
      c("china_hong_kong_sar", "china_macao_sar"),
      "country.name",
      "iso3c",
      custom_match = c("china_hong_kong_sar" = "HKG")
    ),
    warning = function(w) w
  )
  expect_match(conditionMessage(w), "china_macao_sar")
  expect_false(grepl("china_hong_kong_sar", conditionMessage(w)))
})

test_that("non-ambiguous custom_match produces no warnings (AC4)", {
  expect_no_warning(
    countrycode(
      c("republic_of_korea", "isle_of_man"),
      "country.name",
      "iso3c",
      custom_match = c(
        "republic_of_korea" = "KOR",
        "isle_of_man" = "IMN"
      )
    )
  )
})
