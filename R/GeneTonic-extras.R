#' Create a GeneTonicList object
#'
#' Create a list for GeneTonic from the single required components.
#'
#' @details Having this dedicated function saves the pain of remembering which names
#' the components of the list should have.
#' For backwards compatibility, the `GeneTonic_list` function is still provided
#' as a synonim, and will likely be deprecated in the upcoming release cycles.
#' 
#' @param dds A `DESeqDataSet` object, normally obtained after running your data
#' through the `DESeq2` framework.
#' @param res_de A `DESeqResults` object. As for the `dds` parameter, this is
#' also commonly used in the `DESeq2` framework.
#' @param res_enrich A `data.frame` object, storing the result of the functional
#' enrichment analysis. Required columns for enjoying the full functionality of
#' [GeneTonic()] include:
#' - a gene set identifier (e.g. GeneOntology id, `gs_id`) and its term description
#' (`gs_description`)
#' - a numeric value for the significance of the enrichment (`gs_pvalue`)
#' - a column named `gs_genes` containing a comma separated vector of the gene names
#' associated to the term, one for each term
#' - the number of genes in the geneset of interest detected as differentially
#' expressed (`gs_de_count`), or in the background set of genes (`gs_bg_count`)
#' See [shake_topGOtableResult()] or [shake_enrichResult()] for examples of such
#' formatting helpers
#' @param annotation_obj A `data.frame` object, containing two columns, `gene_id`
#' with a set of unambiguous identifiers (e.g. ENSEMBL ids) and `gene_name`,
#' containing e.g. HGNC-based gene symbols. This object can be constructed via
#' the `org.eg.XX.db` packages, e.g. with convenience functions such as
#' [mosdef::get_annotation_orgdb()].
#'
#' @return A `GeneTonic`-list object, containing in its named slots the arguments
#' specified above: `dds`, `res_de`, `res_enrich`, and `annotation_obj` - the names
#' of the list are specified following the requirements for using it as single
#' input to `GeneTonic()`
#'
#' @export
#'
#' @author Federico Marini
#'
#' @examples
#' library("macrophage")
#' library("DESeq2")
#' library("org.Hs.eg.db")
#' library("AnnotationDbi")
#'
#' # dds object
#' data("gse", package = "macrophage")
#' dds_macrophage <- DESeqDataSet(gse, design = ~ line + condition)
#' rownames(dds_macrophage) <- substr(rownames(dds_macrophage), 1, 15)
#' dds_macrophage <- estimateSizeFactors(dds_macrophage)
#'
#' # annotation object
#' anno_df <- data.frame(
#'   gene_id = rownames(dds_macrophage),
#'   gene_name = mapIds(org.Hs.eg.db,
#'     keys = rownames(dds_macrophage),
#'     column = "SYMBOL",
#'     keytype = "ENSEMBL"
#'   ),
#'   stringsAsFactors = FALSE,
#'   row.names = rownames(dds_macrophage)
#' )
#'
#'
#' # res object
#' data(res_de_macrophage, package = "GeneTonic")
#' res_de <- res_macrophage_IFNg_vs_naive
#'
#' # res_enrich object
#' data(res_enrich_macrophage, package = "GeneTonic")
#' res_enrich <- shake_topGOtableResult(topgoDE_macrophage_IFNg_vs_naive)
#' res_enrich <- get_aggrscores(res_enrich, res_de, anno_df)
#'
#' gtl_macrophage <- GeneTonicList(
#'   dds = dds_macrophage,
#'   res_de = res_de,
#'   res_enrich = res_enrich,
#'   annotation_obj = anno_df
#' )
#'
#' # now everything is in place to launch the app
#' if (interactive()) {
#'   GeneTonic(gtl = gtl_macrophage)
#' }
GeneTonicList <- function(dds,
                           res_de,
                           res_enrich,
                           annotation_obj) {
  checkup_GeneTonic(
    dds,
    res_de,
    res_enrich,
    annotation_obj
  )

  gtl <- list(
    dds = dds,
    res_de = res_de,
    res_enrich = res_enrich,
    annotation_obj = annotation_obj
  )

  message(describe_gtl(gtl))

  return(gtl)
}

#' @rdname GeneTonicList
#' @export
GeneTonic_list <- GeneTonicList

