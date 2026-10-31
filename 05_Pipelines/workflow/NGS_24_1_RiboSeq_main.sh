#!/bin/bash
set -e

source /Data2/caoq/miniforge3/bin/activate ngstools

threads=6
genomeIndexDir=00_refGenome/genomeIndex
genomeSeq=$genomeIndexDir/genome.fa
genomeAnno=$genomeIndexDir/genome.gtf

mkdir -p logs

############################################################
echo "Analysis process starts: $(date +"%Y-%m-%d %H:%M:%S")" \
    > logs/run.time.log

ls 01_raw/*_1.fq.gz | while read fq1
do
    fq1=$(basename $fq1)
    #fq2=${fq1/_1.fq.gz/_2.fq.gz}
    fq2=$(echo $fq1 | sed 's/_1.fq.gz/_2.fq.gz/')
    prefix=$(basename $fq1 "_1.fq.gz")

    bash NGS_24_2_RiboSeq.sh $fq1 $fq2 $prefix $threads $genomeIndexDir \
        1>logs/$prefix.run.log 2>&1
    echo "$prefix - process completed!: $(date +"%Y-%m-%d %H:%M:%S")" \
        >> logs/run.time.log
done

############################################################
mkdir -p 04_star/02_featureCounts

featureCounts -T $threads -g gene_id -t CDS -a $genomeAnno --ignoreDup \
    -o 04_star/02_featureCounts/counts_CDS.count \
    04_star/*.Aligned.sortedByCoord.out.bam \
    1>04_star/02_featureCounts/featureCounts.log 2>&1

echo "featureCounts star bam: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/run.time.log

############################################################
# Reads count by htseq-count
mkdir -p 04_star/01_htseqCount

samtools sort -@ $threads -n \
    -o 04_star/$prefix.Aligned.out.sortedByName.bam \
    04_star/$prefix.Aligned.sortedByCoord.out.bam

htseq-count -f bam -s no -a 10 -m union -t CDS -i gene_id --nonunique none \
    04_star/$prefix.Aligned.out.sortedByName.bam $genomeAnno \
    >04_star/01_htseqCount/$prefix.htseq.result \
    2>04_star/01_htseqCount/$prefix.htseq.log

rm 04_star/$prefix.Aligned.out.sortedByName.bam

echo "htseq-count star bam: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log


############################################################
mkdir -p 04_star/02_featureCounts

featureCounts -T $threads -g gene_id -t CDS -a $genomeAnno \
    -B -C -p --countReadPairs --ignoreDup \
    -o 04_star/02_featureCounts/counts_RNA.count \
    04_star/*.Aligned.sortedByCoord.out.bam \
    1>04_star/02_featureCounts/featureCounts.log 2>&1

echo "featureCounts star bam: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/run.time.log

############################################################
multiqc 01_raw -n 01_raw -o 01_raw
multiqc 02_clean -n 02_clean -o 02_clean
multiqc 03_rmncRNA -n 03_rmncRNA -o 03_rmncRNA
multiqc 04_star -n 04_star -o 04_star

echo "multiqc: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/run.time.log

############################################################
mkdir -p 04_ribotish

allSampleBam=$(ls 04_star/*.Aligned.sortedByCoord.out.bam | tr '\n' ',')

ribotish predict -p $threads -g $genomeAnno -f $genomeSeq \
    --framebest --seq --inframecount -b $allSampleBam \
    -o 04_ribotish/$prefix.pred.framebest.txt

echo "ribotish framebest: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/run.time.log

echo "Analysis process ends: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/run.time.log


#if [ ! -d 06_bedtoolsTag ]; then
#   mkdir 06_bedtoolsTag
#fi
#ls 04_starResult_RPF/*fastx.trimmed_trimmed.Aligned.sortedByCoord.out.bam | while read id
#do
##  /Data2/caoq/miniforge3/envs/riboseq/bin/bedtools bamtobed -i $id >07_bedtoolsTag/$(basename $id ".fastx.trimmed_trimmed.Aligned.sortedByCoord.out.bam").reads.bed
#   #awk '{print $3-$2}' 07_bedtoolsTag/$(basename $id ".fastx.trimmed_trimmed.Aligned.sortedByCoord.out.bam").reads.bed \
#   #   >07_bedtoolsTag/$(basename $id ".fastx.trimmed_trimmed.Aligned.sortedByCoord.out.bam").reads.length.csv
##  /Data2/caoq/miniforge3/envs/riboseq/bin/bedtools tag -i $id \
##      -files 00_refGenome/Mus_musculus.GRCm38.102.chr.CDS.bed 00_refGenome/Mus_musculus.GRCm38.102.chr.five_prime_utr.bed \
##      00_refGenome/Mus_musculus.GRCm38.102.chr.three_prime_utr.bed 00_refGenome/Mus_musculus.GRCm38.102.chr.intron.bed \
##      -labels CDS 5UTR 3UTR Introns >07_bedtoolsTag/$(basename $id ".fastx.trimmed_trimmed.Aligned.sortedByCoord.out.bam").tmp.bam
##  /Data2/caoq/miniforge3/envs/riboseq/bin/samtools view 07_bedtoolsTag/$(basename $id ".fastx.trimmed_trimmed.Aligned.sortedByCoord.out.bam").tmp.bam | \
##      grep "YB:Z:" | awk -F"YB:Z:" '{print $2}' | awk -F";" '{print $1}' | \
##      sort | uniq -c | sort -n >07_bedtoolsTag/$(basename $id ".fastx.trimmed_trimmed.Aligned.sortedByCoord.out.bam").stat.txt
##  rm 07_bedtoolsTag/$(basename $id ".fastx.trimmed_trimmed.Aligned.sortedByCoord.out.bam").tmp.bam
#done


