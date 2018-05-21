ext_as_df <- function(f) {
  f_ext <- gsub(".+\\.(.+)", "\\1", f)
  switch(
    f_ext,
    "json" = jsonlite::fromJSON(f),
    "csv" = utils::read.csv(f, stringsAsFactors = FALSE),
    "tsv" = utils::read.csv(f, sep = "\t", stringsAsFactors = FALSE)
  )
}

has_url_prefix <- function(f) grepl("^http[s]?://|^!", f)

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

get_type <- function(type){
  switch(toupper(type),
         "Q" = "quantitative",
         "N" = "nominal",
         "O" = "ordinal",
         "T" = "temporal",
         "G" = "geojson",
         type
  )
}

name_encodings <- function(...){
  l <- list(...)
  if (any(!sapply(l, is.list)))
    l <- list(l)
  #tooltips can take separate lists
  l <- lapply(l, function(d){
    if (is.null(names(d)[1]) || !nchar(names(d)[1]))
      names(d)[1] <- "field"

    if (!is.null(d$type))
      d$type <- get_type(d$type)

    if (!is.null(d$field) && grepl(":(.)$", d$field)){
      type <- gsub(".*:(.)$", "\\1", d$field)
      d$type <- get_type(type)
      d$field <- gsub(paste0(":", type), "", d$field)
    }

    d
  })
  if (length(l) > 1)
    l <- list(l)
  l
}

#layer and spec -> append to existing list
#others -> append as separate list; n + 1
exit <- function(l){
  n <- length(l)
  nn <- length(l[[n - 1]])
  if (names(l[n - 1]) == "spec")
    l[[n - 1]] <- append(l[[n - 1]], l[n])
  else if (nn)
    l[[n - 1]][[nn]] <- append(l[[n - 1]][[nn]], l[n])
  else
    l[[n - 1]] <- append(l[[n - 1]], list(l[n])) # nested layers
  l[1:(n - 1)]
}

add <- function(l){
  n <- length(l)
  nn <- length(l[[n]]) + 1
  l[[n]][[nn]] <- list()
  l
}

update_spec <- function(l, k){
  if (!length(k)) return(l)
  n <- length(l)
  nn <- length(l[[n]]) + 1
  if (is.list(l[[n]])){
    l[[n]][[nn]] <- k
  } else {
    l[[n]] <- append(l[[n]], k)
  }
  l
}
