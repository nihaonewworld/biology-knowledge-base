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

bowtieIndexDir=$genomeIndexDir/bowtieIndex/genome
bowtie2IndexDir=$genomeIndexDir/bowtie2Index/genome
bwaIndexDir=$genomeIndexDir/bwaIndex/genome

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

trim_galore --cores $threads --phred33 --illumina -q 25 \
    --stringency 1 -e 0.1 --gzip --length 36 --paired \
    -o $outputDir/02_clean 01_raw/$fq1 01_raw/$fq2

cleanR1=$outputDir/02_clean/${prefix}_R1_trimmed.fq.gz
cleanR2=$outputDir/02_clean/${prefix}_R2_trimmed.fq.gz

echo "trimmomatic / trim_galore reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

############################################################
# Evaluate the quality of clean reads
fastqc -t $threads -o $outputDir/02_clean $cleanR1
fastqc -t $threads -o $outputDir/02_clean $cleanR2

echo "fastqc clean reads: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

############################################################
# Alignment reads by bowtie
mkdir -p $outputDir/03_bowtie

bowtie -p $threads -x $bowtieIndexDir -1 $fq1 -2 $fq2 | \
    samtools sort -O bam -@ $threads -o $prefix.bowtie.sorted.bam
bam_stat.py -q 10 -i $outputDir/05_bwa/$prefix.bowtie.sorted.bam \
    > $outputDir/05_bwa/$prefix.bowtie.sorted.bamStat.txt

echo "bowtie2 align: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

samtools index $outputDir/03_bowtie2/$prefix.bowtie2.sorted.bam

samtools flagstat $outputDir/03_bowtie2/$prefix.bowtie2.sorted.bam \
    > $outputDir/03_bowtie2/$prefix.bowtie2.sorted.flagstat

echo "samtools sort and index: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

############################################################
# Alignment reads by bowtie2
mkdir -p $outputDir/04_bowtie2

bowtie2 -p $threads -x $bowtie2IndexDir -1 $fq1 -2 $fq2 | \
    samtools sort -O bam -@ $threads \
        -o $outputDir/04_bowtie2/$prefix.bowtie2.sorted.bam
bam_stat.py -q 10 -i $outputDir/05_bwa/$prefix.bowtie2.sorted.bam \
    > $outputDir/05_bwa/$prefix.bowtie2.sorted.bamStat.txt

echo "bowtie2 align: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

samtools index $outputDir/04_bowtie2/$prefix.bowtie2.sorted.bam

samtools flagstat $outputDir/04_bowtie2/$prefix.bowtie2.sorted.bam \
    > $outputDir/04_bowtie2/$prefix.bowtie2.sorted.flagstat

echo "samtools sort and index: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

############################################################
# Alignment reads by bwa
mkdir -p $outputDir/05_bwa

bwa mem -v 3 -k 19 -t $threads $bwaIndexDir $fq1 $fq2 | \
    samtools sort -O bam -@ $threads \
        -o $outputDir/05_bwa/$prefix.bwa.sorted.bam
bam_stat.py -q 10 -i $outputDir/05_bwa/$prefix.bwa.sorted.bam \
    > $outputDir/05_bwa/$prefix.bwa.sorted.bamStat.txt

echo "bwa align: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

samtools index $outputDir/05_bwa/$prefix.bwa.sorted.bam

samtools flagstat $outputDir/05_bwa/$prefix.bwa.sorted.bam \
    > $outputDir/05_bwa/$prefix.bwa.sorted.flagstat

samtools view $outputDir/05_bwa/$prefix.bwa.sorted.bam | \
    awk -v Min=20 -v Max=1000 '{if($9>=Min & $9 <= Max) print$9}' | 
    sort | uniq -c | \
    awk '{print $2","$1}' \
        > $outputDir/05_bwa/$prefix.distributionOfReadsLengthData.csv

echo "samtools sort and index: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

############################################################
# Call peak by macs2
mkdir -p $outputDir/05_bwa/01_macs2

macs2 callpeak -f BAMPE -g hs --keep-dup 1 -q 0.05 --nomodel -B --SPMR\
    -t $outputDir/05_bwa/$prefix.bwa.sorted.bam \
    -n $prefix --outdir $outputDir/05_bwa/01_macs2

echo "macs2 callpeak from bwa bam: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log


cat control.bed treatment.bed | sort -k1,1 -k2,2n > temp.bed
bedtools merge -i temp.bed -d 0 -scores max
bedtools multicov -bams %s -bed %s.bed

scaleFactor = 1000000 / mapped reads (spikein)
sizeFactor = mapped reads (genome)

############################################################
# Convert bigWig To Visualization
# method 1
bedGraphToBigWig $outputDir/05_bwa/01_macs2/${prefix}_treat_pileup.bdg \
    $chromosomeSize $outputDir/05_bwa/01_macs2/${prefix}_treat_pileup.bw

# method 2
bamCoverage -p $threads --binSize 10 --normalizeUsing RPKM --extendReads \
    -b $outputDir/05_bwa/$prefix.bwa.sorted.bam \
    -o $outputDir/05_bwa/$prefix.bwa.sorted.bw

############################################################
#
bedtools multicov -bams $outputDir/05_bwa/$prefix.bwa.sorted.bam \
    -bed $outputDir/05_bwa/01_macs2/$prefix.bed \
    > $outputDir/05_bwa/01_macs2/$prefix.peakCounts.txt

############################################################
#
mkdir -p $outputDir/temp
awk -v OFS='\t' '$3=="gene" {print $1,$4,$5,$6,$7,$8}' $genomeAnno \
    > $outputDir/temp/genes.bed

computeMatrix reference-point -p $threads --referencePoint TSS -b 2000 -a 2000 \
    --skipZeros --missingDataAsZero \
    -S $outputDir/05_bwa/$prefix.bwa.sorted.bw \
    -R $outputDir/temp/genes.bed \
    -o $prefix.matrix_TSS.gz \
    --outFileSortedRegions regions_genes.bed

computeMatrix scale-regions -p $threads -b 3000 -a 3000 --regionBodyLength 6000 \
    --skipZeros --missingDataAsZero \
    -S $outputDir/05_bwa/$prefix.bwa.sorted.bw \
    -R $outputDir/05_bwa/01_macs2/$prefix.bed \
    --outFileName $prefix.matrix_TssTes.gz \
    --outFileSortedRegions $prefix.matrix_TssTes.bed

echo "Analysis process ends: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/$prefix.time.log

