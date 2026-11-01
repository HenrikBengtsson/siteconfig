#' Infer the CBI-Specific R User Library
#'
#' The CBI software stack installs R under
#' `.../CBI/_<os>/R-<version>-gcc<N>/`. R packages built with that R should
#' not be mixed with packages built by other R installations, so the `r`
#' module sets `R_LIBS_USER` to `~/R/<os>-%p-library/%v-CBI-gcc<N>`.
#' This function infers the same folder from the R installation itself, which
#' also works when the module environment is not available, e.g. in an
#' Open OnDemand RStudio session.
#'
#' @param home The R home folder.
#'
#' @return A path, or `NA_character_` if `home` is not a CBI installation.
#'
#' @examples
#' cbi_libs_user()
#' cbi_libs_user("/opt/CBI/_rocky9/R-4.6.2-gcc13/lib/R")
#'
#' @export
cbi_libs_user <- function(home = R.home()) {
  pattern <- "^.*/_([^/]+)/R-[[:digit:]]+[.][[:digit:]]+[.][[:digit:]]+(-gcc([[:digit:]]+))?(/lib/R|/lib64/R)?$"
  home <- sub("/+$", "", home)
  if (!grepl(pattern, home)) return(NA_character_)
  os <- sub(pattern, "\\1", home)
  gcc <- sub(pattern, "\\3", home)
  ver <- sprintf("%s.%s", R.version$major, sub("[.].*", "", R.version$minor))
  path <- sprintf("~/R/%s-%s-library/%s-CBI", os, R.version$platform, ver)
  if (nzchar(gcc)) path <- paste0(path, "-gcc", gcc)
  path
}

#' Use the CBI-Specific R User Library
#'
#' Sets `R_LIBS_USER` and updates [base::.libPaths()] so that R sessions that
#' did not get the module environment, e.g. Open OnDemand RStudio, use the
#' same user library as `module load CBI r`.
#'
#' Nothing is changed if `R_LIBS_USER` is set to something other than R's
#' default user library (or subfolders of it), or if R is not a CBI installation.
#'
#' @param path The user library. Default is [cbi_libs_user()].
#'
#' @return The previous `.libPaths()`, invisibly.
#'
#' @examples
#' \dontrun{
#' use_libpaths()
#' }
#'
#' @export
use_libpaths <- function(path = cbi_libs_user()) {
  old <- .libPaths()
  if (is.na(path)) return(invisible(old))

  ## Respect a non-default R_LIBS_USER, e.g. one set by the CBI module.
  ## Entries below R's default user library, e.g. a '_bioc-<version>'
  ## subfolder, are moved along with it.
  norm <- function(x) normalizePath(path.expand(x), winslash = "/", mustWork = FALSE)
  default <- norm(sprintf("~/R/%s-library/%s.%s", R.version$platform,
                          R.version$major, sub("[.].*", "", R.version$minor)))
  path <- norm(path)
  current <- Sys.getenv("R_LIBS_USER", "")
  libs <- path
  if (nzchar(current)) {
    libs <- norm(strsplit(current, split = .Platform$path.sep, fixed = TRUE)[[1]])
    is_default <- (libs == default | startsWith(libs, paste0(default, "/")))
    if (!all(is_default)) return(invisible(old))
    libs <- paste0(path, substring(libs, nchar(default) + 1L))
  }
  Sys.setenv(R_LIBS_USER = paste(libs, collapse = .Platform$path.sep))

  ## .libPaths() silently drops folders that do not exist yet
  libs <- libs[file_test("-d", libs)]
  .libPaths(c(libs, setdiff(old, libs)))
  invisible(old)
}
