#' @title Evaluate multiple expressions created with symbol substitution.
#' @export
#' @description Loop over a grid of values, create an expression object
#'   from each one, and then evaluate that expression.
#'   Helps with general metaprogramming.
#' @return A list of return values from the generated expression objects.
#' @inheritParams tar_eval_raw
#' @param expr Starting expression. Values are iteratively substituted
#'   in place of symbols in `expr` to create each new expression,
#'   and then each new expression is evaluated.
#' @examples
#' # tar_map() is incompatible with tar_render() because the latter
#' # operates on preexisting tar_target() objects. By contrast,
#' # tar_eval() and tar_sub() iterate over the literal code
#' # farther upstream.
#' values <- list(
#'   name = rlang::syms(c("name1", "name2")),
#'   file = list("file1.Rmd", "file2.Rmd")
#' )
#' tar_sub(tar_render(name, file), values = values)
#' targets::tar_dir({
#' file.create(c("file1.Rmd", "file2.Rmd"))
#' str(tar_eval(tar_render(name, file), values = values))
#' # So in your _targets.R file, you can define a pipeline like as below.
#' # Just make sure to set a unique name for each target
#' # (which tar_map() does automatically).
#' values <- list(
#'   name = rlang::syms(c("name1", "name2")),
#'   file = c("file1.Rmd", "file2.Rmd")
#' )
#' targets::tar_pipeline(
#'   tar_eval(tar_render(name, file), values = values)
#' )
#' })
tar_eval <- function(expr, values, envir = parent.frame()) {
  force(envir)
  tar_eval_raw(expr = substitute(expr), values = values, envir = envir)
}
