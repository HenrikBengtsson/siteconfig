## use() sets options and unloads the package, unless it is attached
rscript <- file.path(R.home("bin"), "Rscript")
run <- function(expr) {
  out <- system2(rscript, c("-e", shQuote(expr)), stdout = TRUE, stderr = FALSE)
  trimws(tail(out, 1L))
}

res <- run('siteconfig::use(offline = FALSE); cat(is.character(getOption("repos")), "siteconfig" %in% loadedNamespaces())')
stopifnot(identical(res, "TRUE FALSE"))

res <- run('library(siteconfig); use(offline = FALSE); cat("siteconfig" %in% loadedNamespaces())')
stopifnot(identical(res, "TRUE"))