#' Describe a GeneTonic list
#'
#' Obtain a quick textual overview of the essential features of the components
#' of the GeneTonic list object
#'
#' @param gtl A `GeneTonic`-list object, containing in its named slots the required
#' `dds`, `res_de`, `res_enrich`, and `annotation_obj`
#'
#' @export
#'
#' @return A character string, that can further be processed (e.g. by `message()`
#' or `cat()`, or easily rendered inside Shiny's `renderText` elements)
describe_gtl <- function(gtl) {
  dds <- gtl$dds
  res_de <- gtl$res_de
  res_enrich <- gtl$res_enrich
  annotation_obj <- gtl$annotation_obj

  # extracting relevant info
  n_features <- nrow(dds)
  n_samples <- ncol(dds)

  n_tested <- nrow(res_de)
  n_upDE <- sum(res_de$log2FoldChange > 0 & res_de$padj < 0.05, na.rm = TRUE)
  n_downDE <- sum(res_de$log2FoldChange < 0 & res_de$padj < 0.05, na.rm = TRUE)
  n_DE <- n_upDE + n_downDE

  n_genesets <- nrow(res_enrich)

  n_featanno <- nrow(annotation_obj)
  n_featids <- ncol(annotation_obj)

  to_print <- c(
    "---------------------------------\n",
    "----- GeneTonicList object ------\n",
    "---------------------------------\n",
    "\n----- dds object -----\n",
    sprintf(
      "Providing an expression object (as DESeqDataset) of %d features over %d samples\n",
      n_features, n_samples
    ),
    "\n----- res_de object -----\n",
    sprintf(
      "Providing a DE result object (as DESeqResults), %d features tested, %d found as DE\n",
      n_tested, n_DE
    ),
    sprintf("Upregulated:     %d\n", n_upDE),
    sprintf("Downregulated:   %d\n", n_downDE),
    "\n----- res_enrich object -----\n",
    sprintf("Providing an enrichment result object, %d reported\n", n_genesets),
    "\n----- annotation_obj object -----\n",
    sprintf(
      "Providing an annotation object of %d features with information on %d identifier types\n",
      n_featanno, n_featids
    )
  )
  return(to_print)
}


#' Information on a GeneOntology identifier
#'
#' Assembles information, in HTML format, regarding a Gene Ontology identifier
#'
#' Also creates a link to the AmiGO database
#'
#' @param go_id Character, specifying the GeneOntology identifier for which
#' to retrieve information
#' @param res_enrich A `data.frame` object, storing the result of the functional
#' enrichment analysis. If not provided, the experiment-related information is not
#' shown, and only some generic info on the identifier is displayed.
#' See more in the main function, [GeneTonic()], to check the
#' formatting requirements (a minimal set of columns should be present).
#'
#' @return HTML content related to a GeneOntology identifier, to be displayed in
#' web applications (or inserted in Rmd documents)
#' @export
#'
#' @examples
#' go_2_html("GO:0002250")
#' go_2_html("GO:0043368")
go_2_html <- function(go_id,
                      res_enrich = NULL) {
  .Deprecated(old = "go_2_html", new = "mosdef::go_to_html", 
              msg = paste0(
                "Please use `mosdef::go_to_html()` in replacement of the `go_2_html()` function, ",
                "originally located in the GeneTonic package. \nCheck the manual page for ",
                "`?mosdef::go_to_html()` to see the details on how to use it"))
  
  mycontent <- mosdef::go_to_html(go_id = go_id,
                                  res_enrich = res_enrich)
  return(mycontent)
}

#' Link to the AmiGO database
#'
#' @param val A string, with the GO identifier
#'
#' @return HTML for an action button
#' @noRd
.link2amigo <- function(val) {
  .Deprecated(old = ".link2amigo", new = "mosdef::create_link_GO", 
              msg = paste0(
                "Please use `mosdef::create_link_GO()` in replacement of the `.link2amigo()` function, ",
                "originally located in the GeneTonic package. \nCheck the manual page for ",
                "`?mosdef::create_link_GO()` to see the details on how to use it"))
  
  mosdef::create_link_GO(val = val)
}

