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
      data[[idColumn]] <- as.character(data[[idColumn]])
      data[[parentColumn]] <- as.character(data[[parentColumn]])

      getLevel <- function(data, id, idColumn, parentIdColumn, previous) {
        parent <- data[which(data[[idColumn]] == id),][[parentIdColumn]]
        if (length(parent) > 0) {
          result <- getLevel(data, parent, idColumn, parentIdColumn, id)
          result[['level']] <- result[['level']] + 1
        } else {
          result <- list(level = 0, id = previous);
        }
        result
      }

      outData <- data
      levels <- lapply(data[[idColumn]], function(val) {
        getLevel(data, val, idColumn, parentColumn)
      })
      listIds <- lapply(levels, function(elem) { elem$id })
      listlevels <- lapply(levels, function(elem) { elem$level })
      browser()
      outData[['levels']] <- unlist(listlevels)
      outData[['root']] <- unlist(listIds)

      write.csv(outData, file = file.path(normalizePath(dataDir, mustWork = FALSE), "out/tables/tree.csv"), row.names = FALSE)
    }
  )
)
