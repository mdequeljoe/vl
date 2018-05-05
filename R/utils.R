
rm_dots <- function(l, n){
  lapply(l, function(m){
    if (is.list(m) && !is.data.frame(m)) {
      rm_dots(m, n)
    } else {
      if (is.data.frame(m))
        colnames(m) <- gsub("\\.", " ", colnames(m))
      else if (m %in% n)
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
    if (is.list(d))
      nm_fields(d)
    else
      d
  })
}

