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
#' # setup word2vec Julia dependency
#' setup_word2vec()
#' 
#' # sample corpus
#' data("macbeth", package = "word2vec.r")
#' 
#' # train model
#' model_path <- word2vec(macbeth)
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
  if(!file.exists(train[1])){
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
  julia_eval(opts)

  # cleanup
  if(input_temp) unlink(train_path, force = TRUE)
  
  # build
  output <- .construct_word2vec(output, temp = output_temp)
  invisible(output)
}

#' As Word2vec
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
  assert_that(!file.exists(file), msg = "`file` does not exist")
  path <- normalizePath(file)
  .construct_word2vec(path, temp = FALSE)
}

#' Word Vectors
#' 
#' Generate a word vectors from the model file.
#' 
#' @param file Path to model, output of \code{\link{word2vec}} or \code{\link{as_word2vec}}.
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
#' model_path <- word2vec(macbeth)
#' 
#' # get word vectors
#' model <- word_vectors(model_path)
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
  assert_that(file.exists(file$file), msg = "`file` does not exist")
  opts <- glue::glue('wordvectors("{file}");', file = file$file)
  model <- julia_eval(opts)
  if(file$temp) unlink(file$file, force = TRUE) # cleanup
  .construct_word2vec_model(model)
}

#' Word Vectors Reference Class
#'
#' Convert the output of \code{word_vectors} into a convenient reference class.
#' 
#' @section Methods: 
#' All methods applicable to objects of class \code{wordvectors} as returned 
#' by \code{\link{word_vectors}} are valid here. See their respective man pages
#' for documentation on their arguments and return values.
#' 
#' \itemize{
#'   \item{\code{\link{get_vector}}}
#'   \item{\code{\link{vocabulary}}}
#'   \item{\code{\link{in_vocabulary}}}
#'   \item{\code{\link{size}}}
#'   \item{\code{\link{index}}}
#'   \item{\code{\link{cosine}}}
#'   \item{\code{\link{cosine_similar_words}}}
#'   \item{\code{\link{similarity}}}
#'   \item{\code{\link{analogy}}}
#'   \item{\code{\link{analogy_words}}}
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
#' model_path <- word2vec(macbeth)
#' 
#' # get word vectors
#' model <- word_vectors(model_path)
#' wv <- WordVectors$new(model)
#' wv$get_vector("king")
#' wv$in_vocabulary("cake")
#' }
#' 
#' @export
WordVectors <- R6::R6Class(
  "WordVectors",
  public = list(
    initialize = function(model){
      assert_that(!missing(model), msg = "Missing `model`")
      private$.model <- model
    },
    get_vector = function(word){
      get_vector(private$.model, word)
    },
    vocabulary = function(word){
      vocabulary(private$.model)
    },
    in_vocabulary = function(word){
      in_vocabulary(private$.model, word)
    },
    size = function(){
      size(private$.model)
    },
    index = function(word){
      index(private$.model, word)
    },
    cosine = function(word, n = 10L){
      cosine(private$.model, word, n = 10L)
    },
    cosine_similar_words = function(word, n = 10L){
      cosine_similar_words(private$.model, word, n = 10L)
    },
    similarity = function(word1, word2){
      similarity(private$.model, word1, word2)
    },
    analogy = function(pos, neg, n = 5L){
      analogy(private$.model, pos, neg, n = 5L)
    },
    analogy_words = function(pos, neg, n = 5L){
      analogy_words(private$.model, pos, neg, n = 5L)
    }
  ),
  private = list(
    .model = NULL
  )
)

#' Get Vector
#' 
#' Extract a specific word vector.
#' 
#' @param model A model as returned by \code{\link{word_vectors}}.
#' @param word The word to extract.
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
#' model_path <- word2vec(macbeth)
#' 
#' # get word vectors
#' model <- word_vectors(model_path)
#' 
#' # get vector of specific word
#' get_vector(model, "macbeth")
#' }
#' 
#' @name get_vector
#' 
#' @export
get_vector <- function(model, word) UseMethod("get_vector")

#' @rdname get_vector
#' @method get_vector wordvectors
#' @export
get_vector.wordvectors <- function(model, word){
  assert_that(!missing(word), msg = "Missing `word`")
  julia_call("get_vector", model, word)
}

