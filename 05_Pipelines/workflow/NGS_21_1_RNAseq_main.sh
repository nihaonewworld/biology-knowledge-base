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

    bash NGS_21_2_RNAseq.sh $fq1 $fq2 $prefix $threads $genomeIndexDir \
        1>logs/$prefix.run.log 2>&1
    echo "$prefix - process completed!: $(date +"%Y-%m-%d %H:%M:%S")" \
        >> logs/run.time.log
done

############################################################
mkdir -p 04_star/01_featureCounts

featureCounts -T $threads -p --countReadPairs -B -C \
    -a $genomeAnno -g gene_id -t exon --extraAttributes gene_name \
    -o 04_star/01_featureCounts/counts_RNA.count 04_star/*.Aligned.out.bam \
    1>04_star/01_featureCounts/featureCounts.log 2>&1

echo "featureCounts star bam: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/run.time.log

############################################################
# Reads count by htseq-count
mkdir -p 04_star/02_htseqCount

htseq-count -f bam -s no -a 10 -m union --nonunique none \
    -t exon -i gene_id --additional-attr=gene_name \
    --secondary-alignments=ignore --supplementary-alignments=ignore \
    -c 04_star/02_htseqCount/$prefix.htseq.tsv \
    04_star/$prefix.Aligned.out.bam $genomeAnno \
    2>04_star/02_htseqCount/$prefix.htseq.log

echo "htseq-count star bam: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
mkdir -p 05_hisat/01_featureCounts

featureCounts -T $threads -p --countReadPairs -B -C \
    -a $genomeAnno -g gene_id -t exon --extraAttributes gene_name \
    -o 05_hisat/01_featureCounts/counts_RNA.count 05_hisat/*.hisat2.bam \
    1>05_hisat/01_featureCounts/featureCounts.log 2>&1

echo "featureCounts hisat2 bam: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/run.time.log

############################################################
# Reads count by htseq-count
mkdir -p 05_hisat/02_htseqCount

htseq-count -f bam -s no -a 10 -m union --nonunique none \
    -t exon -i gene_id --additional-attr=gene_name \
    --secondary-alignments=ignore --supplementary-alignments=ignore \
    -c 05_hisat/02_htseqCount/$prefix.htseq.tsv \
    05_hisat/$prefix.hisat2.bam $genomeAnno \
    2>05_hisat/02_htseqCount/$prefix.htseq.log

echo "htseq-count hisat2 bam: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/$prefix.time.log

############################################################
multiqc 01_raw -n 01_raw -o 01_raw
multiqc 02_clean -n 02_clean -o 02_clean
multiqc 03_rmrRNA -n 03_rmrRNA -o 03_rmrRNA
multiqc 04_star -n 04_star -o 04_star
multiqc 05_hisat -n 05_hisat -o 05_hisat
multiqc 06_salmon -n 06_salmon -o 06_salmon
multiqc 07_kallisto -n 07_kallisto -o 07_kallisto
multiqc 08_stringtie -n 08_stringtie -o 08_stringtie

echo "multiqc: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/run.time.log

echo "Analysis process ends: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/run.time.log
