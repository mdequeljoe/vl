context("basic tests")

v <- vl::vl()
l <- v$data(iris)$
  point()$
  x("Sepal.Width", type = "Q")$
  y("Sepal.Length", type = "Q")$
  color("Species:N")$
  title("Iris")$
  as_spec()

test_that("basic plot spec valid", {
  expect_equal(names(l), c("data", "mark", "encoding", "title", "$schema"))
  expect_equal(names(l$encoding), c("x", "y", "color"))
  expect_equal(l$encoding$y$field, "Sepal Length")
  expect_equal(l$encoding$color$type, "nominal")
  expect_equal(names(l$encoding$color), c("field", "type"))
  expect_equal(l$title, "Iris")
})

v <- vl::vl()
l <- v$data("!cars.json")$
  point()$
  x("Horsepower:Q")$
  y("Miles_per_Gallon:Q")$
  color("Cylinders:N")$
  title(text = "Cars", anchor = "start")$
  as_spec()

test_that("vega urls are valid", {
  expect_equal(names(l$data), "url")
  expect_equal(l$data$url, "https://vega.github.io/vega-datasets/data/cars.json")
})

test_that("arguments passed to view spec properties are valid", {
  expect_equal(l$title$text, "Cars")
  expect_equal(length(l$title), 2)
  expect_equal(names(l$title), c("text", "anchor"))
})

v <- vl::vl()
l <- v$data(iris)$
  rect()$
  x("Sepal.Width:Q", bin = list(maxbins = 15))$
  y("Sepal.Length:Q", bin = list(maxbins = 15))$
  color(aggregate = "count", type = "quantitative")$
  config(
    range = list(heatmap = list(scheme = "greenblue")),
    view = list(stroke = "transparent")
  )$
  as_spec()

test_that("config options valid", {
  expect_equal(length(l$config), 2)
  expect_equal(names(l$config), c("range", "view"))
})

air <- function(){
  vl::vl()$data(airquality)$point()$x("Ozone")$y("Temp")$as_spec()
}

test_that("vl's `this_call` works in functions",{
  expect_equal(names(air()), c("data", "mark", "encoding", "$schema"))
})

l <- vl::vl()$
  data(mtcars)$
  tick()$
  x("mpg")$
  as_spec("JSON")
l <- suppressWarnings(vl:::validate_schema(l))
test_that("vl validation returns list when warnings are signalled",{
  expect_true(is.list(l))
})
