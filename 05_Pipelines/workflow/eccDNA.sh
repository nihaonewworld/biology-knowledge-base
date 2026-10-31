#!/bin/bash
set -euo pipefail

# Align reads and sort by coordinate
bwa mem -t {threads} -q "{input.index}" "{input.fq1}" "{input.fq2}" | \
	samtools sort -@ {threads} -o "{output.sorted.bam}" -

samtools index "{output.sorted.bam}"

# Sort by read name for ReadExtractor and Realign
samtools sort -@ {threads} -n -o "{output.sortedByName.bam}" "{output.sorted.bam}"

# Extract candidate circular DNA reads
Circle-Map ReadExtractor -i "{output.sortedByName.bam}" -o "{output.candidates.bam}"

# Sort candidate reads by coordinate and index
samtools sort -@ {threads} -o "{output.candidates.sorted.bam}" "{output.candidates.bam}"

samtools index "{output.candidates.sorted.bam}"

# Detect candidate eccDNA
Circle-Map Realign \
	-t {threads} \
	-fasta "{input.fa}" \
	-i "{output.candidates.sorted.bam}" \
	-qbam "{output.sortedByName.bam}" \
	-sbam "{output.sorted.bam}" \
	-o "{output.circularDNA.bed}"
