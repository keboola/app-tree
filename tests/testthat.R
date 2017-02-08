library(testthat)

# default values
KBC_DATADIR <- 'tests/data'

print(getwd())
# override with config if any
if (file.exists("config.R")) {
    source("config.R")
}

# override with environment if any
if (nchar(Sys.getenv("KBC_DATADIR")) > 0) {
    KBC_DATADIR <- Sys.getenv("KBC_DATADIR")
}

rep <- MultiReporter$new(
    reporters = list(SummaryReporter$new())
    # , CheckReporter$new(), FailReporter$new()s
)
test_check("keboola.r.custom.application.tree", reporter = rep)

