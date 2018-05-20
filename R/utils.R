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

# dont need this in this form anymore
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
