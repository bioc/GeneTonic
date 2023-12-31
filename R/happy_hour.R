# nocov start

#' Check whether `pandoc` and `pandoc-citeproc` are available
#'
#' @details Credits to the original implementation proposed by Charlotte Soneson,
#' upon which this function is **heavily** inspired.
#'
#' @param ignore_pandoc Logical. If TRUE, just give a warning if one of pandoc or
#'   pandoc-citeproc is not available. If FALSE, an error is thrown.
#'
#' @return No value is returned. If `pandoc` or `pandoc-citeproc` are missing,
#' either warning or error messages are triggered.
#'
.check_pandoc <- function(ignore_pandoc) {
  if (Sys.which("pandoc") == "") {
    if (ignore_pandoc) {
      ## If ignore_pandoc is TRUE, just give a warning
      warning(
        "pandoc is not available! ",
        "The final report will not be generated."
      )
    } else {
      ## If ignore_pandoc is FALSE, stop
      stop("pandoc is not available!")
    }
  }
  if (Sys.which("pandoc-citeproc") == "") {
    if (ignore_pandoc) {
      ## If ignore_pandoc is TRUE, just give a warning
      warning(
        "pandoc-citeproc is not available! ",
        "The final report will not be generated."
      )
    } else {
      ## If ignore_pandoc is FALSE, stop
      stop("pandoc-citeproc is not available!")
    }
  }
}



