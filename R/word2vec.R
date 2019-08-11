#' Word2Vec
#' 
#' Train Word2Vec model.
#' 
#' @export
word2vec <- function(train, output = NULL, size = 100L, window = 5L, 
  sample = 1e-3, hs = 0L,  negative = 5L, threads = 12L, iter = 5L, 
  min_count = 5L, alpha = 0.025, debug = 2L, binary = 1L, cbow = 1L, 
  verbose = TRUE, ...) {
  assert_that(!missing(train), msg = "Missing `train`")
  word2vec(train, output, size = size, window = window, 
    sample = sample, hs = hs,  negative = negative, 
    threads = threads, iter = iter, min_count = min_count, 
    alpha = alpha, debug = debug, binary = binary, cbow = cbow, 
    verbose = verbose, ...
  )
}