% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gpuFunctions.R
\name{gpuMagic.setOptions}
\alias{gpuMagic.setOptions}
\title{Set the openCL options}
\usage{
gpuMagic.setOptions(...)
}
\arguments{
\item{...}{There are two possible ways to set the options. You can either provide
\enumerate{
\item A named argument which name is the same as the name of the options.
\item An R object obtaining from \code{gpuMagic.getOptions()}
}

to change the options.}
}
\value{
No return value
}
\description{
The functions set the computing precision when compile the GPU code and the number of workers in a computing group.
}
\examples{
#Get all the available options
opt=gpuMagic.getOptions()
#change the default float type
opt$default.float='float'
#set the options
gpuMagic.setOptions(opt)

#set the options(Alternative way)
gpuMagic.setOptions(default.float='float')
}
\seealso{
\code{\link[=gpuMagic.getOptions]{gpuMagic.getOptions()}} for the name of the options.
}
