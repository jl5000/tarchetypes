#' @title Create multiple expressions with symbol substitution (raw version).
#' @export
#' @description Loop over a grid of values and create an expression object
#'   from each one. Helps with general metaprogramming. Unlike [tar_sub()],
#'   which quotes the `expr` argument, `tar_sub_raw()` assumes `expr`
#'   is an expression object.
#' @return A list of expression objects.
#' @param expr Expression object with the starting expression.
#'   Values are iteratively substituted
#'   in place of symbols in `expr` to create each new expression.
#' @param values List of values to substitute into `expr` to create
#'   the expressions. All elements of `values` must have the same length.
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
tar_sub_raw <- function(expr, values) {
  assert_lang(expr)
  assert_values_list(values)
  lapply(transpose(values), tar_sub_expr, expr = expr)
}

tar_sub_expr <- function(expr, values) {
  lang <- substitute(
    substitute(expr = expr, env = env),
    env = list(expr = expr, env = values)
  )
  as.expression(eval(lang))
}
