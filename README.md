
<img src="man/figures/GeneTonic.png" align="right" alt="" width="120" />

<!-- README.md is generated from README.Rmd. Please edit that file -->

# GeneTonic

<a href="https://doi.org/10.1186/s12859-021-04461-5"><img src="https://img.shields.io/badge/doi-GeneTonic-blue.svg"><a>
<a href="https://doi.org/10.1002/cpz1.411"><img src="https://img.shields.io/badge/doi-GeneTonic_protocol-blue.svg"><a>

<!-- badges: start -->

[![R build
status](https://github.com/federicomarini/GeneTonic/workflows/R-CMD-check/badge.svg)](https://github.com/federicomarini/GeneTonic/actions)
[![](https://bioconductor.org/shields/build/devel/bioc/GeneTonic.svg)](https://bioconductor.org/checkResults/devel/bioc-LATEST/GeneTonic/)
[![](https://img.shields.io/github/last-commit/federicomarini/GeneTonic.svg)](https://github.com/federicomarini/GeneTonic/commits/master)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://www.tidyverse.org/lifecycle/#stable)
[![Codecov.io coverage
status](https://codecov.io/github/federicomarini/GeneTonic/coverage.svg?branch=master)](https://codecov.io/github/federicomarini/GeneTonic)
<!-- badges: end -->

The goal of GeneTonic is to analyze and integrate the results from
Differential Expression analysis and functional enrichment analysis.

This package provides a Shiny application that aims to combine at
different levels the existing pieces of the transcriptome data and
results, in a way that makes it easier to generate insightful
observations and hypothesis - combining the benefits of interactivity
and reproducibility, e.g. by capturing the features and gene sets of
interest highlighted during the live session, and creating an HTML
report as an artifact where text, code, and output coexist.

GeneTonic can be found on Bioconductor
(<https://www.bioconductor.org/packages/GeneTonic>).

If you use GeneTonic in your work, please refer to the original
publication :page_facing_up: on BMC Bioinformatics
(<https://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-021-04461-5>,
doi:
[10.1186/s12859-021-04461-5](https://doi.org/10.1186/s12859-021-04461-5)).

A preprint :page_facing_up: on GeneTonic is available on bioRxiv at
<https://www.biorxiv.org/content/10.1101/2021.05.19.444862v1>.

## Installation

You can install the development version of GeneTonic from GitHub with:

``` r
library("remotes")
remotes::install_github("federicomarini/GeneTonic", 
                        dependencies = TRUE, build_vignettes = TRUE)
```

## Example

This is a basic example which shows you how to use `GeneTonic` on a demo
dataset (the one included in the `macrophage` package).

``` r
library("GeneTonic")
example("GeneTonic")

# which will in the end run
library("macrophage")
library("DESeq2")
library("org.Hs.eg.db")
library("AnnotationDbi")

# dds object
data("gse", package = "macrophage")
dds_macrophage <- DESeqDataSet(gse, design = ~line + condition)
rownames(dds_macrophage) <- substr(rownames(dds_macrophage), 1, 15)
dds_macrophage <- estimateSizeFactors(dds_macrophage)

# annotation object
anno_df <- data.frame(
  gene_id = rownames(dds_macrophage),
  gene_name = mapIds(org.Hs.eg.db,
                     keys = rownames(dds_macrophage),
                     column = "SYMBOL",
                     keytype = "ENSEMBL"),
  stringsAsFactors = FALSE,
  row.names = rownames(dds_macrophage)
)

# res object
data(res_de_macrophage, package = "GeneTonic")
res_de <- res_macrophage_IFNg_vs_naive

# res_enrich object
data(res_enrich_macrophage, package = "GeneTonic")
res_enrich <- shake_topGOtableResult(topgoDE_macrophage_IFNg_vs_naive)

GeneTonic(dds = dds_macrophage,
          res_de = res_de,
          res_enrich = res_enrich,
          annotation_obj = anno_df,
          project_id = "my_first_genetonic")
```

## Usage overview

You can find the rendered version of the documentation of `GeneTonic` at
the project website <https://federicomarini.github.io/GeneTonic>,
created with `pkgdown`.

## Sneak peek?

Please visit <http://shiny.imbei.uni-mainz.de:3838/GeneTonic/> to see a
small demo instance running, on the `macrophage` dataset.

## Development

If you encounter a bug, have usage questions, or want to share ideas and
functionality to make this package better, feel free to file an
[issue](https://github.com/federicomarini/GeneTonic/issues).

## Code of Conduct

Please note that the GeneTonic project is released with a [Contributor
Code of
Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

## License

MIT © Federico Marini
