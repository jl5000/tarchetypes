#' @title Target formats
#' @name tar_formats
#' @description Target archetypes for specialized storage formats.
#' @details These functions are shorthand for targets with specialized
#'   storage formats. For example, `tar_qs(name, fun())` is equivalent to
#'   `tar_target(name, fun(), format = "qs")`.
#'   For details on specialized storage formats, open the help file of the
#'   `targets::tar_target()` function and read about the `format` argument.
#' @return A `tar_target()` object.
#' @inheritParams targets::tar_target
#' @examples
#' if (identical(Sys.getenv("TARCHETYPES_LONG_EXAMPLES"), "true")) {
#' targets::tar_dir({
#' targets::tar_script(
#'   targets::tar_pipeline(
#'     # equivalent to tar_target(x, 1, format = "rds"):
#'     tarchetypes::tar_rds(x, 1)
#'   )
#' )
#' targets::tar_make()
#' })
#' }
NULL

tar_format <- function(format) {
  out <- tar_format_api
  body(out) <- substitute({
    name <- deparse_language(substitute(name))
    envir <- tar_option_get("envir")
    command <- tidy_eval(as.expression(substitute(command)), envir, tidy_eval)
    pattern <- tidy_eval(as.expression(substitute(pattern)), envir, tidy_eval)
    targets::tar_target_raw(
      name = name,
      command = command,
      pattern = pattern,
      packages = packages,
      library = library,
      format = format,
      iteration = iteration,
      error = error,
      memory = memory,
      garbage_collection = garbage_collection,
      deployment = deployment,
      priority = priority,
      resources = resources,
      storage = storage,
      retrieval = retrieval,
      cue = cue
    )
  }, env = list(format = format))
  out
}

tar_format_api <- function(
  name,
  command,
  pattern = NULL,
  tidy_eval = targets::tar_option_get("tidy_eval"),
  packages = targets::tar_option_get("packages"),
  library = targets::tar_option_get("library"),
  iteration = targets::tar_option_get("iteration"),
  error = targets::tar_option_get("error"),
  memory = targets::tar_option_get("memory"),
  garbage_collection = targets::tar_option_get("garbage_collection"),
  deployment = targets::tar_option_get("deployment"),
  priority = targets::tar_option_get("priority"),
  resources = targets::tar_option_get("resources"),
  storage = targets::tar_option_get("storage"),
  retrieval = targets::tar_option_get("retrieval"),
  cue = targets::tar_option_get("cue")
) {
}

#' @export
#' @rdname tar_formats
tar_file <- tar_format("file")

#' @export
#' @rdname tar_formats
tar_url <- tar_format("url")

#' @export
#' @rdname tar_formats
tar_rds <- tar_format("rds")

#' @export
#' @rdname tar_formats
tar_qs <- tar_format("qs")

#' @export
#' @rdname tar_formats
tar_fst <- tar_format("fst")

#' @export
#' @rdname tar_formats
tar_fst_dt <- tar_format("fst_dt")

#' @export
#' @rdname tar_formats
tar_fst_tbl <- tar_format("fst_tbl")

#' @export
#' @rdname tar_formats
tar_keras <- tar_format("keras")
