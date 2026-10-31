#!/bin/bash
set -e

source /Data2/caoq/miniforge3/bin/activate ngstools

fq1=$1
fq2=$2
prefix=$3
threads=$4

genomeIndex=$5
genomeSeq=$genomeIndex/genome.fa
genomeAnno=$genomeIndex/genome.gtf

############################################################
echo "Analysis process starts: $(date +"%Y-%m-%d %H:%M:%S")" \
    > logs/$prefix.time.log

bowtie2IndexDir=$genomeIndex/bowtie2Index/rrna
starIndexDir=$genomeIndex/starIndex
hisat2IndexDir=$genomeIndex/hisat2Index/genome
salmonIndexDir=$genomeIndex/salmonIndex
kallistoIndexDir=$genomeIndex/kallistoIndex/transcriptome

############################################################
# Evaluate the quality Of raw reads
fastqc -t 2 -o 01_raw 01_raw/$fq1 01_raw/$fq2

echo "fastqc raw reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
# Filter poor quality reads & Remove adaptors
mkdir -p 02_clean

######
trim_galore --cores $threads --phred33 -q 20 \
    -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
    -a2 AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
    --stringency 1 -e 0.1 --gzip --length 36 --paired \
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
    ILLUMINACLIP:${adapters}:2:30:10:2:True \
    SLIDINGWINDOW:5:20 LEADING:20 TRAILING:20 MINLEN:36 CROP:150

cleanR1=02_clean/${prefix}_R1_clean.fq.gz
cleanR2=02_clean/${prefix}_R2_clean.fq.gz

echo "trimmomatic reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
# Evaluate the quality of clean reads
fastqc -t 2 -o 02_clean $cleanR1 $cleanR2

echo "fastqc clean reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
# Remove reads which mapped to rRNA [optional]
mkdir -p 03_rmrRNA

bowtie2 -p $threads -x $bowtie2IndexDir --no-unal \
    --un-conc-gz 03_rmrRNA/$prefix.rmrRNA_R%.fq.gz \
    -1 $cleanR1 -2 $cleanR2 | \
    samtools view -@ $threads -b -S -o 03_rmrRNA/$prefix.rRNA.bam

cleanR1=03_rmrRNA/$prefix.rmrRNA_R1.fq.gz
cleanR2=03_rmrRNA/$prefix.rmrRNA_R2.fq.gz

echo "remove rRNA reads by bowtie2: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
# Evaluate the quality of remove rRNA reads [optional]
fastqc -t 2 -o 03_rmrRNA $cleanR1 $cleanR2

echo "fastqc remove rRNA reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
# Alignment reads by STAR
mkdir -p 04_star

STAR --runThreadN $threads --genomeDir $starIndexDir \
    --readFilesIn $cleanR1 $cleanR2 --readFilesCommand zcat \
    --outSAMattributes All --outSAMtype BAM Unsorted \
    --outFileNamePrefix 04_star/$prefix.

samtools flagstat 04_star/$prefix.Aligned.out.bam \
    > 04_star/$prefix.Aligned.out.flagstat

echo "star align: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
# Alignment reads by Hisat2
mkdir -p 05_hisat

hisat2 -p $threads -x $hisat2IndexDir -1 $cleanR1 -2 $cleanR2 \
    --new-summary --summary-file 05_hisat/$prefix.summary.txt | \
    samtools sort -@ $threads -n -O bam -o 05_hisat/$prefix.hisat2.bam

samtools flagstat 05_hisat/$prefix.hisat2.bam \
    > 05_hisat/$prefix.hisat2.flagstat

echo "hisat2 align: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
# Quantification by salmon
mkdir -p 06_salmon

salmon quant -p $threads -i $salmonIndexDir \
    -l A --gcBias --validateMappings \
    -1 $cleanR1 -2 $cleanR2 \
    -o 06_salmon/$prefix.quant

echo "salmon quantification: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
# Quantification by kallisto
mkdir -p 07_kallisto

kallisto quant -t $threads -i $kallistoIndexDir \
    --bias --pseudobam --genomebam --gtf $genomeAnno \
    -o 07_kallisto/$prefix $cleanR1 $cleanR2

echo "kallisto quantification: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
# Alignment reads by Hisat2 and Stringtie
mkdir -p 08_stringtie

hisat2 -p $threads --dta -x $hisat2IndexDir -1 $cleanR1 -2 $cleanR2 \
    --summary-file 05_hisat/$prefix.summary.txt --new-summary | \
    samtools sort -@ $threads -n -O bam -o 08_stringtie/$prefix.hisat2.bam

stringtie -p $threads -G $genomeAnno 08_stringtie/$prefix.hisat2.bam \
    -A 08_stringtie/$prefix.gene_abund.tab -b 08_stringtie/$prefix.Ballgown \
    -o 08_stringtie/$prefix.gtf 

echo "stringtie: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

echo "Analysis process ends: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log
