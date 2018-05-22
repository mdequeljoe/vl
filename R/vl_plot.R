#' @import htmlwidgets
#'
plot_vl <- function(spec, embed_opt = NULL) {

  spec <- check_vl_spec(spec)

  if (is.null(embed_opt))
    embed_opt <- list(actions = FALSE)

  if (is.null(embed_opt$actions))
    embed_opt$actions <- FALSE

  params = list(
    spec = jsonlite::toJSON(spec, auto_unbox = TRUE),
    embed_opt = embed_opt
  )

  htmlwidgets::createWidget(
    name = 'vl',
    params,
    package = 'vl'
  )
}

check_vl_spec <- function(spec){

  if (is.null(spec$`$schema`))
    spec$`$schema` <- "https://vega.github.io/schema/vega-lite/v2.json"

  #check for dots .
  if (is.data.frame(spec$data$values))
    if (any(grepl("\\.", colnames(spec$data$values))))
      spec <- rm_dots(spec, colnames(spec$data$values))

  spec
}

#' Shiny bindings for vl
#'
#' Output and render functions for using vl within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a vl environment
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name vl-shiny
#'
#' @export
vlOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'vl', width, height, package = 'vl')
}

#' @rdname vl-shiny
#' @export
renderVl <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, vlOutput, env, quoted = TRUE)
}
