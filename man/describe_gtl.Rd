% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/GeneTonic-extras.R
\name{describe_gtl}
\alias{describe_gtl}
\title{Describe a GeneTonic list}
\usage{
describe_gtl(gtl)
}
\arguments{
\item{gtl}{A \code{GeneTonic}-list object, containing in its named slots the required
\code{dds}, \code{res_de}, \code{res_enrich}, and \code{annotation_obj}}
}
\value{
A character string, that can further be processed (e.g. by \code{message()}
or \code{cat()}, or easily rendered inside Shiny's \code{renderText} elements)
}
\description{
Obtain a quick textual overview of the essential features of the components
of the GeneTonic list object
}
