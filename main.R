suppressMessages(library('keboola.r.custom.application.tree', quiet = TRUE))

# run it
app <- RTree$new()
ret <- app$readConfig()
ret <- app$run()