#' Chunk-wise ScaleData for large Seurat objects
#'
#' This function performs feature-wise scaling in chunks to reduce
#' peak memory usage. Scaled results are merged into a single
#' scale.data matrix in the specified assay.
#'
#' @param obj A Seurat object.
#' @param assay Assay name. Defaults to DefaultAssay(obj).
#' @param features Character vector of features to scale.
#'   Defaults to VariableFeatures(obj).
#' @param vars.to.regress Variables to regress out.
#' @param scale.max Maximum absolute scaled value.
#' @param do.scale Logical. Whether to scale features.
#' @param do.center Logical. Whether to center features.
#' @param chunk.size Number of features per chunk.
#'
#' @return A Seurat object with updated scale.data slot.
#' @export
scale_data_chunked <- function(
    obj,
    assay = NULL,
    features = NULL,
    vars.to.regress = NULL,
    scale.max = 10,
    do.scale = TRUE,
    do.center = TRUE,
    chunk.size = 2000
) {

    ## ----------------------------
    ## Dependency & argument checks
    ## ----------------------------
    suppressPackageStartupMessages(require("Seurat"))
    
    if (!inherits(obj, "Seurat")) {
        stop("`obj` must be a Seurat object.", call. = FALSE)
    }

    assay <- assay %||% DefaultAssay(obj)
    features <- features %||% VariableFeatures(obj)
    
    ## ----------------------------
    ## Chunking
    ## ----------------------------
    chunks <- split(
        features, ceiling(seq_along(features) / chunk.size))

    scale.data <- matrix(
        NA_real_, nrow = length(features), ncol = ncol(obj),
        dimnames = list(features, colnames(obj)))

    ## ----------------------------
    ## Chunk-wise scaling
    ## ----------------------------
    for (fset in chunks) {
        tmp <- ScaleData(
            obj, features = fset, assay = assay,
            vars.to.regress = vars.to.regress, scale.max = scale.max,
            do.scale = do.scale, do.center = do.center, verbose = FALSE)

        chunk_scaled <- LayerData(tmp, assay = assay, layer = "scale.data")
        scale.data[rownames(chunk_scaled), ] <- as.matrix(chunk_scaled)
    }

    obj <- SetAssayData(obj, layer = "scale.data", new.data = scale.data)
    
    return(obj)
}
