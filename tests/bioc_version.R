library(siteconfig)

old <- Sys.getenv("R_BIOC_VERSION", NA_character_)

Sys.setenv(R_BIOC_VERSION = "3.19.1")
stopifnot(identical(as.character(bioc_version()), "3.19"))

Sys.setenv(R_BIOC_VERSION = "nonsense")
res <- tryCatch(bioc_version(), error = identity)
stopifnot(inherits(res, "error"))

from_rver <- siteconfig:::bioc_version_from_rver
stopifnot(
  identical(from_rver("4.6.0"), "3.23"),
  identical(from_rver("4.5.1"), "3.21"),
  identical(from_rver("3.1.0"), "3.0")
)

if (is.na(old)) Sys.unsetenv("R_BIOC_VERSION") else Sys.setenv(R_BIOC_VERSION = old)