#' Information on a gene
#'
#' Assembles information, in HTML format, regarding a gene symbol identifier
#'
#' Creates links to the NCBI and the GeneCards databases
#'
#' @param gene_id Character specifying the gene identifier for which to retrieve
#' information
#' @param res_de A `DESeqResults` object, storing the result of the differential
#' expression analysis. If not provided, the experiment-related information is not
#' shown, and only some generic info on the identifier is displayed.
#' The information about the gene is retrieved by matching on the `SYMBOL` column,
#' which should be provided in `res_de`.
#'
#' @return HTML content related to a gene identifier, to be displayed in
#' web applications (or inserted in Rmd documents)
#' @export
#'
#' @examples
#' geneinfo_2_html("ACTB")
#' geneinfo_2_html("Pf4")
geneinfo_2_html <- function(gene_id,
                            res_de = NULL) {
  .Deprecated(old = "geneinfo_2_html", new = "mosdef::geneinfo_to_html", 
              msg = paste0(
                "Please use `mosdef::geneinfo_to_html()` in replacement of the `geneinfo_2_html()` function, ",
                "originally located in the GeneTonic package. \nCheck the manual page for ",
                "`?mosdef::geneinfo_to_html()` to see the details on how to use it"))
  
  mycontent <- mosdef::geneinfo_to_html(gene_id = gene_id,
                                        res_de = res_de)
  
  return(mycontent)
}

#' Link to NCBI database
#'
#' @param val Character, the gene symbol
#'
#' @return HTML for an action button
#' @noRd
.link2ncbi <- function(val) {
  .Deprecated(old = ".link2ncbi", new = "mosdef::create_link_NCBI", 
              msg = paste0(
                "Please use `mosdef::create_link_NCBI()` in replacement of the `.link2ncbi()` function, ",
                "originally located in the GeneTonic package. \nCheck the manual page for ",
                "`?mosdef::create_link_NCBI()` to see the details on how to use it"))
  
  mosdef::create_link_NCBI(val = val)
}

#' Link to the GeneCards database
#'
#' @param val Character, the gene symbol of interest
#'
#' @return HTML for an action button
#' @noRd
.link2genecards <- function(val) {
  .Deprecated(old = ".link2genecards", new = "mosdef::create_link_GeneCards", 
              msg = paste0(
                "Please use `mosdef::create_link_GeneCards()` in replacement of the `.link2genecards()` function, ",
                "originally located in the GeneTonic package. \nCheck the manual page for ",
                "`?mosdef::create_link_GeneCards()` to see the details on how to use it"))
  
  mosdef::create_link_GeneCards(val = val)
}

#' Link to the GTEx Portal
#'
#' @param val Character, the gene symbol of interest
#'
#' @return HTML for an action button
#' @noRd
.link2gtex <- function(val) {
  .Deprecated(old = ".link2gtex", new = "mosdef::create_link_GTEX", 
              msg = paste0(
                "Please use `mosdef::create_link_GTEX()` in replacement of the `.link2gtex()` function, ",
                "originally located in the GeneTonic package. \nCheck the manual page for ",
                "`?mosdef::create_link_GTEX()` to see the details on how to use it"))
  
  mosdef::create_link_GTEX(val = val)
}



#' Generate set of buttons for the hub genes
#'
#' @param x String, gene name
#'
#' @return HTML for the action buttons
#' @noRd
generate_buttons_hubgenes <- function(x) {
  mybuttons <- paste(
    tags$b(x), tags$br(),
    sprintf(
      '<a href = "http://www.ncbi.nlm.nih.gov/gene/?term=%s[sym]" target = "_blank" class = "btn btn-primary" style = "%s">%s</a>',
      x,
      .actionbutton_biocstyle,
      "NCBI"
    ),
    sprintf(
      '<a href = "https://www.genecards.org/cgi-bin/carddisp.pl?gene=%s" target = "_blank" class = "btn btn-primary" style = "%s">%s</a>',
      x,
      .actionbutton_biocstyle,
      "GeneCards"
    ),
    sprintf(
      '<a href = "https://www.gtexportal.org/home/gene/%s" target = "_blank" class = "btn btn-primary" style = "%s">%s</a>',
      x,
      .actionbutton_biocstyle,
      "GTEx"
    ),
    tags$br(style = "display:inline-block"),
    collapse = "\t"
  )
  return(mybuttons)
}




