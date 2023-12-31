% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/GeneTonic-extras.R
\name{editor_to_vector_sanitized}
\alias{editor_to_vector_sanitized}
\title{Extract vectors from editor content}
\usage{
editor_to_vector_sanitized(txt)
}
\arguments{
\item{txt}{A single character text input.}
}
\value{
A character vector representing valid lines in the text input of the
editor.
}
\description{
Extract vectors from the shinyAce editor content, also removing comments
and whitespaces from text.
}
