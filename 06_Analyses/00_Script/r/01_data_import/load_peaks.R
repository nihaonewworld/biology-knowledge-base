# ==============================================================================
# Utility: Peak File Loader
# Description: Imports peak files (narrowPeak/broadPeak/gappedPeak/BED) 
#              as GRanges and performs chromosome & blacklist filtering.
# ==============================================================================

# Ensure dependencies are loaded
suppressPackageStartupMessages({
    library(rtracklayer)
    library(GenomeInfoDb)
    library(IRanges)
})

#' Load MACS peak or BED files as GRanges with customizable filtering options
#'
#' @param file Path to the peak file (.narrowPeak, .broadPeak, .bed, etc.).
#' @param keepStandardChr Logical. Keep only standard chromosomes? Default is TRUE.
#' @param dropSex Logical or Character. If TRUE, drops chrX/chrY/X/Y. 
#'                 Can pass custom vector, e.g. c("chrX"). Default: c("chrX", "chrY").
#' @param dropMito Logical or Character. If TRUE, drops chrM/M/MT/chrMT. 
#'                 Can pass custom vector, e.g. "chrM". Default: c("chrM", "M", "MT").
#' @param blacklist Path to blacklist file or a GRanges object. Default NULL.
#' @param format Format of the file. Auto-detected by default ("auto").
#' @param verbose Logical. Print execution steps? Default TRUE.
#' @return GRanges object
load_peaks <- function(
    file, 
    keepStandardChr = TRUE, 
    dropSex = c("chrX", "chrY"), 
    dropMito = c("chrM"), 
    blacklist = NULL, 
    format = "auto",
    verbose = TRUE
) {
    if (!file.exists(file)) stop("File not found: ", file)
    if (verbose) message("[Info] Importing Peak file: ", basename(file))

    # ---- 1. Auto-detect format ----
    if (format == "auto") {
        if (grepl("\\.narrowPeak(\\.gz)?$", file, ignore.case = TRUE)) {
            format <- "narrowPeak"
        } else if (grepl("\\.broadPeak(\\.gz)?$", file, ignore.case = TRUE)) {
            format <- "broadPeak"
        } else if (grepl("\\.gappedPeak(\\.gz)?$", file, ignore.case = TRUE)) {
            format <- "gappedPeak"
        } else {
            format <- "BED"
        }
    }
    if (verbose) message("  .. Format detected/specified: ", format)

    # ---- 2. Import file ----
    gr <- rtracklayer::import(file, format = format)

    # ---- 3. Keep standard chromosomes ----
    if (isTRUE(keepStandardChr)) {
        if (verbose) message("  .. Keeping standard chromosomes")
        gr <- GenomeInfoDb::keepStandardChromosomes(gr, pruning.mode = "coarse")
    }

    # ---- 4. Drop sex chromosomes ----
    sex_chrs <- NULL
    if (is.character(dropSex)) {
        sex_chrs <- dropSex
    } else if (isTRUE(dropSex)) {
        sex_chrs <- c("chrX", "chrY", "X", "Y")
    }
    
    if (!is.null(sex_chrs)) {
        sex_chrs <- intersect(sex_chrs, GenomeInfoDb::seqlevels(gr))
        if (length(sex_chrs) > 0) {
            if (verbose) message("  .. Dropping sex chromosomes: ", paste(sex_chrs, collapse = ", "))
            gr <- GenomeInfoDb::dropSeqlevels(gr, sex_chrs, pruning.mode = "coarse")
        }
    }

    # ---- 5. Drop mitochondrial DNA ----
    mito_chrs <- NULL
    if (is.character(dropMito)) {
        mito_chrs <- dropMito
    } else if (isTRUE(dropMito)) {
        mito_chrs <- c("chrM", "M", "MT", "chrMT")
    }
    
    if (!is.null(mito_chrs)) {
        mito_chrs <- intersect(mito_chrs, GenomeInfoDb::seqlevels(gr))
        if (length(mito_chrs) > 0) {
            if (verbose) message("  .. Dropping mitochondrial DNA: ", paste(mito_chrs, collapse = ", "))
            gr <- GenomeInfoDb::dropSeqlevels(gr, mito_chrs, pruning.mode = "coarse")
        }
    }

    # ---- 6. Filter blacklist regions ----
    if (!is.null(blacklist)) {
        if (verbose) message("  .. Filtering blacklist regions")
        if (is.character(blacklist)) {
            blacklist <- rtracklayer::import(blacklist)
        }
        gr <- IRanges::subsetByOverlaps(gr, blacklist, invert = TRUE)
    }

    if (verbose) message("  .. Done! Loaded ", length(gr), " peaks.")

    return(gr)
}