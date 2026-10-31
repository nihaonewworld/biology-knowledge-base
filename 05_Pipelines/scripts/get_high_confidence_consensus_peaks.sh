#!/bin/bash

# ==============================================================================
# Script: get_high_confidence_consensus_peaks.sh
# Description: Standardizes narrowPeak files, calculates SPM normalization, 
#			  filters by blacklist, and identifies high-confidence consensus 
#			  peaks across multiple biological replicates (N >= 2).
# ==============================================================================

set -e
set -u
set -o pipefail

# Default values
SPM_CUTOFF=3
PREFIX="consensus"

usage() {
	echo "Usage: $0 -g chrom.sizes -b blacklist.bed [-s spm_cutoff] [-o prefix] peak1.narrowPeak peak2.narrowPeak ..."
	echo "  -g: Chromosome sizes file (required)"
	echo "  -b: Blacklist regions BED file (required)"
	echo "  -s: SPM (Scores Per Million) threshold (default: 3)"
	echo "  -o: Output file prefix (default: 'consensus')"
	exit 1
}

# Parse command line arguments
while getopts "g:b:s:o:" opt; do
	case $opt in
		g) CHROM_SIZES=$OPTARG ;;
		b) BLACKLIST=$OPTARG ;;
		s) SPM_CUTOFF=$OPTARG ;;
		o) PREFIX=$OPTARG ;;
		*) usage ;;
	esac
done
shift $((OPTIND-1))

INPUT_FILES=("$@")

# Validation
if [ ${#INPUT_FILES[@]} -lt 2 ]; then
	echo "Error: At least 2 input narrowPeak files are required."
	usage
fi

# Create a temporary directory for intermediate files
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Processing ${#INPUT_FILES[@]} replicates with SPM >= $SPM_CUTOFF..."

# --- Step 1: Individual Replicate Processing ---
PROCESSED_LIST=()
for i in "${!INPUT_FILES[@]}"; do
	IN_PEAK="${INPUT_FILES[$i]}"
	REP_ID=$((i+1))
	TEMP_BED="$TMP_DIR/rep${REP_ID}.processed.bed"

	# 1.1 Extract summits, expand to 500bp, filter blacklist, and resolve intra-sample overlaps
	awk 'BEGIN{OFS="\t"} $1 ~ /^chr([1-9]|[1-2][0-9]|X|Y)$/ { 
		summit = $2 + $10
		print $1, summit, summit+1, $4, $8, $6 
	}' "$IN_PEAK" | \
	bedtools slop -b 250 -g "$CHROM_SIZES" | \
	bedtools intersect -v -a - -b "$BLACKLIST" | \
	sort -k1,1 -k2,2n -k3,3n | \
	bedtools cluster -i - | \
	sort -k7,7n -k5,5nr | \
	awk 'BEGIN{OFS="\t"} !seen[$7]++ {print $1,$2,$3,$4,$5,$6}' > "$TMP_DIR/rep${REP_ID}.tmp"

	# 1.2 Calculate total score for SPM normalization
	TOTAL_SCORE=$(awk '{sum += $5} END {print sum}' "$TMP_DIR/rep${REP_ID}.tmp")

	# 1.3 Apply SPM normalization and user-defined cutoff
	awk -v s_max="$TOTAL_SCORE" -v cutoff="$SPM_CUTOFF" 'BEGIN{OFS="\t"} {
		spm = $5 * 1e6 / s_max
		if (spm >= cutoff) {
			$5 = spm
			print $0
		}
	}' "$TMP_DIR/rep${REP_ID}.tmp" > "$TEMP_BED"
	
	PROCESSED_LIST+=("$TEMP_BED")
done

# --- Step 2: Inter-replicate Intersection (min 2 replicates) ---
VALIDATED_LIST=()
for i in "${!PROCESSED_LIST[@]}"; do
	CURRENT="${PROCESSED_LIST[$i]}"
	OTHERS=()
	for j in "${!PROCESSED_LIST[@]}"; do
		[[ $i -eq $j ]] && continue
		OTHERS+=("${PROCESSED_LIST[$j]}")
	done
	
	VAL_OUT="$TMP_DIR/rep$((i+1)).validated.bed"
	# Keep peaks in 'A' that overlap with any other replicate 'B' (50% reciprocal)
	bedtools intersect -a "$CURRENT" -b "${OTHERS[@]}" -f 0.5 -r -u > "$VAL_OUT"
	VALIDATED_LIST+=("$VAL_OUT")
done

# --- Step 3: Final Consensus Building ---
cat "${VALIDATED_LIST[@]}" | \
	sort -k1,1 -k2,2n -k3,3n | \
	bedtools cluster -i - | \
	sort -k7,7n -k5,5nr | \
	awk 'BEGIN{OFS="\t"} !seen[$7]++ {print $1,$2,$3,$4,$5,$6}' \
	> "${PREFIX}.consensus.bed"

echo "Done. Final file: ${PREFIX}.consensus.bed"
