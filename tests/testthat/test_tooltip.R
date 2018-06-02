context("tooltips")

v <- vl::vl()$data(mtcars)
v$point()$
  x("mpg:Q")$
  y("hp:Q", scale = list(zero = FALSE))$
  tooltip()
l <- v$as_spec()
l1 <- l

test_that("no-argument tooltips are valid", {
  expect_equal(length(l$encoding$tooltip), 2)
  expect_equal(length(l$encoding$tooltip[[2]]), 2)
  expect_identical(names(l$encoding$tooltip[[2]]), c("field", "type"))
})

v <- vl::vl()$data(mtcars)
v$point()$
  x("mpg:Q")$
  y("hp:Q", scale = list(zero = FALSE))$
  tooltip(list("mpg:Q"), list("hp:Q"))
l <- v$as_spec()

test_that("multiple tooltips are valid", {
  expect_identical(l, l1)
})

v <- vl::vl()$data(mtcars)
v$point()$
  x("mpg:Q")$
  y("hp:Q", scale = list(zero = FALSE))$
  tooltip("mpg:Q")
l <- v$as_spec()

test_that("multiple tooltips are valid", {
  expect_equal(length(l$encoding$tooltip), 1)
  expect_identical(names(l$encoding$tooltip[[1]]), c("field", "type"))
})


