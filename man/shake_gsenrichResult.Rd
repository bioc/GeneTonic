% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gs_shaker.R
\name{shake_gsenrichResult}
\alias{shake_gsenrichResult}
\title{Convert a gseaResult object}
\usage{
shake_gsenrichResult(obj)
}
\arguments{
\item{obj}{A \code{gseaResult} object, obtained via \code{clusterProfiler}}
}
\value{
A \code{data.frame} compatible for use in \code{\link[=GeneTonic]{GeneTonic()}} as \code{res_enrich}
}
\description{
Convert a gseaResult object for straightforward use in \code{\link[=GeneTonic]{GeneTonic()}}
}
\details{
This function is able to handle the output of \code{clusterProfiler}'s \code{gseGO} and
\code{GSEA}, as they both return an object of class \code{gseaResult} - and this in turn
contains the information required to create correctly a \code{res_enrich} object.
}
\examples{
# dds
library("macrophage")
library("DESeq2")
data(gse)
dds_macrophage <- DESeqDataSet(gse, design = ~ line + condition)
rownames(dds_macrophage) <- substr(rownames(dds_macrophage), 1, 15)

# res object
data(res_de_macrophage, package = "GeneTonic")
sorted_genes <- sort(
  setNames(res_macrophage_IFNg_vs_naive$log2FoldChange, 
           res_macrophage_IFNg_vs_naive$SYMBOL), 
  decreasing = TRUE
)
\dontrun{
library("clusterProfiler")
library("org.Hs.eg.db")
gsego_IFNg_vs_naive <- gseGO(
  geneList = sorted_genes,
  ont = "BP",
  OrgDb = org.Hs.eg.db,
  keyType = "SYMBOL",
  minGSSize = 10,
  maxGSSize = 500,
  pvalueCutoff = 0.05,
  verbose = TRUE
)

res_enrich <- shake_gsenrichResult(gsego_IFNg_vs_naive)
head(res_enrich)
gtl_macrophage <- GeneTonicList(
  dds = dds_macrophage,
  res_de = res_macrophage_IFNg_vs_naive,
  res_enrich = res_enrich,
  annotation_obj = anno_df
)
}
}
\seealso{
Other shakers: 
\code{\link{shake_davidResult}()},
\code{\link{shake_enrichResult}()},
\code{\link{shake_enrichrResult}()},
\code{\link{shake_fgseaResult}()},
\code{\link{shake_gprofilerResult}()},
\code{\link{shake_topGOtableResult}()}
}
\concept{shakers}
