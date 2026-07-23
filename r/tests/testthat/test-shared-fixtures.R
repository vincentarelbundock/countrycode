test_that("shared name variations match", {
  expected_names <- read_shared_fixture("name-variations.yaml")

  for (expected in names(expected_names)) {
    for (source in expected_names[[expected]]) {
      actual <- countrycode(
        source,
        origin = "country.name",
        destination = "country.name",
        warn = FALSE
      )
      expect_equal(actual, expected)
    }
  }
})

test_that("shared conversion cases match", {
  origins <- read_shared_fixture("conversions.yaml")

  for (origin in names(origins)) {
    for (destination in names(origins[[origin]])) {
      cases <- origins[[origin]][[destination]]
      for (source in names(cases)) {
        source_value <- source
        if (origin %in% names(codelist) && is.numeric(codelist[[origin]])) {
          source_value <- as.integer(source)
        }
        actual <- countrycode(
          source_value,
          origin = origin,
          destination = destination,
          warn = FALSE
        )
        expected <- cases[[source]]
        if (is.null(expected)) {
          expect_true(is.na(actual))
        } else {
          expect_equal(actual, expected)
        }
      }
    }
  }
})

test_that("shared name nonmatches remain missing", {
  origins <- read_shared_fixture("name-nonmatches.yaml")

  for (origin in names(origins)) {
    for (destination in names(origins[[origin]])) {
      for (source in origins[[origin]][[destination]]) {
        actual <- countrycode(
          source,
          origin = origin,
          destination = destination,
          warn = FALSE
        )
        expect_true(is.na(actual))
      }
    }
  }
})

test_that("shared countryname cases match", {
  destinations <- read_shared_fixture("countryname.yaml")

  for (destination in names(destinations)) {
    cases <- destinations[[destination]]
    for (source in names(cases)) {
      actual <- countryname(source, destination = destination, warn = FALSE)
      expected <- cases[[source]]
      if (is.null(expected)) {
        expect_true(is.na(actual))
      } else {
        expect_equal(actual, expected)
      }
    }
  }
})
