#' Word2Vec
#' 
#' Train Word2Vec model.
#' 
#' @param train Use text data from file to train the model.
#' @param output Use file to save the resulting word vectors / word clusters.
#' @param size Set size of word vectors; default is \code{100L}.
#' @param window Set max skip length between words; default is \code{5L}.
#' @param sample Set threshold for occurrence of words. 
#' Those that appear with higher frequency in the training data will be randomly 
#' down-sampled; default is \code{1e-5}.
#' @param hs Use Hierarchical Softmax; default is \code{1} (\code{0L} = not used)
#' @param negative Number of negative examples; default is \code{0L}, common values are 
#' \code{5 - 10} (\code{0L} = not used).
#' @param threads Use \eqn{n} threads (default \code{12L}).
#' @param iter Run more training iterations (default \code{5}).
#' @param min_count This will discard words that appear less than \eqn{n} times; 
#' default is \code{5L}.
#' @param alpha Set the starting learning rate; default is \code{.025}.
#' @param debug Set the debug mode (default = \code{2L} = more info during training).
#' @param binary Save the resulting vectors in binary moded; default is \code{0L} (off).
#' @param cbow Use the continuous back of words model; default is \code{1L} (skip-gram model).
#' @param verbose Whether to print output from training.
#' 
#' @examples
#' \dontrun{
#' # sample corpus
#' corpus <- paste("Julia has foreign function interfaces for C/Fortran,", 
#'   "C++, Python, R, Java, and many other languages.")
#' 
#' # train model
#' model_path <- word2vec(corpus)
#' }
#' 
#' @return Invisibly returns the \code{output}.
#' 
#' @seealso \code{\link{as_word2vec}} to load a pre-trained model.
#' 
#' @name word2vec
#' 
#' @export
word2vec <- function(train, output = NULL, size = 100L, window = 5L, 
  sample = 1e-3, hs = 0L,  negative = 5L, threads = 12L, iter = 5L, 
  min_count = 5L, alpha = .025, debug = 2L, binary = 0L, cbow = 1L, 
  verbose = TRUE) {

  # sanity checks
  assert_that(!missing(train), msg = "Missing `train`")
  word2vec_installed <- julia_exists("word2vec")
  if(!word2vec_installed) 
    stop(
      "word2vec is ", 
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
  opts <- glue::glue('word2vec("{train}", "{output}", size = {size}, window = {window}, 
    sample = {sample}, hs = {hs},  negative = {negative}, 
    threads = {threads}, iter = {iter}, min_count = {min_count}, 
    alpha = {alpha}, debug = {debug}, binary = {binary}, cbow = {cbow}, 
    verbose = {verbose})',
    train = train_path, output = output, size = size, window = window, 
    sample = sample, hs = hs,  negative = negative, 
    threads = threads, iter = iter, min_count = min_count, 
    alpha = alpha, debug = debug, binary = binary, cbow = cbow, 
    verbose = tolower(verbose)
  )
  print(opts)
  julia_eval(opts)

  # cleanup
  if(input_temp) unlink(train_path, force = TRUE)
  
  # build
  output <- .construct_model(output, temp = output_temp)
  invisible(output)
}

#' As model
#' 
#' Import a previously trained word2vec model.
#' 
#' @param file Path to model file.
#' 
#' @examples
#' \dontrun{
#' model_path <- as_word2vec("path/to/file.txt")
#' }
#'
#' @export
as_word2vec <- function(file){
  assert_that(!missing(file), msg = "Missing `file`")
  path <- normalizePath(file)
  .construct_model(path, temp = FALSE)
}

#' Word Vectors
#' 
#' Import Word vectors.
#' 
#' @param file Path to odel, output of \code{\link{word2vec}} or \code{\link{as_word2vec}}.
#' 
#' @examples
#' \dontrun{
#' # sample corpus
#' corpus <- paste("Julia has foreign function interfaces for C/Fortran,", 
#'   "C++, Python, R, Java, and many other languages.")
#' 
#' # train model
#' model_path <- word2vec(corpus)
#' 
#' # get word vectors
#' word_vectors(model_path)
#' }
#' 
#' @name word_vectors
#' 
#' @seealso \code{\link{word2vec}}
#' 
#' @export
word_vectors <- function(file) UseMethod("word_vectors")

#' @rdname word_vectors
#' @method word_vectors word2vec
#' @export
word_vectors.word2vec <- function(file){
  opts <- glue::glue('model = wordvectors("{file}");', file = file$file)
  julia_command(opts)
  if(file$temp) unlink(file$file, force = TRUE) # cleanup
  invisible()
}