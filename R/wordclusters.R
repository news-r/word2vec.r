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
#' model_path <- word2clusters(macbeth, classes = 50L)
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
      "word2clusters is ", 
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
#' model_path <- as_word2clusters("path/to/file.txt")
#' }
#'
#' @export
as_word2clusters <- function(file){
  assert_that(!missing(file), msg = "Missing `file`")
  path <- normalizePath(file)
  .construct_word2cluster(path, temp = FALSE)
}

#' Word Clusters
#' 
#' Generate a word clusters from the model file.
#' 
#' @param file Path to model, output of \code{\link{word2clusters}} or \code{\link{as_word2clusters}}.
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
#' model_path <- word2clusters(macbeth, classes = 50L)
#' 
#' # get word vectors
#' model <- word_clusters(model_path)
#' }
#' 
#' @name word_clusters
#' 
#' @seealso \code{\link{word2clusters}}
#' 
#' @export
word_clusters <- function(file) UseMethod("word_clusters")

#' @rdname word_clusters
#' @method word_clusters word2clusters
#' @export
word_clusters.word2clusters <- function(file){
  assert_that(file.exists(file$file), msg = "`file` does not exist")
  opts <- glue::glue('wordclusters("{file}");', file = file$file)
  model <- julia_eval(opts)
  if(file$temp) unlink(file$file, force = TRUE) # cleanup
  .construct_word2clusters_model(model)
}

#' Get Cluster
#' 
#' Return the cluster number for a word in the vocabulary.
#'
#' @param model A model as returned by \code{\link{word_clusters}}.
#' @param word Word to retrieve the cluster.
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
#' model_path <- word2clusters(macbeth, classes = 50L)
#' 
#' # get word clusters
#' model <- word_clusters(model_path)
#' 
#' # get cluster
#' get_cluster(model, "king")
#' get_cluster(model, "macbeth")
#' }
#'
#' @name get_cluster
#' 
#' @export
get_cluster <- function(model, word) UseMethod("get_cluster")

#' @rdname get_cluster
#' @method get_cluster wordclusters
#' @export
get_cluster.wordclusters <- function(model, word){
  assert_that(!missing(word), msg = "Missing `word`")
  julia_call("get_cluster", model, word)
}

#' Clusters
#' 
#' Return all the clusters.
#'
#' @inheritParams get_cluster
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
#' model_path <- word2clusters(macbeth, classes = 50L)
#' 
#' # get word vectors
#' model <- word_clusters(model_path)
#'
#' # get cluster
#' clusters(model)
#' }
#'
#' @name clusters
#' 
#' @export
clusters <- function(model) UseMethod("clusters")

#' @rdname clusters
#' @method clusters wordclusters
#' @export
clusters.wordclusters <- function(model){
  julia_call("clusters", model)
}

#' Get words
#' 
#' Return all the words given a cluster.
#'
#' @inheritParams get_cluster
#' @param cluster Cluster number as integral.
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
#' model_path <- word2clusters(macbeth, classes = 25L)
#' 
#' # get word vectors
#' model <- word_clusters(model_path)
#'
#' # get cluster
#' get_words(model, 2L)
#' }
#'
#' @name get_words
#' 
#' @export
get_words <- function(model, cluster = 0L) UseMethod("get_words")

#' @rdname get_words
#' @method get_words wordclusters
#' @export
get_words.wordclusters <- function(model, cluster = 0L){
  cl <- as.integer(cluster)
  julia_call("get_words", model, cl)
}

#' Word Clusters Reference Class
#'
#' Convert the output of \code{word_clusters} into a convenient reference class.
#' 
#' @section Methods: 
#' All methods applicable to objects of class \code{wordclusters} as returned 
#' by \code{\link{word_clusters}} are valid here. See their respective man pages
#' for documentation on their arguments and return values.
#' 
#' \itemize{
#'   \item{\code{\link{vocabulary}}}
#'   \item{\code{\link{in_vocabulary}}}
#'   \item{\code{\link{index}}}
#'   \item{\code{\link{get_cluster}}}
#'   \item{\code{\link{clusters}}}
#'   \item{\code{\link{get_words}}}
#' }
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
#' model_path <- word2clusters(macbeth, classes = 15L)
#' 
#' # get word vectors
#' model <- word_clusters(model_path)
#' wc <- WordClusters$new(model)
#' wc$get_words(4L)
#' wc$in_vocabulary("cake")
#' }
#' 
#' @export
WordClusters <- R6::R6Class(
  "WordClusters",
  public = list(
    initialize = function(model){
      assert_that(!missing(model), msg = "Missing `model`")
      private$.model <- model
    },
    get_words = function(cluster){
      get_words(private$.model, cluster)
    },
    vocabulary = function(word){
      vocabulary(private$.model)
    },
    in_vocabulary = function(word){
      in_vocabulary(private$.model, word)
    },
    index = function(word){
      index(private$.model, word)
    },
    get_cluster = function(word){
      get_cluster(private$.model)
    },
    clusters = function(word){
      clusters(private$.model)
    }
  ),
  private = list(
    .model = NULL
  )
)