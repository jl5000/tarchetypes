#' @title Static aggregation.
#' @export
#' @description Aggregate the results of upstream targets
#'   into a new target.
#' @return A new target object to combine the return values
#'   from the upstream targets.
#' @inheritParams targets::tar_target
#' @param name Symbol, name of the new target.
#' @param ... One or more target objects or list of target objects.
#'   Lists can be arbitrarily nested, as in `targets::tar_pipeline()`.
#' @param command R command to aggregate the targets. Must contain
#'   `!!!.x` where the arguments are to be inserted,
#'   where `!!!` is the unquote splice operator from `rlang`.
#' @param use_names Logical, whether to insert the names of the targets
#'   into the command when splicing.
#' @examples
#' if (identical(Sys.getenv("TARCHETYPES_LONG_EXAMPLES"), "true")) {
#' targets::tar_dir({
#' targets::tar_script({
#'   target1 <- targets::tar_target(x, head(mtcars))
#'   target2 <- targets::tar_target(y, tail(mtcars))
#'   target3 <- tarchetypes::tar_combine(
#'     new_target_name,
#'     target1,
#'     target2,
#'     command = bind_rows(!!!.x)
#'   )
#'   targets::tar_pipeline(target1, target2, target3)
#' })
#' targets::tar_manifest()
#' })
#' }
tar_combine <- function(
  name,
  ...,
  command = vctrs::vec_c(!!!.x),
  use_names = TRUE,
  pattern = NULL,
  packages = targets::tar_option_get("packages"),
  library = targets::tar_option_get("library"),
  format = targets::tar_option_get("format"),
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
  name <- deparse_language(substitute(name))
  targets <- unlist(list(...), recursive = TRUE)
  command <- as.expression(substitute(command))
  pattern <- as.expression(substitute(pattern))
  tar_combine_impl(
    name = name,
    targets = targets,
    command = command,
    use_names = use_names,
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
}

tar_combine_impl <- function(
  name,
  targets,
  command,
  use_names,
  pattern,
  packages,
  library,
  format,
  iteration,
  error,
  memory,
  garbage_collection,
  deployment,
  priority,
  resources,
  storage,
  retrieval,
  cue
) {
  assert_chr(name)
  assert_targets(targets)
  names_chr <- map_chr(targets, ~.x$settings$name)
  names_sym <- rlang::syms(names_chr)
  if (use_names) {
    names(names_sym) <- names_chr
  }
  command <- tidy_eval(command, envir = list(.x = names_sym), tidy_eval = TRUE)
  tar_target_raw(
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
}
