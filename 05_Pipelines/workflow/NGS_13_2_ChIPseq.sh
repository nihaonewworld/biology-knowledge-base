#!/bin/bash
set -e

# ChIP-seq
# CUT&Tag
# ATAC-seq
# CUT&Run

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

bowtieIndexDir=$genomeIndexDir/bowtieIndex/genome
bowtie2IndexDir=$genomeIndexDir/bowtie2Index/genome
bwaIndexDir=$genomeIndexDir/bwaIndex/genome

############################################################
# Evaluate the quality Of raw reads
# fastqc -t $threads -o 01_raw 01_raw/$fq1
# fastqc -t $threads -o 01_raw 01_raw/$fq2
# seqkit stats -a -T $fq1 $fq2 >01_raw/$prefix.stat.tsv

# echo "fastqc raw reads: $(date +"%Y-%m-%d %H:%M:%S")" \
#   >> $outputDir/logs/$prefix.time.log

############################################################
# Filter poor quality reads & Remove adaptors
mkdir -p $outputDir/02_clean

adapters=adapters.fa
trimmomatic PE -phred33 -threads $threads \
    01_raw/$fq1 01_raw/$fq2 \
    $outputDir/02_clean/${prefix}_R1_clean.fq.gz \
    $outputDir/02_clean/${prefix}_R1_unpaired.fq.gz \
    $outputDir/02_clean/${prefix}_R2_clean.fq.gz \
    $outputDir/02_clean/${prefix}_R2_unpaired.fq.gz \
    ILLUMINACLIP:${adapters}:2:30:10 \
    SLIDINGWINDOW:5:20 LEADING:20 TRAILING:20 MINLEN:36 CROP:150

cleanR1=$outputDir/02_clean/${prefix}_R1_clean.fq.gz
cleanR2=$outputDir/02_clean/${prefix}_R2_clean.fq.gz

trim_galore --cores $threads --phred33 --illumina -q 25 \
    --stringency 1 -e 0.1 --gzip --length 36 --paired \
    -o $outputDir/02_clean 01_raw/$fq1 01_raw/$fq2

cleanR1=$outputDir/02_clean/${prefix}_R1_trimmed.fq.gz
cleanR2=$outputDir/02_clean/${prefix}_R2_trimmed.fq.gz

echo "trimmomatic / trim_galore reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

############################################################
# # Evaluate the quality of clean reads
# fastqc -t $threads -o $outputDir/02_clean $cleanR1
# fastqc -t $threads -o $outputDir/02_clean $cleanR2
# seqkit stats -a -T $cleanR1 $cleanR2 >$outputDir/02_clean/$prefix.stat.tsv

# echo "fastqc clean reads: $(date +"%Y-%m-%d %H:%M:%S")" \
#   >> $outputDir/logs/$prefix.time.log

############################################################
# Alignment reads by bowtie2
mkdir -p $outputDir/03_bowtie2

bowtie2 -p $threads -x $bowtie2IndexDir -1 $fq1 -2 $fq2 | \
    samtools sort -@ $threads -O bam \
        -o $outputDir/03_bowtie2/$prefix.sorted.bam

echo "bowtie2 align: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

# Extract unique mapped results and remove PCR duplications
# method 1
samtools view -@ $threads -h -q 1 -F 4 -F 256 $outputDir/03_bowtie2/$prefix.sorted.bam | \
    grep -E -v "chrM|XA:Z|SA:Z" | \
    samtools sort -@ $threads -o $outputDir/03_bowtie2/$prefix.unique.bam
samtools rmdup $outputDir/03_bowtie2/$prefix.unique.bam \
    $outputDir/03_bowtie2/$prefix.rmdup.bam

# method 2
sambamba view -t $threads -f bam -F "[XS] == null and not unmapped and not duplicate" \
    $outputDir/03_bowtie2/$prefix.sorted.bam >$outputDir/03_bowtie2/$prefix.unique.bam
sambamba markdup -t $threads -r $outputDir/03_bowtie2/$prefix.unique.bam \
    $outputDir/03_bowtie2/$prefix.rmdup.bam

samtools flagstat $outputDir/03_bowtie2/$prefix.rmdup.bam \
    >$outputDir/03_bowtie2/$prefix.rmdup.flagstat
samtools index $outputDir/03_bowtie2/$prefix.rmdup.bam

echo "samtools sort, rmdup and index: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

bam_stat.py -q 10 -i $outputDir/03_bowtie2/$prefix.rmdup.bam \
    >$outputDir/03_bowtie2/$prefix.bamStat.txt

samtools view $outputDir/03_bowtie2/$prefix.rmdup.bam | \
    awk -v Min=20 -v Max=1000 '{if($9>=Min & $9<=Max) print$9}' | \
    sort | uniq -c | awk '{print $2","$1}' \
        >$outputDir/03_bowtie2/$prefix.readsLength.csv

