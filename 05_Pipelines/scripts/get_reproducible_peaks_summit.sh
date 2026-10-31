#!/bin/bash
# =============================================================================
# Script: get_reproducible_peaks_summit.sh
# Description: Retain summit-centered narrowPeak regions supported by at least
#              k biological replicates, using >=50% overlap of either interval.
#              Clip windows to chromosome boundaries, filter by SPM, and select
#              the highest-scoring representative per overlap cluster.
# =============================================================================

set -e
set -u
set -o pipefail
export LC_ALL=C

CHROM_SIZES=""
BLACKLIST="none"
FLANK=250
SPM=3
SUPPORT=2
STRANDED=false
OUTPUT="consensus.bed"

usage() {
    echo "Usage: $0 -g chrom.sizes [options] rep1 rep2 ..."
    echo "  -g FILE      Chromosome sizes (required)"
    echo "  -b FILE      Blacklist BED (optional; default: none)"
    echo "  -w INT       Extension per side (default: 250 bp)"
    echo "  -e NUM       Minimum SPM (default: 3)"
    echo "  -k INT       Minimum supporting replicates (default: 2)"
    echo "  -s           Require same strand (default: off)"
    echo "  -o FILE      Output (default: consensus.bed)"
    echo "  -h           Show help"
}

while getopts "g:b:w:e:k:so:h" opt; do
    case "$opt" in
        g) CHROM_SIZES="$OPTARG" ;;
        b) BLACKLIST="$OPTARG" ;;
        w) FLANK="$OPTARG" ;;
        e) SPM="$OPTARG" ;;
        k) SUPPORT="$OPTARG" ;;
        s) STRANDED=true ;;
        o) OUTPUT="$OPTARG" ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done
shift "$((OPTIND - 1))"
INPUTS=("$@")

if [[ -z "$CHROM_SIZES" ]] ||
    ((SUPPORT < 1 || SUPPORT > ${#INPUTS[@]})); then
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

# Column 10 is a summit offset; symmetric extension spans 2 * FLANK + 1 bp.
process_peaks() {
    local input="$1" output="$2"
    local best="${output%.bed}.best.bed"

    awk 'BEGIN {OFS="\t"}
        FILENAME == ARGV[1] {size[$1]=$2; next}
        /^#/ || /^track/ || /^browser/ || NF < 10 {next}
        !($1 in size) || $10 < 0 {next}
        {
            summit=$2+$10
            print $1,summit,summit+1,$4,$8,$6
        }
    ' "$CHROM_SIZES" "$input" | \
        bedtools slop -b "$FLANK" -g "$CHROM_SIZES" | \
        if [[ "$BLACKLIST" == "none" ]]; then
            cat
        else
            bedtools intersect -v -a - -b "$BLACKLIST"
        fi | \
        sort -k1,1 -k2,2n -k3,3n | \
        bedtools cluster -i - "${STRAND_ARGS[@]}" | \
        sort -k7,7n -k5,5nr -k1,1 -k2,2n -k3,3n | \
        awk -v stranded="$STRANDED" 'BEGIN {OFS="\t"}
            !seen[$7,(stranded == "true" ? $6 : ".")]++ {
                print $1,$2,$3,$4,$5,$6
            }' | \
        sort -k1,1 -k2,2n -k3,3n > "$best"

    # SPM = 1e6 * score / sum of retained within-replicate scores.
    # Column 8 is -log10(p-value); SPM is not library-size normalization.
    awk -v cutoff="$SPM" 'BEGIN {OFS="\t"}
        FNR == NR {total+=$5; next}
        total > 0 {
            $5=$5*1000000/total
            if ($5 >= cutoff) print
        }
    ' "$best" "$best" > "$output"
}

echo "Processing ${#INPUTS[@]} replicates; min support: $SUPPORT"
PROCESSED_FILES=()
for input in "${INPUTS[@]}"; do
    name=$(basename -- "$input")
    filtered="$OUTPUT_DIR/${name%.*}.tmp.summit.bed"
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
    bedtools cluster -i - "${STRAND_ARGS[@]}" | \
    sort -k7,7n -k5,5nr -k1,1 -k2,2n -k3,3n | \
    awk -v stranded="$STRANDED" 'BEGIN {OFS="\t"}
        !seen[$7,(stranded == "true" ? $6 : ".")]++ {
            print $1,$2,$3,$4,$5,$6
        }' | \
    sort -k1,1 -k2,2n -k3,3n | \
    awk -v p="${OUTPUT_NAME%.*}" 'BEGIN {OFS="\t"} {
        $4=sprintf("%s_%07d",p,NR); print
    }' > "$OUTPUT"

# Convert BED half-open coordinates to SAF 1-based inclusive coordinates.
awk 'BEGIN {OFS="\t"; print "GeneID","Chr","Start","End","Strand"}
    {print $4,$1,$2+1,$3,$6}' "$OUTPUT" \
    > "${OUTPUT_STEM}.saf"

echo "Done. Final file: $OUTPUT"
