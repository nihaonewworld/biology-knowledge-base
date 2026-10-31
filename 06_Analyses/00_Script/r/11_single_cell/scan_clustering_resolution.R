#' Scan clustering resolutions and evaluate stability
#'
#' This function iterates over a set of clustering resolutions,
#' evaluates cluster separability using a classifier, and optionally
#' generates visualization plots.
#'
#' @param obj A Seurat object.
#' @param reduction Dimensional reduction used for visualization.
#' @param dims Number of dimensions used (passed to UMAP/t-SNE).
#' @param resolutions Numeric vector of resolutions to test.
#' @param cluster.prefix Prefix for cluster columns.
#' @param seed Random seed.
#'
#' @return A list with metrics (data.frame), plots, and clustree.
#' @export
scan_clustering_resolution <- function(
    obj,
    reduction = "pca",
    dims = 30,
    resolutions = seq(0.1, 0.9, 0.1),
    cluster.prefix = "res",
    assess = TRUE,
    seed = NULL,
    plot_dir = NULL, 
    ncols = 3, 
    widths = 21, 
    heights = 18
) {
    ## ----------------------------
    ## Dependency & argument checks
    ## ----------------------------
    suppressPackageStartupMessages(require("Seurat"))
    suppressPackageStartupMessages(require("ggplot2"))
    suppressPackageStartupMessages(require("clustree"))
    
    if (!inherits(obj, "Seurat")) {
        stop("`obj` must be a Seurat object.", call. = FALSE)
    }
    
    metrics <- list()
    umap_plots <- list()
    tsne_plots <- list()

    source("R/assess_cluster_resolution_tree.R")

    for (res in resolutions) {

        obj <- FindClusters(obj, resolution = res, verbose = FALSE)

        if (assess) {
            # Metrics
            metrics[[paste0("res_", res)]] <- data.frame(
                resolution = res,
                assess_cluster_resolution_tree(
                    obj, reduction = reduction, seed = seed), 
                row.names = NULL
            )
        }

        umap_plots[[paste0("res_", res)]] <- DimPlot(
            obj, reduction = "umap", group.by = "seurat_clusters", 
            label = TRUE, label.size = 6, repel = FALSE) +
            ggtitle(paste0("UMAP | res = ", res))
        
        tsne_plots[[paste0("res_", res)]] <- DimPlot(
            obj, reduction = "tsne", group.by = "seurat_clusters", 
            label = TRUE, label.size = 6, repel = FALSE) +
            ggtitle(paste0("t-SNE | res = ", res))
    }

    metrics_df <- if (assess) {
        do.call(rbind, metrics)
    } else {
        NULL
    }

    clustree_plot <- clustree(
        obj@meta.data, prefix = "RNA_snn_res.", node_text_size = 6) +
        theme(legend.title = element_text(size = 18), 
              legend.text = element_text(size = 16))

    return(list(
        metrics = metrics_df,
        umap = umap_plots,
        tsne = tsne_plots,
        clustree = clustree_plot
    ))
}
