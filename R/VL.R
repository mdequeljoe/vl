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

VL <- R6::R6Class("VL", public = list(spec = list()))
VL$set("private", "nest", function(l){
  for (i in length(l):2){
    len <- length(l[[i - 1]])
    l[[i - 1]][[len]][names(l)[i]] <- l[i]
  }
  l[1]
})
VL$set("private", "open", list())
VL$set("private", "inner", list())
VL$set("private", "update_open", function(){
  len <- length(private$open)
  len_inner <- length(private$open[[len]]) + 1
  private$open[[len]][[len_inner]] <- private$inner
})
VL$set("private", "add_composition", function(l){
  #check if first composition
  if (length(names(private$open))){
    private$update_open()
  } else {
    self$spec <- append(self$spec, private$inner)
  }
  private$open <- append(private$open, l)
  private$inner <- list()
})
VL$set("private", "add", function(l){
  #has a composition?
  if (length(names(private$open))){
    #start a new list if we've seen this prop
    if (names(l) %in% names(private$inner)){
      private$update_open()
      private$inner <- list()
    }
  }

  if (names(l) %in% vl_prop$encoding){
    if (length(private$inner$encoding)){
      private$inner$encoding <- append(private$inner$encoding, l)
    } else{
      private$inner$encoding <- l
    }
  } else {
    private$inner <- append(private$inner, l)
  }
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
  self$spec <- append(self$spec, private$open)
  private$open <- list()
  invisible(self)
})

VL$set("private", "update", function(){
  if (length(private$open))
    private$exit()
  else
    self$spec <- append(self$spec, private$inner)
})

VL$set("public", "print", function(){
    print(self$spec)
    print(private$inner)
    print(private$open)
    invisible(self)
})

VL$set("public", "plot", function(){
  private$update()
  plot_vl(self$spec)
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

#view_spec
for (i in vl_prop$view_spec){
  VL$set("public", i, function(...){
    l <- list(list(...))
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



