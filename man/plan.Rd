% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/zzz.plan.R
\name{plan}
\alias{plan}
\title{Plan how to resolve a future}
\usage{
plan(strategy = NULL, ..., substitute = TRUE, .call = TRUE,
  .cleanup = TRUE, .init = TRUE)
}
\arguments{
\item{strategy}{The evaluation function (or name of it) to use
for resolving a future.  If NULL, then the current strategy is returned.}

\item{\dots}{Additional arguments overriding the default arguments
of the evaluation function.  Which additional arguments are supported
depends on what evaluation function is used, e.g. several support
argument \code{workers} but not all.  For details, see the individual
functions of which some are linked to below.}

\item{substitute}{If TRUE, the \code{strategy} expression is
\code{substitute()}:d, otherwise not.}

\item{.call}{(internal) Used for recording the call to this function.}

\item{.cleanup}{(internal) Used to stop implicitly started clusters.}

\item{.init}{(internal) Used to initiate workers.}
}
\value{
If a new strategy is chosen, then the previous one is returned
(invisible), otherwise the current one is returned (visibly).
}
\description{
This function allows \emph{the user} to plan the future, more specifically,
it specifies how \code{\link{future}()}:s are resolved,
e.g. sequentially or in parallel.
}
\details{
The default strategy is \code{\link{sequential}}, but the default can be
configured by option \option{future.plan} and, if that is not set,
system environment variable \env{R_FUTURE_PLAN}.
To reset the strategy back to the default, use \code{plan("default")}.
}
\section{Implemented evaluation strategies}{

\itemize{
 \item{\code{\link{sequential}}:}{
   Resolves futures sequentially in the current \R process.
 }
 \item{\code{\link{transparent}}:}{
   Resolves futures sequentially in the current \R process and
   assignments will be done to the calling environment.
   Early stopping is enabled by default.
 }
 \item{\code{\link{multisession}}:}{
   Resolves futures asynchronously (in parallel) in separate
   \R sessions running in the background on the same machine.
 }
 \item{\code{\link{multicore}}:}{
   Resolves futures asynchronously (in parallel) in separate
   \emph{forked} \R processes running in the background on
   the same machine.  Not supported on Windows.
 }
 \item{\code{\link{multiprocess}}:}{
   If multicore evaluation is supported, that will be used,
   otherwise multisession evaluation will be used.
 }
 \item{\code{\link{cluster}}:}{
   Resolves futures asynchronously (in parallel) in separate
   \R sessions running typically on one or more machines.
 }
 \item{\code{\link{remote}}:}{
   Resolves futures asynchronously in a separate \R session
   running on a separate machine, typically on a different
   network.
 }
}

Other package may provide additional evaluation strategies.
Notably, the \pkg{future.batchtools} package implements a
type of futures that will be resolved via job schedulers
that are typically available on high-performance compute
(HPC) clusters, e.g. LSF, Slurm, TORQUE/PBS, Sun Grid Engine,
and OpenLava.

To "close" any background workers (e.g. `multisession`), change
the plan to something different; `plan(sequential)` is recommended
for this.
}

\section{For package developers}{

Please refrain from modifying the future strategy inside your packages /
functions, i.e. do not call \code{plan()} in your code.  Instead, leave
the control on what backend to use to the end user.  This idea is part of
the core philosophy of the future framework - as a developer you can never
know what future backends the user have access to.  Moreover, by not making
any assumptions about what backends are available, your code will also work
automatically will any new backends developed after you wrote your code.

If you think it is necessary to modify the future strategy within a
function, then make sure to undo the changes when exiting the function.
This can be done using:
\preformatted{
  oplan <- plan()
  on.exit(plan(oplan), add = TRUE)
  [...]
}
}

\examples{
a <- b <- c <- NA_real_

# An sequential future
plan(sequential)
f <- future({
  a <- 7
  b <- 3
  c <- 2
  a * b * c
})
y <- value(f)
print(y)
str(list(a = a, b = b, c = c)) ## All NAs


# A sequential future with lazy evaluation
plan(sequential)
f <- future({
  a <- 7
  b <- 3
  c <- 2
  a * b * c
}) \%lazy\% TRUE
y <- value(f)
print(y)
str(list(a = a, b = b, c = c)) ## All NAs


# A multicore future (specified as a string)
plan("multicore")
f <- future({
  a <- 7
  b <- 3
  c <- 2
  a * b * c
})
y <- value(f)
print(y)
str(list(a = a, b = b, c = c)) ## All NAs


## Multisession futures gives an error on R CMD check on
## Windows (but not Linux or OS X) for unknown reasons.
## The same code works in package tests.
\donttest{

# A multisession future (specified via a string variable)
strategy <- "future::multisession"
plan(strategy)
f <- future({
  a <- 7
  b <- 3
  c <- 2
  a * b * c
})
y <- value(f)
print(y)
str(list(a = a, b = b, c = c)) ## All NAs

}
}
