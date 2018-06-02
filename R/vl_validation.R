validate_schema <- function(spec){

  warn <- getOption("vl.warnings", default = TRUE)
  if (!warn)
    return(invisible())

  cx <- V8::v8()
  cx$source(system.file("htmlwidgets/lib/validation/ajv.min.js", package = "vl"))
  cx$source(system.file("htmlwidgets/lib/validation/vega-lite-schema.min.js", package = "vl"))
  cx$source(system.file("htmlwidgets/lib/validation/json-schema-draft06.min.js", package = "vl"))
  cx$source(system.file("htmlwidgets/lib/validation/vl-validation.js", package = "vl"))
  cx$source(system.file("htmlwidgets/lib/vega-lite/vega-lite.min.js", package = "vl"))

  valid <- cx$get(sprintf("validateVl(%s)", spec))

  if (!is.logical(valid)){
    log <- unique(paste(valid$dataPath, valid$message))
    vega_log <- cx$get(sprintf("logVegaWarnings(%s)", spec)) #vega logs helpful too
    if (length(vega_log))
      log <- c(log, vega_log)
    warning(
      paste(
        sprintf("%i: %s", 1:length(log), log),
        collapse = "\n"
      ),
      call. = FALSE
    )
  }
  invisible(valid)
}

check_encoding <- function(d){

  if (!is.list(d))
    d <- list(d)

  if (length(d$condition))
    d$condition <- check_encoding(d$condition)

  names(d)[is.null(names(d))] <- "field"
  names(d)[!nchar(names(d))] <- "field"

  #types
  # is shorthand?
  if (!is.null(d$type))
    d$type <- get_type(d$type)

  #declared with field?
  if (!is.null(d$field) && grepl(":(.)$", d$field)){
    type <- gsub(".*:(.)$", "\\1", d$field)
    d$type <- get_type(type)
    d$field <- gsub(paste0(":", type), "", d$field)
  }

  d
}

spec_data <- function(l){
  if (is.character(l) && grepl("^http[s]?://|^!", l))
    nm <- "url"
  else
    nm <- "values"
  l <- list(l)
  names(l) <- nm
  #is a local file
  if (is.character(l$values)){
    l$values <- file_df(l$values)
  }
  # is a vega dataset?
  if (!is.null(l$url) && grepl("^!", l$url))
    l$url <- sub("!", "https://vega.github.io/vega-datasets/data/", l$url)
  l
}

file_df <- function(f) {
  f_ext <- gsub(".+\\.(.+)", "\\1", f)
  switch(
    f_ext,
    "json" = jsonlite::fromJSON(f),
    "csv" = utils::read.csv(f, stringsAsFactors = FALSE),
    "tsv" = utils::read.csv(f, sep = "\t", stringsAsFactors = FALSE)
  )
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

