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

bowtie2IndexDir=$genomeIndexDir/bowtie2Index/rrna
starIndexDir=$genomeIndexDir/starIndex150L
hisat2IndexDir=$genomeIndexDir/hisat2Index/genome

############################################################
# Evaluate the quality Of raw reads
fastqc -t $threads -o 01_raw $fq1
fastqc -t $threads -o 01_raw $fq2

seqkit stats -j $threads -a -b -T $fq1 $fq2 \
    >logs/$prefix.fastqStats.tsv

echo "fastqc raw reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
# Filter poor quality reads & Remove adaptors
mkdir -p 02_clean

# Conventional sequencing library
trim_galore --cores $threads --paired --phred33 --gzip \
    -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
    -a2 AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
    -q 25 -e 0.1 --stringency 1 --length 36 \
    --basename $prefix -o 02_clean $fq1 $fq2

# SMART strand-specific library
trim_galore --cores $threads --paired --phred33 --gzip \
    -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
    -a2 AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
    -q 25 -e 0.1 --stringency 1 --length 36 \
    -three_prime_clip_R1 3 -clip_R2 3 \
    --basename $prefix -o 02_clean $fq1 $fq2

cleanR1=02_clean/${prefix}_val_1.fq.gz
cleanR2=02_clean/${prefix}_val_2.fq.gz

echo "trim galore reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

# Conventional sequencing library
adapters=/Data2/caoq/miniforge3/envs/ngstools/share/trimmomatic-0.39-2/adapters/TruSeq3-PE-2.fa
trimmomatic PE -phred33 -threads $threads $fq1 $fq2 \
    02_clean/${prefix}_R1_clean.fq.gz 02_clean/${prefix}_R1_unpaired.fq.gz \
    02_clean/${prefix}_R2_clean.fq.gz 02_clean/${prefix}_R2_unpaired.fq.gz \
    ILLUMINACLIP:${adapters}:2:30:10 \
    SLIDINGWINDOW:4:15 LEADING:3 TRAILING:3 MINLEN:36 CROP:150

cleanR1=02_clean/${prefix}_R1_clean.fq.gz
cleanR2=02_clean/${prefix}_R2_clean.fq.gz

echo "trimmomatic reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
# Evaluate the quality of clean reads
fastqc -t $threads -o 02_clean $cleanR1
fastqc -t $threads -o 02_clean $cleanR2

seqkit stats -j $threads -a -b -T $cleanR1 $cleanR2 \
    >>logs/$prefix.fastqStats.tsv

echo "fastqc clean reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
# Remove reads which mapped to rRNA [optional]
mkdir -p 03_rmrRNA

bowtie2 -p $threads -x $bowtie2IndexDir -1 $cleanR1 -2 $cleanR2 \
    --un-conc-gz 03_rmrRNA/${prefix}_rmrRNA_R%.fq.gz --no-unal | \
    samtools view -@ $threads -b -S -o 03_rmrRNA/$prefix.rRNA.bam

cleanR1=03_rmrRNA/${prefix}_rmrRNA_R1.fq.gz
cleanR2=03_rmrRNA/${prefix}_rmrRNA_R2.fq.gz

echo "remove rRNA reads by bowtie2: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
# Evaluate the quality of remove rRNA reads [optional]
fastqc -t $threads -o 03_rmrRNA $cleanR1
fastqc -t $threads -o 03_rmrRNA $cleanR2

seqkit stats -j $threads -a -b -T $cleanR1 $cleanR2 \
    >>logs/$prefix.fastqStats.tsv

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
bam_stat.py -i 04_star/$prefix.Aligned.out.bam >logs/$prefix.bamStat.txt

echo "star align: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

# Keep uniquely mapped reads
samtools view -@ $threads -b -f 2 -q 10 04_star/$prefix.Aligned.out.bam | \
    samtools sort -@ $threads -o 04_star/$prefix.unique.bam
samtools index 04_star/$prefix.unique.bam
samtools flagstat 04_star/$prefix.unique.bam >04_star/$prefix.unique.flagstat
bam_stat.py -i 04_star/$prefix.unique.bam >>logs/$prefix.bamStat.txt

echo "Keep uniquely mapped reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

# Remove PCR duplicates
java -jar picard MarkDuplicates -REMOVE_DUPLICATES true \
    -I 04_star/$prefix.unique.bam \
    -O 04_star/$prefix.rmdup.bam \
    -M 04_star/$prefix.rmdup_metrics.txt

