#!/bin/bash
# =============================================================================
# Script: get_reproducible_peaks.sh
# Description: Identify replicate-supported peaks using original intervals,
#              summit windows, or external pooled candidates. Configure overlap,
#              score filtering, and final merging or representative selection.
#              Export BED6, replicate support statistics, and SAF annotation.
# =============================================================================

set -e
set -u
set -o pipefail
export LC_ALL=C

METHOD="intersect"
FORMAT="auto"
POOLED=""
CHROM_SIZES=""
BLACKLIST="none"
SUMMIT=0
FLANK=250
SCORE=0
WITHIN="auto"
SPM="auto"
FRACTION=0.5
OVERLAP="either"
SUPPORT=2
STRANDED=false
FINAL="auto"
OUTPUT="consensus.bed"

usage() {
    cat <<EOF
Usage: $0 [options] rep1.peaks rep2.peaks ...
  -m, --method MODE         intersect, summit, pooled (default: intersect)
  -t, --format FORMAT       auto, narrowPeak, broadPeak, bed (default: auto)
  -u, --pooled FILE         External pooled peaks (required in pooled mode)
  -g, --chromSizes FILE     Chromosome sizes (required for summit)
  -b, --blacklist FILE      Blacklist BED (default: none)
  -v, --summit INT          Summit offset column (narrowPeak default: 10)
  -w, --flank INT           Extension per side in bp (default: 250)
  -c, --score INT           Score column (default: summit=8, other=5)
  -q, --within MODE         auto, best, none (default: auto)
  -e, --spm VALUE           auto, none, or a numeric SPM cutoff
  -f, --fraction NUM        Minimum overlap fraction (default: 0.5)
  -r, --overlap MODE        either (default), reciprocal, or candidate
  -k, --support INT         Minimum supporting replicates (default: 2)
  -s, --stranded            Require same strand (default: unstranded)
  -j, --final MODE          auto, best, merge, keep (default: auto)
  -o, --output FILE         Final output (default: consensus.bed)
  -h, --help                Show help

Use --option value; options precede replicate files. Use -- to end options.
Column numbers are 1-based. Summit offsets are relative to BED start.
Input must be plain-text BED6 or richer; summit defaults to narrowPeak.
All intermediate files are retained in the output directory.
Pooled analysis requires both --method pooled and --pooled FILE.
Auto final mode: intersect=merge, summit=best, pooled=keep.
Auto within-replicate mode: summit=best, other methods=none.
SPM 0 keeps scores as SPM without a positive cutoff; none disables SPM.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -m|--method) METHOD="$2"; shift 2 ;;
        -t|--format) FORMAT="$2"; shift 2 ;;
        -u|--pooled) POOLED="$2"; shift 2 ;;
        -g|--chromSizes) CHROM_SIZES="$2"; shift 2 ;;
        -b|--blacklist) BLACKLIST="$2"; shift 2 ;;
        -v|--summit) SUMMIT="$2"; shift 2 ;;
        -w|--flank) FLANK="$2"; shift 2 ;;
        -c|--score) SCORE="$2"; shift 2 ;;
        -q|--within) WITHIN="$2"; shift 2 ;;
        -e|--spm) SPM="$2"; shift 2 ;;
        -f|--fraction) FRACTION="$2"; shift 2 ;;
        -r|--overlap) OVERLAP="$2"; shift 2 ;;
        -k|--support) SUPPORT="$2"; shift 2 ;;
        -s|--stranded) STRANDED=true; shift ;;
        -j|--final) FINAL="$2"; shift 2 ;;
        -o|--output) OUTPUT="$2"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        --) shift; break ;;
        -*) usage; exit 1 ;;
        *) break ;;
    esac
done
INPUTS=("$@")

if ((SUPPORT < 1 || SUPPORT > ${#INPUTS[@]})); then
    echo "Error: --support must be between 1 and the replicate count." >&2
    exit 1
fi
case "$METHOD" in
    intersect|summit|pooled) ;;
    *) usage; exit 1 ;;
esac
if [[ "$METHOD" == "summit" && -z "$CHROM_SIZES" ]]; then
    echo "Error: summit mode requires --chromSizes." >&2
    exit 1
fi
if [[ "$METHOD" == "pooled" && -z "$POOLED" ]]; then
    echo "Error: pooled mode requires --pooled." >&2
    exit 1
fi
if [[ -n "$POOLED" && "$METHOD" != "pooled" ]]; then
    echo "Error: --pooled requires --method pooled." >&2
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
if [[ "$SPM" == "auto" ]]; then
    SPM="none"
    [[ "$METHOD" == "summit" ]] && SPM=3
fi
case "$OVERLAP" in either|reciprocal|candidate) ;;
    *) usage; exit 1 ;;
