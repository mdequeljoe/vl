#' @export
spec <- function(type = "JS"){

  js_obj <- '
vl::vl(\'{
  data: { values:  },
  mark: "" ,
  encoding: {
  x: {field: "" },
  y: {field: "" },
  }
}\')
'
  
  list_obj <- 'vl::vl(list(
  data = list(values = _),
  mark = "",
  encoding = list(x = list(field = ""),
  y = list(field = ""))
  ))'

  if (type == "JSON"){
    pr_obj <- eval(parse(text = list_obj))
    pr_obj <- jsonlite::toJSON(pr_obj, pretty = TRUE, auto_unbox = TRUE)
    pr_obj <-  paste0("'", pr_obj, "'")
  }
  else if (type == "list")
    pr_obj <- list_obj
  else
    pr_obj <- js_obj

  if (!rstudioapi::isAvailable()) {
    message("use for rstudio source editor")
    cat(pr_obj)
    return(invisible())
  }

  #to do - if running in source
  #set cursor to first blank to fill in (i.e. data : _)
  active_id <- rstudioapi::getActiveDocumentContext()$id
  source <- rstudioapi::getSourceEditorContext()
  source_id <- source$id
  source_row <- source$selection[[1]]$range$start[1]
  
  print(source_row)
  rstudioapi::insertText(id = active_id,
                         location = c(source_row, 1),
                         text = pr_obj)

  #comment out the function
  if (source_id == active_id){
    rstudioapi::insertText(id = source_id,
                           location = c(source_row - 1, 1),
                           text = "#")
  }
  data_row <- 2
  data_col <- 19
  rstudioapi::setCursorPosition(
    rstudioapi::document_position(source_row + data_row, data_col),
    id = active_id
  )

  return(invisible())

  }

