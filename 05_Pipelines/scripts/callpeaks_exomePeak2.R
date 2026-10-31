#!/usr/bin/env Rscript

suppressPackageStartupMessages({
    library(exomePeak2)
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
        help = "UCSC genome name, e.g. hg38"
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
        default = "exomePeak2_output",
        help = "Output prefix [default: %default]"
    ),
    make_option(
        "--strandness",
        type = "character",
        default = "unstrand",
        help = paste(
            "Library strandness:",
            "unstrand, 1st_strand, 2nd_strand",
            "[default: %default]"
        )
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
        default = 1e-5,
        help = "P-value cutoff for peak calling [default: %default]"
    ),
    make_option(
        "--threads",
        type = "integer",
        default = 1,
        help = "Number of parallel cores [default: %default]"
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
    x |>
        strsplit(",", fixed = TRUE) |>
        (\(x) x[[1]])() |>
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

if (!opt$strandness %in% c(
    "unstrand",
    "1st_strand",
    "2nd_strand"
)) {
    stop(
        "--strandness must be one of: ",
        "unstrand, 1st_strand, 2nd_strand.",
        call. = FALSE
    )
}

if (!is.finite(opt$pvalue) || opt$pvalue <= 0 || opt$pvalue >= 1) {
    stop(
        "--pvalue must be between 0 and 1.",
        call. = FALSE
    )
}

if (opt$fragment_length <= 0) {
    stop(
        "--fragment_length must be > 0.",
        call. = FALSE
    )
}

if (opt$threads < 1) {
    stop(
        "--threads must be >= 1.",
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
message("exomePeak2 peak calling")
message("============================================================")
message("IP BAM:")
message(paste0("  ", ip_bam, collapse = "\n"))
message("Input BAM:")
message(paste0("  ", input_bam, collapse = "\n"))
message("Genome:          ", opt$genome)
message("GTF:             ", opt$gtf)
message("Output directory:", opt$outdir)
message("Prefix:          ", opt$prefix)
message("Strandness:      ", opt$strandness)
message("Fragment length: ", opt$fragment_length)
message("P-value cutoff:  ", opt$pvalue)
message("Threads:         ", opt$threads)
message("============================================================")

# ==============================================================================
# 6. Peak calling
# ==============================================================================

exomePeak2::exomePeak2(
    bam_ip = ip_bam,
    bam_input = input_bam,
    gff = opt$gtf,
    genome = opt$genome,
    strandness = opt$strandness,
    fragment_length = opt$fragment_length,
    bin_size = 25,
    step_size = 25,
    p_cutoff = opt$pvalue,
    parallel = opt$threads,
    save_output = TRUE,
    save_dir = opt$outdir,
    experiment_name = opt$prefix
)

message("============================================================")
message("Peak calling completed.")
message(
    "Output: ",
    file.path(opt$outdir, opt$prefix)
)
message("============================================================")
