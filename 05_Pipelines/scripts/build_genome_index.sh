#!/bin/bash

set -euo pipefail

# ==========================================================
# 1. Global Configurations & Path Definitions
# ==========================================================
threads=6

genome_dir="$HOME/reference/Homo_sapiens/hg38"
genome_fasta="$genome_dir/GRCh38.primary_assembly.genome.fa"
genome_gtf="$genome_dir/gencode.v48.annotation.gtf"
transcript_fasta="$genome_dir/gencode.v48.transcripts.fa"
ncrna_fasta="$genome_dir/Homo_sapiens.GRCh38.ncrna.fa"
index_dir="$genome_dir/index"

# Create the main index output directory
mkdir -p "$index_dir"

# Create symbolic links for central reference files
ln -s -f "$genome_fasta" "$index_dir/genome.fa"
ln -s -f "$genome_gtf" "$index_dir/genome.gtf"

# Function to display and append timestamped logs
log_time() {
    local message="$1"
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $message" | \
        tee -a "$index_dir/run_time.log"
}

log_time "Build reference genome index process starts."

# ==========================================================
# 2. Activate Conda Environment
# ==========================================================
CONDA_BASE=$(conda info --base 2>/dev/null || echo "$HOME/miniconda3")
if [ -f "$CONDA_BASE/etc/profile.d/conda.sh" ]; then
    source "$CONDA_BASE/etc/profile.d/conda.sh"
    conda activate ngstools
else
    echo "Warning: Failed to locate conda.sh, falling back to direct activation..." >&2
    source "$HOME/miniconda3/bin/activate" ngstools
fi

# ==========================================================
# 3. Extract rRNA Sequences (SeqKit)
# ==========================================================
log_time "Extracting rRNA sequences..."
rrna_fasta="$genome_dir/$(basename "$ncrna_fasta" "ncrna.fa")rrna.fa"

# Extract both nuclear rRNA and mitochondrial rRNA (Mt_rRNA) from ncRNA fasta
seqkit grep -n -r -p "gene_biotype:(rRNA|Mt_rRNA)" \
    -o "$rrna_fasta" "$ncrna_fasta"

samtools faidx "$index_dir/genome.fa"
cut -f 1,2 "$index_dir/genome.fa.fai" > "$index_dir/genome.chrom.sizes"
# ==========================================================
# 4. Bowtie2 Indices v2.5.5
# ==========================================================
log_time "Building Bowtie2 indices..."
mkdir -p "$index_dir/bowtie2_index"

# Genome index
bowtie2-build --threads "$threads" "$genome_fasta" \
    "$index_dir/bowtie2_index/genome" \
    &> "$index_dir/bowtie2_index.log"

# ncRNA index
bowtie2-build --threads "$threads" "$ncrna_fasta" \
    "$index_dir/bowtie2_index/ncrna" \
    &> "$index_dir/bowtie2_index_ncRNA.log"

# rRNA index
bowtie2-build --threads "$threads" "$rrna_fasta" \
    "$index_dir/bowtie2_index/rrna" \
    &> "$index_dir/bowtie2_index_rRNA.log"

log_time "Bowtie2 indices completed."

# ==========================================================
# 5. Bowtie Index v1.3.1
# ==========================================================
log_time "Building Bowtie1 rRNA index..."
mkdir -p "$index_dir/bowtie_index"

bowtie-build --threads "$threads" "$rrna_fasta" \
    "$index_dir/bowtie_index/rrna" \
    &> "$index_dir/bowtie_index_rRNA.log"

log_time "Bowtie1 index completed."

# ==========================================================
# 6. BWA Index v0.7.19
# ==========================================================
log_time "Building BWA index..."
mkdir -p "$index_dir/bwa_index"

bwa index -p "$index_dir/bwa_index/genome" "$genome_fasta" \
    &> "$index_dir/bwa_index.log"

log_time "BWA index completed."

# ==========================================================
# 7. Bismark Index v0.25.1
# ==========================================================
log_time "Building Bismark index..."
mkdir -p "$index_dir/bismark_index"
ln -s -f "$genome_fasta" "$index_dir/bismark_index/genome.fa"

bismark_genome_preparation --parallel 4 --bowtie2 \
    --genomic_composition --verbose "$index_dir/bismark_index" \
    &> "$index_dir/bismark_index.log"

log_time "Bismark index completed."

# ==========================================================
# 8. STAR Index v2.7.11b
# ==========================================================
log_time "Building STAR index..."

STAR --runMode genomeGenerate --runThreadN "$threads" \
    --genomeFastaFiles "$genome_fasta" \
    --sjdbGTFfile "$genome_gtf" --sjdbOverhang 149 \
    --genomeDir "$index_dir/star_index" \
    &> "$index_dir/star_index.log"

log_time "STAR index completed."

# ==========================================================
# 9. HISAT2 Index v2.2.2 (more than 64G)
# ==========================================================
log_time "Building HISAT2 index..."
mkdir -p "$index_dir/hisat2_index"

# Extract splice sites and exons from GTF annotation
hisat2_extract_splice_sites.py "$genome_gtf" \
    > "$index_dir/hisat2_index/extract_splice_sites.ss"

hisat2_extract_exons.py "$genome_gtf" \
    > "$index_dir/hisat2_index/extract_exons.exon"

# Build HISAT2 index incorporating splice site and exon info
hisat2-build -p "$threads" \
    --ss "$index_dir/hisat2_index/extract_splice_sites.ss" \
    --exon "$index_dir/hisat2_index/extract_exons.exon" \
    "$genome_fasta" "$index_dir/hisat2_index/genome" \
    &> "$index_dir/hisat2_index.log"

log_time "HISAT2 index completed."

# ==========================================================
# 10. Salmon Index v1.11.4
# ==========================================================
log_time "Building Salmon index..."
mkdir -p "$index_dir/salmon_index"

salmon index -p "$threads" -k 31 -t "$transcript_fasta" \
    --gencode -i "$index_dir/salmon_index" \
    &> "$index_dir/salmon_index.log"

log_time "Salmon index completed."

# ==========================================================
# 11. Kallisto Index v0.52.0
# ==========================================================
log_time "Building Kallisto index..."
mkdir -p "$index_dir/kallisto_index"

kallisto index -t "$threads" \
    -i "$index_dir/kallisto_index/transcriptome" \
    "$transcript_fasta" \
    &> "$index_dir/kallisto_index.log"

log_time "Kallisto index completed."

log_time "All reference genome indices built successfully!"
