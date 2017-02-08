#' Application which runs KBC transformations in R
#' @import methods
#' @import keboola.r.docker.application
#' @export RTree
#' @exportClass RTree
RTree <- setRefClass(
  'RTree',
  contains = c("DockerApplication"),
  fields = list(
    scriptContent = 'character',
    tags = 'character',
    packages = 'character'
  ),
  methods = list(
    initialize = function(args = NULL) {
      "Constructor.
      \\subsection{Parameters}{\\itemize{
      \\item{\\code{args} Optional name of data directory, if not supplied then it
      will be read from command line argument.}
      }}"
           callSuper(args)
    },


    run = function() {
      "Main application entry point.
      \\subsection{Return Value}{TRUE}"
      .self$logInfo("Initializing R Tree")
      # check for surplus parameters
      enteredParameters <- names(configData$parameters)
      knownParameters <- c('idColumn', 'parentColumn')
      surplusParameters <- enteredParameters[which(!(enteredParameters %in% knownParameters))]
      if (length(surplusParameters) > 0) {
        .self$logError(paste0("Unknown parameters: ", paste(surplusParameters, collapse = ', ')))
      }

      idColumn <- configData$parameters$idColumn
      if (length(idColumn) == 0)  {
        idColumn <- 'categoryId'
      }
      parentColumn <- configData$parameters$parentColumn
      if (length(parentColumn) == 0)  {
        parentColumn <- 'categoryParentId'
      }

      data <- read.csv(file = file.path(normalizePath(dataDir, mustWork = FALSE), "in/tables/tree.csv"))

      browser()
      getLevel <- function(data, id, idColumn, parentIdColumn) {
        browser()
        parent <- data[which(data[[idColumn]] == id),][[parentIdColumn]]
        if (parent > 0) {
          level <- getLevel(data, parent, idColumn, parentIdColumn) + 1;
        } else {
          level <- 1;
        }
        level
      }

      getRoot <- function(data, id, idColumn, parentIdColumn) {
        parent <- data[which(data[[idColumn]] == id),][[parentIdColumn]]
        if (parent > 0) {
          root <- getRoot(data, parent, idColumn, parentIdColumn);
        } else {
          root <- data[which(data[[idColumn]] == id),][[idColumn]];
        }
        root
      }

      outData <- data
      outData$levels <- sapply(data[[idColumn]], function(val) {
        getLevel(data, val, idColumn, parentColumn)
      })
      outData$root <- sapply(data[[idColumn]], function(val) {
        getRoot(data, val, idColumn, parentColumn)
      })

      write.csv(outData, file = file.path(normalizePath(dataDir, mustWork = FALSE), "out/tables/tree.csv"), row.names = FALSE)
    }
  )
)
