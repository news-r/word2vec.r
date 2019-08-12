#' Word Clusters
#' 
#' Gives each word a class ID number.
#' 
#' @inheritParams word2vec
#' @param classes Number of word classes; if \code{0L}, 
#' output word classes rather than word vectors (default \code{0L}).
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
#' model_path <- word2clusters(macbeth)
#' }
#' 
#' @return Invisibly returns the \code{output}.
#' 
#' @name word2clusters
#' 
#' @export
word2clusters <- function(train, output = NULL, 
  classes = 0L, size = 100L, window = 5L,
  sample = .00001, hs = 0L, negative = 5L, threads = 1L, 
  iter = 5L, min_count = 5L, alpha = .025,
  debug = 2L, binary = 0L, cbow = 1L,
  verbose = FALSE){

  # sanity checks
  assert_that(!missing(train), msg = "Missing `train`")
  word2vec_installed <- julia_exists("word2clusters")
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
  opts <- glue::glue('word2clusters("{train}", "{output}", {classes}, size = {size}, window = {window}, 
    sample = {sample}, hs = {hs},  negative = {negative}, 
    threads = {threads}, iter = {iter}, min_count = {min_count}, 
    alpha = {alpha}, debug = {debug}, binary = {binary}, cbow = {cbow}, 
    verbose = {verbose})',
    train = train_path, output = output, classes = classes, 
    window = window, size = size, sample = sample, hs = hs,  negative = negative, 
    threads = threads, iter = iter, min_count = min_count, 
    alpha = alpha, debug = debug, binary = binary, cbow = cbow, 
    verbose = tolower(verbose)
  )
  print(opts)
  julia_eval(opts)

  # cleanup
  if(input_temp) unlink(train_path, force = TRUE)
  
  # build
  output <- .construct_word2cluster(output, temp = output_temp)
  invisible(output)
}

#' As Word2cluster
#' 
#' Import a previously trained word2cluster model.
#' 
#' @param file Path to model file.
#' 
#' @examples
#' \dontrun{
#' model_path <- as_word2cluster("path/to/file.txt")
#' }
#'
#' @export
as_word2cluster <- function(file){
  assert_that(!missing(file), msg = "Missing `file`")
  path <- normalizePath(file)
  .construct_word2cluster(path, temp = FALSE)
}