% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/word2phrase.R
\name{word2phrase}
\alias{word2phrase}
\title{Word2Phrases}
\usage{
word2phrase(train, output = NULL, min_count = 5L, threshold = 100L,
  debug = 2L)
}
\arguments{
\item{train}{Use text data from file to train the model.}

\item{output}{Use file to save the resulting word vectors / word clusters.}

\item{min_count}{This will discard words that appear less than \eqn{n} times;
default is \code{5L}.}

\item{threshold}{The numeric value represents the threshold for 
forming the phrases (higher means less phrases); default \code{100L}.}

\item{debug}{Set the debug mode (default = \code{2L} = more info during training)}
}
\description{
Word2Phrases
}
\examples{
\dontrun{
# setup word2vec Julia dependency
setup_word2vec()

# sample corpus
data("macbeth", package = "word2vec.r")

# train model
model_path <- word2phrase(macbeth)
}
}
