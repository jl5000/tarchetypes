% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tar_rep_raw.R
\name{tar_rep_raw}
\alias{tar_rep_raw}
\title{Batched replication with dynamic branching
(raw version).}
\usage{
tar_rep_raw(
  name,
  command,
  batches = 1,
  reps = 1,
  tidy_eval = targets::tar_option_get("tidy_eval"),
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
)
}
\arguments{
\item{name}{Character of length 1, name of the target.}

\item{command}{Expression object with code to run multiple times.
Must return a list or data frame when evaluated.}

\item{batches}{Number of batches. This is also the number of dynamic
branches created during \code{tar_make()}.}

\item{reps}{Number of replications in each batch. The total number
of replications is \code{batches * reps}.}

\item{tidy_eval}{Whether to invoke tidy evaluation
(e.g. the \verb{!!} operator from \code{rlang}) as soon as the target is defined
(before \code{tar_make()}). Applies to the \code{command} argument.}

\item{packages}{Character vector of packages to load right before
the target builds. Use \code{tar_option_set()} to set packages
globally for all subsequent targets you define.}

\item{library}{Character vector of library paths to try
when loading \code{packages}.}

\item{format}{Optional storage format for the target's return value.
With the exception of \code{format = "file"}, each target
gets a file in \verb{_targets/objects}, and each format is a different
way to save and load this file.
Possible formats:
\itemize{
\item \code{"rds"}: Default, uses \code{saveRDS()} and \code{readRDS()}. Should work for
most objects, but slow.
\item \code{"qs"}: Uses \code{qs::qsave()} and \code{qs::qread()}. Should work for
most objects, much faster than \code{"rds"}. Optionally set the
preset for \code{qsave()} through the \code{resources} argument, e.g.
\code{tar_target(..., resources = list(preset = "archive"))}.
\item \code{"fst"}: Uses \code{fst::write_fst()} and \code{fst::read_fst()}.
Much faster than \code{"rds"}, but the value must be
a data frame. Optionally set the compression level for
\code{fst::write_fst()} through the \code{resources} argument, e.g.
\code{tar_target(..., resources = list(compress = 100))}.
\item \code{"fst_dt"}: Same as \code{"fst"}, but the value is a \code{data.table}.
Optionally set the compression level the same way as for \code{"fst"}.
\item \code{"fst_tbl"}: Same as \code{"fst"}, but the value is a \code{tibble}.
Optionally set the compression level the same way as for \code{"fst"}.
\item \code{"keras"}: Uses \code{keras::save_model_hdf5()} and
\code{keras::load_model_hdf5()}. The value must be a Keras model.
\item \code{"torch"}: Uses \code{torch::torch_save()} and \code{torch::torch_load()}.
The value must be an object from the \code{torch} package
such as a tensor or neural network module.
\item \code{"file"}: A dynamic file. To use this format,
the target needs to manually identify or save some data
and return a character vector of paths
to the data. Then, \code{targets} automatically checks those files and cues
the appropriate build decisions if those files are out of date.
Those paths must point to files or directories,
and they must not contain characters \code{|} or \code{*}.
All the files and directories you return must actually exist,
or else \code{targets} will throw an error. (And if \code{storage} is \code{"worker"},
\code{targets} will first stall out trying to wait for the file
to arrive over a network file system.)
\item \code{"url"}: A dynamic input URL. It works like \code{format = "file"}
except the return value of the target is a URL that already exists
and serves as input data for downstream targets. Optionally
supply a custom \code{curl} handle through the \code{resources} argument, e.g.
\code{tar_target(..., resources = list(handle = curl::new_handle()))}.
The data file at the URL needs to have an ETag or a Last-Modified
time stamp, or else the target will throw an error because
it cannot track the data. Also, use extreme caution when
trying to use \code{format = "url"} to track uploads. You must be absolutely
certain the ETag and Last-Modified time stamp are fully updated
and available by the time the target's command finishes running.
\code{targets} makes no attempt to wait for the web server.
\item \code{"aws_rds"}, \code{"aws_qs"}, \code{"aws_fst"}, \code{"aws_fst_dt"},
\code{"aws_fst_tbl"}, \code{"aws_keras"}: AWS-powered versions of the
respective formats \code{"rds"}, \code{"qs"}, etc. The only difference
is that the data file is uploaded to the AWS S3 bucket
you supply to \code{resources}. See the cloud computing chapter
of the manual for details.
\item \code{"aws_file"}: arbitrary dynamic files on AWS S3. The target
should return a path to a temporary local file, then
\code{targets} will automatically upload this file to an S3
bucket and track it for you. Unlike \code{format = "file"},
\code{format = "aws_file"} can only handle one single file,
and that file must not be a directory.
\code{\link[targets:tar_read]{tar_read()}} and downstream targets
download the file to \verb{_targets/scratch/} locally and return the path.
\verb{_targets/scratch/} gets deleted at the end of \code{\link[targets:tar_make]{tar_make()}}.
Requires the same \code{resources} and other configuration details
as the other AWS-powered formats. See the cloud computing
chapter of the manual for details.
}}

\item{iteration}{Character of length 1, name of the iteration mode
of the target. Choices:
\itemize{
\item \code{"vector"}: branching happens with \code{vctrs::vec_slice()} and
aggregation happens with \code{vctrs::vec_c()}.
\item \code{"list"}, branching happens with \verb{[[]]} and aggregation happens with
\code{list()}.
\item \code{"group"}: \code{dplyr::group_by()}-like functionality to branch over
subsets of a data frame. The target's return value must be a data
frame with a special \code{tar_group} column of consecutive integers
from 1 through the number of groups. Each integer designates a group,
and a branch is created for each collection of rows in a group.
See the \code{\link[targets:tar_group]{tar_group()}} function to see how you can
create the special \code{tar_group} column with \code{dplyr::group_by()}.
}}

\item{error}{Character of length 1, what to do if the target
runs into an error. If \code{"stop"}, the whole pipeline stops
and throws an error. If \code{"continue"}, the error is recorded,
but the pipeline keeps going.}

\item{memory}{Character of length 1, memory strategy.
If \code{"persistent"}, the target stays in memory
until the end of the pipeline (unless \code{storage} is \code{"worker"},
in which case \code{targets} unloads the value from memory
right after storing it in order to avoid sending
copious data over a network).
If \code{"transient"}, the target gets unloaded
after every new target completes.
Either way, the target gets automatically loaded into memory
whenever another target needs the value.
For cloud-based dynamic files such as \code{format = "aws_file"},
this memory policy applies to
temporary local copies of the file in \verb{_targets/scratch/"}:
\code{"persistent"} means they remain until the end of the pipeline,
and \code{"transient"} means they get deleted from the file system
as soon as possible. The former conserves bandwidth,
and the latter conserves local storage.}

\item{garbage_collection}{Logical, whether to run \code{base::gc()}
just before the target runs.}

\item{deployment}{Character of length 1, only relevant to
\code{\link[targets:tar_make_clustermq]{tar_make_clustermq()}} and \code{\link[targets:tar_make_future]{tar_make_future()}}. If \code{"worker"},
the target builds on a parallel worker. If \code{"main"},
the target builds on the host machine / process managing the pipeline.}

\item{priority}{Numeric of length 1 between 0 and 1. Controls which
targets get deployed first when multiple competing targets are ready
simultaneously. Targets with priorities closer to 1 get built earlier.
Only applies to \code{\link[targets:tar_make_future]{tar_make_future()}} and \code{\link[targets:tar_make_clustermq]{tar_make_clustermq()}}
(not \code{\link[targets:tar_make]{tar_make()}}). \code{\link[targets:tar_make_future]{tar_make_future()}} with no extra settings is
a drop-in replacement for \code{\link[targets:tar_make]{tar_make()}} in this case.}

\item{resources}{A named list of computing resources. Uses:
\itemize{
\item Template file wildcards for \code{future::future()} in \code{\link[targets:tar_make_future]{tar_make_future()}}.
\item Template file wildcards \code{clustermq::workers()} in \code{\link[targets:tar_make_clustermq]{tar_make_clustermq()}}.
\item Custom target-level \code{future::plan()}, e.g.
\code{resources = list(plan = future.callr::callr)}.
\item Custom \code{curl} handle if \code{format = "url"},
e.g. \code{resources = list(handle = curl::new_handle())}.
\item Custom preset for \code{qs::qsave()} if \code{format = "qs"}, e.g.
\code{resources = list(handle = "archive")}.
\item Custom compression level for \code{fst::write_fst()} if
\code{format} is \code{"fst"}, \code{"fst_dt"}, or \code{"fst_tbl"}, e.g.
\code{resources = list(compress = 100)}.
\item AWS bucket and prefix for the \code{"aws_"} formats, e.g.
\code{resources = list(bucket = "your-bucket", prefix = "folder/name")}.
\code{bucket} is required for AWS formats. See the cloud computing chapter
of the manual for details.
}}

\item{storage}{Character of length 1, only relevant to
\code{\link[targets:tar_make_clustermq]{tar_make_clustermq()}} and \code{\link[targets:tar_make_future]{tar_make_future()}}.
If \code{"main"}, the target's return value is sent back to the
host machine and saved locally. If \code{"worker"}, the worker
saves the value.}

\item{retrieval}{Character of length 1, only relevant to
\code{\link[targets:tar_make_clustermq]{tar_make_clustermq()}} and \code{\link[targets:tar_make_future]{tar_make_future()}}.
If \code{"main"}, the target's dependencies are loaded on the host machine
and sent to the worker before the target builds.
If \code{"worker"}, the worker loads the targets dependencies.}

\item{cue}{An optional object from \code{tar_cue()} to customize the
rules that decide whether the target is up to date.}
}
\value{
A list of two targets, one upstream and one downstream.
The upstream one does some work and returns some file paths,
and the downstream target is a pattern that applies \code{format = "file"}.
}
\description{
Shorthand for a pattern that replicates a command
using batches. Batches reduce the number of targets
and thus reduce overhead.
}
\details{
\code{tar_rep()} and \code{tar_rep_raw} each create two targets:
an upstream local stem
with an integer vector of batch ids, and a downstream pattern
that maps over the batch ids. (Thus, each batch is a branch.)
Each batch/branch replicates the command a certain number of times.

Both batches and reps within each batch
are aggregated according to the method you specify
in the \code{iteration} argument. If \code{"list"}, reps and batches
are aggregated with \code{list()}. If \code{"vector"},
then \code{vctrs::vec_c()}. If \code{"group"}, then \code{vctrs::vec_rbind()}.
}
\examples{
if (identical(Sys.getenv("TARCHETYPES_LONG_EXAMPLES"), "true")) {
targets::tar_dir({
targets::tar_script({
  targets::tar_pipeline(
    tarchetypes::tar_rep_raw(
      "x",
      expression(data.frame(x = sample.int(1e4, 2))),
      batches = 2,
      reps = 3
    )
  )
})
targets::tar_make(callr_function = NULL)
targets::tar_read(x)
})
}
}
