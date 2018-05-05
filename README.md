# vl

vl provides conveniences for writing vega-lite specifications from R
(work in progress). The preference here is to find a middle ground between encouraging the use of vega-lite directly and relying on an R interface. 


## Examples

A vl specification can be expressed as its JSON-equivalent R list object:

```r
vl::vl(
  list(
    data = list(values = iris),
    mark = "point",
    encoding = list(
      x = list(field = "Sepal.Width", type = "Quantitative"),
      y = list(field = "Sepal.Length", type = "Quantitative"),
      row = list(field = "Species")
    )
  )
)
```
This is a lot of typing. 
For ease of use this can also be written in a reduced form:
```r
vl::vl(
  list(
    data = iris,
    mark = "point",
    encoding = list(
      x = "Sepal.Width:Q",
      y = "Sepal.Length:Q",
      row = "Species"
    )
  )
)
```

## Source editing

### Building off of JSON examples

to do

### Templates

to do

For quick source editing in RStudio a number of templates are pre-specified (to do) which will print to the active document



