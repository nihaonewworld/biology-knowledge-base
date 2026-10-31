#' Calculate QC thresholds using Median Absolute Deviation (MAD)
#'
#' This function calculates robust thresholds for quality control metrics
#' commonly used in single-cell RNA-seq and ATAC-seq analysis. It supports
#' log-transformed or raw metrics, and can compute upper, lower, or both bounds.
#'
#' @param metric Numeric vector. QC metric values (e.g., nFeature_RNA, nCount_ATAC, TSS.enrichment).
#' @param nmads Numeric. Number of MADs from the median to set thresholds. Default is 3.
#' @param log_transform Logical. Whether to log2-transform the metric before MAD calculation. Default is TRUE.
#' @param sides Character. Which side(s) of the distribution to calculate: 
#'   - "both": lower and upper bounds  
#'   - "lower": only lower bound  
#'   - "upper": only upper bound  
#'   Default is "both".
#'
#' @return Named numeric vector of thresholds:
#'   - if sides = "both": c(lower_bound = ..., upper_bound = ...)
#'   - if sides = "lower" or "upper": c(lower = ...) or c(upper = ...)
#'
#' @examples
#' # Example for scRNA nFeature_RNA (both bounds)
#' example_nFeature <- c(500, 1000, 2000, 3000, 4000, 5000)
#' calculate_mad_threshold(example_nFeature)
#'
#' # Example for scATAC TSS enrichment (lower bound only)
#' example_TSS <- c(1, 5, 10, 15, 20)
#' calculate_mad_threshold(example_TSS, log_transform = FALSE, sides = "lower")
#'
#' @export
calculate_mad_threshold <- function(
    metric,
    nmads = 3,
    log_transform = TRUE,
    sides = c("both", "lower", "upper")
) {
    sides <- match.arg(sides)

    # Keep finite and positive values
    x <- metric
    x <- x[is.finite(x) & x > 0]

    if (log_transform) x <- log2(x)

    center <- median(x)
    spread <- mad(x)

    bounds <- switch(
        sides,
        both  = center + c(-1, 1) * nmads * spread,
        lower = center - nmads * spread,
        upper = center + nmads * spread
    )

    if (log_transform) bounds <- 2^bounds

    round(bounds) |>
        setNames(
            if (sides == "both") c("lower_bound", "upper_bound")
            else sides
        )
}

# # Median Absolute Deviation (MAD)
# calculate_mad_threshold <- function(metric, nmads = 3) {
#   x <- log2(metric)
#   bounds <- median(x) + c(-1, 1) * nmads * mad(x)

#   round(2^bounds) |>
#     setNames(c("lower_bound", "upper_bound"))
# }
