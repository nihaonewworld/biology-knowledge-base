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
METHOD="peak"
TYPE="auto"
CHROM_SIZES=""
BLACKLIST="none"
PREFIX="consensus"
SPM_CUTOFF=0
MIN_REPS=2
FRACTION=0.5
OVERLAP="reciprocal"
STRANDED=false
WIDTH=500
SCORE_COL=0
SUMMIT_COL=0
FINAL="best"
POOLED=""

usage() {
    cat <<EOF
Usage: $0 --chrom_sizes FILE [options] rep1.peaks rep2.peaks ...
  -g, --chrom_sizes FILE       Chromosome sizes (required)
  -b, --blacklist FILE         Blacklist BED (default: none)
  -o, --output_prefix TEXT     Output prefix (default: consensus)
  -m, --method MODE            peak, summit, pooled (default: peak)
  -t, --peak_type TYPE         auto, narrowPeak, broadPeak, bed (default: auto)
  -n, --min_reps INT           Minimum supporting replicates (default: 2)
  -f, --overlap_fraction NUM   Minimum overlap fraction (default: 0.5)
  -r, --overlap_mode MODE      reciprocal (default), candidate, or either
  -s, --stranded               Require same strand (default: unstranded)
  -w, --summit_width INT       Summit window width in bp (default: 500)
  -c, --score_column INT       Score column (default: 8 for peaks, 5 for BED)
  -e, --spm_cutoff NUM         SPM cutoff (default: 0, disabled)
  -v, --summit_column INT      Summit offset column (narrowPeak default: 10)
  -j, --final_mode MODE        best or merge (default: best)
  -u, --pooled_peaks FILE      External pooled peaks (required in pooled mode)
  -h, --help                   Show help

Use --option value; options precede replicate files. Use -- to end options.
Column numbers are 1-based. Summit offsets are relative to BED start.
Summit mode has no midpoint fallback. A missing score column uses 1.
The method name bedtools is accepted as an alias for peak.
EOF
}

# Parse short aliases and descriptive long options without external getopt.
while [[ $# -gt 0 ]]; do
    case "$1" in
        -g|--chrom_sizes) CHROM_SIZES="$2"; shift 2 ;;
        -b|--blacklist) BLACKLIST="$2"; shift 2 ;;
        -o|--output_prefix) PREFIX="$2"; shift 2 ;;
        -m|--method) METHOD="$2"; shift 2 ;;
        -t|--peak_type) TYPE="$2"; shift 2 ;;
        -n|--min_reps) MIN_REPS="$2"; shift 2 ;;
        -f|--overlap_fraction) FRACTION="$2"; shift 2 ;;
        -r|--overlap_mode) OVERLAP="$2"; shift 2 ;;
        -s|--stranded) STRANDED=true; shift ;;
        -w|--summit_width) WIDTH="$2"; shift 2 ;;
        -c|--score_column) SCORE_COL="$2"; shift 2 ;;
        -e|--spm_cutoff) SPM_CUTOFF="$2"; shift 2 ;;
        -v|--summit_column) SUMMIT_COL="$2"; shift 2 ;;
        -j|--final_mode) FINAL="$2"; shift 2 ;;
        -u|--pooled_peaks) POOLED="$2"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        --) shift; break ;;
        -*) usage; exit 1 ;;
        *) break ;;
    esac
done
INPUT_FILES=("$@")

# Keep only the basic usage requirements.
if [[ -z "$CHROM_SIZES" || ${#INPUT_FILES[@]} -lt 2 ]]; then
    usage
    exit 1
fi
if ((MIN_REPS < 2 || MIN_REPS > ${#INPUT_FILES[@]})); then
    echo "Error: --min_reps must be between 2 and the replicate count." >&2
    exit 1
fi
[[ "$METHOD" == "bedtools" ]] && METHOD="peak"
case "$METHOD:$FINAL" in
    peak:best|peak:merge|summit:best|summit:merge|pooled:best|pooled:merge) ;;
    *) usage; exit 1 ;;
esac

# Apply one strand policy to support matching and final region grouping.
STRAND_ARGS=()
if "$STRANDED"; then
    STRAND_ARGS=(-s)
fi

mkdir -p "$(dirname -- "$PREFIX")"
TMP_DIR=$(mktemp -d)
trap 'rm -rf -- "$TMP_DIR"' EXIT

read_peaks() {
    case "$1" in
        *.gz) gzip -cd -- "$1" ;;
        *) cat -- "$1" ;;
    esac
}

peak_type() {
    if [[ "$TYPE" != "auto" ]]; then
        echo "$TYPE"
        return
    fi
    case "${1%.gz}" in
        *.narrowPeak) echo narrowPeak ;;
        *.broadPeak) echo broadPeak ;;
        *) echo bed ;;
    esac
}

