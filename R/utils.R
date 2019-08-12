.construct_model <- function(file, temp = FALSE){
  obj <- list(file = file, temp = temp)
  structure(obj, class = c("word2vec", class(file)))
}