
# tarchetypes <img src='man/figures/logo.png' align="right" height="139"/>

[![ropensci](https://badges.ropensci.org/401_status.svg)](https://github.com/ropensci/software-review/issues/401)
[![zenodo](https://zenodo.org/badge/282774543.svg)](https://zenodo.org/badge/latestdoi/282774543)
[![targetopia](https://img.shields.io/badge/targetopia-member-000062?style=flat&labelColor=gray)](https://wlandau.github.io/targetopia.html)
[![cran](http://www.r-pkg.org/badges/version/tarchetypes)](https://cran.r-project.org/package=tarchetypes)
[![status](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![check](https://github.com/wlandau/tarchetypes/workflows/check/badge.svg)](https://github.com/wlandau/tarchetypes/actions?query=workflow%3Acheck)
[![codecov](https://codecov.io/gh/wlandau/tarchetypes/branch/main/graph/badge.svg?token=3T5DlLwUVl)](https://codecov.io/gh/wlandau/targets)
[![lint](https://github.com/wlandau/tarchetypes/workflows/lint/badge.svg)](https://github.com/wlandau/tarchetypes/actions?query=workflow%3Alint)

The `tarchetypes` R package is a collection of target and pipeline
archetypes for the [`targets`](https://github.com/wlandau/targets)
package. These archetypes express complicated pipelines with concise
syntax, which enhances readability and thus reproducibility. Archetypes
are possible because of the flexible metaprogramming capabilities of
[`targets`](https://github.com/wlandau/targets). In
[`targets`](https://github.com/wlandau/targets), one can define a target
as an object outside the central pipeline, and the
[`tar_target_raw()`](https://wlandau.github.io/targets/reference/tar_target_raw.html)
function completely avoids non-standard evaluation. That means anyone
can write their own niche interfaces for specialized projects.
`tarchetypes` aims to include the most common and versatile archetypes
and usage patterns.

## Target archetype example

Consider the following R Markdown report.

    ---
    title: report
    output: html_document
    ---
    
    ```{r}
    library(targets)
    tar_read(dataset)
    ```

We want to define a target to render the report. And because the report
calls `tar_read(dataset)`, this target needs to depend on `dataset`.
Without `tarchetypes`, it is cumbersome to set up the pipeline
correctly.

``` r
# _targets.R
library(targets)
tar_pipeline(
  tar_target(dataset, data.frame(x = letters)),
  tar_target(
    report, {
      # Explicitly mention the symbol `dataset`.
      list(data)
      # Return relative paths to keep the project portable.
      fs::path_rel(
        # Need to return/track all input/output files.
        c( 
          rmarkdown::render(
            input = "report.Rmd",
            # Always run from the project root
            # so the report can find _targets/.
            knit_root_dir = getwd(),
            quiet = TRUE
          ),
          "report.Rmd"
        )
      )
    },
    # Track the input and output files.
    format = "file",
    # Avoid building small reports on HPC.
    deployment = "main"
  )
)
```

With `tarchetypes`, we can simplify the pipeline with the `tar_render()`
archetype.

``` r
# _targets.R
library(targets)
library(tarchetypes)
tar_pipeline(
  tar_target(dataset, data.frame(x = letters)),
  tar_render(report, "report.Rmd")
)
```

Above, `tar_render()` scans code chunks for mentions of targets in
`tar_load()` and `tar_read()`, and it enforces the dependency
relationships it finds. In our case, it reads `report.Rmd` and then
forces `report` to depend on `dataset`. That way, `tar_make()` always
processes `dataset` before `report`, and it automatically reruns
`report.Rmd` whenever `dataset` changes.

## Pipeline archetype example

[`tar_plan()`](https://wlandau.github.io/tarchetypes/reference/tar_plan.html)
is a version of
[`tar_pipeline()`](https://wlandau.github.io/targets/reference/tar_pipeline.html)
that looks and feels like
[`drake_plan()`](https://docs.ropensci.org/drake/reference/drake_plan.html).
For simple targets with no configuration, you can write `target =
command` instead of `tar_target(target, command)`. Ordinarily, pipelines
in `_targets.R` are written like this:

``` r
tar_pipeline(
  tar_target(
    raw_data_file,
    "data/raw_data.csv",
    format = "file"
  ),
  tar_target(
    raw_data,
    read_csv(raw_data_file, col_types = cols())
  ),
  tar_target(
    data,
    raw_data %>%
      mutate(Ozone = replace_na(Ozone, mean(Ozone, na.rm = TRUE)))
  ),
  tar_target(hist, create_plot(data)),
  tar_target(fit, biglm(Ozone ~ Wind + Temp, data)),
  tar_render(report, "report.Rmd")
)
```

With
[`tar_plan()`](https://wlandau.github.io/tarchetypes/reference/tar_plan.html),
the simplest targets become super easy to write.

``` r
tar_plan(
  tar_file(raw_data_file, "data/raw_data.csv", format = "file"),
  # Simple drake-like syntax:
  raw_data = read_csv(raw_data_file, col_types = cols()),
  data =raw_data %>%
    mutate(Ozone = replace_na(Ozone, mean(Ozone, na.rm = TRUE))),
  hist = create_plot(data),
  fit = biglm(Ozone ~ Wind + Temp, data),
  # Needs tar_render() because it is a target archetype:
  tar_render(report, "report.Rmd")
)
```

## Installation

Install the GitHub development version to access the latest features and
patches.

``` r
library(remotes)
install_github("wlandau/tarchetypes")
```

## Documentation

For specific documentation on `tarchetypes`, including the help files of
all user-side functions, please visit the [reference
website](https://wlandau.github.io/tarchetypes/). For documentation on
[`targets`](https://github.com/wlandau/targets) in general, please visit
the [`targets` reference website](https://wlandau.github.io/targets).
Many of the linked resources use `tarchetypes` functions such as
[`tar_render()`](https://wlandau.github.io/tarchetypes/reference/tar_render.html).

## Participation

Development is a community effort, and we welcome discussion and
contribution. By participating in this project, you agree to abide by
the [code of
conduct](https://github.com/wlandau/tarchetypes/blob/main/CODE_OF_CONDUCT.md)
and the [contributing
guide](https://github.com/wlandau/tarchetypes/blob/main/CONTRIBUTING.md).

## Citation

``` r
citation("tarchetypes")
#> Warning in citation("tarchetypes"): no date field in DESCRIPTION file of package
#> 'tarchetypes'
#> Warning in citation("tarchetypes"): could not determine year for 'tarchetypes'
#> from package DESCRIPTION file
#> 
#> To cite package 'tarchetypes' in publications use:
#> 
#>   William Michael Landau (NA). tarchetypes: Archetypes for Targets.
#>   https://wlandau.github.io/tarchetypes/,
#>   https://github.com/wlandau/tarchetypes.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {tarchetypes: Archetypes for Targets},
#>     author = {William Michael Landau},
#>     note = {https://wlandau.github.io/tarchetypes/, https://github.com/wlandau/tarchetypes},
#>   }
```
