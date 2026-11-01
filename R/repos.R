#' Locate the Root of the Local CRAN and Bioconductor Mirrors
#'
#' The root folder is taken from environment variable `R_REPOS_ROOT`.
#' If not set, known cluster locations are tried.
#'
#' @return A path, or `NA_character_` if no existing mirror root was found.
#'
#' @examples
#' local_mirror_root()
#'
#' @importFrom utils file_test
#' @export
local_mirror_root <- function() {
  root <- Sys.getenv("R_REPOS_ROOT", NA_character_)
  if (is.na(root)) {
    ## HARDCODED:
    path <- "/mnt/software/cbi/mirrors/r-mirrors"
    if (file_test("-d", path)) {
      root <- path
    }
  }
  if (!is_dir(root)) return(NA_character_)
  normalizePath(root, mustWork = TRUE)
}

#' Default CRAN and Bioconductor Repositories
#'
#' With internet access, the standard remote repositories are used. Without
#' internet access (see [no_internet()]), repositories are redirected to
#' local mirrors on the file system (see [local_mirror_root()]), and any
#' remaining remote `http(s)://` repositories are dropped.
#'
#' @param repos Repositories to start from.
#'
#' @param biocver The Bioconductor version.
#'
#' @param offline Whether there is no internet access.
#'
#' @return A named character vector with CRAN first.
#'
#' @section Side effects:
#' Without internet access, environment variable `R_BIOC_MIRROR` is set when
#' the corresponding local files exist and the variables are not already set.
#'
#' @examples
#' default_repos()
#'
#' @export
default_repos <- function(repos = getOption("repos"), biocver = bioc_version(),
                          offline = no_internet()) {
  biocver <- package_version(biocver)
  repos <- c(repos, known_repos(), CRAN = "https://cloud.r-project.org")
  repos <- repos[!is.na(repos) & !grepl("^@.*@$", repos)]
  repos <- repos[!grepl("(CRANextra|R-Forge|rforge.net)", names(repos))]

  if (biocver >= "3.6") repos <- repos[names(repos) != "BioCextra"]
  if (biocver >= "3.7" && "BioCsoft" %in% names(repos)) {
    repos[["BioCworkflows"]] <- sub("bioc$", "workflows", repos[["BioCsoft"]])
  }

  ## Bring CRAN to the front; keep first of each named repository
  repos <- repos[!(nzchar(names(repos)) & duplicated(names(repos)))]
  idx <- match("CRAN", names(repos))
  if (!is.na(idx)) repos <- c(repos[idx], repos[-idx])

  if (getRversion() < "3.2.2") repos <- gsub("https://", "http://", repos, fixed = TRUE)

  if (offline) repos <- local_repos(repos, biocver)
  repos
}

local_repos <- function(repos, biocver) {
  root <- local_mirror_root()
  if (is.na(root)) return(repos)

  uri <- function(...) {
    path <- file.path(root, ...)
    if (is_dir(path)) sprintf("file://%s", normalizePath(path)) else NULL
  }

  if (!is.null(u <- uri("cran"))) repos[["CRAN"]] <- u

  bioc <- file.path(root, "bioconductor")
  if (is_dir(bioc)) {
    path <- file.path(bioc, "packages")
    if (is_dir(path) && is.na(Sys.getenv("R_BIOC_MIRROR", NA_character_))) {
      Sys.setenv(R_BIOC_MIRROR = path)  ## used by 'remotes'
    }
    ver <- as.character(biocver)
    if (!is.null(u <- uri("bioconductor", ver, "bioc"))) repos[["BioCsoft"]] <- u
    if (!is.null(u <- uri("bioconductor", ver, "data", "annotation"))) repos[["BioCann"]] <- u
    if (!is.null(u <- uri("bioconductor", ver, "data", "experiment"))) repos[["BioCexp"]] <- u
    if (!is.null(u <- uri("bioconductor", ver, "workflows"))) repos[["BioCworkflows"]] <- u
  }

  ## Remote repositories cannot be reached; some tools (e.g. revdepcheck)
  ## error out on unreachable repositories
  repos <- repos[!grepl("^https?://", repos)]

  repos
}

#' Set the Default CRAN and Bioconductor Repositories
#'
#' Sets option `repos` to [default_repos()] and environment variable
#' `R_BIOC_VERSION` to [bioc_version()]. Call from `Rprofile.site`, e.g.
#' `if (!nzchar(Sys.getenv("R_CMD"))) siteconfig::use_repos()`.
#'
#' @param ... Arguments passed to [default_repos()].
#'
#' @return Invisibly, the previous `repos` option.
#'
#' @export
use_repos <- function(...) {
  biocver <- bioc_version()
  Sys.setenv(R_BIOC_VERSION = as.character(biocver))
  old <- options(repos = default_repos(biocver = biocver, ...))
  invisible(old[["repos"]])
}

is_dir <- function(path) isTRUE(file.info(path)$isdir)

## Repositories known to R, e.g. from ~/.R/repositories
known_repos <- function() {
  p <- file.path(Sys.getenv("HOME"), ".R", "repositories")
  if (!file.exists(p)) p <- file.path(R.home("etc"), "repositories")
  if (!file.exists(p)) return(character(0))
  ## Moved from 'tools' to 'utils' in R (>= 4.3.0)
  reader <- NULL
  for (pkg in c("tools", "utils")) {
    ns <- getNamespace(pkg)
    if (exists(".read_repositories", envir = ns, inherits = FALSE)) {
      reader <- get(".read_repositories", envir = ns, inherits = FALSE)
      break
    }
  }
  if (is.null(reader)) return(character(0))
  a <- tryCatch(reader(p), error = function(e) NULL)
  if (is.null(a)) return(character(0))
  repos <- a$URL
  names(repos) <- rownames(a)
  repos
}
