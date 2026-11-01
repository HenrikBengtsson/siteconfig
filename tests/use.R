## Attaching the package sets options and R_LIBS_USER; loading does not
rscript <- file.path(R.home("bin"), "Rscript")
run <- function(expr) {
  out <- system2(rscript, c("-e", shQuote(expr)), stdout = TRUE, stderr = FALSE)
  trimws(tail(out, 1L))
}

res <- run('library(siteconfig); cat(is.character(getOption("repos")))')
stopifnot(identical(res, "TRUE"))

res <- run('options(repos = NULL); loadNamespace("siteconfig"); cat(is.null(getOption("repos")))')
stopifnot(identical(res, "TRUE"))
