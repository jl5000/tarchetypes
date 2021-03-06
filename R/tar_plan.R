#' @title A `drake`-plan-like pipeline archetype
#' @description Simplify target specification in pipelines.
#' @details Allows targets with just targets and commands
#'   to be written in the pipeline as `target = command` instead of
#'   `tar_target(target, command)`. Also supports ordinary
#'   target objects if they are unnamed.
#'   `tar_plan(x = 1, y = 2, tar_target(z, 3), tar_render(r, "r.Rmd"))`
#'   is equivalent to
#'   `tar_pipeline(tar_target(x, 1), tar_target(y, 2), tar_target(z, 3), tar_render(r, "r.Rmd"))`. # nolint
#' @export
#' @return A `targets::tar_pipeline()` object.
#' @param ... Named and unnamed targets. All named targets must follow
#'   the `drake`-plan-like `target = command` syntax, and all unnamed
#'   arguments must be explicit calls to create target objects,
#'   e.g. `tar_target()`, target archetypes like [tar_render()], or similar.
#' @examples
#' if (identical(Sys.getenv("TARCHETYPES_LONG_EXAMPLES"), "true")) {
#' targets::tar_dir({
#' lines <- c(
#'   "---",
#'   "title: report",
#'   "output_format: html_document",
#'   "---",
#'   "",
#'   "```{r}",
#'   "targets::tar_read(data)",
#'   "```"
#' )
#' writeLines(lines, "report.Rmd")
#' targets::tar_script({
#'   library(tarchetypes)
#'   tar_plan(
#'     data = data.frame(x = seq_len(26), y = sample.int(26)),
#'     means = colMeans(data),
#'     tar_render(report, "report.Rmd")
#'   )
#' })
#' targets::tar_make()
#' })
#' }
tar_plan <- function(...) {
  commands <- tar_plan_parse(match.call(expand.dots = FALSE)$...)
  targets <- lapply(commands, eval, envir = targets::tar_option_get("envir"))
  targets::tar_pipeline(targets)
}

tar_plan_parse <- function(commands) {
  names <- names(commands) %||% rep("", length(commands))
  is_named <- !is.na(names) & nzchar(names)
  commands[is_named] <- tar_plan_parse_named(commands[is_named])
  commands
}

tar_plan_parse_named <- function(commands) {
  lapply(names(commands), tar_plan_parse_command, commands = commands)
}

tar_plan_parse_command <- function(name, commands) {
  env <- list(name = rlang::sym(name), command = commands[[name]])
  substitute(targets::tar_target(name, command), env = env)
}
