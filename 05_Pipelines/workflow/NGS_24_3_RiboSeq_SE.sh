#!/bin/bash
set -e
shopt -s nocasematch

fq=$1
prefix=$2

threads=$3
isRemoveNotCodingRNA=$4

genomeIndexDir=$5
genomeSeq=$genomeIndexDir/genome.fa
genomeAnno=$genomeIndexDir/genome.gtf

outputDir=$6

############################################################
echo "Analysis process starts: $(date +"%Y-%m-%d %H:%M:%S")" \
    > $outputDir/logs/$prefix.time.log

bowtie2IndexDir=$genomeIndexDir/bowtie2Index_ncrna/ncrna
starIndexDir=$genomeIndexDir/starIndex150L
#starIndexDir=$genomeIndexDir/starIndex50L

############################################################
# Evaluate the quality Of raw reads
fastqc -t $threads -o 01_raw 01_raw/$fq

echo "fastqc raw reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

############################################################
# Filter poor quality reads & Remove adaptors
mkdir -p $outputDir/02_clean

#adapters=TGGAATTCTCGGGTGCCAAGG
#
#gunzip -k 01_raw/$fq
#fastx_clipper -a $adapters -Q33 -l 25 -c -n -z \
#   -i 01_raw/$(basename $fq ".gz") \
#   -o $outputDir02_clean/$prefix.fastx.fq.gz
#rm 01_raw/$(basename $fq ".gz")
#
#echo "fastx_clipper reads: $(date +"%Y-%m-%d %H:%M:%S")" \
#   >> $outputDir/logs/$prefix.time.log
#
#trim_galore --cores $threads -a $adapters \
#   -q 25 --length 25 --max_length 40 --max_n 50 \
#   --gzip --fastqc -o $outputDir/02_clean \
#   $outputDir/02_clean/$prefix.fastx.fq.gz
#
#echo "trim_galore reads: $(date +"%Y-%m-%d %H:%M:%S")" \
#   >> $outputDir/logs/$prefix.time.log
#
#cleanR=$outputDir/02_clean/${prefix}.fastx_trimmed.fq.gz

trimmomatic SE -phred33 -threads $threads \
    01_raw/$fq $outputDir/02_clean/${prefix}_clean.fq.gz \
    ILLUMINACLIP:adapters.fa:2:30:10 \
    SLIDINGWINDOW:5:20 LEADING:20 TRAILING:20 MINLEN:25 CROP:40

# trim_galore --cores 6 -a AGATCGGAAGAGCAC -q 25 \
#   --length 25 --max_n 50 --gzip \
#   --clip_R1 2 --three_prime_clip_R1 5 \
#   -o 02_clean $id

cleanR=$outputDir/02_clean/${prefix}_clean.fq.gz

echo "trimmomatic reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

############################################################
# Evaluate the quality of clean reads
fastqc -t $threads -o $outputDir/02_clean $cleanR

echo "fastqc clean reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

############################################################
# Remove reads which mapped to ncRNA from the fastq files using bowtie2 [optional]
if [[ "$isRemoveNotCodingRNA" == "true" ]]; then
    mkdir -p $outputDir/02_rmncrna

    bowtie2 -p $threads -x $bowtie2IndexDir -U $cleanR \
        --un-gz $outputDir/02_rmncrna/$prefix.rmncrna.fq.gz | \
        samtools view -@ $threads -b -S \
            -o $outputDir/02_rmncrna/$prefix.ncrna.bam

    cleanR=$outputDir/02_rmncrna/$prefix.rmncrna.fq.gz

    fastqc -t $threads -o $outputDir/02_rmncrna $cleanR

    echo "remove ncrna reads: $(date +"%Y-%m-%d %H:%M:%S")" \
        >> $outputDir/logs/$prefix.time.log
fi

############################################################
# Alignment reads by STAR
mkdir -p $outputDir/03_star

STAR --runThreadN $threads --genomeDir $starIndexDir \
    --readFilesIn $cleanR \
    --alignEndsType EndToEnd --outFilterMultimapNmax 1 \
    --outSAMattributes All --readFilesCommand zcat \
    --outSAMtype BAM SortedByCoordinate --quantMode TranscriptomeSAM \
    --outFileNamePrefix $outputDir/03_star/$prefix.

echo "star align: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

samtools index $outputDir/03_star/$prefix.Aligned.sortedByCoord.out.bam

samtools flagstat $outputDir/03_star/$prefix.Aligned.sortedByCoord.out.bam \
    > $outputDir/03_star/$prefix.Aligned.sortedByCoord.out.flagstat

echo "samtools sort and index: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

samtools view $outputDir/03_star/$prefix.Aligned.sortedByCoord.out.bam | \
    awk '{print length($10)}' | sort | uniq -c | \
    awk '{print $2","$1}' > $outputDir/03_star/$prefix.distributionOfReadsLengthData.csv

############################################################
# Reads count by htseq-count
mkdir -p $outputDir/03_star/01_htseqCount

samtools sort -@ $threads -n \
    -o $outputDir/03_star/$prefix.Aligned.out.sortedByName.bam \
    $outputDir/03_star/$prefix.Aligned.sortedByCoord.out.bam

htseq-count -f bam -s no -a 10 -m union -t CDS -i gene_id --nonunique none \
    $outputDir/03_star/$prefix.Aligned.out.sortedByName.bam $genomeAnno \
    >$outputDir/03_star/01_htseqCount/$prefix.htseq.result \
    2>$outputDir/03_star/01_htseqCount/$prefix.htseq.log

rm $outputDir/03_star/$prefix.Aligned.out.sortedByName.bam

echo "htseq-count star bam: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

############################################################
mkdir -p $outputDir/04_ribotish/01_quality

ribotish quality -p $threads -l 25,35 -g $genomeAnno \
    -b $outputDir/03_star/$prefix.Aligned.sortedByCoord.out.bam \
    -o $outputDir/04_ribotish/01_quality/${prefix}_qual.txt \
    -f $outputDir/04_ribotish/01_quality/${prefix}_qual.pdf \
    -r $outputDir/04_ribotish/01_quality/${prefix}.para.py

echo "ribotish quality: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

############################################################
mkdir -p $outputDir/04_ribotish/02_predict

ribotish predict -p $threads -g $genomeAnno -f $genomeSeq \
    --longest --seq --inframecount \
    --ribopara $outputDir/04_ribotish/01_quality/${prefix}.para.py \
    -b $outputDir/03_star/$prefix.Aligned.sortedByCoord.out.bam \
    -o $outputDir/04_ribotish/02_predict/$prefix.pred.longest.txt

echo "ribotish predict: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

############################################################
mkdir -p $outputDir/05_ribotricer

ribotricer detect-orfs \
    --bam $outputDir/03_star/$prefix.Aligned.sortedByCoord.out.bam \
    --ribotricer_index $genomeIndexDir/../ribotricer_candidate_ORFs.tsv \
    --prefix $outputDir/05_ribotricer/$prefix

echo "ribotricer predict: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

echo "Analysis process ends: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log
