library(siteconfig)

old <- Sys.getenv("NO_INTERNET", NA_character_)

Sys.setenv(NO_INTERNET = "true");  stopifnot(isTRUE(no_internet()))
Sys.setenv(NO_INTERNET = "false"); stopifnot(isFALSE(no_internet()))
Sys.unsetenv("NO_INTERNET");       stopifnot(isFALSE(no_internet()))

if (!is.na(old)) Sys.setenv(NO_INTERNET = old)
