this_call <- function() {
  call <- deparse(sys.call(which = -1L)[[1]])
  gsub(".+\\$(.+)", "\\1", call[length(call)])
}

rm_dots <- function(l, n){
  lapply(l, function(m){
    if (inherits(m, "list")) {
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


