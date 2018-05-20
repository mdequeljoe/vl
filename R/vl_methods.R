
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
    jsonlite::toJSON(check_vl_spec(private$spc), auto_unbox = TRUE)
  else
    check_vl_spec(private$spc)
})

VL$set("public", "print", function(){
  private$update_spec()
  print(plot_vl(private$spc))
  invisible(self)
})

VL$set("public", "plot", function(){
  private$update_spec()
  plot_vl(private$spc)
})

#data
VL$set("public", "data", function(data, ...){
  l <- list(data = list(data, ...))
  l <- spec_data(l)
  private$add_prop(l)
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
    private$add_prop(l)
    invisible(self)
  })
}

for (i in vl_prop$encoding){
  VL$set("public", i, function(...){
    l <- list(...)
    if (is.null(names(l)[1]) || !nchar(names(l)[1]))
      names(l)[1] <- "field"
    if (!is.null(l$field) && grepl(":(.)$", l$field)){
      type <- gsub(".*:(.)$", "\\1", l$field)
      l$type <- get_type(type)
      l$field <- gsub(paste0(":", type), "", l$field)
    }
    l <- list(l)
    names(l) <- this_call()
    if (names(l) == "label") names(l) <- "text"
    if (!is.null(l[[1]]$type))
      l[[1]]$type <- get_type(l[[1]]$type)
    private$inner$encoding <- append(private$inner$encoding, l)
    invisible(self)
  })
}

#encoding
# for (i in vl_prop$encoding){
#   VL$set("public", i, function(...){
#     l <- list(list(...))
#     #name fields
#     field <- names(l[[1]])[1]
#     if (!nchar(field) || is.null(field))
#       names(l[[1]])[1] <- "field"
#
#     names(l) <- this_call()
#     if (names(l) == "label") names(l) <- "text"
#     if (!is.null(l[[1]]$type))
#       l[[1]]$type <- get_type(l[[1]]$type)
#     private$inner$encoding <- append(private$inner$encoding, l)
#     invisible(self)
#   })
# }

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
    if (any(sapply(l, is.list)) || length(l) > 1)
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