#' Get Vocabulary
#' 
#' Return the vocabulary as a vector of words.
#' 
#' @param model A model as returned by \code{\link{word_vectors}} or
#' \code{\link{word_clusters}}.
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
#' model_path <- word2vec(macbeth)
#' 
#' # get word vectors
#' model <- word_vectors(model_path)
#' 
#' # get vocabulary
#' vocab <- vocabulary(model)
#' head(vocab)
#' }
#' 
#' @name vocabulary
#' 
#' @export
vocabulary <- function(model) UseMethod("vocabulary")

#' @rdname vocabulary
#' @method vocabulary wordvectors
#' @export
vocabulary.wordvectors <- function(model){
  julia_call("vocabulary", model)
}

#' @rdname vocabulary
#' @method vocabulary wordclusters
#' @export
vocabulary.wordclusters <- function(model){
  julia_call("vocabulary", model)
}

#' In Vocabulary
#' 
#' Return whether a specific word is in the vocabulary.
#' 
#' @inheritParams get_vector
#' @param model A model as returned by \code{\link{word_vectors}} or
#' \code{\link{word_clusters}}.
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
#' model_path <- word2vec(macbeth)
#' 
#' # get word vectors
#' model <- word_vectors(model_path)
#' 
#' # check if James I is mentioned
#' in_vocabulary(model, "james")
#' }
#' 
#' @name in_vocabulary
#' 
#' @export
in_vocabulary <- function(model, word) UseMethod("in_vocabulary")

#' @rdname in_vocabulary
#' @method in_vocabulary wordvectors
#' @export
in_vocabulary.wordvectors <- function(model, word){
  assert_that(!missing(word), msg = "Missing `word`")
  julia_call("in_vocabulary", model, word)
}

#' @rdname in_vocabulary
#' @method in_vocabulary wordclusters
#' @export
in_vocabulary.wordclusters <- function(model, word){
  assert_that(!missing(word), msg = "Missing `word`")
  julia_call("in_vocabulary", model, word)
}

#' Size
#' 
#' Return the word vector length and the number of words.
#' 
#' @inheritParams get_vector
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
#' model_path <- word2vec(macbeth)
#' 
#' # get word vectors
#' model <- word_vectors(model_path)
#' 
#' # check size of model
#' size(model)
#' }
#' 
#' @name size
#' 
#' @export
size <- function(model) UseMethod("size")

#' @rdname size
#' @method size wordvectors
#' @export
size.wordvectors <- function(model){
  size <- julia_call("size", model)
  class(size) <- "list" # dangerous but wtf, a tuple is just a list innit
  tibble::tibble(
    length = as.integer(size[[1]]),
    words = as.integer(size[[2]])
  )
}

#' Index
#' 
#' Return the index of the work in the vectors.
#' 
#' @inheritParams get_vector
#' @param model A model as returned by \code{\link{word_vectors}} or
#' \code{\link{word_clusters}}.
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
#' model_path <- word2vec(macbeth)
#' 
#' # get word vectors
#' model <- word_vectors(model_path)
#' 
#' # cindex of macbeth
#' index(model, "macbeth")
#' }
#' 
#' @name index2
#' 
#' @export
index <- function(model, word) UseMethod("index")

#' @rdname index2
#' @method index wordvectors
#' @export
index.wordvectors <- function(model, word){
  assert_that(!missing(word), msg = "Missing `word`")
  julia_call("index", model, word)
}

#' @rdname index2
#' @method index wordclusters
#' @export
index.wordclusters <- function(model, word){
  assert_that(!missing(word), msg = "Missing `word`")
  julia_call("index", model, word)
}

#' Cosine
#' 
#' Return the position of \code{n} (by default \code{n = 10}) neighbors 
#' of \code{word} and their cosine similarities.
#' 
#' @inheritParams get_vector
#' @param n Number of neightbours to return.
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
#' model_path <- word2vec(macbeth)
#' 
#' # get word vectors
#' model <- word_vectors(model_path)
#' 
#' # neighbours of macbeth and their cosine
#' cosine(model, "macbeth", 20L)
#' }
#' 
#' @return A \link[tibble]{tibble} of word \code{index} and their \code{cosine}.
#' 
#' @name cosine
#' 
#' @export
cosine <- function(model, word, n = 10L) UseMethod("cosine")

