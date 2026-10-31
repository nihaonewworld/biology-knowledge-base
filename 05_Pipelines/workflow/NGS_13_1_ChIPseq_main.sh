#!/bin/bash
set -e

source /Data2/caoq/miniforge3/bin/activate chipseq

threads=6
genomeIndexDir=00_refGenome/genomeIndex
genomeSeq=$genomeIndexDir/genome.fa
genomeAnno=$genomeIndexDir/genome.gtf
outputDir=rnaSeqOutput

mkdir -p $outputDir/logs

############################################################
echo "Analysis process starts: $(date +"%Y-%m-%d %H:%M:%S")" \
    > $outputDir/logs/run.time.log

ls 01_raw/*RNAseq*_1.fq.gz | while read fq1
do
    fq1=$(basename $fq1)
    #fq2=${fq1/_1.fq.gz/_2.fq.gz}
    fq2=$(echo $fq1 | sed 's/_1.fq.gz/_2.fq.gz/')
    prefix=$(basename $fq1 "_1.fq.gz")

    bash rnaSeq.sh $fq1 $fq2 $prefix $threads \
        $genomeIndexDir $outputDir \
        1>$outputDir/logs/$prefix.run.log 2>&1
    echo "$prefix - process completed!: $(date +"%Y-%m-%d %H:%M:%S")" \
        >> $outputDir/logs/run.time.log
done

############################################################
mkdir -p $outputDir/10_DiffPeaks

sort -k1,1 -k2,2n $outputDir/06_macs2/*bed >$outputDir/10_DiffPeaks/allPeaks.bed
bedtools merge -i $outputDir/10_DiffPeaks/allPeaks.bed -d 0 -c 5 -o max \
    >$outputDir/10_DiffPeaks/mergePeaks.bed

bedtools multicov -bams $outputDir/05_bwa/*.bam \
    -bed $outputDir/10_DiffPeaks/mergePeaks.bed \
    >$outputDir/10_DiffPeaks/peakCounts.txt



############################################################
multiqc 01_raw -n 01_raw -o 01_raw
multiqc $outputDir/02_clean -n 02_clean -o $outputDir/02_clean
multiqc $outputDir/03_star -n 03_star -o $outputDir/03_star
multiqc $outputDir/04_hisat -n 04_hisat -o $outputDir/04_hisat
multiqc $outputDir/05_salmon -n 05_salmon -o $outputDir/05_salmon
multiqc $outputDir/06_kallisto -n 06_kallisto -o $outputDir/06_kallisto
multiqc $outputDir/07_stringtie -n 07_stringtie -o $outputDir/07_stringtie

echo "multiqc: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/run.time.log

echo "Analysis process ends: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/run.time.log
