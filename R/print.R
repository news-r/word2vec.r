#' @export
print.word2vec <- function(x, ...){
  tick_cross <- ifelse(
    x$temp, 
    crayon::green(cli::symbol$tick), 
    crayon::red(cli::symbol$cross)
  )
  cat(
    crayon::blue(cli::symbol$info), "Path:", x$file, "\n",
    tick_cross, "Temp file\n",
    ...
  )
}