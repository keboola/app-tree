#suppressMessages(library('keboola.r.custom.application.tree', quiet = TRUE))
install.packages('jsonlite', repos = c("https://cran.r-project.org"))
library('devtools')
library('methods')
library('jsonlite')

# install the transformation application ancestors
devtools::install_github('keboola/r-application', ref = "master", force = TRUE)
devtools::install_github('keboola/r-docker-application', ref = "master", force = TRUE)
library('keboola.r.application')
library('keboola.r.docker.application')
source('R/keboola.r.custom.application.tree.R')

# run it
app <- RTree$new('/data/')
ret <- app$readConfig()
ret <- app$run()