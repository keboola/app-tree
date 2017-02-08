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
      .self$logInfo("Initializing R transformation")
      data <- read.csv(file = file.path(normalizePath(dataDir, mustWork = FALSE), "in/tables/tree.csv"))

      getLevel <- function(data, id, idColumn, parentIdColumn) {
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
          root <- data[which(data[[idColumn]] == id),][['title']];
        }
        root
      }

      outData <- data
      outData$levels <- sapply(data$categoryId, function(val) {
        getLevel(data, val, 'categoryId', 'categoryParentId')
      })
      outData$root <- sapply(data$categoryId, function(val) {
        getRoot(data, val, 'categoryId', 'categoryParentId')
      })

      write.csv(outData, file = file.path(normalizePath(dataDir, mustWork = FALSE), "out/tables/tree.csv"), row.names = FALSE)
    }
  )
)
