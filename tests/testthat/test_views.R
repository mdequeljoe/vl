context("composition views")

v <- vl::vl()
l <- v$data(iris)$
  layer()$
  point()$
    x("Sepal.Width")$
    y("Sepal.Length")$
    color("Species")$
  line()$
    x("Sepal.Width")$
    y("Sepal.Length")$
  as_spec()

test_that("layer spec is valid", {
  expect_true(is.list(l$layer[[1]]))
  expect_true(length(l$layer) == 2)
 }
)

v <- vl::vl()
l <- v$data(iris)$
  hconcat()$
  layer()$
  point()$
    x("Sepal.Width")$
    y("Sepal.Length")$
    color("Species")$
  line()$
    x("Sepal.Width")$
    y("Sepal.Length")$
  exit_view()$
    point()$
    x("Sepal.Width")$
    y("Sepal.Length")$
  as_spec()

test_that("nested layers are valid", {
  expect_true(is.null(names(l$hconcat)))
  expect_equal(length(l$hconcat), 2)
  expect_equal(length(l$hconcat[[1]]$layer), 2)
  expect_true( is.list(l$hconcat[[1]][[1]]) )
  expect_true( !is.list(l$hconcat[[2]][[1]]) )
 }
)

v <- vl::vl()
l <- v$data(iris)$
  hconcat()$
  layer()$
  point()$
  x("Sepal.Width")$
  y("Sepal.Length")$
  color("Species")$
  line()$
  x("Sepal.Width")$
  y("Sepal.Length")$
  exit_view()$
  add_view()$
  layer()$
  point()$
  x("Sepal.Width")$
  y("Sepal.Length")$
  color("Species")$
  tick()$
  x("Sepal.Width")$
  y("Sepal.Length")$
  as_spec()

test_that("adding views is valid", {
  expect_equal(length(l$hconcat), 2)
  expect_equal(length(l$hconcat[[2]]$layer), 2)
  expect_true( is.list(l$hconcat[[2]][[1]]) )
 }
)

v <- vl::vl()
l <- v$repeat_column(c("hp", "mpg", "qsec"))$
  spec()$
  data(mtcars)$
  bar()$
  x(field = list('repeat' = "column"),
    type = "quantitative",
    bin = TRUE)$
  y(aggregate = "count",
    type = "quantitative"
  )$
  color("cyl")$
  as_spec()

test_that("repeat specs are valid", {
  expect_true(all(nchar(names(l$spec)) > 0))
  expect_equal(length(names(l$spec)), 3)
 }
)

v <- vl::vl()
l <- v$repeat_column(c("hp", "mpg", "qsec"))$
  spec()$
  data(mtcars)$
  layer()$
  point()$
    x(field = list('repeat' = "column"),
      type = "quantitative")$
    y("disp")$
    color("cyl")$
  tick()$
    x(field = list('repeat' = "column"),
      type = "quantitative")$
    y("disp")$
    color("cyl")$
  as_spec()

test_that("specs with inner views are valid", {
  expect_true(all(nchar(names(l$spec)) > 0))
  expect_equal(length(names(l$spec)), 2)
 }
)

v <- vl::vl()
l <- v$data(mtcars)$
  vconcat()$
  repeat_column(c("hp", "mpg", "qsec"))$
  spec()$
  bar()$
  x(field = list('repeat' = "column"),
    type = "quantitative",
    bin = TRUE)$
  y(aggregate = "count",
    type = "quantitative"
  )$
  color("cyl")$
  exit_view()$
  repeat_column(c("disp", "drat", "vs"))$
  spec()$
  bar()$
  x(field = list('repeat' = "column"),
    type = "quantitative",
    bin = TRUE)$
  y(aggregate = "count",
    type = "quantitative")$
  color("cyl")$
  as_spec()

test_that("nested repeat specs are valid", {
  expect_equal(length(l$vconcat), 2)
  expect_true(is.null(names(l$vconcat)))
  expect_equal(length(l$vconcat[[1]]), 2)
  expect_equal(length(l$vconcat[[2]]), 2)
}
)

