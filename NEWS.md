# GeneTonic 2.99.0

## Other notes

* The transition to the functions available in the `mosdef` Bioconductor is complete, with the original functions now being deprecated. This applies to `goseqTable()` (now replaced by `mosdef::run_goseq()`), which has now been made faster and more robust in its functionality and in the ways it can be executed
* The gene plot widgets now also use the `gene_plot()` function from `mosdef`, instead of the previous `ggplotCounts()` function - `gene_plot()` is more flexible and has more options to control the behavior of the final plot object
* The `deseqresult2tbl()` and `deseqresult2DEgenes()` are now replaced by the more flexible `mosdef::deresult_to_df()`
* The internally defined `createLinkENS()`, `createLinkGeneSymbol()`, and `createLinkGO()` are now replaced by the equivalent functions in `mosdef`
* The Roxygen-based documentation now supports markdown. No visible changes should appear to the user, as the content should have stayed fairly the same
* Although no visible changes for the end user are expected, the incoming major version bump will reflect the change in the dependency graph, ensuring that this is noticed at least at the version numbering level


# GeneTonic 2.8.0

## Other notes

* Updated functions used from other packages to reflect changes in their API/nomenclature
* Adapted the internal code of functions to the latest version of `igraph` - no changes happening 
for the end user

# GeneTonic 2.6.0

## Bug fixes

* `describe_gtl()` correctly extracts the number of up and down regulated genes from the DE results
* Fortified the behavior of `gs_scores()` to handle cases where only one gene would be included in the
signature to plot

# GeneTonic 2.4.0

## New features

* `enhance_table()` has now the possibility to plot the visual summaries as ridge lines.
* When plotting the gene expression for the selected features in the gene-geneset-graph box, it is now possible to disable the labels from being displayed (could lead to unnecessary clutter sometimes).

## Other notes

* Fortified the behavior of `gene_plot()` to fail early when providing an invalid value to the `intgroup` parameter.

# GeneTonic 2.2.0

## New features

* `gs_heatmap` gains the `winsorize_threshold` parameter, to control the behavior of the geneset heatmap in presence of extreme values, either negative or positive ones. If not specified, the heatmap is not introducing any winsorization.
* `map2color()` has a behavior that better accounts for asymmetric ranges of values. This propagates to some of the functions that use it for mapping to colors, such as `enrichment_map()`, or `ggs_backbone()`.

## Other notes

* Fixed the behavior of the reactive elements after uploading the `GeneTonicList` object at runtime. 
* Fixed the label namings for the `gs_heatmap` function
* The `enhance_table()` function can handle the case where a gene is in the enrichment results table but not present in the annotation (e.g. annotations are updated, so some correspondences might get lost). It also presents an informative message on which genesets/genes are potentially responsible for the behavior. 
* Some additional checks are in place for controlling the cases where the `z_score` of a geneset is detected as NA (e.g. because there was a mismatch between gene names and identifiers in the annotation).
 
# GeneTonic 2.0.0

## New features

* `GeneTonic` now offers the possibility to upload a `GeneTonicList` at runtime. This makes it possible to use the app as a server-like dashboard, which runs by default on no dataset provided, and populates its components upon successfully providing the data as expected
* The `GeneSpector` functionality in the Welcome panel provides a means to explore any gene in the expression set, coloring and grouping by any experimental covariate of interest
* It is possible to enter a set of genes and genesets in the Bookmarks panel, and these can be doubled checked against the available features of the current `GeneTonicList` - this, combined to the upload functionality, makes it possible to easily compare different `gtl` objects
* The `GeneTonic` app has a button to export the currently provided dataset - regardless of the input format - as a `GeneTonicList`. This is especially useful if one is providing the individual components (`dds`, `res_de`, `res_enrich`, `annotation_obj`) and would like to obtain the correct serialized object 
* `gs_upset` adds the possibility to represent the results of enrichment analyses as upset plots, with the option to decorate them with DE-related information

## Other notes

* The manuscript about `GeneTonic` is now published on BMC Bioinformatics at https://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-021-04461-5 - the citation item has been updated accordingly
* The jittered position in the `gene_plot` is now completely reproducible, by setting a seed internally in the jitter generating function

# GeneTonic 1.6.0

## New features

* `GeneTonic` can now accept the input of `clusterProfiler`'s gene set enrichment analysis functions (`gseGO` and `GSEA`), as implemented in the `shake_gsenrichResult()` function
* Below each plot and interactive widget, we provide a button that opens up a modal window where the code required to reproduce that output is shown as a snippet. These can be readily copied in extended reports or used to document the exploratory process.

