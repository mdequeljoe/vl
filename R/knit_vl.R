
knit_vl <- function(options){
  knit_print <- get("knit_print", envir = asNamespace("knitr"))
  engine_output <- get("engine_output", envir = asNamespace("knitr"))

  vl_spec <- vl(paste(options$code, collapse = "\n"), 
                embed_opt = options$embed_opt)

  vl_output <- knit_print(vl_spec, options = options)
  engine_output(
    options, out = list(
      structure(list(src = options$code), class = 'source'),
      vl_output
    )
  )
}