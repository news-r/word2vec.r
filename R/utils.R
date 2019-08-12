.construct_word2vec <- function(file, temp = FALSE){
  obj <- list(file = file, temp = temp)
  structure(obj, class = c("word2vec", class(obj)))
}

.construct_word2cluster <- function(file, temp = FALSE){
  obj <- list(file = file, temp = temp)
  structure(obj, class = c("word2clusters", class(obj)))
}

.construct_word2vec_model <- function(model){
  structure(model, class = c("wordvectors", class(model)))
}

.construct_word2clusters_model <- function(model){
  structure(model, class = c("wordclusters", class(model)))
}