## code to prepare `DATASET` dataset goes here
library(nltk4r)

macbeth <- gutenberg_raw("shakespeare-macbeth.txt", to_r = TRUE)
macbeth <- tolower(macbeth)
macbeth <- gsub("[[:punct:] ]+", " ", macbeth)
macbeth <- trimws(macbeth)

usethis::use_data(macbeth, overwrite = TRUE)

# Download dataset
# http://mattmahoney.net/dc/text8.zip
temp <- tempfile(fileext = ".zip")
download.file("http://mattmahoney.net/dc/text8.zip", destfile = temp)
unzip(temp, "text8")
unlink(temp, recursive = TRUE, force = TRUE)

text8 <- readLines("text8")

usethis::use_data(text8, overwrite = TRUE)
