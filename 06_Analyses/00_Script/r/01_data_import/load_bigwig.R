# ==============================================================================
# Utility: BigWig Loader
# Description: Imports BigWig file as GRanges and performs chromosome filtering
# ==============================================================================

# Ensure dependencies are loaded
suppressPackageStartupMessages({
    library(rtracklayer)
    library(GenomeInfoDb)
    library(IRanges)
})

#' Load BigWig file as GRanges with customizable filtering options
#'
#' @param file Path to the BigWig (.bw / .bigWig) file.
#' @param keepStandardChr Logical. Keep only standard chromosomes? Default is TRUE.
#' @param dropSex Logical or Character. If TRUE, drops chrX/chrY/X/Y. 
#'                 Can pass custom vector, e.g. c("chrX"). Default: c("chrX", "chrY").
#' @param dropMito Logical or Character. If TRUE, drops chrM/M/MT/chrMT. 
#'                 Can pass custom vector, e.g. "chrM". Default: c("chrM", "M", "MT").
#' @param blacklist Path to blacklist file (bed/gtf/bw) or a GRanges object. Default NULL.
#' @param verbose Logical. Print execution steps? Default TRUE.
#' @return GRanges object
load_bigwig <- function(
    file, 
    keepStandardChr = TRUE, 
    dropSex = c("chrX", "chrY"), 
    dropMito = c("chrM"), 
    blacklist = NULL,
    verbose = TRUE
) {
    if (!file.exists(file)) stop("File not found: ", file)
    if (verbose) message("[Info] Importing BigWig: ", basename(file))

    # ---- 1. Import BigWig ----
    gr <- rtracklayer::import.bw(file)

    # ---- 2. Keep standard chromosomes ----
    if (isTRUE(keepStandardChr)) {
        if (verbose) message("  .. Keeping standard chromosomes")
        gr <- GenomeInfoDb::keepStandardChromosomes(gr, pruning.mode = "coarse")
    }

    # ---- 3. Drop sex chromosomes ----
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

    # ---- 4. Drop mitochondrial DNA ----
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

    # ---- 5. Filter blacklist regions ----
    if (!is.null(blacklist)) {
        if (verbose) message("  .. Filtering blacklist regions")
        if (is.character(blacklist)) {
            blacklist <- rtracklayer::import(blacklist)
        }
        gr <- IRanges::subsetByOverlaps(gr, blacklist, invert = TRUE)
    }

    if (verbose) message("  .. Done! Loaded ", length(gr), " ranges.")

    return(gr)
}