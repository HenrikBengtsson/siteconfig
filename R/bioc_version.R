#' Infer the Default Bioconductor Version
#'
#' The version is inferred, in order, from:
#'
#' 1. environment variable `R_BIOC_VERSION`
#' 2. the version of the installed 'BiocVersion' package
#' 3. `BiocManager::version()`
#' 4. a curated table mapping the R version to a Bioconductor version
#'
#' @param rver The R version to map from in the last step.
#'
#' @return A [base::package_version] object, e.g. `3.23`.
#'
#' @examples
#' bioc_version()
#'
#' @export
bioc_version <- function(rver = getRversion()) {
  v <- Sys.getenv("R_BIOC_VERSION")
  if (!nzchar(v)) v <- bioc_version_from_BiocVersion()
  if (!nzchar(v)) v <- bioc_version_from_BiocManager()
  if (!nzchar(v)) v <- bioc_version_from_rver(rver)

  biocver <- package_version(v, strict = FALSE)
  if (is.na(biocver)) {
    stop(sprintf("Failed to infer Bioconductor version (from string %s). If set, make sure environment variable 'R_BIOC_VERSION' is a valid version: %s", sQuote(v), sQuote(Sys.getenv("R_BIOC_VERSION"))), call. = FALSE)
  }
  ## Normalize to <major>.<minor>
  package_version(sprintf("%d.%d", biocver$major, biocver$minor))
}

bioc_version_from_BiocVersion <- function() {
  tryCatch({
    as.character(utils::packageVersion("BiocVersion")[, 1:2])
  }, error = function(e) "")
}

bioc_version_from_BiocManager <- function() {
  if (!requireNamespace("BiocManager", quietly = TRUE)) return("")
  tryCatch({
    on.exit(unloadNamespace("BiocManager"))
    as.character(BiocManager::version())
  }, error = function(e) "")
}

bioc_version_from_rver <- function(rver) {
  rver <- package_version(rver)
  ## Lower bound on R version -> Bioconductor version
  table <- c(
    "4.6.0" = "3.23", ## 2026-04-29
    "4.5.2" = "3.22", ## 2025-10-30
    "4.5.0" = "3.21", ## 2025-04-16
    "4.4.2" = "3.20", ## 2024-10-30
    "4.4.0" = "3.19", ## 2024-05-01
    "4.3.2" = "3.18", ## 2023-10-25
    "4.3.0" = "3.17", ## 2023-04-26
    "4.2.2" = "3.16", ## 2022-11-02
    "4.2.0" = "3.15", ## 2022-04-27
    "4.1.1" = "3.14", ## 2021-10-27
    "4.1.0" = "3.13", ## 2021-05-20
    "4.0.3" = "3.12", ## 2020-10-28
    "4.0.0" = "3.11", ## 2020-04-28
    "3.6.1" = "3.10", ## 2019-10-30
    "3.6.0" = "3.9",
    "3.5.1" = "3.8",
    "3.5.0" = "3.7",
    "3.4.2" = "3.6",
    "3.4.0" = "3.5",
    "3.3.1" = "3.4",
    "3.3.0" = "3.3",
    "3.2.2" = "3.2",
    "3.2.0" = "3.1",
    "0.0.0" = "3.0"
  )
  for (kk in seq_along(table)) {
    if (rver >= names(table)[kk]) return(table[[kk]])
  }
  
  "3.0"
}
