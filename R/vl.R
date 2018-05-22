vl_prop = list(
  view_spec = c('description', 'title', 'width', 'height', 'name', '$schema',
                'background', 'padding', 'autosize', 'config', 'selection',
                 'facet','resolve', 'transform', 'projection'),
  compose = c('layer', 'hconcat', 'vconcat'),
  mark = c('area', 'bar', 'circle', 'line', 'point', 'rect', 'rule', 'square',
           'text', 'tick', 'geoshape', 'trail', 'box_plot'),
  encoding = c('x', 'y', 'x2', 'y2', 'color', 'opacity', 'size', 'shape',
               'label', 'tooltip', 'href', 'order', 'detail', 'row', 'column')
)

#' vl, a Vega-Lite environment
#'
#' Provides an interface to building Vega-Lite JSON specifications that stays close
#' to the underlying JSON syntax. In this way, vl can be used to write specifications
#' in a short-form notation.
#'
#' @section Usage:
#' \preformatted{v <- vl()}
#' @section Methods:
#' \subsection{data}
#' Data can be attached to the current view via \code{data} as a dataframe,
#' local file, or url. To refer to a vega dataset url,
#' prefix the file name with \code{!}, for instance, $data("!cars.json").
#' \subsection{view specification}{
#'  hi \code{rar()}
#' }
#' @name vl
#' @examples
#' \dontrun{
#' v <- vl()
#' v$data(mtcars)$
#'   point()$
#'     x("mpg:Q")$
#'     y("hp")$
#'   plot()
#' }
#'
NULL

#' @export
vl <- function() VL$new()
VL <- R6::R6Class("VL")

