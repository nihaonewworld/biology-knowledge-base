#' Run a configurable Seurat preprocessing pipeline
#'
#' This function executes a flexible Seurat preprocessing workflow,
#' including normalization, dimensional reduction, graph construction,
#' clustering, and optional visualization. It is designed to support
#' common downstream analyses such as DoubletFinder.
#'
#' @param seurat A Seurat object.
#' @param assay Assay to use. Default: current DefaultAssay(seurat).
#' @param norm.method Normalization method: "lognorm" or "sctransform".
#' @param ndim Number of principal components to compute and use.
#' @param nfeatures Number of variable features (lognorm only).
#' @param vars.to.regress Variables to regress out (optional).
#' @param neighbors.k Number of neighbors for graph construction.
#' @param resolution Clustering resolution.
#'
#' @return A processed Seurat object.
#' @export
run_seurat_pipeline <- function(
    obj,
    assay = NULL,
    norm.method = c("lognorm", "sctransform"),
    ndim = 10,
    nfeatures = 2000,
    vars.to.regress = NULL,
    neighbors.k = 20,
    resolution = 0.5
) {

    ## ----------------------------
    ## Dependency & argument checks
    ## ----------------------------
    suppressPackageStartupMessages(require("Seurat"))
    
    if (!inherits(obj, "Seurat")) {
        stop("`obj` must be a Seurat object.", call. = FALSE)
    }

    assay <- assay %||% DefaultAssay(obj)
    norm.method <- match.arg(norm.method)

    ## ----------------------------
    ## Normalization & scaling
    ## ----------------------------
    if (norm.method == "lognorm") {
        # LogNormalize
        obj <- NormalizeData(
            obj, verbose = FALSE) |>
        FindVariableFeatures(
            nfeatures = nfeatures, verbose = FALSE) |>
        ScaleData(
            vars.to.regress = vars.to.regress, 
            verbose = FALSE)
    } else {
        # sctransform v2
        obj <- SCTransform(
            obj, vars.to.regress = vars.to.regress,
            verbose = FALSE)
    }

    ## ----------------------------
    ## Dimensional reduction
    ## ----------------------------
    obj <- RunPCA(
        obj, npcs = ndim, verbose = FALSE)

    ## ----------------------------
    ## Graph construction & clustering
    ## ----------------------------
    obj <- FindNeighbors(
        obj, dims = seq_len(ndim), k.param = neighbors.k, 
        verbose = FALSE) |>
    FindClusters(
        resolution = resolution, verbose = FALSE)

    ## ----------------------------
    ## Optional visualization
    ## ----------------------------
    obj <- RunUMAP(
        obj, dims = seq_len(ndim), verbose = FALSE) |>
    RunTSNE(
        dims = seq_len(ndim), verbose = FALSE)

    return(obj)
}
