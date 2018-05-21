vl_prop = list(
  view_spec = c('description', 'title', 'width', 'height', 'name', '$schema',
                'background', 'padding', 'autosize', 'config', 'selection','
                 facet','resolve', 'transform'),
  compose = c('layer', 'hconcat', 'vconcat'),
  mark = c('area', 'bar', 'circle', 'line', 'point', 'rect', 'rule', 'square',
           'text', 'tick', 'geoshape', 'trail'),
  encoding = c('x', 'y', 'x2', 'y2', 'color', 'opacity', 'size', 'shape',
               'label', 'tooltip', 'href', 'order', 'detail', 'row', 'column')
)

this_call <- function() {
  call <- gsub("\\(\\)", "", as.character(sys.call(which = -1L)))
  gsub(".+\\$(.+)", "\\1", call[1])
}


#' vl, a Vega-Lite environment
#'
#' Provides an interface to building Vega-Lite JSON specifications
#'
#' @section Usage:
#' \preformatted{
#' v <- vl()
#' v$data(mtcars)$
#'   point()$
#'     x("mpg:Q")$
#'     y("hp")$plot()
#' }
#'


#' @export
vl <- function() VL$new()
VL <- R6::R6Class("VL")

