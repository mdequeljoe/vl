context("transform specs")

v <- vl::vl()
l <- v$data(airquality)$
  transform(
    aggregate = list(
      list(
        op = "mean",
        field = "Ozone",
        as = "mean_Ozone"
      )
    ),
    groupby = list("Month")
  )$
  bar()$
  x("Month", type = "Nominal")$
  y("mean_Ozone", type = "quantitative")$
  as_spec()

test_that("aggregation transform spec is valid", {
  expect_true(is.null(names(l$transform)))
  expect_true(is.null(names(l$transform[[1]]$aggregate)))
  expect_equal(length(l$transform), 1)
})

df <- jsonlite::fromJSON('[
                         {"a": "A","b": 28},
                         {"a": "B","b": 55},
                         {"a": "C","b": 43},
                         {"a": "G","b": 19},
                         {"a": "H","b": 87},
                         {"a": "I","b": 52},
                         {"a": "D","b": 91},
                         {"a": "E","b": 81},
                         {"a": "F","b": 53}
                         ]
                         ')

v <- vl::vl()
l <- v$data(df)$
  transform(
    list(calculate = "2*datum.b", as = "b2"),
    filter = "datum.b2 > 60"
  )$
  bar()$
  y(field = "b2", type = "quantitative")$
  x(field = "a", type = "ordinal")$
  as_spec()

test_that("calculation transform spec is valid", {
  expect_true(is.null(names(l$transform)))
  expect_identical(names(l$transform[[2]]), "filter")
  expect_equal(length(l$transform), 2)
})
