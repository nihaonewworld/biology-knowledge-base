#!/bin/bash
# =============================================================================
# Script: get_reproducible_peaks.sh
# Description: Select reproducible regions across biological replicates using
#              peak intervals, summit windows, or pooled peak candidates.
#              Accept narrowPeak, broadPeak, and BED; process one condition.
# =============================================================================

set -e
set -u
set -o pipefail
export LC_ALL=C

# Default values
METHOD="intersect"
TYPE="auto"
CHROM_SIZES=""
BLACKLIST="none"
OUTPUT_FILE="consensus.bed"
SPM_CUTOFF="auto"
MIN_REPS=2
FRACTION=0.5
OVERLAP="either"
STRANDED=false
FLANK=250
WITHIN="auto"
SCORE_COL=0
SUMMIT_COL=0
FINAL="auto"
POOLED=""

usage() {
    cat <<EOF
Usage: $0 [options] rep1.peaks rep2.peaks ...
  -g, --chromSizes FILE     Chromosome sizes (required for summit)
  -b, --blacklist FILE      Blacklist BED (default: none)
  -o, --output FILE         Final output (default: consensus.bed)
  -m, --method MODE         intersect, summit, pooled (default: intersect)
  -t, --format TYPE         auto, narrowPeak, broadPeak, bed (default: auto)
  -n, --support INT         Minimum supporting replicates (default: 2)
  -f, --fraction NUM        Minimum overlap fraction (default: 0.5)
  -r, --overlap MODE        either (default), reciprocal, or candidate
  -s, --stranded            Require same strand (default: unstranded)
  -w, --flank INT           Extension per side in bp (default: 250)
  -c, --score INT           Score column (default: 8 for peaks, 5 for BED)
  -e, --spm VALUE           auto, none, or a numeric SPM cutoff
  -v, --summit INT          Summit offset column (narrowPeak default: 10)
  -j, --final MODE          auto, best, merge, keep (default: auto)
  -q, --within MODE         auto, best, none (default: auto)
  -u, --pooled FILE         External pooled peaks (required in pooled mode)
  -h, --help                Show help

Use --option value; options precede replicate files. Use -- to end options.
Column numbers are 1-based. Summit offsets are relative to BED start.
Summit mode has no midpoint fallback. A missing score column uses 1.
Aliases peak and bedtools select intersect.
Auto final mode: intersect=merge, summit=best, pooled=keep.
Auto within-replicate mode: summit=best, other methods=none.
SPM 0 keeps scores as SPM without a positive cutoff; none disables SPM.
EOF
}

# Parse short aliases and descriptive long options without external getopt.
while [[ $# -gt 0 ]]; do
    case "$1" in
        -g|--chromSizes) CHROM_SIZES="$2"; shift 2 ;;
        -b|--blacklist) BLACKLIST="$2"; shift 2 ;;
        -o|--output) OUTPUT_FILE="$2"; shift 2 ;;
        -m|--method) METHOD="$2"; shift 2 ;;
        -t|--format) TYPE="$2"; shift 2 ;;
        -n|--support) MIN_REPS="$2"; shift 2 ;;
        -f|--fraction) FRACTION="$2"; shift 2 ;;
        -r|--overlap) OVERLAP="$2"; shift 2 ;;
        -s|--stranded) STRANDED=true; shift ;;
        -w|--flank) FLANK="$2"; shift 2 ;;
        -c|--score) SCORE_COL="$2"; shift 2 ;;
        -e|--spm) SPM_CUTOFF="$2"; shift 2 ;;
        -v|--summit) SUMMIT_COL="$2"; shift 2 ;;
        -j|--final) FINAL="$2"; shift 2 ;;
        -q|--within) WITHIN="$2"; shift 2 ;;
        -u|--pooled) POOLED="$2"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        --) shift; break ;;
        -*) usage; exit 1 ;;
        *) break ;;
    esac
done
INPUT_FILES=("$@")

# Keep only the basic usage requirements.
if ((${#INPUT_FILES[@]} < 1)); then
    usage
    exit 1
fi
if ((MIN_REPS < 1 || MIN_REPS > ${#INPUT_FILES[@]})); then
    echo "Error: --support must be between 1 and the replicate count." >&2
    exit 1
fi
case "$METHOD" in
    peak|bedtools) METHOD="intersect" ;;
    intersect|summit|pooled) ;;
    *) usage; exit 1 ;;
esac
if [[ "$METHOD" == "summit" && -z "$CHROM_SIZES" ]]; then
    echo "Error: summit mode requires --chromSizes." >&2
    exit 1
fi
if [[ "$METHOD" == "pooled" && -z "$POOLED" ]]; then
    usage
    exit 1
fi
if [[ "$FINAL" == "auto" ]]; then
    case "$METHOD" in
        intersect) FINAL="merge" ;;
        summit) FINAL="best" ;;
        pooled) FINAL="keep" ;;
    esac
