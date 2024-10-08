% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/deprecated.R
\name{deprecated}
\alias{deprecated}
\title{Deprecated functions in GeneTonic}
\arguments{
\item{...}{Ignored arguments.}
}
\value{
All functions throw a warning, with a deprecation message pointing
towards its descendent (if available).
}
\description{
Functions that are on their way to the function afterlife.
Their successors are also listed.
}
\details{
The successors of these functions are likely coming after the rework that
led to the creation of the \code{mosdef} package. See more into its
documentation for more details.
}
\section{Transitioning to the mosdef framework}{

\itemize{
\item \code{\link[=deseqresult2df]{deseqresult2df()}}, now replaced by the more consistent
\code{\link[mosdef:deresult_to_df]{mosdef::deresult_to_df()}}. The only change in its functionality concerns
the parameter names
\item \code{\link[=gene_plot]{gene_plot()}} has now been moved to \code{\link[mosdef:gene_plot]{mosdef::gene_plot()}}, where it
generalizes with respect to the container of the DE workflow object. In a
similar fashion, \code{\link[=get_expression_values]{get_expression_values()}} is replaced by
\code{\link[mosdef:get_expr_values]{mosdef::get_expr_values()}}. Both functions lose the \code{gtl} parameter, which
was anyways not really exploited throughout the different calls in the
package
\item \code{\link[=go_2_html]{go_2_html()}} and \code{\link[=geneinfo_2_html]{geneinfo_2_html()}} have been replaced by the more
information-rich (and flexible) \code{\link[mosdef:go_to_html]{mosdef::go_to_html()}} and
\code{\link[mosdef:geneinfo_to_html]{mosdef::geneinfo_to_html()}}, respectively. No change is expected for the
end user
\item \code{\link[=map2color]{map2color()}} and \code{\link[=styleColorBar_divergent]{styleColorBar_divergent()}} are now moved to the
\code{\link[mosdef:map_to_color]{mosdef::map_to_color()}} and \code{\link[mosdef:styleColorBar_divergent]{mosdef::styleColorBar_divergent()}}, again with
no visible changes for the end user
\item The internally defined functions \code{.link2amigo()}, \code{.link2ncbi()},
\code{.link2genecards()} and \code{.link2gtex()} are now replaced by the equivalent
functions in \code{mosdef}:
\code{\link[mosdef:create_link_GO]{mosdef::create_link_GO()}}, \code{\link[mosdef:create_link_NCBI]{mosdef::create_link_NCBI()}},
\code{\link[mosdef:create_link_GeneCards]{mosdef::create_link_GeneCards()}} and \code{\link[mosdef:create_link_GO]{mosdef::create_link_GO()}}.
Notably, the \code{mosdef} package expanded on the
concept of automatically generated buttons, taking this to the extreme of
efficiency with the \code{\link[mosdef:buttonifier]{mosdef::buttonifier()}} function
}
}

\examples{
# try(deseqresult2df())

}
\author{
Federico Marini
}
