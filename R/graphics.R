#' Use an alternative graphics device if X11 is not available
#' 
#' @export
use_graphics <- function() {
  if (!capabilities("X11")) {
    if (capabilities("cairo")) {
      options(bitmapType = "cairo")
    }
  }
}
