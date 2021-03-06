map <- function(x, f, ...) {
  lapply(X = x, FUN = as_function(f), ...)
}

map_chr <- function(x, f, ...) {
  vapply(X = x, FUN = as_function(f), FUN.VALUE = character(1), ...)
}

map_int <- function(x, f, ...) {
  vapply(X = x, FUN = as_function(f), FUN.VALUE = integer(1), ...)
}

set_names <- function(x, names) {
  names(x) <- unname(names)
  x
}

transpose <- function(x) {
  x <- lapply(x, as.list)
  lapply(seq_along(x[[1]]), transpose_elt, x = x)
}

transpose_elt <- function(index, x) {
  lapply(x, `[[`, index)
}