fi
if [[ "$WITHIN" == "auto" ]]; then
    WITHIN="none"
    [[ "$METHOD" == "summit" ]] && WITHIN="best"
fi
if [[ "$SPM_CUTOFF" == "auto" ]]; then
    SPM_CUTOFF="none"
    [[ "$METHOD" == "summit" ]] && SPM_CUTOFF=3
fi
case "$FINAL" in best|merge|keep) ;; *) usage; exit 1 ;; esac
case "$WITHIN" in best|none) ;; *) usage; exit 1 ;; esac
case "$TYPE" in
    auto|narrowPeak|broadPeak|bed) ;;
    *) usage; exit 1 ;;
esac

# An empty array lets awk read only stdin when chromosome sizes are omitted.
CHROM_FILES=()
if [[ -n "$CHROM_SIZES" ]]; then
    CHROM_FILES=("$CHROM_SIZES")
fi

# Apply one strand policy to support matching and final region grouping.
STRAND_ARGS=()
if "$STRANDED"; then
    STRAND_ARGS=(-s)
fi

# Derive companion filenames from the final output basename.
OUTPUT_DIR=$(dirname -- "$OUTPUT_FILE")
OUTPUT_NAME=$(basename -- "$OUTPUT_FILE")
OUTPUT_STEM="$OUTPUT_DIR/${OUTPUT_NAME%.*}"
mkdir -p "$OUTPUT_DIR"
TMP_DIR=$(mktemp -d)
trap 'rm -rf -- "$TMP_DIR"' EXIT

# Standardize, filter, optionally collapse, and normalize each peak file.
process_peaks() {
    local input="$1" output="$2" label="$3"
    local type score summit extension=0
    type="$TYPE"
    if [[ "$type" == "auto" ]]; then
        case "${input%.gz}" in
            *.narrowPeak) type="narrowPeak" ;;
            *.broadPeak) type="broadPeak" ;;
            *) type="bed" ;;
        esac
    fi
    score="$SCORE_COL"
    summit="$SUMMIT_COL"
    if ((score == 0)); then
        case "$type" in
            narrowPeak|broadPeak) score=8 ;;
            bed) score=5 ;;
        esac
    fi
    [[ "$type" == "narrowPeak" && "$summit" == "0" ]] && summit=10
    if [[ "$METHOD" == "summit" && "$summit" == "0" ]]; then
        echo "Error: summit mode needs narrowPeak or -v offset_column." >&2
        exit 1
    fi

    [[ "$METHOD" == "summit" ]] && extension="$FLANK"
    case "$input" in
        *.gz) gzip -cd -- "$input" ;;
        *) cat -- "$input" ;;
    esac | \
        awk -v mode="$METHOD" -v sc="$score" \
        -v su="$summit" -v label="$label" -v stranded="$STRANDED" \
        -v genome="$CHROM_SIZES" \
        'BEGIN {OFS="\t"}
        genome != "" && FILENAME == genome {size[$1]=$2; next}
        /^#/ || /^track/ || /^browser/ || NF < 3 {next}
        genome != "" && !($1 in size) {next}
        {
            start=$2; end=$3
            if (mode == "summit") {
                if (su > NF || $su < 0) next
                start+=$su
                end=start+1
            }
            if (end <= start) next
            strand="."
            if (stranded == "true") {
                if (NF < 6 || $6 !~ /^[+-]$/) {
                    print "Error: -s requires +/- in column 6." \
                        > "/dev/stderr"
                    exit 1
                }
                strand=$6
            }
            name=(NF >= 4 ? $4 : label "_" FNR)
            value=(sc <= NF ? $sc : 1)
            print $1,start,end,name,value,strand
        }
    ' "${CHROM_FILES[@]}" - > "$output.coords"

    # Only apply chromosome filtering/clipping when a sizes file is supplied.
    if [[ -n "$CHROM_SIZES" ]]; then
        bedtools slop -i "$output.coords" -b "$extension" \
            -g "$CHROM_SIZES" > "$output.raw"
    else
        cat "$output.coords" > "$output.raw"
    fi

    if [[ "$BLACKLIST" == "none" ]]; then
        cat "$output.raw" > "$output.clean"
    else
        bedtools intersect -v -a "$output.raw" -b "$BLACKLIST" \
            > "$output.clean"
    fi

    # Select within-file representatives before calculating the denominator.
    if [[ "$WITHIN" == "best" ]]; then
        sort -k1,1 -k2,2n -k3,3n "$output.clean" | \
            bedtools cluster -i - "${STRAND_ARGS[@]}" | \
            sort -k7,7n -k5,5nr -k1,1 -k2,2n -k3,3n | \
            awk 'BEGIN {OFS="\t"} !seen[$7,$6]++ {
                print $1,$2,$3,$4,$5,$6
            }' | \
            sort -k1,1 -k2,2n -k3,3n \
            > "$output.selected"
    else
        cat "$output.clean" > "$output.selected"
    fi

    # SPM uses the retained scores in this file, not fragment counts.
    awk -v cutoff="$SPM_CUTOFF" 'BEGIN {OFS="\t"}
        FNR == NR {total+=$5; next}
        cutoff == "none" {print; next}
        total > 0 {
            $5=$5*1000000/total
            if ($5 >= cutoff) print
        }
    ' "$output.selected" "$output.selected" | \
        sort -k1,1 -k2,2n -k3,3n > "$output"
}

