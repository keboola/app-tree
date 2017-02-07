data <- read.csv(file = "/data/in/tables/tree.csv");

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

write.csv(outData, file = "/data/out/tables/tree.csv", row.names = FALSE)