
rm_dots <- function(l, n){
  lapply(l, function(m){
    if (is.list(m) && !is.data.frame(m)) {
      rm_dots(m, n)
    } else {
      if (is.data.frame(m))
        colnames(m) <- gsub("\\.", " ", colnames(m))
      else if (any(m %in% n))
        m <- gsub("\\.", " ", m)
      m
    }
  })
}

nm_fields <- function(l){

  if (any(names(l) == "encoding")){
    l$encoding <- lapply(l$encoding, function(d){
      if (is.list(d)){
        names(d)[is.null(names(d))] <- "field"
        names(d)[names(d) == ""] <- "field"
      } else {
        d <- list(field = d)
      }
      d
    })
  }
  lapply(l, function(d){
    if (is.list(d) && !is.data.frame(d))
      nm_fields(d)
    else
      d
  })
}

set_types <- function(l){
  if (any(names(l) == "encoding")){
    l$encoding <- lapply(l$encoding, function(d){
      if (length(d$field) && grepl(":(.)$", d$field)){
        type <- gsub(".*:(.)$", "\\1", d$field)
        d$type <- switch(type,
                         "Q" = "quantitative",
                         "N" = "nominal",
                         "O" = "ordinal",
                         "T" = "temporal",
                         "G" = "geojson"
        )
        d$field <- gsub(paste0(":", type), "", d$field)
      }
      d
    })
  }
  lapply(l, function(d){
    if (is.list(d) && !is.data.frame(d))
      set_types(d)
    else
      d
  })
}
