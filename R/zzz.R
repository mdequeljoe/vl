#thanks to rstudio/r2d3 for idea/code

.onLoad <- function(...) {
  if (requireNamespace("knitr", quietly = TRUE)) {
    knit_engines <- get("knit_engines", envir = asNamespace("knitr"))
    knit_engines$set(vl = knit_vl)
  }
}