#' @rdname cosine
#' @method cosine wordvectors
#' @export
cosine.wordvectors <- function(model, word, n = 10L){
  assert_that(!missing(word), msg = "Missing `word`")
  n <- as.integer(n) # force integer
  cosine <- julia_call("cosine", model, word, n)
  class(cosine) <- "list" # dangerous but wtf, a tuple is just a list innit
  tibble::tibble(
    index = as.integer(cosine[[1]]),
    cosine = as.numeric(cosine[[2]])
  )
}

#' Similarity
#' 
#' Return the cosine similarity value between two words \code{word1} and \code{word2}.
#' 
#' @inheritParams get_vector
#' @param word1,word2 Words to compare.
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
#' model_path <- word2vec(macbeth)
#' 
#' # get word vectors
#' model <- word_vectors(model_path)
#' 
#' # similarity b/w macbeth and wife
#' similarity(model, "macbeth", "king")
#' }
#' 
#' @name similarity
#' 
#' @export
similarity <- function(model, word1, word2) UseMethod("similarity")

#' @rdname similarity
#' @method similarity wordvectors
#' @export
similarity.wordvectors <- function(model, word1, word2){
  assert_that(!missing(word1), msg = "Missing `word1`")
  assert_that(!missing(word2), msg = "Missing `word2`")
  julia_call("similarity", model, word1, word2)
}

#' Cosine Similar Words
#' 
#' Return the top \code{n} (by default \code{n = 10}) words 
#' similar to \code{word}.
#' 
#' @inheritParams get_vector
#' @param n Number of neightbours to return.
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
#' model_path <- word2vec(macbeth)
#' 
#' # get word vectors
#' model <- word_vectors(model_path)
#' 
#' # words similar to macbeth
#' cosine_similar_words(model, "macbeth", 20L)
#' }
#' 
#' @name cosine_similar_words
#' 
#' @export
cosine_similar_words <- function(model, word, n = 10L) UseMethod("cosine_similar_words")

#' @rdname cosine_similar_words
#' @method cosine_similar_words wordvectors
#' @export
cosine_similar_words.wordvectors <- function(model, word, n = 10L){
  assert_that(!missing(word), msg = "Missing `word`")
  n <- as.integer(n) # force integer
  julia_call("cosine_similar_words", model, word, n)
}

#' Analogy
#' 
#' Compute the analogy similarity between two lists of words. The positions
#' and the similarity values of the top \code{n} similar words will be returned.
#' For example: "king - man + woman =~ queen"
#' 
#' @inheritParams get_vector
#' @param pos,neg Positive and negative words.
#' @param n Number of neightbours to return.
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
#' model_path <- word2vec(macbeth)
#' 
#' # get word vectors
#' model <- word_vectors(model_path)
#' 
#' # "king - man + woman =~ queen"
#' analogy_words(model, pos = list("king"), neg = list("malcolme"), 8L)
#' }
#' 
#' @name analogy
#' 
#' @export
analogy <- function(model, pos, neg, n = 5L) UseMethod("analogy")

#' @rdname analogy
#' @method analogy wordvectors
#' @export
analogy.wordvectors <- function(model, pos, neg, n = 5L){
  n <- as.integer(n) # force integer
  cosine <- julia_call("analogy", model, as.list(pos), as.list(neg), n)
  class(cosine) <- "list" # dangerous but wtf, a tuple is just a list innit
  tibble::tibble(
    index = as.integer(cosine[[1]]),
    cosine = as.numeric(cosine[[2]])
  )
}

#' @rdname analogy
#' @export
analogy_words <- function(model, pos, neg, n = 5L) UseMethod("analogy_words")

#' @rdname analogy
#' @method analogy_words wordvectors
#' @export
analogy_words.wordvectors <- function(model, pos, neg, n = 5L){
  n <- as.integer(n) # force integer
  julia_call("analogy_words", model, as.list(pos), as.list(neg), n)
}