# Step 1: Process independent replicates.
echo "Processing ${#INPUT_FILES[@]} replicates; min support: $MIN_REPS"
PROCESSED_LIST=()
for i in "${!INPUT_FILES[@]}"; do
    REP_ID=$((i + 1))
    REP_FILE="$TMP_DIR/rep${REP_ID}.bed"
    process_peaks "${INPUT_FILES[i]}" "$REP_FILE" "rep${REP_ID}"
    PROCESSED_LIST+=("$REP_FILE")
done

# Step 2: Use external pooled peaks or the replicate peak collection.
if [[ "$METHOD" == "pooled" ]]; then
    process_peaks "$POOLED" "$TMP_DIR/candidates.raw" pooled
else
    cat "${PROCESSED_LIST[@]}" > "$TMP_DIR/candidates.raw"
fi

# Deduplicate by coordinates and strand; keep the highest-scoring record.
sort -k1,1 -k2,2n -k3,3n -k6,6 -k5,5nr "$TMP_DIR/candidates.raw" | \
    awk 'BEGIN {OFS="\t"} !seen[$1,$2,$3,$6]++ {
        print $1,$2,$3,sprintf("candidate_%07d",++n),$5,$6
    }' > "$TMP_DIR/candidates.bed"

# Step 3: Each replicate contributes at most one vote per candidate.
OVERLAP_ARGS=(-f "$FRACTION")
case "$OVERLAP" in
    reciprocal) OVERLAP_ARGS+=(-r) ;;
    candidate) ;;
    either) OVERLAP_ARGS+=(-F "$FRACTION" -e) ;;
    *) usage; exit 1 ;;
esac

: > "$TMP_DIR/votes.tsv"
for i in "${!PROCESSED_LIST[@]}"; do
    bedtools intersect -u -a "$TMP_DIR/candidates.bed" \
        -b "${PROCESSED_LIST[i]}" "${OVERLAP_ARGS[@]}" \
        "${STRAND_ARGS[@]}" | \
        awk -v rep="$((i + 1))" 'BEGIN {OFS="\t"} {print $4,rep}' \
        >> "$TMP_DIR/votes.tsv"
done

awk -v k="$MIN_REPS" 'BEGIN {
        FS=OFS="\t"
        print "chrom","start","end","id","score","strand", \
              "n_support","replicates","pass"
    }
    FILENAME == ARGV[1] {
        count[$1]++
        reps[$1]=reps[$1] (reps[$1] == "" ? "" : ",") $2
        next
    }
    {print $0,count[$4]+0,reps[$4],(count[$4]>=k ? 1 : 0)}
' "$TMP_DIR/votes.tsv" "$TMP_DIR/candidates.bed" \
    > "${OUTPUT_STEM}.support.tsv"

awk 'BEGIN {FS=OFS="\t"} NR>1 && $9==1 {
    print $1,$2,$3,$4,$5,$6
}' "${OUTPUT_STEM}.support.tsv" > "$TMP_DIR/supported.bed"

# Step 4: Resolve overlaps only after evaluating replicate support.
case "$FINAL" in
    best)
        sort -k1,1 -k2,2n -k3,3n "$TMP_DIR/supported.bed" | \
            bedtools cluster -i - "${STRAND_ARGS[@]}" | \
            sort -k7,7n -k5,5nr -k1,1 -k2,2n -k3,3n | \
            awk 'BEGIN {OFS="\t"} !seen[$7,$6]++ {
                print $1,$2,$3,$4,$5,$6
            }' | \
            sort -k1,1 -k2,2n -k3,3n \
            > "$OUTPUT_FILE"
        ;;
    merge)
        bedtools merge -i "$TMP_DIR/supported.bed" \
            "${STRAND_ARGS[@]}" -c 6 -o distinct | \
            sort -k1,1 -k2,2n -k3,3n -k4,4 | \
            awk -v p="${OUTPUT_NAME%.*}" 'BEGIN {OFS="\t"} {
                print $1,$2,$3,sprintf("%s_%07d",p,NR),0,$4
            }' > "$OUTPUT_FILE"
        ;;
    keep) cat "$TMP_DIR/supported.bed" > "$OUTPUT_FILE" ;;
esac

awk 'BEGIN {OFS="\t"; print "GeneID","Chr","Start","End","Strand"}
    {print $4,$1,$2+1,$3,$6}' "$OUTPUT_FILE" \
    > "${OUTPUT_STEM}.saf"

echo "Done. Final file: $OUTPUT_FILE"