## Other notes

* The manuscript about `GeneTonic` is now available on bioRxiv at https://www.biorxiv.org/content/10.1101/2021.05.19.444862v1 - the citation item has been updated accordingly
* `GeneTonic`'s Shiny app now uses the latest version of `bs4Dash`, which introduced some breaking changes. Most elements should be now available as they were in the original implementation

# GeneTonic 1.4.0

## New features

* The main function `GeneTonic()` gains an extra parameter, `gtl` - this can be used to provided a named list object where a single parameter is passed (e.g. after loading in a single serialized object), while the functionality stays unaltered. 
  The same `gtl` parameter is also exposed in other functions of the package - see the vignette for some examples, or check the documentation of each specific function.
  To create this object in a standardized manner, the function `GeneTonic_list()` is now available.
  
* A new function to perform fuzzy clustering (following the implementation of DAVID) is added - see `gs_fuzzyclustering()`. It returns a table with additional information on the cluster of genesets and the status of each set in the group.  

* The `ggs_backbone()` function can extract the bipartite graph backbone from the Gene-Geneset graph, this can be further explored below the main element in the Gene-Geneset panel. Once the backbone is created, you are one step away from checking out the genes that act as "hubs" in the Gene-Geneset graph, and possibly identify the nodes playing an essential role based on their connectivity.

* A new function, `signature_volcano()`, adds a signature volcano plot to the Gene-Geneset panel. This plot displays the genes of a chosen geneset in color, while the remaining genes of the data are shown as shaded dots in the background. 
  The color and transparency of the displayed genes can be chosen by the user, as well as the option to display the gene names of all genes in the geneset.

* `gs_summary_overview()` can also generate bar plots instead of the default segment-dot (lollipop) plots.

* A new function, `summarize_ggs_hubgenes()`, builds a DT `datatable` for the Gene-Geneset panel. This table lists the individual genes of the input data and their respective degree in the Gene-Geneset graph. Furthermore, `action buttons` linking to the NCBI, GeneCards and GTEx databases are included for each gene.

* `gene_plot()` gains the extra `labels_display` argument to control whether the labels are at all shown; now the display of the labels is also respecting the jitter of the points

## Other notes

* `gs_heatmap()` has now the possibility to set the arguments to the call to heatmap generating function, via ellipsis
* `gs_heatmap()` handles the colors in a consistent way over the different executions, without relying on the random palettes provided by the `Heatmap`'s annotation functionality - could have been misleading if encountering too similar hues are randomly picked
* the plots obtained via `gs_mds()` and `gs_volcano()` now always display the line segments for the data points to be labeled (increasing the readability - as "matching back the label to the drawn circle" - thanks for the suggestion!)

# GeneTonic 1.2.0

## New features

* The geneset distillery is officially open! `GeneTonic` offers functionality to aggregate together gene sets into overarching biological themes, based on a network-based refinement of the enrichment map. 
  Corresponding graphical functionalities are also extended to accommodate meta-genesets.
  An efficient implementation for the Markov clustering on graph objects is also provided
  
* `GeneTonic` can now receive the input of many other tools for functional enrichment analysis - this includes the output (text export) of DAVID (`shake_davidResult`), enrichr (from website and via the package, with `shake_enrichrResult`), fgsea (`shake_fgseaResult`), and g:Profiler (with `shake_gprofilerResult`, which can handle the textual output from the website, as well the one from the call to the `gost` in `gprofiler2`)

* An export button to a `SummarizedExperiment` object for `iSEE` and its underlying machinery has been added. If the visualization options in `GeneTonic` are not exactly what you would expect, you might find an excellent venue in the `iSEE` framework

## Other notes

* Added an additional mechanism for safe fails when not finding the GO Term and searching for the definition - this could happen e.g. when the term becomes outdated and is removed from the `GO.db` package, or also mistyped if entered by hand at some point.
* `gs_heatmap` has a new parameter, `plot_title`, to override the title to be displayed and set it to any custom string
* It is now possible to save a snapshot of the graphs created with `visNetwork`
* The Gene Box now also contains links to the GTEx portal for the selected feature
* `export_to_sif` enables to export a graph object to a text file, encoded with the SIF format

# GeneTonic 1.0.0

## Other notes

* `GeneTonic` has become a part of Bioconductor!

# GeneTonic 0.99.0

## Other notes

* `GeneTonic` is now submitted to Bioconductor!

# GeneTonic 0.10.0

## New features

