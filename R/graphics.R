#' Use an alternative graphics device if X11 is not available
#'
#' @return Nothing (`NULL`, invisibly). Called for its side effect of setting
#' option `bitmapType` to `"cairo"` when X11 is unavailable but cairo is.
#'
#' @export
use_graphics <- function() {
  if (!capabilities("X11")) {
    if (capabilities("cairo")) {
      options(bitmapType = "cairo")
    }
  }
  invisible(NULL)
}
