#!/bin/bash
# =============================================================================
# Script: get_reproducible_peaks_idr.sh
# Description: Select reproducible narrowPeak regions from two biological
#              replicates using pooled candidates and a global IDR threshold.
#              Rank by p-value significance and apply the blacklist after IDR.
# =============================================================================

set -e
set -u
set -o pipefail
export LC_ALL=C

POOLED=""
BLACKLIST="none"
IDR=0.05
OUTPUT="consensus.narrowPeak"

usage() {
    echo "Usage: $0 -u pooled.narrowPeak [options] rep1 rep2"
    echo "  -u FILE      Pooled narrowPeak file (required)"
    echo "  -b FILE      Blacklist BED (optional; default: none)"
    echo "  -i NUM       Global IDR threshold (default: 0.05)"
    echo "  -o FILE      Output (default: consensus.narrowPeak)"
    echo "  -h           Show help"
}

while getopts "u:b:i:o:h" opt; do
    case "$opt" in
        u) POOLED="$OPTARG" ;;
        b) BLACKLIST="$OPTARG" ;;
        i) IDR="$OPTARG" ;;
        o) OUTPUT="$OPTARG" ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done
shift "$((OPTIND - 1))"

if [[ -z "$POOLED" || $# -ne 2 ]]; then
    usage
    exit 1
fi

OUTPUT_DIR=$(dirname -- "$OUTPUT")
OUTPUT_NAME=$(basename -- "$OUTPUT")
OUTPUT_STEM="$OUTPUT_DIR/${OUTPUT_NAME%.*}"
mkdir -p "$OUTPUT_DIR"

# Fit the pairwise IDR model to the original narrowPeak rankings.
# Keep all model diagnostics in the output directory.
IDR_RESULTS="${OUTPUT_STEM}.tmp.idr.tsv"
IDR_LOG="${OUTPUT_STEM}.tmp.idr.log"
$HOME/software/ngsToolkit/idr/bin/idr \
    --samples "$1" "$2" \
    --peak-list "$POOLED" \
    --input-file-type narrowPeak \
    --rank p.value \
    --soft-idr-threshold "$IDR" \
    --use-best-multisummit-IDR \
    --output-file "$IDR_RESULTS" \
    --log-output-file "$IDR_LOG" \
    --plot

# Column 12 is -log10(global IDR); the soft threshold alone does not filter.
awk -v t="$IDR" 'BEGIN {OFS="\t"; cutoff=-log(t)/log(10)}
    NF >= 12 && $12 >= cutoff {NF=10; print}
' "$IDR_RESULTS" | \
    sort -k1,1 -k2,2n -k3,3n | \
    if [[ "$BLACKLIST" == "none" ]]; then
        cat
    else
        bedtools intersect -v -a - -b "$BLACKLIST"
    fi > "$OUTPUT"

echo "Done. Final file: $OUTPUT"