esac
case "$FINAL" in best|merge|keep) ;; *) usage; exit 1 ;; esac
case "$WITHIN" in best|none) ;; *) usage; exit 1 ;; esac
case "$FORMAT" in
    auto|narrowPeak|broadPeak|bed) ;;
    *) usage; exit 1 ;;
esac

CHROM_FILES=()
if [[ -n "$CHROM_SIZES" ]]; then
    CHROM_FILES=("$CHROM_SIZES")
fi

STRAND_ARGS=()
if "$STRANDED"; then
    STRAND_ARGS=(-s)
fi

OUTPUT_DIR=$(dirname -- "$OUTPUT")
OUTPUT_NAME=$(basename -- "$OUTPUT")
OUTPUT_STEM="$OUTPUT_DIR/${OUTPUT_NAME%.*}"
mkdir -p "$OUTPUT_DIR"

# Choose the highest-scoring interval per connected overlap cluster.
best_peaks() {
    sort -k1,1 -k2,2n -k3,3n | \
        bedtools cluster -i - "${STRAND_ARGS[@]}" | \
        sort -k7,7n -k5,5nr -k1,1 -k2,2n -k3,3n | \
        awk -v stranded="$STRANDED" 'BEGIN {OFS="\t"}
            !seen[$7,(stranded == "true" ? $6 : ".")]++ {
                print $1,$2,$3,$4,$5,$6
            }' | \
        sort -k1,1 -k2,2n -k3,3n
}

# Standardize, filter, optionally collapse, and normalize each peak file.
process_peaks() {
    local input="$1" output="$2"
    local format score summit extension=0
    local selected="${output%.bed}.selected.bed"
    format="$FORMAT"
    if [[ "$format" == "auto" ]]; then
        case "$input" in
            *.narrowPeak) format="narrowPeak" ;;
            *.broadPeak) format="broadPeak" ;;
            *) format="bed" ;;
        esac
    fi
    score="$SCORE"
    summit="$SUMMIT"
    if ((score == 0)); then
        score=5
        [[ "$METHOD" == "summit" ]] && score=8
    fi
    if [[ "$format" == "narrowPeak" && "$summit" == "0" ]]; then
        summit=10
    fi
    if [[ "$METHOD" == "summit" && "$summit" == "0" ]]; then
        echo "Error: summit mode needs narrowPeak or -v offset_column." >&2
        exit 1
    fi

    [[ "$METHOD" == "summit" ]] && extension="$FLANK"
    awk -v mode="$METHOD" -v sc="$score" -v su="$summit" \
        -v genome="$CHROM_SIZES" \
        'BEGIN {OFS="\t"}
        genome != "" && FILENAME == genome {size[$1]=$2; next}
        /^#/ || /^track/ || /^browser/ || NF < 6 {next}
        genome != "" && !($1 in size) {next}
        {
            start=$2; end=$3
            if (mode == "summit") {
                if (su > NF || $su < 0) next
                start+=$su
                end=start+1
            }
            if (end <= start) next
            print $1,start,end,$4,$sc,$6
        }
    ' "${CHROM_FILES[@]}" "$input" | \
        if [[ -n "$CHROM_SIZES" ]]; then
            bedtools slop -i - -b "$extension" -g "$CHROM_SIZES"
        else
            cat
        fi | \
        if [[ "$BLACKLIST" == "none" ]]; then
            cat
        else
            bedtools intersect -v -a - -b "$BLACKLIST"
        fi | \
        if [[ "$WITHIN" == "best" ]]; then
            best_peaks
        else
            cat
        fi | \
        if [[ "$SPM" == "none" ]]; then
            cat
        else
            # Keep the scoring input for two-pass SPM calculation and review.
            cat > "$selected"
            awk -v cutoff="$SPM" 'BEGIN {OFS="\t"}
                FNR == NR {total+=$5; next}
                total > 0 {
                    $5=$5*1000000/total
                    if ($5 >= cutoff) print
                }
            ' "$selected" "$selected"
        fi > "$output"
}

