shared_fixture_path <- function(name) {
  path <- system.file("extdata", name, package = "countrycode")
  if (!nzchar(path)) {
    path <- testthat::test_path("..", "..", "inst", "extdata", name)
  }
  path
}

read_shared_fixture <- function(name) {
  yaml::read_yaml(shared_fixture_path(name))
}
