#!/bin/bash
set -e

fq1=$1
fq2=$2
prefix=$3
threads=$4

genomeIndexDir=$5
genomeSeq=$genomeIndexDir/genome.fa
genomeAnno=$genomeIndexDir/genome.gtf

############################################################
echo "Analysis process starts: $(date +"%Y-%m-%d %H:%M:%S")" \
    > logs/$prefix.time.log

bowtie2IndexDir=$genomeIndexDir/bowtie2Index/ncrna
starIndexDir=$genomeIndexDir/starIndex150L

############################################################
# Evaluate the quality Of raw reads
fastqc -t $threads -o 01_raw 01_raw/$fq1
fastqc -t $threads -o 01_raw 01_raw/$fq2

echo "fastqc raw reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
# Filter poor quality reads & Remove adaptors
mkdir -p 02_clean

######
trim_galore --cores $threads --phred33 -q 25 \
    -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
    -a2 AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
    --stringency 1 -e 0.1 --gzip --length 25 --max_length 40 --paired \
    -o 02_clean $fq1 $fq2

cleanR1=02_clean/${prefix}_1_val_1.fq.gz
cleanR2=02_clean/${prefix}_2_val_2.fq.gz

echo "trim galore reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

######
adapters=/Data2/caoq/miniforge3/envs/ngstools/share/trimmomatic-0.39-2/adapters/TruSeq3-PE-2.fa
trimmomatic PE -phred33 -threads $threads 01_raw/$fq1 01_raw/$fq2 \
    02_clean/${prefix}_R1_clean.fq.gz 02_clean/${prefix}_R1_unpaired.fq.gz \
    02_clean/${prefix}_R2_clean.fq.gz 02_clean/${prefix}_R2_unpaired.fq.gz \
    ILLUMINACLIP:${adapters}:2:30:10 \
    SLIDINGWINDOW:4:15 LEADING:3 TRAILING:3 MINLEN:25 CROP:40

cleanR1=02_clean/${prefix}_R1_clean.fq.gz
cleanR2=02_clean/${prefix}_R2_clean.fq.gz

echo "trimmomatic reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
# Evaluate the quality of clean reads
fastqc -t $threads -o 02_clean $cleanR1
fastqc -t $threads -o 02_clean $cleanR2

echo "fastqc clean reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
# Remove reads which mapped to ncRNA [optional]
mkdir -p 03_rmncRNA

bowtie2 -p $threads -x $bowtie2IndexDir -1 $cleanR1 -2 $cleanR2 \
    --un-conc-gz 03_rmncRNA/$prefix.rmncRNA_R%.fq.gz | \
    samtools view -@ $threads -b -S -o 03_rmncRNA/$prefix.ncRNA.bam

cleanR1=03_rmncRNA/$prefix.rmrRNA_R1.fq.gz
cleanR2=03_rmncRNA/$prefix.rmrRNA_R2.fq.gz

echo "remove ncRNA reads by bowtie2: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
# Evaluate the quality of remove ncRNA reads [optional]
fastqc -t $threads -o 03_rmncRNA $cleanR1
fastqc -t $threads -o 03_rmncRNA $cleanR2

echo "fastqc remove ncRNA reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
# Alignment reads by STAR
mkdir -p 04_star

STAR --runThreadN $threads --genomeDir $starIndexDir \
    --readFilesIn $cleanR1 $cleanR2 \
    --alignEndsType EndToEnd --outFilterMultimapNmax 1 \
    --outSAMattributes All --readFilesCommand zcat \
    --outSAMtype BAM Unsorted --quantMode TranscriptomeSAM \
    --outFileNamePrefix 04_star/$prefix.

samtools sort -@ $threads 04_star/$prefix.Aligned.out.bam \
    -o 04_star/$prefix.sorted.bam
samtools index 04_star/$prefix.sorted.bam

samtools flagstat 04_star/$prefix.sorted.bam \
    >04_star/$prefix.sorted.flagstat

echo "star align: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
mkdir -p 05_ribotish

ribotish quality -p $threads -l 25,35 -g $genomeAnno \
    -b 04_star/$prefix.sorted.bam -o 05_ribotish/${prefix}_qual.txt \
    -f 05_ribotish/${prefix}_qual.pdf -r 05_ribotish/${prefix}.para.py

echo "ribotish quality: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
mkdir -p 05_ribotish

ribotish predict -p $threads -g $genomeAnno -f $genomeSeq \
    --longest --seq --inframecount -b 04_star/$prefix.sorted.bam \
    --ribopara 05_ribotish/${prefix}.para.py \
    -o 05_ribotish/$prefix.pred.longest.txt

echo "ribotish bam: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
mkdir -p 06_ribotricer

ribotricerIndexDir=$genomeIndexDir/../ribotricer_candidate_ORFs.tsv
ribotricer detect-orfs --bam 04_star/$prefix.sorted.bam \
    --ribotricer_index $ribotricerIndexDir --prefix 06_ribotricer/$prefix

echo "ribotricer predict: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

echo "Analysis process ends: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log
