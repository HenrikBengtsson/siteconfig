## cbi_libs_user() infers the CBI user library from R_HOME
ver <- sprintf("%s.%s", R.version$major, sub("[.].*", "", R.version$minor))
plat <- R.version$platform

res <- siteconfig::cbi_libs_user("/x/CBI/_rocky9/R-4.6.2-gcc13/lib/R")
stopifnot(identical(res, sprintf("~/R/rocky9-%s-library/%s-CBI-gcc13", plat, ver)))

res <- siteconfig::cbi_libs_user("/usr/lib64/R")
stopifnot(is.na(res))

## use_libpaths() respects a non-default R_LIBS_USER
Sys.setenv(R_LIBS_USER = tempdir())
old <- .libPaths()
siteconfig::use_libpaths("~/R/dummy")
stopifnot(identical(Sys.getenv("R_LIBS_USER"), tempdir()), identical(.libPaths(), old))

## ... but replaces R's default one
Sys.setenv(R_LIBS_USER = sprintf("~/R/%s-library/%s", plat, ver))
path <- file.path(tempdir(), "lib")
dir.create(path)
siteconfig::use_libpaths(path)
stopifnot(identical(Sys.getenv("R_LIBS_USER"), path), identical(.libPaths()[1], normalizePath(path)))
