#' Check Whether the Current Compute Environment Has No Internet Access
#'
#' The decision is made from environment variable `NO_INTERNET`. If
#' `true`, there is no internet, If `false`, there is internet.
#' If not set, it is assumed there is internet.
#'
#' @return `TRUE` or `FALSE`.
#'
#' @examples
#' no_internet()
#'
#' @export
no_internet <- function() {
  value <- Sys.getenv("NO_INTERNET", NA_character_)
  if (is.na(value)) return(FALSE)
  identical(toupper(value), "TRUE")
}
