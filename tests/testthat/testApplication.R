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
    as.character(c('1', '1', '1', '1'))
  )
})

test_that("run with parameters", {
  app <- RTree$new(file.path(KBC_DATADIR, '02'))
  app$readConfig()
  app$run()

  expect_true(file.exists(file.path(KBC_DATADIR, '02', 'out', 'tables', 'tree.csv')))
  data <- read.csv(file.path(KBC_DATADIR, '02', 'out', 'tables', 'tree.csv'))
  expect_equal(
    c(1, 2, 2, 3),
    data[['levels']]
  )
  expect_equal(
    as.character(data[['root']]),
    as.character(c('1', '1', '1', '1'))
  )
})

test_that("run with string IDs", {
  app <- RTree$new(file.path(KBC_DATADIR, '03'))
  app$readConfig()
  app$run()

  expect_true(file.exists(file.path(KBC_DATADIR, '03', 'out', 'tables', 'tree.csv')))
  data <- read.csv(file.path(KBC_DATADIR, '03', 'out', 'tables', 'tree.csv'))
  expect_equal(
    c(1, 2, 1, 3),
    data[['levels']]
  )
  expect_equal(
    as.character(data[['root']]),
    as.character(c('a', 'c', 'c', 'c'))
  )
})

test_that("run with loop", {
  app <- RTree$new(file.path(KBC_DATADIR, '04'))
  app$readConfig()
  app$run()

  expect_true(file.exists(file.path(KBC_DATADIR, '04', 'out', 'tables', 'tree.csv')))
  data <- read.csv(file.path(KBC_DATADIR, '04', 'out', 'tables', 'tree.csv'))
  expect_equal(
    c(1, 2, 2, 3),
    data[['levels']]
  )
  expect_equal(
    as.character(data[['root']]),
    as.character(c('1', '1', '1', '1'))
  )
})
