#!/bin/bash
set -e

source /Data2/caoq/miniforge3/bin/activate ngstools

threads=6
genomeIndexDir=00_refGenome/genomeIndex
genomeSeq=$genomeIndexDir/genome.fa
genomeAnno=$genomeIndexDir/genome.gtf
outputDir=polysomeSeqOutput

mkdir -p $outputDir/logs

############################################################
echo "Analysis process starts: $(date +"%Y-%m-%d %H:%M:%S")" \
    > $outputDir/logs/run.time.log

ls 01_raw/*_1.fq.gz | while read fq1
do
    fq1=$(basename $fq1)
    #fq2=${fq1/_1.fq.gz/_2.fq.gz}
    fq2=$(echo $fq1 | sed 's/_1.fq.gz/_2.fq.gz/')
    prefix=$(basename $fq1 "_1.fq.gz")

    bash polysomeSeq.sh $fq1 $fq2 $prefix $threads \
        $genomeIndexDir $outputDir \
        1>$outputDir/logs/$prefix.run.log 2>&1
    echo "$prefix - process completed!: $(date +"%Y-%m-%d %H:%M:%S")" \
        >> $outputDir/logs/run.time.log
done

############################################################
mkdir -p $outputDir/03_star/02_featureCounts

featureCounts -T $threads -g gene_id -t exon -a $genomeAnno \
    -B -C -p --countReadPairs --ignoreDup \
    -o $outputDir/03_star/02_featureCounts/counts_RNA.count \
    $outputDir/03_star/*.Aligned.sortedByCoord.out.bam \
    1>$outputDir/03_star/02_featureCounts/featureCounts.log 2>&1

echo "featureCounts star bam: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/run.time.log

############################################################
multiqc 01_raw -n 01_raw -o 01_raw
multiqc $outputDir/02_clean -n $outputDir/02_clean -o $outputDir/02_clean
multiqc $outputDir/03_star -n $outputDir/03_star -o $outputDir/03_star
multiqc $outputDir/05_salmon -n $outputDir/05_salmon -o $outputDir/05_salmon

echo "Analysis process ends: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> $outputDir/logs/run.time.log
