#' Word2Phrases
#' 
#' 
#' @param train Use text data from file to train the model.
#' @param output Use file to save the resulting word vectors / word clusters.
#' @param min_count This will discard words that appear less than \eqn{n} times;
#'  default is \code{5L}.
#' @param threshold The numeric value represents the threshold for 
#' forming the phrases (higher means less phrases); default \code{100L}.
#' @param debug Set the debug mode (default = \code{2L} = more info during training)
#' 
#' @examples
#' \dontrun{
#' # setup word2vec Julia dependency
#' setup_word2vec()
#' 
#' # sample corpus
#' data("macbeth", package = "word2vec.r")
#' 
#' # train model
#' model_path <- word2phrase(macbeth)
#' }
#' @export
word2phrase <- function(train, output = NULL, min_count = 5L, 
  threshold = 100L, debug = 2L){

  # sanity checks
  assert_that(!missing(train), msg = "Missing `train`")
  word2vec_installed <- julia_exists("word2phrase")
  if(!word2vec_installed) 
    stop(
      "word2phrase is ", 
      crayon::red("not installed"), 
      " see `",
      crayon::blue("setup_word2vec"), "`", 
      call. = TRUE
    )

  # prepare output
  output_temp <- FALSE
  if(is.null(output)){
    output <- tempfile(fileext = ".txt")
    output_temp <- TRUE
  }

  # prepare input
  input_temp <- FALSE

  # write to file if character string passed
  if(!file.exists(train)){
    train_path <- tempfile(fileext = "") # no extension
    write(train, file = train_path)
    input_temp <- TRUE
  } else {
    train_path <- normalizePath(train)
  }

  # train model
  opts <- glue::glue('word2phrase("{train}", "{output}", min_count = {min_count},
    threshold = {threshold}, debug = {debug})',
    train = train_path, output = output, min_count = min_count, 
    threshold = threshold, debug = debug
  )

  julia_eval(opts)

  # cleanup
  if(input_temp) unlink(train_path, force = TRUE)
  
  # build
  output <- .construct_word2vec(output, temp = output_temp)
  invisible(output)
}