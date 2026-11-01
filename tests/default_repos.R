library(siteconfig)

root <- tempfile("mirrors-")
dir.create(file.path(root, "cran"), recursive = TRUE)
dir.create(file.path(root, "bioconductor", "3.23", "bioc"), recursive = TRUE)

old <- Sys.getenv("R_REPOS_ROOT", NA_character_)
Sys.setenv(R_REPOS_ROOT = root)

## Offline: local file-system mirrors only
repos <- default_repos(biocver = "3.23", offline = TRUE)
stopifnot(
  identical(names(repos)[1], "CRAN"),
  grepl("^file://", repos[["CRAN"]]),
  grepl("^file://.*/3\\.23/bioc$", repos[["BioCsoft"]]),
  !any(grepl("^https?://", repos))
)

## Online: remote repositories
repos <- default_repos(biocver = "3.23", offline = FALSE)
stopifnot(grepl("^https?://", repos[["CRAN"]]))

## Default arguments
stopifnot(is.character(default_repos(biocver = "3.23")))

if (is.na(old)) Sys.unsetenv("R_REPOS_ROOT") else Sys.setenv(R_REPOS_ROOT = old)
