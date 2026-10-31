#!/usr/bin/env bash

# ==============================================================================
# Script: run_rmats_simple.sh
# Description: Runs rMATS, selects significant JC events, and draws Sashimi plots.
# Input: Prepared, coordinate-sorted and indexed BAM files.
# Direction: b1 = control, b2 = treatment; delta PSI = control - treatment.
# ==============================================================================

set -euo pipefail
shopt -s nullglob

export LC_ALL=C
export MPLBACKEND=Agg

# Paths and sample groups

base_dir="$PWD/02_output"
bam_dir="$base_dir/03_align"
rmats_dir="$base_dir/06_rmats"

ctrl="WT"
treat="KO"
prefix="KO_vs_WT"

results_dir="$rmats_dir/$prefix/all_events"
significant_dir="$rmats_dir/$prefix/filtered_events"
sashimi_dir="$rmats_dir/$prefix/sashimi"

gtf="$HOME/reference/Mus_musculus/mm10/index/genome.gtf"
threads=6
read_length=150
lib_type="fr-unstranded"
fdr_cutoff=0.01
dpsi_cutoff=0.05

# --- Step 1: Prepare BAM Lists ---

mkdir -p "$results_dir" "$significant_dir" "$sashimi_dir"
tmp_dir=$(mktemp -d "$rmats_dir/tmp")

ctrl_bams=("$bam_dir"/*"$ctrl"*.bam)
treat_bams=("$bam_dir"/*"$treat"*.bam)

ctrl_list="$rmats_dir/${prefix}_ctrl.txt"
treat_list="$rmats_dir/${prefix}_treat.txt"

printf '%s\n' "${ctrl_bams[@]}" | paste -sd, - > "$ctrl_list"
printf '%s\n' "${treat_bams[@]}" | paste -sd, - > "$treat_list"

# --- Step 2: Run rMATS ---

# cstat controls the statistical test; dpsi_cutoff controls downstream filtering.
# mil and mel apply only to novel splice-site discovery enabled by novelSS.

rmats.py \
    --gtf "$gtf" \
    --b1 "$ctrl_list" \
    --b2 "$treat_list" \
    --od "$results_dir" \
    --tmp "$rmats_dir/$prefix/.rmats" \
    -t paired \
    --libType "$lib_type" \
    --readLength "$read_length" \
    --variable-read-length \
    --nthread "$threads" \
    --cstat 0.0001 \
    --novelSS \
    --mil 50 \
    --mel 500 \
    --allow-clipping \
    --individual-counts \
    &> "$rmats_dir/rmats.${prefix}.log"

# --- Step 3: Filter Significant Events and Generate Sashimi Plots ---

events=(SE A3SS A5SS MXE RI)

for event in "${events[@]}"; do
    echo "Processing ${event} events..."

    result_file="$results_dir/${event}.MATS.JC.txt"
    significant_file="$significant_dir/${event}.significant.JC.txt"
    event_plot_dir="$sashimi_dir/${event}"
    plot_log="$sashimi_dir/${event}.log"


    if [[ ! -s "$result_file" ]]; then
        echo "Error: Missing or empty result file: $result_file" >&2
        exit 1
    fi

    # Preserve the original columns and select events with valid statistics.
    awk -F '\t' \
        -v fdr_cutoff="$fdr_cutoff" \
        -v dpsi_cutoff="$dpsi_cutoff" '
        function is_number(x) {
            return x ~ /^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)([eE][+-]?[0-9]+)?$/
        }
        NR == 1 {
            sub(/\r$/, "")
            for (i = 1; i <= NF; i++) {
                if ($i == "FDR") fdr_col = i
                if ($i == "IncLevelDifference") diff_col = i
            }
            print
            next
        }
        {
            sub(/\r$/, "")
            if (!is_number($fdr_col) || !is_number($diff_col)) next

            fdr = $fdr_col + 0
            diff = $diff_col + 0
            abs_diff = (diff < 0) ? -diff : diff

            if (fdr >= 0 && fdr < fdr_cutoff && abs_diff > dpsi_cutoff && abs_diff <= 1) {
                print
            }
        }
    ' "$result_file" > "$significant_file"

    event_count=$(awk 'END {print NR - 1}' "$significant_file")
    echo "${event}: ${event_count} significant events."

    # Skip plotting when the filtered table contains only the header.
    if (( event_count == 0 )); then
        echo "Skipping ${event}: no significant events."
        continue
    fi

    # Keep the same group order and BAM lists as the rMATS analysis.
    rmats2sashimiplot \
        --b1 "$(cat "$ctrl_list")" \
        --b2 "$(cat "$treat_list")" \
        --l1 "$ctrl" \
        --l2 "$treat" \
        --event-type "$event" \
        -e "$significant_file" \
        --exon_s 1 \
        --intron_s 5 \
        -o "$event_plot_dir" \
        &> "$plot_log"

    echo "${event}: plotting command finished. Log: $plot_log"
done
