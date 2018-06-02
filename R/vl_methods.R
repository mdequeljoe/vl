VL$set("private", "embed_opt", list())
VL$set("private", "spc", list())
VL$set("private", "open", list())
VL$set("private", "inner", character(0))
VL$set("private", "add_compose", function(l){
  #push contents of inner list
  #check if first composition
  if (length(private$open)){
    private$open <- update_spec(private$open, private$inner)
  } else {
    private$spc <- append(private$spc, private$inner)
  }
  private$open <- append(private$open, l)
  private$inner <- character(0)
})

VL$set("private", "add_prop", function(l){
  # is a composition open?
  if (length(private$open)){
    #start a new list if we've seen this prop before
    if (names(l) %in% names(private$inner)){
      private$open <- update_spec(private$open, private$inner)
      private$inner <- character(0)
    }
  }
  private$inner <- append(private$inner, l)
})

VL$set("private", "check_inner", function(){
  if (length(private$inner)){
    private$open <- update_spec(private$open, private$inner)
    private$inner <- character(0)
  }
})

VL$set("public", "embed", function(...){
  private$embed_opt <- list(...)
  invisible(self)
})

VL$set("public", "add_view", function(){
  private$check_inner()
  private$open <- add(private$open)
  invisible(self)
})

VL$set("public", "exit_view", function(){
  private$check_inner()
  if (length(private$open) == 1){
    private$spc <- append(private$spc, private$open)
    private$open <- list()
  } else {
    private$open <- exit(private$open)
  }
  invisible(self)
})

VL$set("private", "update_spec", function(){
  if (length(private$open)){
    self$exit_view()
    private$spc <- append(private$spc, private$open)
    private$open <- list()
  } else {
    private$spc <- append(private$spc, private$inner)
  }
  private$inner <- character(0)
})

VL$set("public", "as_spec", function(type = c("list", "JSON")){
  type <- match.arg(type)
  private$update_spec()
  if (type == "JSON")
    jsonlite::toJSON(check_vl_spec(private$spc), auto_unbox = TRUE, pretty = TRUE)
  else
    check_vl_spec(private$spc)
})

VL$set("public", "print", function(){
  print(self$plot())
  invisible(self)
})

VL$set("public", "plot", function(){
  private$update_spec()
  private$validate()
  plot_vl(private$spc, private$embed_opt)
})

#data
VL$set("public", "data", function(data, ...){
  l <- list(data = list(...))
  l$data <- append(l$data, spec_data(data))
  private$add_prop(l)
  invisible(self)
})

#marks
for (i in vl_prop$mark){
  VL$set("public", i, function(...){
    call <- this_call()
    if (call == "box_plot")
      call <- "box-plot"
    if (length(list(...))){
      l <- list(...)
      l$type <- call
      l <- list(mark = l)
    } else {
      l <- list(mark = call)
    }
    private$add_prop(l)
    invisible(self)
  })
}

for (i in vl_prop$encoding){
  VL$set("public", i, function(...){
    l <- check_encoding(list(...))
    l <- list(l)
    names(l) <- this_call()
    if (names(l) == "label")
      names(l) <- "text"
    private$inner$encoding <- append(private$inner$encoding, l)
    invisible(self)
  })
}

VL$set("public", "tooltip", function(...){
  if (!length(list(...)) && length(private$inner$encoding)){
    l <- lapply(private$inner$encoding, function(d){
      d <- d[vl_tooltip_props]
      d[!is.na(names(d))]
    })
    names(l) <- NULL
    l <- list(l)
  }
  else {
    l <- list(lapply(list(...), check_encoding))
  }
  names(l) <- "tooltip"
  private$inner$encoding <- append(private$inner$encoding, l)
  invisible(self)
})

VL$set("public", "show", function(){
  private$update_spec()
  private$spc
})

#view specs
for (i in vl_prop$view_spec){
  VL$set("public", i, function(...){
    l <- list(...)
    if (this_call() == "transform"){ #transform is an array
      if (all(nchar(names(l))))
        l <- list(l)
      else
        l <- lapply(seq_along(l), function(k)
          if (!nchar(names(l[k]))) l[[k]] else l[k]
        )
    }
    if (any(sapply(l, is.list)) || length(names(l)))
      l <- list(l)
    names(l) <- this_call()
    private$add_prop(l)
    invisible(self)
  })
}

#view compositions
for (i in vl_prop$compose){
  VL$set("public", i, function(){
    l <- list(list())
    names(l) <- this_call()
    private$add_compose(l)
    invisible(self)
  })
}

VL$set("public", "spec", function(){
  l <- list(NULL)
  names(l) <- "spec"
  private$add_compose(l)
  invisible(self)
})

#repeat row
VL$set("public", "repeat_row", function(row){
  l <- list('repeat' = list(row = row))
  private$add_prop(l)
  invisible(self)
})

#repeat col
VL$set("public", "repeat_column", function(column){
  l <- list('repeat' = list(column = column))
  private$add_prop(l)
  invisible(self)
})

#repeat row col
VL$set("public", "repeat_row_column", function(row, column){
  l <- list('repeat' = list(row = row, column = column))
  private$add_prop(l)
  invisible(self)
})

VL$set("private", "validate", function(){
  s <- check_vl_spec(private$spc)
  s <- jsonlite::toJSON(s, auto_unbox = TRUE)
  validate_schema(s)
})

