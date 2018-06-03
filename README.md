# vl 
vl provides an R6 interface for writing, validating, and parsing vega-lite specifications. Inspired mainly by [to-vega](https://github.com/gjmcn/to-vega), vl can be thought of as a way to write the JSON equivalent spec in short-form notation.

```r
vl::vl()$
  data("!cars.json")$
  tick()$
    x("Horsepower:Q")$
    y("Cylinders:O")$
  width(400)$
  plot()
```
![](man/img/Cars.png)

vl tries to find a middle ground between writing specs via an interface (instead of writing out the equivalent R list object) without abstracting too far away from the underlying JSON syntax. This complements the existing R htmlwidgets package, [vegalite](https://github.com/hrbrmstr/vegalite), which provides a great `%>%`-able api.

## Install

vl is a work in progress. Install via 

```r
devtools::install_github("mdequeljoe/vl")
```

## Usage

A new vl environment can be initiated with `vl`. 

```r
v <- vl::vl()
```

A vl specification can be validated and parsed with `plot`. The validation is the same as in the [vega-editor](https://vega.github.io/editor/#/). `as_spec` returns the current specification as a list or JSON. vl can also be used in shiny apps with `renderVl` and `vlOutput`.

[embed](https://github.com/vega/vega-embed) options can be passed with `embed`. For instance, this can be used to set a vega-theme. Note that by default actions are turned off.

### View specifications 

View specifications can be set with one or more of the following: `description`, `title`, `data`, `transform`, `width`, `height`, `name`, `background`, `padding`, `autosize`, `config`, `selection`, `facet`, `repeat_row`, `repeat_column`,
`repeat_row_column`

Data can be attached to the current view via `data` as a dataframe, local file, or url. To refer to a vega dataset url, prefix the file name with a `!`. 

These methods accept relevant their properties/parameters as arguments and are applied to the current view. For properties that accept either a string type or parameter objects, passing an unnamed vector will be taken as the string type. For instance `title("a title")` would be specified as `title(text = "a title", anchor = "start")` when additional arguments are passed in.

Note that `repeat_row`, `repeat_column`, `repeat_row_column` refer to [repeat](https://vega.github.io/vega-lite/docs/repeat.html) in order to avoid clashing with `base::repeat` 


### Mark

Specify a mark as one of `area`, `bar`, `circle`, `line`, `point`, `rect`, `rule`, `square`, `text`, `tick`, `geoshape`, `trail`, `box_plot`

These methods accept any optionally specified properties relevant to that mark. For instance, `text(align = 'left', dx = 100, dy = -5)` See the official [docs](https://vega.github.io/vega-lite/docs/mark.html) for details on mark-specific properties.

### Encoding

Specify an encoding channel as one of  `x`, `y`, `x2`, `y2`, `color`, `opacity`, `size`, `shape`, `label`, `tooltip`, `href`, `order`, `detail`, `row`, `column`.

Note that `label` refers to the [text](https://vega.github.io/vega-lite/docs/text.html) encoding to avoid a clash with the `text` mark. 

When an encoding is specified, it applies to the preceding mark of the current view. The encoding type can be specified [altair](https://altair-viz.github.io/user_guide/encoding.html) style, `x(field = "var:Q")`, short-form style,
`x(field = "var", type = "Q")` or in full form notation `x(field = "var", type = "quantitative")` for those who like extra typing. If the first argument is unnamed it is set as the field property.

if `tooltip` is specified with no arguments then it will be parsed with the fields specified
in the previous encodings of the current mark. 

```r
vl::vl()$
  data(mtcars)$
  point()$
    x("hp:Q")$
    y("mpg:Q")$
    tooltip()$
  plot()
```

Multiple fields not previously used as encodings can be shown in a tooltip by passing them as seperate lists.

### View compositions

View compositions can be set with `layer`, `hconcat`, `vconcat`, `spec`.

These methods take no arguments. When a view composition is specified, any succeeding vl method will be applied to this compostion. To exit the current view composition use `exit_view`. Note that it is not necessary to call `exit_view` if only two views are present and the succeeding method is `plot` or `as_spec`. 

To add a composition to an existing composition use `add_view`. 

To take an [example](https://bl.ocks.org/g3o2/bd4362574137061c243a2994ba648fb8):

```r
v <- vl::vl()
v$data("!cars.json")$
  hconcat()$
  tick()$
    y("Horsepower:Q")$
    x("Origin:N")$
    color("Origin:N")$
  add_view()$
  vconcat()$
  point()$
    x("Miles_per_Gallon:Q")$
    y("Horsepower:Q")$
    color("Origin:N")$
  tick()$
    x("Miles_per_Gallon:Q")$
    y("Origin:N")$
    color("Origin:N")$
  plot()
```
![](man/img/Cars_dash.png)


## Related

Beyond the projects already previously mentioned, here are some related works

[altair](https://github.com/vegawidget/altair) R interface

[vegaliteR](https://github.com/timelyportfolio/vegaliteR)

[finch](https://github.com/netbek/finch)
