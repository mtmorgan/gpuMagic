% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RCParserSupportFunc.R, R/extCodeManager.R
\name{gpu_cast_float}
\alias{gpu_cast_float}
\alias{gpu_cast_double}
\alias{gpu_cast_uint}
\alias{gpu_cast_int}
\alias{gpu_cast_long}
\alias{gpu_cast_ulong}
\alias{isgreater}
\alias{extractVars}
\alias{extractVars.default}
\alias{extractVars.extCode}
\alias{extractVars.expression}
\title{Internal usage only, the package export this function only for the other package to access.}
\usage{
gpu_cast_float(x)

gpu_cast_double(x)

gpu_cast_uint(x)

gpu_cast_int(x)

gpu_cast_long(x)

gpu_cast_ulong(x)

isgreater(x, y)

extractVars(x)

\method{extractVars}{default}(x)

\method{extractVars}{extCode}(x)

\method{extractVars}{expression}(x)
}
\arguments{
\item{x}{Internal usage only}

\item{y}{Internal usage only}
}
\value{
A double type data

A vector of variables
}
\description{
Internal usage only, the package export this function only for the other package to access.

Internal usage only, the package export this function only for the other package to access.

Internal usage only, the package export this function only for the other package to access.

Internal usage only, the package export this function only for the other package to access.

Internal usage only, the package export this function only for the other package to access.

Internal usage only, the package export this function only for the other package to access.

Internal usage only, the package export this function only for the other package to access.
}
\examples{
gpu_cast_float(10)
#Just to make biocCheck happy with that.
}