echo "bam information: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

############################################################
# Alignment reads by bwa
mkdir -p $outputDir/03_bwa

bwa mem -v 3 -k 19 -t $threads $bwaIndexDir $fq1 $fq2 | \
    samtools sort -@ $threads -O bam \
        -o $outputDir/03_bwa/$prefix.sorted.bam

echo "bwa align: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

samtools view -@ $threads -h -q 1 -F 4 -F 256 \
    $outputDir/03_bwa/$prefix.sorted.bam | \
    grep -E -v "chrM|XA:Z|SA:Z" | \
    samtools sort -@ $threads -o $outputDir/03_bwa/$prefix.unique.bam
samtools rmdup $outputDir/03_bwa/$prefix.unique.bam \
    $outputDir/03_bwa/$prefix.rmdup.bam

samtools flagstat $outputDir/03_bwa/$prefix.rmdup.bam \
    >$outputDir/03_bwa/$prefix.rmdup.flagstat
samtools index $outputDir/03_bwa/$prefix.rmdup.bam

echo "samtools sort, rmdup and index: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

bam_stat.py -q 10 -i $outputDir/03_bwa/$prefix.rmdup.bam \
    > $outputDir/03_bwa/$prefix.bwa.bamStat.txt

samtools view $outputDir/03_bwa/$prefix.rmdup.bam | \
    awk -v Min=20 -v Max=1000 '{if($9>=Min & $9<=Max) print$9}' | \
    sort | uniq -c | awk '{print $2","$1}' \
        >$outputDir/03_bwa/$prefix.readsLength.csv

echo "bam information: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

############################################################
# Call peak by macs2
mkdir -p $outputDir/04_macs2

ip_bam=$outputDir/03_bowtie2/$prefix.ip.rmdup.bam
input_bam=$outputDir/03_bowtie2/$prefix.input.rmdup.bam

# narrowPeak
macs2 callpeak -f BAMPE -g hs --keep-dup 1 --nomodel -q 0.05 \
    --bdg --SPMR -t $ip_bam -c input_bam -n $prefix \
    --outdir $outputDir/04_macs2

macs2 callpeak -f BAMPE -g hs --keep-dup 1 --nomodel -q 0.05 \
    --bdg --SPMR -t $ip_bam -n $prefix \
    --outdir $outputDir/04_macs2
# broadPeak
macs2 callpeak -f BAMPE -g hs --keep-dup 1 --nomodel -q 0.05 \
    --bdg --SPMR --broad --broad-cutoff 0.05 -t $ip_bam -c input_bam \
    -n $prefix --outdir $outputDir/04_macs2

echo "macs2 call peak: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

############################################################
# Convert bigWig To Visualization
mkdir -p $outputDir/05_bigwig

# method 1
bedGraphToBigWig $outputDir/04_macs2/${prefix}_treat_pileup.bdg \
    $chromosomeSize $outputDir/05_bigwig/${prefix}_treat_pileup.bw

# method 2
bamCoverage -p $threads --binSize 10 --normalizeUsing RPKM --extendReads \
    -b $ip_bam -o $outputDir/05_bigwig/$prefix.bamCoverage.bw

# method 3
bamCompare -p $threads --binSize 10 --normalizeUsing RPKM --extendReads \
    --scaleFactorsMethod None  --operation log2 --outFileFormat bigwig \
    -b1 $ip_bam -b2 $input_bam -o $prefix.bamCompare.bw

############################################################
#
mkdir -p $outputDir/06_deeptools

awk -v OFS='\t' '$3=="gene" {print $1,$4,$5,$6,$7,$8}' $genomeAnno \
    >$outputDir/08_deeptools/genes.bed

computeMatrix scale-regions -p $threads \
    -b 3000 -a 3000 --regionBodyLength 4000 \
    --skipZeros --missingDataAsZero \
    -S $outputDir/05_bigwig/$prefix.bamCoverage.bw \
    -R $outputDir/08_deeptools/genes.bed \
    --outFileName $prefix.matrix_Genebody.gz \
    --outFileSortedRegions $prefix.matrix_Genebody.bed

computeMatrix reference-point -p $threads \
    --referencePoint TSS -b 2000 -a 2000 \
    --skipZeros --missingDataAsZero \
    -S $outputDir/05_bigwig/$prefix.bamCoverage.bw \
    -R $outputDir/08_deeptools/genes.bed \
    --outFileName $prefix.matrix_TSS.gz \
    --outFileSortedRegions $prefix.matrix_TSS.bed

plotHeatmap -m $prefix.matrix_Genebody.gz --colorMap Reds \
    --zMin 0 --zMax 100 --whatToShow "heatmap and colorbar" \
    --heatmapHeight 9 --heatmapWidth 6 --regionsLabel " " \
    -out $prefix.matrix_TSS.heatmap.pdf

echo "Analysis process ends: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

############################################################

