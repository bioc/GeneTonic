#' Dendrogram of the gene set enrichment results
#'
#' Calculate (and plot) the dendrogram of the gene set enrichment results
#'
#' @param res_enrich A `data.frame` object, storing the result of the functional
#' enrichment analysis. See more in the main function, [GeneTonic()], to see the
#' formatting requirements.
#' @param gtl A `GeneTonic`-list object, containing in its slots the arguments
#' specified above: `dds`, `res_de`, `res_enrich`, and `annotation_obj` - the names
#' of the list _must_ be specified following the content they are expecting
#' @param n_gs Integer value, corresponding to the maximal number of gene sets to
#' be included (from the top ranked ones). Defaults to the number of rows of
#' `res_enrich`
#' @param gs_ids Character vector, containing a subset of `gs_id` as they are
#' available in `res_enrich`. Lists the gene sets to be included, additionally to
#' the ones specified via `n_gs`. Defaults to NULL.
#' @param gs_dist_type Character string, specifying which type of similarity (and
#' therefore distance measure) will be used. Defaults to `kappa`, which uses
#' [create_kappa_matrix()]
#' @param clust_method Character string defining the agglomeration method to be
#' used for the hierarchical clustering. See [stats::hclust()] for details, defaults
#' to `ward.D2`
#' @param color_leaves_by Character string, which columns of `res_enrich` will
#' define the color of the leaves. Defaults to `z_score`
#' @param size_leaves_by Character string, which columns of `res_enrich` will
#' define the size of the leaves. Defaults to the `gs_pvalue`
#' @param color_branches_by Character string, which columns of `res_enrich` will
#' define the color of the branches. Defaults to `clusters`, which calls
#' [dynamicTreeCut::cutreeDynamic()] to define the clusters
#' @param create_plot Logical, whether to create the plot as well.
#'
#' @return A dendrogram object is returned invisibly, and a plot can be generated
#' as well on that object.
#' @export
#'
#' @examples
#'
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
#' # res object
#' data(res_de_macrophage, package = "GeneTonic")
#' res_de <- res_macrophage_IFNg_vs_naive
#'
#' # res_enrich object
#' data(res_enrich_macrophage, package = "GeneTonic")
#' res_enrich <- shake_topGOtableResult(topgoDE_macrophage_IFNg_vs_naive)
#' res_enrich <- get_aggrscores(res_enrich, res_de, anno_df)
#'
#' gs_dendro(res_enrich,
#'   n_gs = 100
#' )
gs_dendro <- function(res_enrich,
                      gtl = NULL,
                      n_gs = nrow(res_enrich),
                      gs_ids = NULL,
                      gs_dist_type = "kappa", # alternatives
                      clust_method = "ward.D2",
                      color_leaves_by = "z_score",
                      size_leaves_by = "gs_pvalue",
                      color_branches_by = "clusters",
                      create_plot = TRUE) {
  if (!is.null(gtl)) {
    checkup_gtl(gtl)
    dds <- gtl$dds
    res_de <- gtl$res_de
    res_enrich <- gtl$res_enrich
    annotation_obj <- gtl$annotation_obj
  }

  if (!is.null(color_leaves_by)) {
    if (!color_leaves_by %in% colnames(res_enrich)) {
      stop(
        "Your res_enrich object does not contain the ",
        color_leaves_by,
        " column.\n",
        "Compute this first or select another column to use for the leaves color."
      )
    }
  }
  if (!is.null(size_leaves_by)) {
    if (!size_leaves_by %in% colnames(res_enrich)) {
      stop(
        "Your res_enrich object does not contain the ",
        size_leaves_by,
        " column.\n",
        "Compute this first or select another column to use for the leaves size."
      )
    }
  }

  n_gs <- min(n_gs, nrow(res_enrich))
  gs_to_use <- unique(
    c(
      res_enrich$gs_id[seq_len(n_gs)], # the ones from the top
      gs_ids[gs_ids %in% res_enrich$gs_id] # the ones specified from the custom list
    )
  )

  if (gs_dist_type == "kappa") {
    dmat <- create_kappa_matrix(res_enrich, n_gs = n_gs, gs_ids = gs_ids)
  } else if (gs_dist_type == "jaccard") {
    dmat <- create_jaccard_matrix(res_enrich, n_gs = n_gs, gs_ids = gs_ids, return_sym = TRUE)
  }

  rownames(dmat) <- colnames(dmat) <- res_enrich[gs_to_use, "gs_description"]

  my_hclust <- as.dist(1 - dmat) %>%
    hclust(method = clust_method)
  my_dend <- my_hclust %>%
    as.dendrogram(hang = -1) %>%
    set("leaves_pch", 19)

  dend_idx <- order.dendrogram(my_dend) # keep the sorted index vector for the leaves

  # leaves: colored by Z score
  # size: colored by squared size?
  # branches: indicating the treecut clusters

  if (!is.null(color_leaves_by)) {
    # setup color
    mypal <- rev(scales::alpha(colorRampPalette(RColorBrewer::brewer.pal(name = "RdYlBu", 11))(50), 1))
    col_var <- res_enrich[gs_to_use, color_leaves_by]
    
    if (all(col_var <= 1) & all(col_var > 0)) { # likely p-values...
      col_var <- -log10(col_var)
      mypal <- (scales::alpha(
        colorRampPalette(RColorBrewer::brewer.pal(name = "YlOrRd", 9))(50), 0.8
      ))
      leaves_col <- mosdef::map_to_color(col_var, mypal, symmetric = FALSE,
                              limits = range(na.omit(col_var)))[dend_idx]
      
    } else {
      # e.g. using z_score or aggregated value
      if (prod(range(na.omit(col_var))) >= 0) {
        # gradient palette
        mypal <- (scales::alpha(
          colorRampPalette(RColorBrewer::brewer.pal(name = "Oranges", 9))(50), 0.8
        ))
        leaves_col <- mosdef::map_to_color(col_var, mypal, symmetric = FALSE,
                                limits = range(na.omit(col_var)))[dend_idx]
        
      } else {
        # divergent palette to be used
        mypal <- rev(scales::alpha(
          colorRampPalette(RColorBrewer::brewer.pal(name = "RdYlBu", 11))(50), 0.8
        ))
        leaves_col <- mosdef::map_to_color(col_var, mypal, symmetric = TRUE,
                                limits = range(na.omit(col_var)))[dend_idx]
        
      }
    }
    
    # set NA values to light grey to prevent errors in assigning colors
    leaves_col[is.na(leaves_col)] <- "lightgrey"
    
    my_dend <- set(my_dend, "leaves_col", leaves_col)
  }

  if (!is.null(size_leaves_by)) {
    # setup size
    size_var <- -log10(as.numeric(res_enrich[gs_to_use, "gs_pvalue"]))[dend_idx]
    leaves_size <- 2 * (size_var - min(size_var)) / (max(size_var) - min(size_var) + 1e-10) + 0.3

    my_dend <- set(my_dend, "leaves_cex", leaves_size) # or to use gs_size?
  }

  if (!is.null(color_branches_by)) {
    my.clusters <- unname(dynamicTreeCut::cutreeDynamic(my_hclust,
      distM = as.matrix(dmat),
      minClusterSize = 4,
      verbose = 0
    ))
    # or use rainbow_hcl from colorspace
    clust_pal <- RColorBrewer::brewer.pal(max(my.clusters), "Set1")
    clust_cols <- (clust_pal[my.clusters])[dend_idx]

    my_dend <- branches_attr_by_clusters(my_dend, my.clusters[dend_idx], values = clust_pal)
  }

  if (create_plot) {
    par(mar = c(0, 0, 1, 25))
    plot(my_dend, horiz = TRUE)
  }

  return(invisible(my_dend))
  # to be plotted with plot(my_dend, horiz = TRUE)
  # as.ggdend() %>% ggplot() %>% plotly::ggplotly()
}
