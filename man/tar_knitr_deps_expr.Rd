% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tar_knitr_deps_expr.R
\name{tar_knitr_deps_expr}
\alias{tar_knitr_deps_expr}
\title{Expression with literate programming dependencies.}
\usage{
tar_knitr_deps_expr(path)
}
\arguments{
\item{path}{Character vector, path to one or more R Markdown or
\code{knitr} reports.}
}
\description{
Construct an expression whose global variable dependencies
are the target dependencies of one or more literate programming reports
(R Markdown or \code{knitr}). This helps third-party developers create their
own third-party target factories for literate programming targets
(similar to \code{\link[=tar_knit]{tar_knit()}} and \code{\link[=tar_render]{tar_render()}}).
}
\examples{
lines <- c(
  "---",
  "title: report",
  "output_format: html_document",
  "---",
  "",
  "```{r}",
  "tar_load(data1)",
  "tar_read(data2)",
  "```"
)
report <- tempfile()
writeLines(lines, report)
tar_knitr_deps_expr(report)
}
