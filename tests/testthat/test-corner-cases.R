context('Corner cases')


test_that("Issue #258", {
    expect_equal(
        codelist_panel[codelist_panel$country.name.en == "Germany" & codelist_panel$year == 1900,]$gwn,
        255,
        ignore_attr = TRUE)
    expect_equal(
        codelist_panel[grepl("Korea", codelist_panel$country.name.en) & codelist_panel$year == 1900,]$gwn,
        730)
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
        if (nrow(pan_i) == 0) next
        expect_equal(min(pan_i$year), rec$start)
        expect_equal(max(pan_i$year), rec$end)

        idx_cs <- which(cs$gwc == rec$gwc & cs$gwn == rec$gwn)
        cs_i <- cs[idx_cs, , drop = FALSE]
        expect_equal(nrow(cs_i), 1)
    }
})

test_that("Issue #320: GW historical code conversion", {
    expect_equal(89, countrycode("UPC", "gwc", "gwn"))
    expect_equal(563, countrycode("TRA", "gwc", "gwn"))
    expect_equal(564, countrycode("OFS", "gwc", "gwn"))
    expect_equal(711, countrycode("TBT", "gwc", "gwn"))
    expect_equal(815, countrycode("VNM", "gwc", "gwn"))
    expect_equal(817, countrycode("RVN", "gwc", "gwn"))

    expect_equal("UPC", countrycode(89, "gwn", "gwc"))
    expect_equal("TRA", countrycode(563, "gwn", "gwc"))
    expect_equal("OFS", countrycode(564, "gwn", "gwc"))
    expect_equal("TBT", countrycode(711, "gwn", "gwc"))
    expect_equal("VNM", countrycode(815, "gwn", "gwc"))
    expect_equal("RVN", countrycode(817, "gwn", "gwc"))
})


test_that("UN spanish name is Trinidad y Tabago: Issue #299", {
    expect_equal(countrycode("Trinidad and Tobago", "country.name", "un.name.es"), "Trinidad y Tabago")
})


test_that("Issue #244", {
    expect_equal(countrycode('.de', 'cctld', 'country.name'), "Germany")
})


test_that('Namibia iso2c is not converted to NA', {
    expect_equal('NA', countrycode("Namibia", 'country.name', 'iso2c'))
    expect_equal('NA', countrycode("Namibia", 'country.name', 'genc2c'))
    expect_equal('NA', countrycode("Namibia", 'country.name', 'eurostat'))
    expect_equal('NA', countrycode("Namibia", 'country.name', 'wb_api2c'))
    expect_equal('NA', countrycode("Namibia", 'country.name', 'ecb'))
})

test_that("Viet Nam variations", {
  expect_equal("RVN", countrycode("Republic of Viet Nam", "country.name", "cowc"))
  expect_equal("RVN", countrycode("Republic of VietNam", "country.name", "cowc"))
  expect_equal("RVN", countrycode("South VietNam", "country.name", "cowc"))
  expect_equal("DRV", countrycode("Democratic Republic of VietNam", "country.name", "cowc"))
  expect_equal("DRV", countrycode("Democratic Republic of Viet Nam", "country.name", "cowc"))
  expect_equal("DRV", countrycode("North Viet Nam", "country.name", "cowc"))

  expect_equal(35, countrycode("Republic of VietNam", "country.name", "vdem"))
  expect_equal(34, countrycode("Democratic Republic of Viet Nam", "country.name", "vdem"))
  expect_equal(34, countrycode("VietNam", "country.name", "vdem"))
})

test_that("bangladesh", {
    expect_equal(
        countrycode("Bangladesh", "country.name.de", "iso3c"),
        "BGD")
    expect_equal(
        countrycode("Bangladesch", "country.name.de", "iso3c"),
        "BGD")
})

test_that("netherlands", {
    expect_equal(
        countrycode("Holland", "country.name", "country.name"),
        "Netherlands")
    expect_equal(
        countrycode("Hollande", "country.name.fr", "country.name"),
        "Netherlands")
    expect_equal(
        countrycode("Niederländische Antillen", "country.name.de", "country.name.en"),
        "Netherlands Antilles")
    expect_equal(
        countrycode("Karibische Niederlande", "country.name.de", "country.name.en"),
        "Caribbean Netherlands")
    expect_equal(
        countrycode("Caraibi olandesi", "country.name.it", "country.name.en"),
        "Caribbean Netherlands")
})


test_that("macedonia", {
    expect_equal(
        countrycode("Macédoine du Nord", "country.name.fr", "country.name.en"),
        "North Macedonia")
    expect_equal(
        countrycode("FYROM", "country.name.fr", "country.name.en"),
        "North Macedonia")
})



test_that("misc", {
    expect_equal(
        countrycode("Sint Maarten", "country.name.de", "iso3c"),
        "SXM")
    expect_equal(
        countrycode("Aruba", "country.name.de", "iso3c"),
        "ABW")
    expect_equal(
        countrycode("Curaçao", "country.name.de", "iso3c"),
        "CUW")
})


# Issue #364: custom_match should suppress duplicate-match warnings
test_that("custom_match suppresses duplicate-match warning (AC1)", {
    expect_no_warning(
        countrycode(
            c("china_hong_kong_sar", "china_macao_sar"),
            "country.name", "iso3c",
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
            "country.name", "iso3c",
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
        countrycode(c("china_hong_kong_sar", "china_macao_sar"), "country.name", "iso3c"),
        "matched more than once"
    )
})

test_that("partial custom_match warns only for non-overridden value (AC3)", {
    w <- tryCatch(
        countrycode(
            c("china_hong_kong_sar", "china_macao_sar"),
            "country.name", "iso3c",
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
            "country.name", "iso3c",
            custom_match = c(
                "republic_of_korea" = "KOR",
                "isle_of_man" = "IMN"
            )
        )
    )
})


test_that("Turkey regex matches dotted capital \u0130 spelling", {
    x <- c("Turkey", "Turkiye", "T\u00fcrkiye", "T\u00dcRK\u0130YE")
    out <- countrycode(x, "country.name", "country.name", warn = FALSE)
    expect_equal(out, rep("Turkey", length(x)))
})