sambamba markdup -t $threads -r \
    04_star/$prefix.unique.bam 04_star/$prefix.rmdup.bam \
    2>04_star/$prefix.rmdup.log.txt

# Deduplicating reads with umi-tools
umi_tools dedup --method -I 04_star/$prefix.unique.bam \
    --output-stats=dedup -L 04_star/$prefix.umitools.log \
    --temp-dir=./ -S 04_star/$prefix.rmdup.bam

samtools index 04_star/$prefix.rmdup.bam
samtools flagstat 04_star/$prefix.rmdup.bam >04_star/$prefix.rmdup.flagstat
bam_stat.py -i 04_star/$prefix.rmdup.bam >>logs/$prefix.bamStat.txt

echo "Remove PCR duplicates: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

# Splitting reads by strand [optional]
samtools view -@ $threads -F 16 -b \
    -o 04_star/$prefix.rmdup.fwd.bam 04_star/$prefix.rmdup.bam
samtools index -@ $threads 04_star/$prefix.rmdup.fwd.bam

samtools view -@ $threads -f 16 -b \
    -o 04_star/$prefix.rmdup.rev.bam 04_star/$prefix.rmdup.bam
samtools index -@ $threads 04_star/$prefix.rmdup.rev.bam

echo "Splitting reads by strand: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log
###########################################################
# Alignment reads by Hisat2
mkdir -p 05_hisat2

# Conventional sequencing library
hisat2 -p $threads -x $hisat2IndexDir -1 $cleanR1 -2 $cleanR2 \
    --summary-file 05_hisat2/$prefix.summary.txt --new-summary | \
    samtools sort -@ $threads -n -O bam -o 05_hisat2/$prefix.bam

samtools flagstat 05_hisat2/$prefix.bam >05_hisat2/$prefix.flagstat

# Strand-specific library
hisat2 -p $threads --rna-strandness RF -x $hisat2IndexDir -1 $cleanR1 -2 $cleanR2 \
    --summary-file 05_hisat2/$prefix.summary.txt --new-summary | \
    samtools sort -@ $threads -n -O bam -o 05_hisat2/$prefix.bam

samtools flagstat 05_hisat2/$prefix.bam >05_hisat2/$prefix.flagstat

echo "hisat2 align: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

# Keep uniquely mapped reads
samtools view -@ $threads -b -f 2 -q 10 05_hisat2/$prefix.bam | \
    samtools sort -@ $threads -o 05_hisat2/$prefix.unique.bam
samtools index 05_hisat2/$prefix.unique.bam
samtools flagstat 05_hisat2/$prefix.unique.bam \
    > 05_hisat2/$prefix.unique.flagstat

echo "Keep uniquely mapped reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

# Remove PCR duplicates
java -jar picard MarkDuplicates -REMOVE_DUPLICATES true \
    -I 05_hisat2/$prefix.unique.bam \
    -O 05_hisat2/$prefix.rmdup.bam \
    -M 05_hisat2/$prefix.rmdup_metrics.txt

/Data2/caoq/miniforge3/envs/chipseq/bin/sambamba markdup -t $threads -r \
    05_hisat2/$prefix.unique.bam \
    05_hisat2/$prefix.rmdup.bam \
    2>05_hisat2/$prefix.rmdup.log.txt

samtools index 05_hisat2/$prefix.rmdup.bam
samtools flagstat 05_hisat2/$prefix.rmdup.bam \
    > 05_hisat2/$prefix.rmdup.flagstat

echo "Remove PCR duplicates: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
# Convert Signal File
mkdir -p 06_bamCoverage

bamCoverage -p $threads --binSize 10 --normalizeUsing RPKM \
    -b 04_star/$prefix.unique.bam \
    -o 06_bamCoverage/$prefix.star.unique.bw
bamCoverage -p $threads --binSize 10 --normalizeUsing RPKM \
    -b 04_star/$prefix.rmdup.bam \
    -o 06_bamCoverage/$prefix.star.rmdup.bw

bamCoverage -p $threads --binSize 10 --normalizeUsing RPKM \
    -b 05_hisat2/$prefix.unique.bam \
    -o 06_bamCoverage/$prefix.hisat2.unique.bw
bamCoverage -p $threads --binSize 10 --normalizeUsing RPKM \
    -b 05_hisat2/$prefix.rmdup.bam \
    -o 06_bamCoverage/$prefix.hisat2.rmdup.bw

echo "bamCoverage: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

echo "Analysis process ends: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log