#' Happy hour!
#'
#' Start the happy hour, creating a report containing a document full of goodies
#' derived from the provided objects.
#'
#' @details When `happy_hour` is called, a RMarkdown template file will be copied
#' into the output directory, and [rmarkdown::render()] will be called to
#' generate the final report.
#'
#' As a default template, `happy_hour` uses the one delivered together with the
#' `GeneTonic` package, which provides a comprehensive overview of what the user
#' can extract. Experienced users can take that as a starting point to further
#' edit and customize.
#'
#' If there is already a .Rmd file with the same name in the output directory,
#' the function will raise an error and stop, to avoid overwriting the existing
#' file. The reason for this behaviour is that the copied template in the output
#' directory will be deleted once the report is generated.
#'
#' Credits to the original implementation proposed by Charlotte Soneson,
#' upon which this function is **heavily** inspired.
#'
#' @param dds A `DESeqDataSet` object, normally obtained after running your data
#' through the `DESeq2` framework.
#' @param res_de A `DESeqResults` object. As for the `dds` parameter, this is
#' also commonly used in the `DESeq2` framework.
#' @param res_enrich A `data.frame` object, storing the result of the functional
#' enrichment analysis. See [GeneTonic()] for the formatting requirements.
#' @param annotation_obj A `data.frame` object with the feature annotation
#' information, with at least two columns, `gene_id` and `gene_name`. See
#' [GeneTonic()] for the formatting requirements.
#' @param gtl A `GeneTonic`-list object, containing in its slots the arguments
#' specified above: `dds`, `res_de`, `res_enrich`, and `annotation_obj` - the names
#' of the list _must_ be specified following the content they are expecting
#' @param project_id A character string, which can be considered as an identifier
#' for the set/session, and will be e.g. used in the title of the report created
#' via [happy_hour()]
#' @param mygenesets A vector of character strings, containing the genesets to 
#' focus on in the report - for each geneset, e.g. a signature heatmap can be 
#' created.
#' @param mygenes A vector of character strings, containing the genes to focus on 
#' in the report - for each gene, the plot of the expression values is included.
#' @param mygroup A character string, or a vector thereof. Contains the experimental
#' variables to be used to split into groups the expression data, and color 
#' accordingly.
#' @param usage_mode A character string, which controls the behavior of the Rmd
#' document, based on whether the rendering is triggered while using the app
#' ("shiny_mode"), or offline, in batch mode. Defaults to "batch_mode".
#' @param input_rmd Character string with the path to the RMarkdown (.Rmd) file
#' that will be used as the template for generating the report. Defaults to NULL,
#' which will then use the one provided with the `GeneTonic` package.
#' @param output_file Character string, specifying the file name of the output
#' report. The file name extension must be either `.html` or `.pdf`, and consistent
#' with the value of `output_format`.
#' @param output_dir Character, defining the path to the output directory where
#' the report will be generated. Defaults to the temp directory (`tempdir()`).
#' @param output_format The format of the output report. Either `html_document`
#' or `pdf_document`. The file name extension of `output_file` must be consistent
#' with this choice. Can also be left empty and determined accordingly.
#' @param force_overwrite Logical, whether to force overwrite an existing report
#' with the same name in the output directory. Defaults to FALSE.
#' @param knitr_show_progress Logical, whether to display the progress of `knitr`
#' while generating the report. Defaults to FALSE.
#' @param ignore_pandoc Logical, controlling how the report generation function
#' will behave if `pandoc` or `pandoc-citeproc` are missing.
#' @param open_after_creating Logical, whether to open the report in the default
#' browser after being generated. Defaults to TRUE.
#' @param ... Other arguments that will be passed to [rmarkdown::render()].
#'
#' @seealso [GeneTonic()], [shake_topGOtableResult()], [shake_enrichResult()]
#'
#' @return Generates a fully fledged report in the `output_dir` directory, called
#' `output_file` and returns (invisibly) the name of the generated report.
#' @export
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
#' # res object
#' data(res_de_macrophage, package = "GeneTonic")
#' res_de <- res_macrophage_IFNg_vs_naive
#'
#' # res_enrich object
#' data(res_enrich_macrophage, package = "GeneTonic")
#' res_enrich <- shake_topGOtableResult(topgoDE_macrophage_IFNg_vs_naive)
#' res_enrich <- get_aggrscores(res_enrich, res_de, anno_df)
#' \dontrun{
#' happy_hour(
#'   dds = dds_macrophage,
#'   res_de = res_de,
#'   res_enrich = res_enrich,
#'   annotation_obj = anno_df,
#'   project_id = "examplerun",
#'   mygroup = "condition",
#'   # mygroup = "line",   # alternatively
#'   mygenesets = res_enrich$gs_id[c(1:5, 11, 31)],
#'   mygenes = c(
#'     "ENSG00000125347",
#'     "ENSG00000172399",
#'     "ENSG00000137496"
#'   )
#' )
#' }
happy_hour <- function(dds,
                       res_de,
                       res_enrich,
                       annotation_obj,
                       gtl = NULL,
                       project_id,
                       mygenesets,
                       mygenes,
                       mygroup = NULL, 
                       usage_mode = "batch_mode",
                       input_rmd = NULL,
                       output_file = "my_first_GeneTonic_happyhour.html",
                       output_dir = tempdir(),
                       output_format = NULL,
                       force_overwrite = FALSE,
                       knitr_show_progress = FALSE,
                       ignore_pandoc = FALSE,
                       open_after_creating = TRUE,
                       ...) {
  # generates a nice number of outputs, plots, and so on, placed in a report. Boom :)
  if (!is.null(gtl)) {
    checkup_gtl(gtl)
    dds <- gtl$dds
    res_de <- gtl$res_de
    res_enrich <- gtl$res_enrich
    annotation_obj <- gtl$annotation_obj
  }

  # Check if pandoc and pandoc-citeproc are available
  .check_pandoc(ignore_pandoc)

  # If possible, set output format based on the extension of output_file, if the output format is not provided
  if (is.null(output_format)) {
    if (tools::file_ext(output_file) == "pdf") {
      output_format <- "pdf_document"
    } else {
      output_format <- "html_document"
    }
  }

  # Raise an error if output_format is not one of the allowed
  if (!(output_format %in% c("pdf_document", "html_document"))) {
    stop("The provided output_format is currently not supported. Please ",
      "use either 'html_document' or 'pdf_document'.",
      call. = FALSE
    )
  }

  # Raise an error if the output format and file name extension don't match
  if (output_format != paste0(tools::file_ext(output_file), "_document")) {
    stop("File name extension of output_file (.",
      tools::file_ext(output_file),
      ") doesn't agree with the ",
      "output_format, should be .",
      gsub("_document$", "", output_format),
      call. = FALSE
    )
  }

  # Check that all required input files are available and correctly formatted
  checkup_GeneTonic(
    dds,
    res_de,
    res_enrich, #  or directly get_aggrscores(res_enrich, res_de, annotation_obj)
    annotation_obj
  )
  
  # checking that a group is provided, otherwise assign the first column
  if (is.null(mygroup)) {
    # defaults to first column name in the colData
    mygroup <- colnames(colData(dds))[1]
  }

  # output files
  output_report <- file.path(output_dir, basename(output_file)) # no need of normalizePath?
  output_rmd <- file.path(
    output_dir,
    paste0(tools::file_path_sans_ext(basename(output_file)), ".Rmd")
  )

  # report
  if (file.exists(output_report)) {
    if (!force_overwrite) {
      stop("The file ", output_report,
        " already exists. Please remove or rename the file, provide ",
        "another value of output_file, or set force_overwrite = TRUE.",
        call. = FALSE
      )
    } else {
      warning("The file ", output_report,
        " already exists and will be overwritten, since ",
        "force_overwrite = TRUE.",
        immediate. = TRUE,
        call. = FALSE
      )
    }
  }

  # Rmd template
  if (is.null(input_rmd)) {
    template_rmd <- system.file("extdata",
      "cocktail_recipe.Rmd",
      package = "GeneTonic"
    )
  } else {
    template_rmd <- input_rmd
  }

  if (file.exists(template_rmd)) {
    if (file.exists(output_rmd)) {
      stop("There is already an .Rmd file called ", output_rmd,
        ". Please remove or rename this file, or choose another ",
        "output_file name.",
        call. = FALSE
      )
    } else {
      # another possible thought: work in a tempdir, that is probably even more elegant
      file.copy(from = template_rmd, to = output_rmd, overwrite = FALSE)
    }
  } else {
    stop("The Rmd template file ", template_rmd, " does not exist.",
      call. = FALSE
    )
  }

  # Process the arguments
  args <- list(...)
  args$input <- output_rmd
  args$output_format <- output_format
  args$output_file <- output_file
  args$quiet <- !knitr_show_progress

  # Render the report

  output_file <- do.call("render", args = args)

  # Remove temporary file
  file.remove(output_rmd)

  # Open up in a browser
  if (open_after_creating) {
    browseURL(output_file)
  }
  
  message("Report created in ", output_file)

  invisible(output_file)
}

# nocov end
