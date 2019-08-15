#' Setup a session
#' 
#' Setup a session, installs Word2Vec Juia dependency if needed.
#' 
#' @param ... Arguments passed to \link[JuliaCall]{julia_setup}.
#' 
#' @import JuliaCall
#' @import assertthat
#' 
#' @name setup_word2vec
#' @export
setup_word2vec <- function (...){
  julia <- JuliaCall::julia_setup(...)
  JuliaCall::julia_install_package_if_needed("Word2Vec")
  JuliaCall::julia_library("Word2Vec")
}

#' @rdname setup_word2vec
#' @export
init_word2vec <- setup_word2vec
