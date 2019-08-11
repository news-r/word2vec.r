#' Install Dependencies
#' 
#' Install Word2Vec Juia dependency.
#' 
#' @import JuliaCall
#' 
#' @export
install_word2vec <- function(){
  julia_install_package_if_needed("Word2Vec")
}