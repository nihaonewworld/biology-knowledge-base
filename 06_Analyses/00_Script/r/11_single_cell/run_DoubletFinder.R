#' Run DoubletFinder on a Seurat object
#'
#' This function performs parameter sweep, homotypic doublet estimation,
#' and doublet classification using DoubletFinder.
#'
#' @param obj A Seurat object.
#' @param assay Assay to use. Default: current DefaultAssay(seurat).
#' @param ndim Integer. Number of PCs to use.
#' @param clusters Character scalar. Column name in obj@meta.data
#'   indicating cluster assignments.
#' @param pN Numeric. Proportion of artificial doublets.
#' @param sct Logical. Whether SCT normalization was used.
#' @param multiplet.rate Optional numeric. Override default doublet rate.
#' @param threads Integer. Number of threads for parameter sweep.
#' @param seed Integer or NULL. Random seed for reproducibility.
#'
#' @return A Seurat object with standardized DoubletFinder results:
#'   \itemize{
#'     \item DoubletFinder.pANN
#'     \item DoubletFinder.class
#'   }
#'
#' @export
run_DoubletFinder <- function(
    obj,
    assay = NULL,
    ndim = 10,
    clusters = "seurat_clusters",
    pN = 0.25,
    sct = FALSE,
    multiplet.rate = 0.008,
    threads = 1,
    seed = NULL
) {

    ## ----------------------------
    ## Dependency & argument checks
    ## ----------------------------
    suppressPackageStartupMessages(require("Seurat"))
    suppressPackageStartupMessages(require("DoubletFinderSilence"))
    
    if (!inherits(obj, "Seurat")) {
        stop("`obj` must be a Seurat object.", call. = FALSE)
    }
    
    assay <- assay %||% DefaultAssay(obj)

    ## ----------------------------
    ## Preprocessing
    ## ----------------------------
    source("Rscript/run_seurat_pipeline.R")
    sce <- run_seurat_pipeline(
        obj, ndim = ndim, 
        norm.method = if (sct) "sctransform" else "lognorm")

    ## ----------------------------
    ## Parameter sweep
    ## ----------------------------
    if (!is.null(seed)) set.seed(seed)
    sweep.res.list <- paramSweep(
        sce, PCs = seq_len(ndim), sct = sct, num.cores = threads)

    ## ----------------------------
    ## pK identification (no ground-truth)
    ## ----------------------------
    sweep.stats <- summarizeSweep(
        sweep.res.list, GT = FALSE)

    ## ----------------------------
    ## pK Identification (ground-truth)
    ## GT is a vector containing "Singlet" and "Doublet" calls recorded using
    ## sample multiplexing classification and/or in silico geneotyping results
    ## ----------------------------
    # gt.calls <- temp@meta.data[rownames(sweep.res.list[[1]]), "GT"].
    # sweep.stats <- summarizeSweep(
    #     sweep.res.list, GT = TRUE, GT.calls = gt.calls)

    bcmvn <- find.pK(sweep.stats)

    optimal.pK <- bcmvn$pK[which.max(bcmvn$BCmetric)] |>
        as.vector() |> as.numeric()

    ## ----------------------------
    ## Expected doublets
    ## ----------------------------
    homotypic.prop <- modelHomotypic(sce@meta.data[, clusters])

    nCell <- Cells(sce) |> length()
    nExp <- round(nCell / 1000 * multiplet.rate * nCell)
    nExp.adj <- round(nExp * (1 - homotypic.prop))

    ## ----------------------------
    ## DoubletFinder classification
    ## ----------------------------
    if (!is.null(seed)) set.seed(seed)
    sce <- doubletFinder(
        sce, PCs = seq_len(ndim), pN = pN, 
        pK = optimal.pK, nExp = nExp.adj)

    ## ----------------------------
    ## Standardize output columns
    ## ----------------------------
    col_suffix <- paste(pN, optimal.pK, nExp.adj, sep = "_")
    pANN_col <- paste0("pANN_", col_suffix)
    class_col <- paste0("DF.classifications_", col_suffix)

    obj$DoubletFinder.pANN <- sce@meta.data[, pANN_col]
    obj$DoubletFinder.class <- factor(
        sce@meta.data[, class_col],
        levels = c("Singlet", "Doublet")
    )

    message(
        "DoubletFinder completed: ",
        "pN = ", pN,
        ", pK = ", optimal.pK,
        ", nExp_adj = ", nExp.adj)

    return(obj)
}
