#' Compare clustering results across different numbers of PCs
#'
#' This function independently performs neighbor finding, clustering,
#' and low-dimensional visualization (UMAP or t-SNE) for a range of
#' principal component dimensions, and returns plots for comparison.
#'
#' @param obj A Seurat object containing the specified reduction.
#' @param assay Assay name. Defaults to DefaultAssay(obj).
#' @param reduction Reduction to use for neighbors (e.g. "pca").
#' @param dims Integer vector of numbers of PCs to test.
#' @param resolution Clustering resolution.
#' @param method Visualization method: "umap" or "tsne".
#' @param group.by Meta.data column to color points by.
#'
#' @return A named list of ggplot objects.
#' @export
compare_npcs_clustering <- function(
    obj,
    assay = NULL,
    reduction = "pca",
    dims = c(10, 20, 25, 30, 40, 50),
    resolution = 0.5,
    method = c("umap", "tsne"),
    group.by = "seurat_clusters"
) {

    ## ----------------------------
    ## Dependency & argument checks
    ## ----------------------------
    suppressPackageStartupMessages(require("Seurat"))
    suppressPackageStartupMessages(require("ggplot2"))
    
    if (!inherits(obj, "Seurat")) {
        stop("`obj` must be a Seurat object.", call. = FALSE)
    }

    assay <- assay %||% DefaultAssay(obj)
    method <- match.arg(method)

    max_dim <- ncol(Seurat::Embeddings(obj, reduction))
    dims <- sort(unique(dims[dims <= max_dim]))

    plots <- list()

    ## ----------------------------
    ## Independent evaluation
    ## ----------------------------
    for (d in dims) {
        obj <- FindNeighbors(
            obj, reduction = reduction,
            dims = seq_len(d), verbose = FALSE) |>
        FindClusters(
            resolution = resolution, verbose = FALSE)

        if (method == "umap") {
            plots[[paste0("nPCs_", d)]] <- RunUMAP(
                obj, reduction = reduction, dims = seq_len(d), verbose = FALSE) |>
            DimPlot(
                reduction = "umap", group.by = "seurat_clusters", 
                label = TRUE, label.size = 6, repel = FALSE) +
                ggtitle(paste0("UMAP, nPCs = ", d))
        } else {
            plots[[paste0("nPCs_", d)]] <- RunTSNE(
                obj, reduction = reduction, dims = seq_len(d), verbose = FALSE) |>
            DimPlot(
                reduction = "tsne", group.by = "seurat_clusters", 
                label = TRUE, label.size = 6, repel = FALSE) +
                ggtitle(paste0("t-SNE, nPCs = ", d))
        }
    }

    return(plots)
}
