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
    packages = 'character',
    inFile = 'character',
    outFile = 'character'
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
      tryCatch({
        inFile <<- unlist(.self$getInputTables())[2]
        outFile <<- unlist(.self$getExpectedOutputTables())[1]
      }, error = function(e) {
        stop("There must be exactly one input and output table.")
      })

      data <- read.csv(file = file.path(normalizePath(dataDir, mustWork = FALSE), "in", "tables", .self$inFile))
      data[[idColumn]] <- as.character(data[[idColumn]])
      data[[parentColumn]] <- as.character(data[[parentColumn]])
      if (!(parentColumn %in% colnames(data))) {
        stop(paste0("Column ", parentColumn, " not present in table."))
      }
      if (!(idColumn %in% colnames(data))) {
        stop(paste0("Column ", idColumn, " not present in table."))
      }

      getLevel <- function(data, id, idColumn, parentIdColumn, previous) {
        parent <- data[which(data[[idColumn]] == id),][[parentIdColumn]]
        if (length(parent) > 0) {
          if (parent == id) {
            .self$logInfo("Loop detected")
            result <- list(level = 0, id = id);
          } else {
            result <- getLevel(data, parent, idColumn, parentIdColumn, id)
          }
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
      outData[['levels']] <- unlist(listlevels)
      outData[['root']] <- unlist(listIds)

      write.csv(outData, file = file.path(normalizePath(dataDir, mustWork = FALSE), "out", "tables", .self$outFile), row.names = FALSE)
    }
  )
)