* The functions for comparing different `res_enrich`, namely `gs_radar`, `gs_summary_overview_pair`, and `gs_horizon` were internally rewritten to accept correctly the comparison elements
* The vignette now covers completely the usage cases, with the full description of the user interface of `GeneTonic`
* The introductory tours are available for all the main panels of `GeneTonic`. Feel free to try them out!

## Other notes

* Some widgets have been added in the UI of `GeneTonic` to enable finer control of the output aspect
* Examples and unit tests have been further expanded, with better messages for checking progress
* `check_colors` verify that color palettes are correctly provided
* Info on `GeneTonic` is now provided with modal dialog windows, rather than in a separate tab
* The tab names in the main app were slightly edited to better describe their content
* The info boxes are now shown with a uniform style, based on the `bs4Card` UI element
* The UI elements have now a better spacing throughout the different tabs
* Soon the package will be submitted to Bioconductor!

# GeneTonic 0.9.0

## New features

* `GeneTonic` sports a blazing new hex sticker - say bye to the original draft!
* The overview DT `datatable`s has some styling with color bars - e.g. for DE results - to enhance the visual perception of numeric values (e.g. log2FoldChange)
* `gs_heatmap` can now take a custom list of gene identifiers (when no geneset is passed)
* The color palettes in enrichment maps now respect the values and the range specified of the numeric values to be used for mapping to colors
* `gs_mds` is now optionally returning a data.frame, to be further used for custom plotting or downstream processing
* `gs_summary_overview` now has coloring enabled by the variable of choice

## Other notes

* The UI has received some restyling (e.g. in the choice of the icons for the dropdown menus, or the name of some buttons)
* Added tour contents for most of the functionality
* Added link to the demo instance
* Added examples for overlap functions, gene info buttons, map2color, and deseqresult2df
* Extended documentation of some parameters
* Some functions have gained an alias for calling them: `gs_spider` is equivalent to `gs_radar`, and `gs_sankey` is equivalent to `gs_alluvial`

# GeneTonic 0.8.0

## New features

* `GeneTonic` now delivers bundled example objects to make examples and tests slim
* `gs_volcano` can now plot points by different colors according to the columns of interest
* `GeneTonic` has a fully fledged manual describing its functionality and user interface

## Other notes

* Now using ids for genes and genesets for exchanging information in the app
* Added examples for all functions
* Most tabs have working tours - anchor and text elements

# GeneTonic 0.7.0

## New features

* Introduced a uniform interface for calculating different similarity/distance matrices. This enables the usage in the different functions that might need such matrices for further downstream processing (e.g. `enrichment_map()`, `gs_mds()`)
* First appearance of `gs_dendro()` to display distance matrices with some visualization sugar, as an alternative to other methods
* The `n_gs` and `gs_ids` are exposed to more functions to enable custom subsets of the enrichment results to be inspected

# GeneTonic 0.6.0

## New features

* `gs_heatmap` now relies on `ComplexHeatmap`, to avoid the issues with Shiny of not displaying the outputs in the app, and enabling a comfortable heatmap annotation
* Many functions gain the possibility to pass a set of custom geneset identifiers to be added to the top N sets (default): among these, `gs_mds`, `gs_volcano` (parameter: `gs_labels`), `gs_alluvial`, `ggs_network`, `enrichment_map`, and `enhance_table` (using `gs_ids`)

## Other notes

* `gs_ggheatmap` got renamed to `gs_scoresheat`
* The report generated from the bookmarked content is expanded in its default content

# GeneTonic 0.5.0

## New features

* `GeneTonic` now enforces a format for `res_enrich`, and provides some conversion functions, `shake_*()`. Requirements are specified in the documentation, if an appropriate converter does not (yet) exist.
* The reporting feature is active to some extent on the bookmarked content.

# GeneTonic 0.4.0

## New features

* Added functionality for bookmarking
* Bookmarking can work (PoP) by pressing a key (left control)!
* `gene_plot` can enforce a plot type overriding the default based on the number of samples per condition
* `GeneTonic` uses now `bs4Dash` and many of its nice features, replacing the previous implementation based on `shinydashboard`

# GeneTonic 0.3.0

## Other notes

* Rearranging the order of parameters to harmonize it across functions, and uniforming similarly called parameters

# GeneTonic 0.2.0

## New features

* added geneset scoring calculation and corresponding heatmap

# GeneTonic 0.1.0

## New features

* much of the functionality available, in a proof of concept format

# GeneTonic 0.0.1

## New features

* backbone of the project started!