# Process each biological replicate independently.
echo "Processing ${#INPUTS[@]} replicates; min support: $SUPPORT"
PROCESSED_FILES=()
for input in "${INPUTS[@]}"; do
    name=$(basename -- "$input")
    filtered="$OUTPUT_DIR/${name%.*}.tmp.${METHOD}.bed"
    process_peaks "$input" "$filtered"
    PROCESSED_FILES+=("$filtered")
done

# Pooled candidates retain their original names, order, scores, and boundaries
# under the defaults. For other methods, remove only identical BED6 records.
if [[ "$METHOD" == "pooled" ]]; then
    name=$(basename -- "$POOLED")
    CANDIDATES="$OUTPUT_DIR/${name%.*}.tmp.${METHOD}.bed"
    process_peaks "$POOLED" "$CANDIDATES"
else
    CANDIDATES="${OUTPUT_STEM}.tmp.candidates.bed"
    sort -u "${PROCESSED_FILES[@]}" > "$CANDIDATES"
fi

OVERLAP_ARGS=(-f "$FRACTION")
case "$OVERLAP" in
    reciprocal) OVERLAP_ARGS+=(-r) ;;
    candidate) ;;
    either) OVERLAP_ARGS+=(-F "$FRACTION" -e) ;;
esac

# Each replicate contributes one vote per candidate, regardless of hit count.
VOTES="${OUTPUT_STEM}.tmp.votes.tsv"
: > "$VOTES"
for i in "${!PROCESSED_FILES[@]}"; do
    bedtools intersect -u -a "$CANDIDATES" \
        -b "${PROCESSED_FILES[i]}" "${OVERLAP_ARGS[@]}" \
        "${STRAND_ARGS[@]}" | \
        awk -v rep="$((i + 1))" 'BEGIN {OFS="\t"} {print $0,rep}' \
        >> "$VOTES"
done

# Use BED6 keys to separate same-name intervals; count each replicate once.
awk -v k="$SUPPORT" 'BEGIN {
        FS=OFS="\t"
        print "chrom","start","end","id","score","strand", \
              "n_support","replicates","pass"
    }
    FILENAME == ARGV[1] {
        key=$1 FS $2 FS $3 FS $4 FS $5 FS $6
        if (!seen[key,$7]++) {
            count[key]++
            reps[key]=reps[key] (reps[key] == "" ? "" : ",") $7
        }
        next
    }
    {print $0,count[$0]+0,reps[$0],(count[$0]>=k ? 1 : 0)}
' "$VOTES" "$CANDIDATES" > "${OUTPUT_STEM}.support.tsv"

# Resolve final intervals after evaluating replicate support.
awk 'BEGIN {FS=OFS="\t"} NR>1 && $9==1 {
    print $1,$2,$3,$4,$5,$6
}' "${OUTPUT_STEM}.support.tsv" | \
    case "$FINAL" in
        best)
            best_peaks | \
                awk -v p="${OUTPUT_NAME%.*}" 'BEGIN {OFS="\t"} {
                    $4=sprintf("%s_%07d",p,NR); print
                }'
            ;;
        merge)
            sort -k1,1 -k2,2n -k3,3n | \
                bedtools merge -i - "${STRAND_ARGS[@]}" -c 6 -o distinct | \
                sort -k1,1 -k2,2n -k3,3n -k4,4 | \
                awk -v p="${OUTPUT_NAME%.*}" 'BEGIN {OFS="\t"} {
                    strand=($4 ~ /,/ ? "." : $4)
                    print $1,$2,$3,sprintf("%s_%07d",p,NR),0,strand
                }'
            ;;
        keep) cat ;;
    esac > "$OUTPUT"

# Convert BED half-open coordinates to SAF 1-based inclusive coordinates.
awk 'BEGIN {OFS="\t"; print "GeneID","Chr","Start","End","Strand"}
    {print $4,$1,$2+1,$3,$6}' "$OUTPUT" \
    > "${OUTPUT_STEM}.saf"

echo "Done. Final file: $OUTPUT"
