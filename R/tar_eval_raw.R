#' @title Evaluate multiple expressions created with symbol substitution
#'   (raw version).
#' @export
#' @description Loop over a grid of values, create an expression object
#'   from each one, and then evaluate that expression.
#'   Helps with general metaprogramming. Unlike [tar_sub()],
#'   which quotes the `expr` argument, `tar_sub_raw()` assumes `expr`
#'   is an expression object.
#' @return A list of return values from evaluating the expression objects.
#' @inheritParams tar_sub_raw
#' @param expr Expression object with the starting expression.
#'   Values are iteratively substituted
#'   in place of symbols in `expr` to create each new expression,
#'   and then each expression is evaluated.
#' @param envir Environment in which to evaluate the new expressions.
#' @examples
#' # tar_map() is incompatible with tar_render() because the latter
#' # operates on preexisting tar_target() objects. By contrast,
#' # tar_eval_raw() and tar_sub_raw() iterate over code farther upstream.
#' values <- list(
#'   name = rlang::syms(c("name1", "name2")),
#'   file = c("file1.Rmd", "file2.Rmd")
#' )
#' tar_sub_raw(quote(tar_render(name, file)), values = values)
#' targets::tar_dir({
#' file.create(c("file1.Rmd", "file2.Rmd"))
#' str(tar_eval_raw(quote(tar_render(name, file)), values = values))
#' # So in your _targets.R file, you can define a pipeline like as below.
#' # Just make sure to set a unique name for each target
#' # (which tar_map() does automatically).
#' values <- list(
#'   name = rlang::syms(c("name1", "name2")),
#'   file = c("file1.Rmd", "file2.Rmd")
#' )
#' targets::tar_pipeline(
#'   tar_eval_raw(quote(tar_render(name, file)), values = values)
#' )
#' })
tar_eval_raw <- function(expr, values, envir = parent.frame()) {
  assert_lang(expr)
  assert_values_list(values)
  force(envir)
  exprs <- tar_sub_raw(expr = expr, values = values)
  lapply(X = exprs, FUN = eval, envir = envir)
}
