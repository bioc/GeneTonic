#' Deprecated functions in GeneTonic
#'
#' Functions that are on their way to the function afterlife.
#' Their successors are also listed.
#' 
#' The successors of these functions are likely coming after the rework that
#' led to the creation of the `mosdef` package. See more into its 
#' documentation for more details. 
#' 
#' @param ... Ignored arguments.
#' 
#' @return All functions throw a warning, with a deprecation message pointing 
#' towards its descendent (if available).
#' 
#' @name deprecated
#' 
#' @section Transitioning to the mosdef framework:
#' 
#' - [deseqresult2df()], now replaced by the more consistent 
#' [mosdef::deresult_to_df()]. The only change in its functionality concerns 
#' the parameter names
#' - [gene_plot()] has now been moved to [mosdef::gene_plot()], where it 
#' generalizes with respect to the container of the DE workflow object. In a 
#' similar fashion, [get_expression_values()] is replaced by 
#' [mosdef::get_expr_values()]. Both functions lose the `gtl` parameter, which
#' was anyways not really exploited throughout the different calls in the 
#' package
#' - [go_2_html()] and [geneinfo_2_html()] have been replaced by the more 
#' information-rich (and flexible) [mosdef::go_to_html()] and 
#' [mosdef::geneinfo_to_html()], respectively. No change is expected for the 
#' end user
#' - [map2color()] and [styleColorBar_divergent()] are now moved to the 
#' [mosdef::map_to_color()] and [mosdef::styleColorBar_divergent()], again with
#' no visible changes for the end user
#' - The internally defined functions `.link2amigo()`, `.link2ncbi()`, 
#' `.link2genecards()` and `.link2gtex()` are now replaced by the equivalent 
#' functions in `mosdef`: 
#' [mosdef::create_link_GO()], [mosdef::create_link_NCBI()], 
#' [mosdef::create_link_GeneCards()] and [mosdef::create_link_GO()]. 
#' Notably, the `mosdef` package expanded on the 
#' concept of automatically generated buttons, taking this to the extreme of 
#' efficiency with the [mosdef::buttonifier()] function
#' 
#' @author Federico Marini
#' 
#' @examples
#' # try(deseqresult2df())
#' 
NULL


## #' @export
## #' @rdname defunct
## trendVar <- function(...) {
##   .Defunct("fitTrendVar")
## }
