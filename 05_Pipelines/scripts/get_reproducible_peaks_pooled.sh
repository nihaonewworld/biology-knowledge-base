#!/bin/bash
# =============================================================================
# Script: get_reproducible_peaks_pooled.sh
# Description: Retain pooled peaks supported by at least k biological
#              replicates, requiring >=50% overlap of either interval.
#              Preserve candidate boundaries and export BED6 and SAF.
# =============================================================================

set -e
set -u
set -o pipefail
export LC_ALL=C

POOLED=""
BLACKLIST="none"
SUPPORT=2
STRANDED=false
OUTPUT="consensus.bed"

usage() {
    echo "Usage: $0 [options] rep1 rep2 ..."
    echo "  -u FILE      External pooled peaks (required)"
    echo "  -b FILE      Blacklist BED (optional; default: none)"
    echo "  -k INT       Minimum supporting replicates (default: 2)"
    echo "  -s           Require same-strand overlap (default: off)"
    echo "  -o FILE      Output (default: consensus.bed)"
    echo "  -h           Show help"
}

while getopts "u:b:k:so:h" opt; do
    case "$opt" in
        u) POOLED="$OPTARG" ;;
        b) BLACKLIST="$OPTARG" ;;
        k) SUPPORT="$OPTARG" ;;
        s) STRANDED=true ;;
        o) OUTPUT="$OPTARG" ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done
shift "$((OPTIND - 1))"
INPUTS=("$@")

if ((SUPPORT < 1 || SUPPORT > ${#INPUTS[@]})); then
    usage
    exit 1
fi
if [[ -z "$POOLED" ]]; then
    usage
    exit 1
fi

STRAND_ARGS=()
if "$STRANDED"; then
    STRAND_ARGS=(-s)
fi

OUTPUT_DIR=$(dirname -- "$OUTPUT")
OUTPUT_NAME=$(basename -- "$OUTPUT")
OUTPUT_STEM="$OUTPUT_DIR/${OUTPUT_NAME%.*}"
mkdir -p "$OUTPUT_DIR"

# Preserve the first six columns and exclude any blacklist overlap.
# Write all intermediate files to the final output directory.
process_peaks() {
    local input="$1" output="$2"

    awk 'BEGIN {OFS="\t"}
        /^#/ || /^track/ || /^browser/ || NF < 6 {next}
        {print $1,$2,$3,$4,$5,$6}
    ' "$input" | \
        if [[ "$BLACKLIST" == "none" ]]; then
            cat
        else
            bedtools intersect -v -a - -b "$BLACKLIST"
        fi > "$output"
}

echo "Processing ${#INPUTS[@]} replicates; min support: $SUPPORT"

# Pooled peaks define the candidates but do not contribute a support vote.
name=$(basename -- "$POOLED")
CANDIDATES="$OUTPUT_DIR/${name%.*}.tmp.filtered.bed"
process_peaks "$POOLED" "$CANDIDATES"
VOTES="${OUTPUT_STEM}.tmp.votes.bed"
: > "$VOTES"

# Each replicate contributes at most one vote per pooled interval.
# A match covers >=50% of the candidate OR the replicate interval.
for input in "${INPUTS[@]}"; do
    name=$(basename -- "$input")
    filtered="$OUTPUT_DIR/${name%.*}.tmp.filtered.bed"
    process_peaks "$input" "$filtered"
    bedtools intersect -u -a "$CANDIDATES" -b "$filtered" \
        -f 0.5 -F 0.5 -e "${STRAND_ARGS[@]}" >> "$VOTES"
done

# Match complete BED6 records so support does not depend on unique peak names.
# Preserve candidate order, coordinates, names, scores, and strand.
awk -v k="$SUPPORT" '
    FILENAME == ARGV[1] {count[$0]++; next}
    count[$0] >= k {print}
' "$VOTES" "$CANDIDATES" > "$OUTPUT"

# Convert BED half-open coordinates to SAF 1-based inclusive coordinates.
awk 'BEGIN {OFS="\t"; print "GeneID","Chr","Start","End","Strand"}
    {print $4,$1,$2+1,$3,$6}' "$OUTPUT" \
    > "${OUTPUT_STEM}.saf"

echo "Done. Final file: $OUTPUT"
