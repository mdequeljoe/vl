#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export
vl <- function(spec, embed_opt = NULL, elementId = NULL, height = NULL, width = NULL) {
  
  if (is.character(spec)){

    if (!jsonlite::validate(spec)){
      #check if data value refers to R object
      if (grepl("data.*:.*values.*:[\n| ]*", spec)){
        data <- trimws(gsub(".*values.*:[\n| ]*(.*?)[\n| ]*}.*", "\\1", spec))
        spec <- gsub(data, "[]", spec)
      }

      cx <- V8::v8()
      spec <- cx$get(sprintf('JSON.stringify(%s)', spec))
    }
    
    spec <- jsonlite::fromJSON(spec)
    
    # retrieve data if R object
    if (!length(spec$data$values))
      spec$data$values <- eval(parse(text = data))
  }
  
  if (!length(spec$`$schema`))
    spec$`$schema` <- "https://vega.github.io/schema/vega-lite/v2.json"
  
  # replace '.' with space for variable names
  # need to also check other possibilites
  #  i.e. '..., "repeat" : {"Sepal.Width", ....}, ..."
  # what about url json ?
  encodings <- unlist(spec$encoding)
  if (any(grepl("\\.", encodings))){
    if ("values" %in% names(spec$data))
      colnames(spec$data$values) <- gsub("\\.", " ", colnames(spec$data$values))
    
    spec <- rm_dots(spec)
  }
  
  if (is.null(embed_opt))
    embed_opt <- list(actions = FALSE)
  
  if (!length(embed_opt$actions))
    embed_opt$actions <- FALSE
  
  params = list(
    spec = jsonlite::toJSON(spec, auto_unbox = TRUE),
    embed_opt = embed_opt
  )
  

  # create widget
  htmlwidgets::createWidget(
    name = 'vl',
    params,
    width = width,
    height = height,
    package = 'vl',
    elementId = elementId
  )
}

rm_dots <- function(l){
  lapply(l, function(m){
    if (is.list(m) && !is.data.frame(m)) {
      if ('field' %in% names(m)) {
        m$field <- gsub("\\.", " ", m$field)
        m
      } else
        rm_dots(m)
    } else
      m
  })
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
