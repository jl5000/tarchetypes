targets::tar_test("tar_render_rep() manifest", {
  lines <- c(
    "---",
    "title: report",
    "output_format: html_document",
    "params:",
    "  par: \"default value\"",
    "---",
    "",
    "```{r}",
    "print(params$par)",
    "print(tar_read(x))",
    "```"
  )
  writeLines(lines, "report.Rmd")
  targets::tar_script({
    library(tarchetypes)
    tar_pipeline(
      tar_target(x, "value_of_x"),
      tar_render_rep(
        report,
        "report.Rmd",
        params = data.frame(
          par = c("parval1", "parval2", "parval3", "parval4"),
          stringsAsFactors = FALSE
        ),
        batches = 2
      )
    )
  })
  out <- targets::tar_manifest(callr_function = NULL)
  expect_equal(nrow(out), 3L)
  expect_equal(sort(out$name), sort(c("x", "report_params", "report")))
  expect_equal(sum(is.na(out$pattern)), 2L)
  expect_equal(out$pattern[out$name == "report"], "map(report_params)")
})

targets::tar_test("tar_render_rep() graph", {
  lines <- c(
    "---",
    "title: report",
    "output_format: html_document",
    "params:",
    "  par: \"default value\"",
    "---",
    "",
    "```{r}",
    "print(params$par)",
    "print(tar_read(x))",
    "```"
  )
  writeLines(lines, "report.Rmd")
  targets::tar_script({
    library(tarchetypes)
    tar_pipeline(
      tar_target(x, "value_of_x"),
      tar_render_rep(
        report,
        "report.Rmd",
        params = data.frame(
          par = c("parval1", "parval2", "parval3", "parval4"),
          stringsAsFactors = FALSE
        ),
        batches = 2
      )
    )
  })
  out <- targets::tar_network(callr_function = NULL)$edges
  expect_equal(nrow(out), 2L)
  expect_true(any(out$from == "report_params" & out$to == "report"))
  expect_true(any(out$from == "x" & out$to == "report"))
})

targets::tar_test("tar_render_rep() run", {
  lines <- c(
    "---",
    "title: report",
    "output_format: html_document",
    "params:",
    "  par: \"default value\"",
    "---",
    "",
    "```{r}",
    "print(params$par)",
    "print(tar_read(x))",
    "```"
  )
  writeLines(lines, "report.Rmd")
  targets::tar_script({
    library(tarchetypes)
    tar_pipeline(
      tar_target(x, "value_of_x"),
      tar_render_rep(
        report,
        "report.Rmd",
        params = data.frame(
          par = c("parval1", "parval2", "parval3", "parval4"),
          stringsAsFactors = FALSE
        ),
        batches = 2
      )
    )
  })
  targets::tar_make(callr_function = NULL)
  # results of params
  out <- targets::tar_read(report_params)
  exp <- data.frame(
    par = c("parval1", "parval2", "parval3", "parval4"),
    tar_group = c(1L, 1L, 2L, 2L),
    stringsAsFactors = FALSE
  )
  expect_equal(out, exp)
  # results of branch 1
  out <- targets::tar_read(report, branches = 1)
  out <- grep(pattern = "\\.html$", x = out, value = TRUE)
  expect_equal(length(out), 2L)
  expect_true(all(file.exists(out)))
  skip_if_not_installed("xml2")
  read_code <- function(path) {
    file <- xml2::read_html(path)
    out <- xml2::xml_find_all(file, xpath = ".//code")
    as.character(unlist(xml2::as_list(out)))
  }
  out_file <- read_code(out[1])
  expect_true(any(grepl("value_of_x", out_file)))
  expect_true(any(grepl("parval1", out_file)))
  expect_false(any(grepl("parval2", out_file)))
  expect_false(any(grepl("parval3", out_file)))
  expect_false(any(grepl("parval4", out_file)))
  out_file <- read_code(out[2])
  expect_true(any(grepl("value_of_x", out_file)))
  expect_false(any(grepl("parval1", out_file)))
  expect_true(any(grepl("parval2", out_file)))
  expect_false(any(grepl("parval3", out_file)))
  expect_false(any(grepl("parval4", out_file)))
  # results of branch 2
  out <- targets::tar_read(report, branches = 2)
  out <- grep(pattern = "\\.html$", x = out, value = TRUE)
  expect_equal(length(out), 2L)
  expect_true(all(file.exists(out)))
  out_file <- read_code(out[1])
  expect_true(any(grepl("value_of_x", out_file)))
  expect_false(any(grepl("parval1", out_file)))
  expect_false(any(grepl("parval2", out_file)))
  expect_true(any(grepl("parval3", out_file)))
  expect_false(any(grepl("parval4", out_file)))
  out_file <- read_code(out[2])
  expect_true(any(grepl("value_of_x", out_file)))
  expect_false(any(grepl("parval1", out_file)))
  expect_false(any(grepl("parval2", out_file)))
  expect_false(any(grepl("parval3", out_file)))
  expect_true(any(grepl("parval4", out_file)))
  # target invalidation
  out <- targets::tar_outdated(callr_function = NULL)
  expect_equal(out, character(0))
  # change a param
  targets::tar_script({
    library(tarchetypes)
    tar_pipeline(
      tar_target(x, "value_of_x"),
      tar_render_rep(
        report,
        "report.Rmd",
        params = data.frame(
          par = c("parval1", "parval2", "parval3-modified", "parval4"),
          stringsAsFactors = FALSE
        ),
        batches = 2
      )
    )
  })
  targets::tar_make(callr_function = NULL)
  out <- targets::tar_progress()
  out <- out[grepl("^report", out$name), ]
  expect_equal(nrow(out), 3)
  out <- out$progress[!(out$name %in% c("report", "report_params"))]
  expect_equal(out, "built")
})

targets::tar_test("tar_render_rep() run with output_file specified", {
  lines <- c(
    "---",
    "title: report",
    "output_format: html_document",
    "params:",
    "  par: \"default value\"",
    "---",
    "",
    "```{r}",
    "print(params$par)",
    "print(tar_read(x))",
    "```"
  )
  writeLines(lines, "report.Rmd")
  targets::tar_script({
    library(tarchetypes)
    tar_pipeline(
      tar_target(x, "value_of_x"),
      tar_render_rep(
        report,
        "report.Rmd",
        params = data.frame(
          par = c("parval1", "parval2", "parval3", "parval4"),
          output_file = c("f1.html", "f2.html", "f3.html", "f4.html"),
          stringsAsFactors = FALSE
        )
      )
    )
  })
  expect_false(any(file.exists(c("f1.html", "f2.html", "f3.html", "f4.html"))))
  targets::tar_make(callr_function = NULL)
  expect_true(all(file.exists(c("f1.html", "f2.html", "f3.html", "f4.html"))))
  out <- unlist(targets::tar_meta(report, children)$children)
  expect_equal(length(out), 4L)
  expect_equal(length(unique(out)), 4L)
})