# Standardize to BED6 without collapsing peaks within a replicate.
process_peaks() {
    local input="$1" output="$2" label="$3"
    local type score summit
    type=$(peak_type "$input")
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

    read_peaks "$input" | awk \
        -v mode="$METHOD" -v width="$WIDTH" -v sc="$score" \
        -v su="$summit" -v label="$label" -v stranded="$STRANDED" \
        'BEGIN {OFS="\t"}
        FILENAME == ARGV[1] {size[$1]=$2; next}
        /^#/ || /^track/ || /^browser/ || NF < 3 {next}
        !($1 in size) {next}
        {
            start=$2; end=$3
            if (mode == "summit") {
                if (su > NF || $su < 0) next
                center=start+$su
                start=center-int(width/2)
                end=start+width
            }
            if (start < 0) start=0
            if (end > size[$1]) end=size[$1]
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
    ' "$CHROM_SIZES" - > "$output.raw"

    if [[ "$BLACKLIST" == "none" ]]; then
        cat "$output.raw" > "$output.clean"
    else
        bedtools intersect -v -a "$output.raw" -b "$BLACKLIST" \
            > "$output.clean"
    fi

    # SPM uses the retained scores in this file, not fragment counts.
    awk -v cutoff="$SPM_CUTOFF" 'BEGIN {OFS="\t"}
        FNR == NR {total+=$5; next}
        cutoff == 0 {print; next}
        total > 0 {
            $5=$5*1000000/total
            if ($5 >= cutoff) print
        }
    ' "$output.clean" "$output.clean" \
        | sort -k1,1 -k2,2n -k3,3n > "$output"
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
sort -k1,1 -k2,2n -k3,3n -k6,6 -k5,5nr "$TMP_DIR/candidates.raw" \
    | awk 'BEGIN {OFS="\t"} !seen[$1,$2,$3,$6]++ {
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
        "${STRAND_ARGS[@]}" \
        | awk -v rep="$((i + 1))" 'BEGIN {OFS="\t"} {print $4,rep}' \
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
    > "${PREFIX}.support.tsv"

awk 'BEGIN {FS=OFS="\t"} NR>1 && $9==1 {
    print $1,$2,$3,$4,$5,$6
}' "${PREFIX}.support.tsv" > "$TMP_DIR/supported.bed"

# Step 4: Resolve overlaps only after evaluating replicate support.
if [[ "$FINAL" == "best" ]]; then
    bedtools cluster -i "$TMP_DIR/supported.bed" "${STRAND_ARGS[@]}" \
        | sort -k7,7n -k5,5nr -k1,1 -k2,2n -k3,3n \
        | awk 'BEGIN {OFS="\t"} !seen[$7,$6]++ {
            print $1,$2,$3,$4,$5,$6
        }' | sort -k1,1 -k2,2n > "${PREFIX}.consensus.bed"
else
    bedtools merge -i "$TMP_DIR/supported.bed" \
        "${STRAND_ARGS[@]}" -c 6 -o distinct \
        | sort -k1,1 -k2,2n -k3,3n -k4,4 \
        | awk -v p="$(basename -- "$PREFIX")" 'BEGIN {OFS="\t"} {
            print $1,$2,$3,sprintf("%s_%07d",p,NR),0,$4
        }' > "${PREFIX}.consensus.bed"
fi

awk 'BEGIN {OFS="\t"; print "GeneID","Chr","Start","End","Strand"}
    {print $4,$1,$2+1,$3,$6}' "${PREFIX}.consensus.bed" \
    > "${PREFIX}.consensus.saf"

echo "Done. Final file: ${PREFIX}.consensus.bed"
