#' @import htmlwidgets
#'
plot_vl <- function(spec, embed_opt = NULL, elementId = NULL, height = NULL, width = NULL) {

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
    width = width,
    height = height,
    package = 'vl',
    elementId = elementId
  )
}

check_vl_spec <- function(spec){

  if (is.null(spec$`$schema`))
    spec$`$schema` <- "https://vega.github.io/schema/vega-lite/v2.json"

  #name fields and list types
  spec <- nm_fields(spec)
  spec <- set_types(spec)

  #check for dots .
  if (is.data.frame(spec$data$values))
    if (any(grepl("\\.", colnames(spec$data$values))))
      spec <- rm_dots(spec, colnames(spec$data$values))

  spec
}

spec_data <- function(l){

  el <- l[[1]][[1]]
  if (is.character(el) && has_url_prefix(el))
    names(l[[1]]) <- "url"
  else
    names(l[[1]]) <- "values"
  #is a local file
  if (is.character(l$data$values)){
    l$data$values <- ext_as_df(l$data$values)
  }
  # is a vega dataset?
  if (!is.null(l$data$url) && grepl("^!", l$data$url))
    l$data$url <- gsub("!", "https://vega.github.io/vega-datasets/data/", l$data$url)
  l
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
#' @param expr An expression that generates a vl
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
