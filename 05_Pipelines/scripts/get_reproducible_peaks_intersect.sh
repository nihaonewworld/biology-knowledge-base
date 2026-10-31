#!/bin/bash
# =============================================================================
# Script: get_reproducible_peaks_intersect.sh
# Description: Retain peaks supported by at least k biological replicates,
#              requiring >=50% overlap of either interval. Merge retained
#              intervals into consensus BED6 regions and export SAF annotation.
# =============================================================================

set -e
set -u
set -o pipefail
export LC_ALL=C

BLACKLIST="none"
SUPPORT=2
STRANDED=false
OUTPUT="consensus.bed"

usage() {
    echo "Usage: $0 [options] rep1 rep2 ..."
    echo "  -b FILE      Blacklist BED (optional; default: none)"
    echo "  -k INT       Minimum supporting replicates (default: 2)"
    echo "  -s           Match and group by strand (default: off)"
    echo "  -o FILE      Output (default: consensus.bed)"
    echo "  -h           Show help"
}

while getopts "b:k:so:h" opt; do
    case "$opt" in
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

STRAND_ARGS=()
if "$STRANDED"; then
    STRAND_ARGS=(-s)
fi

OUTPUT_DIR=$(dirname -- "$OUTPUT")
OUTPUT_NAME=$(basename -- "$OUTPUT")
OUTPUT_STEM="$OUTPUT_DIR/${OUTPUT_NAME%.*}"
mkdir -p "$OUTPUT_DIR"

# Preserve BED6 fields and apply the optional blacklist before matching.
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
PROCESSED_FILES=()
for input in "${INPUTS[@]}"; do
    name=$(basename -- "$input")
    filtered="$OUTPUT_DIR/${name%.*}.tmp.filtered.bed"
    process_peaks "$input" "$filtered"
    PROCESSED_FILES+=("$filtered")
done

# Count distinct supporting replicates, not overlapping peaks.
# A match covers >=50% of the candidate OR the replicate interval.
CANDIDATES="${OUTPUT_STEM}.tmp.candidates.bed"
VOTES="${OUTPUT_STEM}.tmp.votes.bed"
sort -u "${PROCESSED_FILES[@]}" > "$CANDIDATES"
: > "$VOTES"
for REP in "${PROCESSED_FILES[@]}"; do
    bedtools intersect -u -a "$CANDIDATES" -b "$REP" \
        -f 0.5 -F 0.5 -e "${STRAND_ARGS[@]}" \
        >> "$VOTES"
done

# The source replicate contributes to support for its own candidates.
awk -v k="$SUPPORT" '
    {count[$0]++}
    END {for (peak in count) if (count[peak] >= k) print peak}
' "$VOTES" | \
    sort -k1,1 -k2,2n -k3,3n | \
    bedtools merge -i - "${STRAND_ARGS[@]}" -c 6 -o distinct | \
    sort -k1,1 -k2,2n -k3,3n -k4,4 | \
    awk -v p="${OUTPUT_NAME%.*}" 'BEGIN {OFS="\t"} {
        strand=($4 ~ /,/ ? "." : $4)
        print $1,$2,$3,sprintf("%s_%07d",p,NR),0,strand
    }' > "$OUTPUT"

# Convert BED half-open coordinates to SAF 1-based inclusive coordinates.
awk 'BEGIN {OFS="\t"; print "GeneID","Chr","Start","End","Strand"}
    {print $4,$1,$2+1,$3,$6}' "$OUTPUT" \
    > "${OUTPUT_STEM}.saf"

echo "Done. Final file: $OUTPUT"
