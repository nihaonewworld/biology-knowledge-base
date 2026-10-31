#!/usr/bin/env Rscript

# WARNING: MeTPeak is an outdated R package, and this peak-calling
# workflow has not been validated.

suppressPackageStartupMessages({
    library(MeTPeak)
    library(optparse)
})

# ==============================================================================
# 1. Command-line options
# ==============================================================================

option_list <- list(
    make_option(
        "--ip",
        type = "character",
        help = "Comma-separated IP BAM files"
    ),
    make_option(
        "--input",
        type = "character",
        help = "Comma-separated Input BAM files"
    ),
    make_option(
        "--genome",
        type = "character",
        default = NULL,
        help = "UCSC genome name [default: NULL]"
    ),
    make_option(
        "--gtf",
        type = "character",
        help = "GTF annotation file"
    ),
    make_option(
        "--outdir",
        type = "character",
        default = ".",
        help = "Output directory [default: %default]"
    ),
    make_option(
        "--prefix",
        type = "character",
        default = "MeTPeak_output",
        help = "Output prefix [default: %default]"
    ),
    make_option(
        "--fragment_length",
        type = "integer",
        default = 100,
        help = "Expected fragment length [default: %default]"
    ),
    make_option(
        "--pvalue",
        type = "double",
        default = NULL,
        help = "P-value cutoff for peak calling [default: NULL]"
    ),
    make_option(
        "--fdr",
        type = "double",
        default = 0.05,
        help = "FDR cutoff for peak calling [default: %default]"
    ),
    make_option(
        "--fc",
        type = "double",
        default = 1,
        help = "Minimum fold enrichment [default: %default]"
    )
)

option_parser <- OptionParser(
    usage = "%prog [options]",
    option_list = option_list
)

opt <- parse_args(option_parser)

# ==============================================================================
# 2. Helper functions
# ==============================================================================

split_bams <- function(x) {
    strsplit(x, ",", fixed = TRUE)[[1]] |>
        trimws() |>
        (\(x) x[nzchar(x)])()
}

check_files <- function(files, label) {
    missing <- files[!file.exists(files)]

    if (length(missing) > 0) {
        stop(
            label, " file(s) do not exist:\n",
            paste(missing, collapse = "\n"),
            call. = FALSE
        )
    }
}

# ==============================================================================
# 3. Check arguments
# ==============================================================================

required <- c("ip", "input", "gtf")

missing <- required[
    vapply(
        required,
        \(x) is.null(opt[[x]]) || !nzchar(opt[[x]]),
        logical(1)
    )
]

if (length(missing) > 0) {
    stop(
        "Missing required option(s): ",
        paste0("--", missing, collapse = ", "),
        call. = FALSE
    )
}

if (opt$fragment_length <= 0) {
    stop(
        "--fragment_length must be > 0.",
        call. = FALSE
    )
}

if (!is.null(opt$pvalue)) {
    if (!is.finite(opt$pvalue) || opt$pvalue <= 0 || opt$pvalue >= 1) {
        stop(
            "--pvalue must be between 0 and 1.",
            call. = FALSE
        )
    }
}

if (!is.finite(opt$fdr) || opt$fdr <= 0 || opt$fdr >= 1) {
    stop(
        "--fdr must be between 0 and 1.",
        call. = FALSE
    )
}

if (!is.finite(opt$fc) || opt$fc <= 0) {
    stop(
        "--fc must be > 0.",
        call. = FALSE
    )
}

# ==============================================================================
# 4. Parse input files
# ==============================================================================

ip_bam <- split_bams(opt$ip)
input_bam <- split_bams(opt$input)

if (length(ip_bam) == 0) {
    stop("--ip contains no valid BAM files.", call. = FALSE)
}

if (length(input_bam) == 0) {
    stop("--input contains no valid BAM files.", call. = FALSE)
}

check_files(ip_bam, "IP BAM")
check_files(input_bam, "Input BAM")
check_files(opt$gtf, "GTF")

if (!dir.exists(opt$outdir)) {
    dir.create(
        opt$outdir,
        recursive = TRUE,
        showWarnings = FALSE
    )
}

# ==============================================================================
# 5. Print configuration
# ==============================================================================

message("============================================================")
message("MeTPeak peak calling")
message("============================================================")
message("IP BAM:")
message(paste0("  ", ip_bam, collapse = "\n"))
message("Input BAM:")
message(paste0("  ", input_bam, collapse = "\n"))
message("Genome:          ", if (is.null(opt$genome)) "NULL" else opt$genome)
message("GTF:             ", opt$gtf)
message("Output directory:", opt$outdir)
message("Prefix:          ", opt$prefix)
message("Fragment length: ", opt$fragment_length)
message(
    "P-value cutoff:  ",
    if (is.null(opt$pvalue)) "NULL" else opt$pvalue
)
message("FDR cutoff:      ", opt$fdr)
message("Fold enrichment: ", opt$fc)
message("============================================================")

# ==============================================================================
# 6. Peak calling
# ==============================================================================

MeTPeak::metpeak(
    IP_BAM = ip_bam,
    INPUT_BAM = input_bam,
    GENOME = opt$genome,
    GENE_ANNO_GTF = opt$gtf,
    OUTPUT_DIR = opt$outdir,
    EXPERIMENT_NAME = opt$prefix,
    FRAGMENT_LENGTH = opt$fragment_length,
    PEAK_CUTOFF_PVALUE = opt$pvalue,
    PEAK_CUTOFF_FDR = opt$fdr,
    FOLD_ENRICHMENT = opt$fc
)

message("============================================================")
message("Peak calling completed.")
message(
    "Output: ",
    file.path(opt$outdir, opt$prefix)
)
message("============================================================")