#' Calculate overlap coefficient
#'
#' Calculate similarity coefficient between two sets, based on the overlap
#'
#' @param x Character vector, corresponding to set 1
#' @param y Character vector, set 2
#'
#' @return A numeric value between 0 and 1
#' @export
#'
#' @seealso https://en.wikipedia.org/wiki/Overlap_coefficient
#'
#' @examples
#' a <- seq(1, 21, 2)
#' b <- seq(1, 11, 2)
#' overlap_coefficient(a, b)
overlap_coefficient <- function(x, y) {
  length(intersect(x, y)) / min(length(x), length(y))
}

#' Calculate Jaccard Index between two sets
#'
#' Calculate similarity coefficient with the Jaccard Index
#'
#' @param x Character vector, corresponding to set 1
#' @param y Character vector, corresponding to set 2
#'
#' @return A numeric value between 0 and 1
#' @export
#'
#' @examples
#' a <- seq(1, 21, 2)
#' b <- seq(1, 11, 2)
#' overlap_jaccard_index(a, b)
overlap_jaccard_index <- function(x, y) {
  length(intersect(x, y)) / length(unique(c(x, y)))
  # about 2x faster than using union()
}






#' Style DT color bars
#'
#' Style DT color bars for values that diverge from 0.
#'
#' @details This function draws background color bars behind table cells in a column,
#' width the width of bars being proportional to the column values *and* the color
#' dependent on the sign of the value.
#'
#' A typical usage is for values such as `log2FoldChange` for tables resulting from
#' differential expression analysis.
#' Still, the functionality of this can be quickly generalized to other cases -
#' see in the examples.
#'
#' The code of this function is heavily inspired from styleColorBar, and borrows
#' at full hands from an excellent post on StackOverflow -
#' https://stackoverflow.com/questions/33521828/stylecolorbar-center-and-shift-left-right-dependent-on-sign/33524422#33524422
#'
#' @param data The numeric vector whose range will be used for scaling the table
#' data from 0-100 before being represented as color bars. A vector of length 2
#' is acceptable here for specifying a range possibly wider or narrower than the
#' range of the table data itself.
#' @param color_pos The color of the bars for the positive values
#' @param color_neg The color of the bars for the negative values
#'
#' @return This function generates JavaScript and CSS code from the values
#' specified in R, to be used in DT tables formatting.
#'
#' @export
#'
#' @examples
#'
#' data(res_de_macrophage, package = "GeneTonic")
#' res_df <- mosdef::deresult_to_df(res_macrophage_IFNg_vs_naive)
#' library("magrittr")
#' library("DT")
#' DT::datatable(res_df[1:50, ],
#'   options = list(
#'     pageLength = 25,
#'     columnDefs = list(
#'       list(className = "dt-center", targets = "_all")
#'     )
#'   )
#' ) %>%
#'   formatRound(columns = c("log2FoldChange"), digits = 3) %>%
#'   formatStyle(
#'     "log2FoldChange",
#'     background = styleColorBar_divergent(
#'       res_df$log2FoldChange,
#'       scales::alpha("navyblue", 0.4),
#'       scales::alpha("darkred", 0.4)
#'     ),
#'     backgroundSize = "100% 90%",
#'     backgroundRepeat = "no-repeat",
#'     backgroundPosition = "center"
#'   )
#'
#'
#' simplest_df <- data.frame(
#'   a = c(rep("a", 9)),
#'   value = c(-4, -3, -2, -1, 0, 1, 2, 3, 4)
#' )
#'
#' # or with a very simple data frame
#' DT::datatable(simplest_df) %>%
#'   formatStyle(
#'     "value",
#'     background = styleColorBar_divergent(
#'       simplest_df$value,
#'       scales::alpha("forestgreen", 0.4),
#'       scales::alpha("gold", 0.4)
#'     ),
#'     backgroundSize = "100% 90%",
#'     backgroundRepeat = "no-repeat",
#'     backgroundPosition = "center"
#'   )
styleColorBar_divergent <- function(data,
                                    color_pos,
                                    color_neg) {
  .Deprecated(old = "styleColorBar_divergent", new = "mosdef::styleColorBar_divergent", 
              msg = paste0(
                "Please use `mosdef::styleColorBar_divergent()` in replacement of the `styleColorBar_divergent()` function, ",
                "originally located in the GeneTonic package. \nCheck the manual page for ",
                "`?mosdef::styleColorBar_divergent()` to see the details on how to use it"))
  
  code_ret <- mosdef::styleColorBar_divergent(
    data = data,
    color_pos = color_pos,
    color_neg = color_neg
  )
  
  return(code_ret)
}




