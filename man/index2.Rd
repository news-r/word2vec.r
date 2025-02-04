% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/wordvectors.R
\name{index2}
\alias{index2}
\alias{index}
\alias{index.wordvectors}
\alias{index.wordclusters}
\title{Index}
\usage{
index(model, word)

\method{index}{wordvectors}(model, word)

\method{index}{wordclusters}(model, word)
}
\arguments{
\item{model}{A model as returned by \code{\link{word_vectors}} or
\code{\link{word_clusters}}.}

\item{word}{The word to extract.}
}
\description{
Return the index of the work in the vectors.
}
\examples{
\dontrun{
# setup word2vec Julia dependency
setup_word2vec()

# sample corpus
data("macbeth", package = "word2vec.r")

# train model
model_path <- word2vec(macbeth)

# get word vectors
model <- word_vectors(model_path)

# cindex of macbeth
index(model, "macbeth")
}

}
