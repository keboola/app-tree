test_that("basic run", {
  app <- RTree$new(file.path(KBC_DATADIR, '01'))
  app$readConfig()
  app$run()

  expect_true(file.exists(file.path(KBC_DATADIR, '01', 'out', 'tables', 'tree.csv')))
  data <- read.csv(file.path(KBC_DATADIR, '01', 'out', 'tables', 'tree.csv'))
  expect_equal(
    c(1, 2, 2, 3),
    data[['levels']]
  )
  expect_equal(
    as.character(data[['root']]),
    as.character(c('foo', 'foo', 'foo', 'foo'))
  )
})
