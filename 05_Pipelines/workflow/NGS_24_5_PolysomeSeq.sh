#!/bin/bash
set -e

fq1=$1
fq2=$2
prefix=$3

threads=$4

genomeIndexDir=$5
genomeSeq=$genomeIndexDir/genome.fa
genomeAnno=$genomeIndexDir/genome.gtf

outputDir=$6

############################################################

echo "Analysis process starts: $(date +"%Y-%m-%d %H:%M:%S")" \
    > $outputDir/logs/$prefix.time.log

starIndexDir=$genomeIndexDir/starIndex150L
salmonIndexDir=$genomeIndexDir/salmonIndex

############################################################
# Evaluate the quality Of raw reads
fastqc -t $threads -o 01_raw 01_raw/$fq1
fastqc -t $threads -o 01_raw 01_raw/$fq2

echo "fastqc raw reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

############################################################
# Filter poor quality reads & Remove adaptors
mkdir -p $outputDir/02_clean

trimmomatic PE -phred33 -threads $threads \
    01_raw/$fq1 01_raw/$fq2 \
    $outputDir/02_clean/${prefix}_R1_clean.fq.gz \
    $outputDir/02_clean/${prefix}_R1_unpaired.fq.gz \
    $outputDir/02_clean/${prefix}_R2_clean.fq.gz \
    $outputDir/02_clean/${prefix}_R2_unpaired.fq.gz \
    ILLUMINACLIP:adapters.fa:2:30:10 \
    SLIDINGWINDOW:5:20 LEADING:20 TRAILING:20 MINLEN:36 CROP:150

cleanR1=$outputDir/02_clean/${prefix}_R1_clean.fq.gz
cleanR2=$outputDir/02_clean/${prefix}_R2_clean.fq.gz

echo "trimmomatic reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

############################################################
# Evaluate the quality of clean reads
fastqc -t $threads -o $outputDir/02_clean $cleanR1
fastqc -t $threads -o $outputDir/02_clean $cleanR2

echo "fastqc clean reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

############################################################
# Alignment reads by STAR
mkdir -p $outputDir/03_star

STAR --runThreadN $threads --genomeDir $starIndexDir \
    --readFilesIn $cleanR1 $cleanR2 --readFilesCommand zcat \
    --outSAMattributes All --outSAMtype BAM SortedByCoordinate \
    --outFileNamePrefix $outputDir/03_star/$prefix.

echo "star align: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

samtools index $outputDir/03_star/$prefix.Aligned.sortedByCoord.out.bam

samtools flagstat $outputDir/03_star/$prefix.Aligned.sortedByCoord.out.bam \
    > $outputDir/03_star/$prefix.Aligned.sortedByCoord.out.flagstat

echo "samtools sort and index: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

############################################################
# Reads count by htseq-count
mkdir -p $outputDir/03_star/01_htseqCount

samtools sort -@ $threads -n $outputDir/03_star/$prefix.Aligned.sortedByCoord.out.bam \
    -o $outputDir/03_star/$prefix.Aligned.out.sortedByName.bam

htseq-count -f bam -s no -a 10 -m union -t exon -i gene_id --nonunique none \
    $outputDir/03_star/$prefix.Aligned.out.sortedByName.bam $genomeAnno \
    >$outputDir/03_star/01_htseqCount/$prefix.htseq.result \
    2>$outputDir/03_star/01_htseqCount/$prefix.htseq.log

rm $outputDir/03_star/$prefix.Aligned.out.sortedByName.bam

echo "htseq-count star bam: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

############################################################
# Quantification by salmon
mkdir -p $outputDir/05_salmon

salmon quant -p $threads -i $salmonIndexDir \
    -l A --gcBias --validateMappings \
    -1 $cleanR1 -2 $cleanR2 \
    -o $outputDir/05_salmon/$prefix.quant

echo "salmon quantification: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

echo "Analysis process ends: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log