#' Maps numeric values to color values
#'
#' Maps numeric continuous values to values in a color palette
#'
#' @param x A character vector of numeric values (e.g. log2FoldChange values) to
#' be converted to a vector of colors
#' @param pal A vector of characters specifying the definition of colors for the
#' palette, e.g. obtained via \code{\link{brewer.pal}}
#' @param symmetric Logical value, whether to return a palette which is symmetrical
#' with respect to the minimum and maximum values - "respecting" the zero.
#' Defaults to `TRUE`.
#' @param limits A vector containing the limits of the values to be mapped. If
#' not specified, defaults to the range of values in the `x` vector.
#'
#' @return A vector of colors, each corresponding to an element in the original
#' vector
#' @export
#'
#' @examples
#' a <- 1:9
#' pal <- RColorBrewer::brewer.pal(9, "Set1")
#' map2color(a, pal)
#' plot(a, col = map2color(a, pal), pch = 20, cex = 4)
#'
#' b <- 1:50
#' pal2 <- grDevices::colorRampPalette(
#'   RColorBrewer::brewer.pal(name = "RdYlBu", 11)
#' )(50)
#' plot(b, col = map2color(b, pal2), pch = 20, cex = 3)
map2color <- function(x, pal, symmetric = TRUE, limits = NULL) {
  .Deprecated(old = "map2color", new = "mosdef::map_to_color", 
              msg = paste0(
                "Please use `mosdef::map_to_color()` in replacement of the `map2color()` function, ",
                "originally located in the GeneTonic package. \nCheck the manual page for ",
                "`?mosdef::map_to_color()` to see the details on how to use it"))
  
  pal_ret <- map_to_color(x = x, 
                          pal = pal,
                          symmetric = symmetric,
                          limits = limits)
  return(pal_ret)
}


#' Check colors
#'
#' Check correct specification of colors
#'
#' This is a vectorized version of [grDevices::col2rgb()]
#'
#' @param x A vector of strings specifying colors
#'
#' @return A vector of logical values, one for each specified color - `TRUE` if
#' the color is specified correctly
#' @export
#'
#' @examples
#' # simple case
#' mypal <- c("steelblue", "#FF1100")
#' check_colors(mypal)
#' mypal2 <- rev(
#'   scales::alpha(
#'     colorRampPalette(RColorBrewer::brewer.pal(name = "RdYlBu", 11))(50), 0.4
#'   )
#' )
#' check_colors(mypal2)
#' # useful with long vectors to check at once if all cols are fine
#' all(check_colors(mypal2))
check_colors <- function(x) {
  vapply(x, function(col) {
    tryCatch(is.matrix(col2rgb(col)),
      error = function(e) FALSE
    )
  }, logical(1))
}

#' Generate a table from the `DESeq2` results
#'
#' Generate a tidy table with the results of `DESeq2`
#'
#' @param res_de A `DESeqResults` object.
#' @param FDR Numeric value, specifying the significance level for thresholding
#' adjusted p-values. Defaults to NULL, which would return the full set of results
#' without performing any subsetting based on FDR.
#'
#' @return A tidy `data.frame` with the results from differential expression,
#' sorted by adjusted p-value. If FDR is specified, the table contains only genes
#' with adjusted p-value smaller than the value.
#'
#' @export
#'
#' @examples
#' data(res_de_macrophage, package = "GeneTonic")
#' head(res_macrophage_IFNg_vs_naive)
#' res_df <- mosdef::deresult_to_df(res_macrophage_IFNg_vs_naive)
#' head(res_df)
deseqresult2df <- function(res_de, FDR = NULL) {
  .Deprecated(old = "deseqresult2df", new = "mosdef::deresult_to_df", 
              msg = paste0(
                "Please use `mosdef::deresult_to_df()` in replacement of the `deseqresult2df()` function, ",
                "originally located in the GeneTonic package. \nCheck the manual page for ",
                "`?mosdef::deresult_to_df()` to see the details on how to use it"))
  
  df <- mosdef::deresult_to_df(res_de = res_de,
                               FDR = FDR)
  return(df)
}

