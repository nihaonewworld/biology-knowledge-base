#' Assess clustering resolution using a decision tree classifier
#'
#' This function evaluates how well cluster assignments can be
#' predicted from expression data using a decision tree model.
#'
#' @param obj A Seurat object.
#' @param cluster.col Meta.data column containing cluster labels.
#' @param features Features used as predictors.
#' @param reduction Dimensional reduction used for visualization.
#' @param train_frac Fraction of cells used for training.
#' @param maxdepth Maximum depth of decision tree.
#' @param cp Complexity parameter for rpart.
#' @param return_model Logical. Whether to return fitted model.
#' @param seed Random seed.
#'
#' @return A named list of evaluation metrics (and model optionally).
#' @export
assess_cluster_resolution_tree <- function(
    obj,
    features = NULL,
    reduction = "pca",
    cluster.col = "seurat_clusters",
    train_frac = 0.7,
    maxdepth = 4,
    cp = 0.01,
    return_model = FALSE,
    seed = NULL
) {

    ## ----------------------------
    ## Dependency & argument checks
    ## ----------------------------
    suppressPackageStartupMessages(require("Seurat"))

    if (!inherits(obj, "Seurat")) {
        stop("`obj` must be a Seurat object.", call. = FALSE)
    }

    if (!is.null(seed)) set.seed(seed)
    features <- features %||% VariableFeatures(obj)

    df <- LayerData(obj, features = features, layer = "data") |>
        t() |> data.frame()
    
    cluster <- factor(Idents(obj))
    df$cluster <- cluster

    ## ----------------------------
    ## Train / test split
    ## ----------------------------
    idx <- caret::createDataPartition(
        df$cluster, p = train_frac, list = FALSE)
    train <- df[idx, , drop = FALSE]
    test <- df[-idx, , drop = FALSE]

    ## ----------------------------
    ## Decision tree predictability
    ## ----------------------------
    fit <- rpart::rpart(
        cluster ~ ., data = train, method = "class",
        control = rpart::rpart.control(
            maxdepth = maxdepth, cp = cp))

    pred <- predict(fit, test, type = "class")

    ## ----------------------------
    ## Silhouette (geometry in PCA space)
    ## ----------------------------
    emb <- Embeddings(obj, reduction)

    sil <- cluster::silhouette(
        as.integer(cluster), dist(emb))

    sil_mean <- mean(sil[, "sil_width"])

    ## ----------------------------
    ## Modularity (graph structure)
    ## ----------------------------
    mod <- igraph::graph_from_adjacency_matrix(
        obj@graphs$RNA_snn, mode = "undirected",
        weighted = TRUE, diag = FALSE) |>
    igraph::modularity(
        membership = as.integer(cluster))

    ## ----------------------------
    ## Output
    ## ----------------------------
    out <- list(
        n_cluster = nlevels(cluster),
        accuracy = mean(pred == test$cluster),
        f1 = MLmetrics::F1_Score(pred, test$cluster),
        silhouette = sil_mean,
        modularity = mod
    )

    if(return_model) out$model <- fit

    return(out)
}
