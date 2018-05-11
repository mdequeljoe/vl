vl_prop = list(
  view_spec = c('description', 'title', 'width', 'height', 'name', '$schema',
                'background', 'padding', 'autosize', 'config', 'selection','
                 facet','repeat'),
  compose = c('layer', 'hconcat', 'vconcat'),
  mark = c('area', 'bar', 'circle', 'line', 'point', 'rect', 'rule', 'square',
           'text', 'tick', 'geoshape'),
  encoding = c('x', 'y', 'x2', 'y2', 'color', 'opacity', 'size', 'shape',
               'label', 'tooltip', 'href', 'order', 'detail', 'row', 'column')
)

this_call <- function() {
  call <- gsub("\\(\\)", "", as.character(sys.call(which = -1L)))
  gsub(".+\\$(.+)", "\\1", call[1])
}

#'
#' @export
vl <- function() VL$new()

VL <- R6::R6Class("VL", public = list(spc = list()))

VL$set("private", "nest", function(l){
  for (i in length(l):2){
    len <- length(l[[i - 1]])
    l[[i - 1]][[len]][names(l)[i]] <- l[i]
  }
  l[1]
})

VL$set("private", "as_spec", function(){
  idx <- which(names(l) == "spec") + 1
  private$inner$spec <- private$inner[idx:length(private$inner)]
  private$inner <- private$inner[1:(idx - 1)]
})

VL$set("private", "open", list())
VL$set("private", "inner", list())

VL$set("private", "update_open", function(){
  if ("spec" %in% names(private$inner) && !length(private$inner$spec))
    private$as_spec()
  len <- length(private$open)
  len_inner <- length(private$open[[len]]) + 1
  private$open[[len]][[len_inner]] <- private$inner
})

VL$set("private", "add_composition", function(l){
  #check if first composition
  if (length(private$open)){
    private$update_open()
  } else {
    self$spc <- append(self$spc, private$inner)
  }
  private$open <- append(private$open, l)
  private$inner <- list()
})

VL$set("private", "add", function(l){
  #has a composition?
  if (length(private$open)){
    #start a new list if we've seen this prop before
    if (names(l) %in% names(private$inner)){
      private$update_open()
      private$inner <- list()
    }
  }

  if (names(l) %in% vl_prop$encoding)
    private$inner$encoding <- append(private$inner$encoding, l)
  else
    private$inner <- append(private$inner, l)

})

VL$set("public", "exit_layer", function(){
  private$update_open()
  private$inner <- list()

  if (length(private$open) > 1)
    private$open <- private$nest(private$open)
  invisible(self)
})

VL$set("private", "exit", function(){
  self$exit_layer()
  self$spc <- append(self$spc, private$open)
  private$open <- list()
  invisible(self)
})

VL$set("private", "update", function(){

  if ("spec" %in% names(private$inner) && !length(private$inner$spec))
    private$as_spec()

  if (length(private$open))
    private$exit()
  else
    self$spc <- append(self$spc, private$inner)
})

VL$set("public", "print", function(){
    print(self$spc)
    print(private$inner)
    print(private$open)
    invisible(self)
})

VL$set("public", "plot", function(){
  private$update()
  plot_vl(self$spc)
})

#transform
VL$set("public", "transform", function(...){
  if (any(!sapply(list(...), is.list)))
    stop("$transform accepts lists only", call. = FALSE)
  private$add(list(transform = list(...)))
  invisible(self)
})

#data
VL$set("public", "data", function(data){
  if (is.character(data))
    l <- list(data = list(url = data))
  else
    l <- list(data = list(values = data))
  private$add(l)
  invisible(self)
})

#marks
for (i in vl_prop$mark){
  VL$set("public", i, function(...){
    if (length(list(...))){
      l <- list(...)
      l$type <- this_call()
      l <- list(mark = l)
    } else {
      l <- list(mark = this_call())
    }
    private$add(l)
    invisible(self)
  })
}

#encoding
for (i in vl_prop$encoding){
  VL$set("public", i, function(...){
    l <- list(list(...))
    names(l) <- this_call()
    private$add(l)
    invisible(self)
  })
}

#view_spc
for (i in vl_prop$view_spec){
  VL$set("public", i, function(x){
    l <- list(x)
    names(l) <- this_call()
    private$add(l)
    invisible(self)
  })
}

#marks
for (i in vl_prop$compose){
  VL$set("public", i, function(){
    l <- list(list())
    names(l) <- this_call()
    private$add_composition(l)
    invisible(self)
  })
}

#repeat
VL$set("public", "repeat_row", function(x){
  l <- list('repeat' = list(row = x))
  private$add(l)
  invisible(self)
})

#repeat
VL$set("public", "repeat_column", function(y){
  l <- list('repeat' = list(column = y))
  private$add(l)
  invisible(self)
})

#repeat
VL$set("public", "repeat_row_column", function(x, y){
  l <- list('repeat' = list(row = x, column = y))
  private$add(l)
  invisible(self)
})

VL$set("public", "spec", function(){
  l <- list(list())
  names(l) <- "spec"
  private$add(l)
  invisible(self)
})

# VL$set("public", "spec", function(){
#   if (length(private$inner)){
#     if (length(private$open))
#       private$update_open()
#     else
#       self$spc <- append(self$spc, private$inner)
#     private$inner <- list()
#   }
#   private$as_spec <- TRUE
#   invisible(self)
# })