#' Export to sif
#'
#' Export a graph to a Simple Interaction Format file
#'
#' @param g An `igraph` object
#' @param sif_file Character string, the path to the file where to save the exported
#' graph as .sif file
#' @param edge_label Character string, defining the name of the interaction type.
#' Defaults here to "relates_to"
#'
#' @return Returns the path to the exported file, invisibly
#'
#' @export
#'
#' @examples
#' library("igraph")
#' g <- make_full_graph(5) %du% make_full_graph(5) %du% make_full_graph(5)
#' g <- add_edges(g, c(1, 6, 1, 11, 6, 11))
#' export_to_sif(g, tempfile())
export_to_sif <- function(g, sif_file = "", edge_label = "relates_to") {
  stopifnot(is(g, "igraph"))
  stopifnot(is.character(sif_file) & length(sif_file) == 1)
  sif_file <- normalizePath(sif_file, mustWork = FALSE)
  stopifnot(is.character(edge_label) && length(edge_label) == 1)

  el <- as_edgelist(g)
  sif_df <- data.frame(
    n1 = el[, 1],
    edge_label = edge_label,
    n2 = el[, 2]
  )
  message("Saving the file to ", sif_file)
  write.table(sif_df,
    file = sif_file, sep = "\t", quote = FALSE,
    col.names = FALSE, row.names = FALSE
  )
  message("Done!")
  return(invisible(sif_file))
}

#' Extract vectors from editor content
#'
#' Extract vectors from the shinyAce editor content, also removing comments
#' and whitespaces from text.
#'
#' @param txt A single character text input.
#'
#' @return A character vector representing valid lines in the text input of the
#' editor.
editor_to_vector_sanitized <- function(txt) {
  rn <- strsplit(txt, split="\n")[[1]]
  rn <- sub("#.*", "", rn)
  rn <- sub("^ +", "", rn)
  sub(" +$", "", rn)
}

GeneTonic_footer <- fluidRow(
  column(
    width = 1,
    align = "right",
    a(
      href = "https://github.com/federicomarini/GeneTonic",
      target = "_blank",
      img(src = "GeneTonic/GeneTonic.png", height = "50px")
    )
  ),
  column(
    width = 11,
    align = "center",
    "GeneTonic is a project developed by Annekathrin Ludt and ",
    tags$a(href = "https://federicomarini.github.io", "Federico Marini"),
    " in the Bioinformatics division of the ",
    tags$a(href = "http://www.unimedizin-mainz.de/imbei", "IMBEI"),
    "- Institute for Medical Biostatistics, Epidemiology and Informatics", br(),
    "License: ", tags$a(href = "https://opensource.org/licenses/MIT", "MIT"),
    "- The GeneTonic package is developed and available on ",
    tags$a(href = "https://github.com/federicomarini/GeneTonic", "GitHub")
  )
)

# Shiny resource paths ----------------------------------------------------

.onLoad <- function(libname, pkgname) {
  # Create link to logo
  # nocov start
  shiny::addResourcePath("GeneTonic", system.file("www", package = "GeneTonic"))
  # nocov end
}


# Some constant values ----------------------------------------------------

.actionbutton_biocstyle <- "color: #ffffff; background-color: #0092AC"
.helpbutton_biocstyle <- "color: #0092AC; background-color: #FFFFFF; border-color: #FFFFFF"

# custom download button with icon and color tweaks
gt_downloadButton <- function(outputId,
                              label = "Download",
                              icon = "magic",
                              class = NULL,
                              ...) {
  aTag <- tags$a(
    id = outputId,
    class = paste("btn btn-default shiny-download-link", class),
    href = "",
    target = "_blank",
    download = NA,
    icon(icon),
    label
  )
  return(aTag)
}


.gt_code_setup <- c(
  "library('GeneTonic')",
  "",
  "# this information is taken from the gtl object you're working on",
  "# you can read it in from a serialized object",
  "# gtl <- readRDS('path/to/GeneTonicList.rds')",
  "# get a quick overview on the object",
  "message(describe_gtl(gtl))",
  "",
  "# setup the individual elements for the explicit call",
  "dds <- gtl$dds",
  "res_enrich <- gtl$res_enrich",
  "res_de <- gtl$res_de",
  "annotation_obj <- gtl$annotation_obj",
  "",
  "# this is the part dedicated to the function call"
)

.gt_code_closeup <- c(
  "",
  "# this is a ggplot object, so you can save it with a call to `ggsave()`",
  "# ggsave('plot_filename.png')    # you can change the extension"
)


.biocgreen <- "#0092AC"
