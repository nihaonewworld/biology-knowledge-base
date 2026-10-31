#!/usr/bin/env Rscript

suppressPackageStartupMessages({
    library(exomePeak)
    library(txdbmaker)
})

# ==============================================================================
# 1. Parse arguments
# ==============================================================================

args <- commandArgs(trailingOnly = TRUE)

opts <- list(
    ip      = NULL,
    input   = NULL,
    gtf     = NULL,
    outdir  = ".",
    prefix  = "exomePeak_output",
    pvalue  = NA_real_,
    fdr     = 0.05,
    fc      = 1
)

i <- 1

while (i <= length(args)) {

    arg <- args[[i]]

    if (arg %in% c("-h", "--help")) {

        cat("
exomePeak MeRIP-seq peak calling

Required:
  --ip FILE
  --input FILE
  --gtf FILE

Optional:
  --outdir DIR            Output directory [default: .]
  --prefix NAME           Output prefix [default: exomePeak_output]
  --pvalue FLOAT          Peak p-value cutoff [default: NA]
  --fdr FLOAT             Peak FDR cutoff [default: 0.05]
  --fc FLOAT              Fold enrichment cutoff [default: 1]

Example:
  Rscript callpeaks_exomePeak.R \\
      --ip IP.bam \\
      --input Input.bam \\
      --gtf genes.gtf \\
      --outdir outdir \\
      --prefix sample \\
      --pvalue 1e-5 \\
      --fdr 0.01 \\
      --fc 1

")

        quit(status = 0)
    }

    if (i == length(args)) {
        stop("Missing value for argument: ", arg, call. = FALSE)
    }

    value <- args[[i + 1]]

    if (arg == "--ip") {
        opts$ip <- value
    } else if (arg == "--input") {
        opts$input <- value
    } else if (arg == "--gtf") {
        opts$gtf <- value
    } else if (arg == "--outdir") {
        opts$outdir <- value
    } else if (arg == "--prefix") {
        opts$prefix <- value
    } else if (arg == "--pvalue") {
        opts$pvalue <- as.numeric(value)
    } else if (arg == "--fdr") {
        opts$fdr <- as.numeric(value)
    } else if (arg == "--fc") {
        opts$fc <- as.numeric(value)
    } else {
        stop("Unknown argument: ", arg, call. = FALSE)
    }

    i <- i + 2
}

# ==============================================================================
# 2. Check arguments
# ==============================================================================

if (is.null(opts$ip)) {
    stop("--ip is required.", call. = FALSE)
}

if (is.null(opts$input)) {
    stop("--input is required.", call. = FALSE)
}

if (is.null(opts$gtf)) {
    stop("--gtf is required.", call. = FALSE)
}

if (!file.exists(opts$ip)) {
    stop("IP BAM does not exist: ", opts$ip, call. = FALSE)
}

if (!file.exists(opts$input)) {
    stop("Input BAM does not exist: ", opts$input, call. = FALSE)
}

if (!file.exists(opts$gtf)) {
    stop("GTF does not exist: ", opts$gtf, call. = FALSE)
}

if (!is.na(opts$pvalue) &&
    (opts$pvalue <= 0 || opts$pvalue >= 1)) {
    stop("--pvalue must be between 0 and 1.", call. = FALSE)
}

if (opts$fdr <= 0 || opts$fdr >= 1) {
    stop("--fdr must be between 0 and 1.", call. = FALSE)
}

if (opts$fc <= 0) {
    stop("--fc must be > 0.", call. = FALSE)
}

if (!dir.exists(opts$outdir)) {
    dir.create(opts$outdir, recursive = TRUE)
}

# ==============================================================================
# 3. Build TxDb from GTF
# ==============================================================================

message("Building TxDb from GTF...")

txdb <- txdbmaker::makeTxDbFromGFF(
    opts$gtf,
    format = "gtf"
)

# ==============================================================================
# 4. Peak calling
# ==============================================================================

message("============================================================")
message("exomePeak peak calling")
message("============================================================")
message("IP:             ", opts$ip)
message("Input:          ", opts$input)
message("GTF:            ", opts$gtf)
message("Output dir:     ", opts$outdir)
message("Prefix:         ", opts$prefix)
message("P-value cutoff: ", opts$pvalue)
message("FDR cutoff:     ", opts$fdr)
message("FC cutoff:      ", opts$fc)
message("============================================================")

exomepeak(
    IP_BAM = opts$ip,
    INPUT_BAM = opts$input,
    TXDB = txdb,
    OUTPUT_DIR = opts$outdir,
    EXPERIMENT_NAME = opts$prefix,
    PEAK_CUTOFF_PVALUE = opts$pvalue,
    PEAK_CUTOFF_FDR = opts$fdr,
    FOLD_ENRICHMENT = opts$fc,
    FRAGMENT_LENGTH = 100, 
    READ_LENGTH = NA, 
    MINIMAL_MAPQ = 30
)

message("Peak calling completed.")
message("Output: ", file.path(opts$outdir, opts$prefix))
