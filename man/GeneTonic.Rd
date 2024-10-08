% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/GeneTonic.R
\name{GeneTonic}
\alias{GeneTonic}
\title{GeneTonic}
\usage{
GeneTonic(
  dds = NULL,
  res_de = NULL,
  res_enrich = NULL,
  annotation_obj = NULL,
  gtl = NULL,
  project_id = "",
  size_gtl = 50
)
}
\arguments{
\item{dds}{A \code{DESeqDataSet} object, normally obtained after running your data
through the \code{DESeq2} framework.}

\item{res_de}{A \code{DESeqResults} object. As for the \code{dds} parameter, this is
also commonly used in the \code{DESeq2} framework.}

\item{res_enrich}{A \code{data.frame} object, storing the result of the functional
enrichment analysis. Required columns for enjoying the full functionality of
\code{\link[=GeneTonic]{GeneTonic()}} include:
\itemize{
\item a gene set identifier (e.g. GeneOntology id, \code{gs_id}) and its term description
(\code{gs_description})
\item a numeric value for the significance of the enrichment (\code{gs_pvalue})
\item a column named \code{gs_genes} containing a comma separated vector of the gene names
associated to the term, one for each term
\item the number of genes in the geneset of interest detected as differentially
expressed (\code{gs_de_count}), or in the background set of genes (\code{gs_bg_count})
See \code{\link[=shake_topGOtableResult]{shake_topGOtableResult()}} or \code{\link[=shake_enrichResult]{shake_enrichResult()}} for examples of such
formatting helpers
}}

\item{annotation_obj}{A \code{data.frame} object, containing two columns, \code{gene_id}
with a set of unambiguous identifiers (e.g. ENSEMBL ids) and \code{gene_name},
containing e.g. HGNC-based gene symbols. This object can be constructed via
the \code{org.eg.XX.db} packages, e.g. with convenience functions such as
\code{\link[mosdef:get_annotation_orgdb]{mosdef::get_annotation_orgdb()}}.}

\item{gtl}{A \code{GeneTonic}-list object, containing in its slots the arguments
specified above: \code{dds}, \code{res_de}, \code{res_enrich}, and \code{annotation_obj} - the names
of the list \emph{must} be specified following the content they are expecting}

\item{project_id}{A character string, which can be considered as an identifier
for the set/session, and will be e.g. used in the title of the report created
via \code{\link[=happy_hour]{happy_hour()}}}

\item{size_gtl}{Numeric value, specifying the maximal size in MB for the
accepted GeneTonicList object - this applies when uploading the dataset at
runtime}
}
\value{
A Shiny app object is returned, for interactive data exploration
}
\description{
GeneTonic, main function for the Shiny app
}
\examples{
library("macrophage")
library("DESeq2")
library("org.Hs.eg.db")
library("AnnotationDbi")

# dds object
data("gse", package = "macrophage")
dds_macrophage <- DESeqDataSet(gse, design = ~ line + condition)
rownames(dds_macrophage) <- substr(rownames(dds_macrophage), 1, 15)
dds_macrophage <- estimateSizeFactors(dds_macrophage)

# annotation object
anno_df <- data.frame(
  gene_id = rownames(dds_macrophage),
  gene_name = mapIds(org.Hs.eg.db,
    keys = rownames(dds_macrophage),
    column = "SYMBOL",
    keytype = "ENSEMBL"
  ),
  stringsAsFactors = FALSE,
  row.names = rownames(dds_macrophage)
)


# res object
data(res_de_macrophage, package = "GeneTonic")
res_de <- res_macrophage_IFNg_vs_naive

# res_enrich object
data(res_enrich_macrophage, package = "GeneTonic")
res_enrich <- shake_topGOtableResult(topgoDE_macrophage_IFNg_vs_naive)
res_enrich <- get_aggrscores(res_enrich, res_de, anno_df)

# now everything is in place to launch the app
if (interactive()) {
  GeneTonic(
    dds = dds_macrophage,
    res_de = res_de,
    res_enrich = res_enrich,
    annotation_obj = anno_df,
    project_id = "myexample"
  )
}
# alternatively...
gtl_macrophage <- GeneTonicList(
  dds = dds_macrophage,
  res_de = res_de,
  res_enrich = res_enrich,
  annotation_obj = anno_df
)
# GeneTonic(gtl = gtl_macrophage)

# if running it "as a server", without input data specified:
if (interactive()) {
  GeneTonic(size_gtl = 300)   # for fairly large gtl objects
}
}
\author{
Federico Marini
}
