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

ls 01_raw/*_R1.fq.gz | while read fq1
do
    fq2=$(echo $fq1 | sed 's/_R1.fq.gz/_R2.fq.gz/')
    prefix=$(basename $fq1 "_R1.fq.gz")

    bash NGS_22_2_RIPseq.sh $fq1 $fq2 $prefix $threads $genomeIndexDir \
        1>logs/$prefix.run.log 2>&1
    echo "$prefix - process completed!: $(date +"%Y-%m-%d %H:%M:%S")" \
        >> logs/run.time.log
done

############################################################
mkdir -p 04_star/01_featureCounts

featureCounts -T $threads -p --countReadPairs -B -C \
    -a $genomeAnno -g gene_id -t exon --extraAttributes gene_name \
    -o 04_star/01_featureCounts/counts_RNA.count \
    04_star/*Input*.Aligned.out.bam \
    1>04_star/01_featureCounts/featureCounts.log 2>&1

echo "featureCounts star bam: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/run.time.log

############################################################
mkdir -p 07_macs2
cat ip_input.txt | while read id
do
    arr=($id)
    ip=${arr[0]}
    input=${arr[1]}
    ip_bam=04_star/${ip}.rmdup.bam
    input_bam=04_star/${input}.rmdup.bam

    /Data2/caoq/miniforge3/envs/chipseq/bin/macs2 callpeak \
        -f BAM --nomodel -g 1e8 --keep-dup 1 --extsize 100 \
        -q 0.05 -t $ip_bam -c $input_bam -n $ip \
        --outdir 07_macs2/$ip --cutoff-analysis \
        1>>logs/${ip}.run.log 2>&1

# ARTR-seq --keep-dup all --extsize 30 (https://github.com/mingming-cgz/ARTR-seq)
done

############################################################
# Getting the motif using Homer2
# findMotifsGenome.pl $peaks $genomeSeq $outputDir -p $threads -rna -S 10 -len 5,6,7,8,9 -bg ${annoforHomer2}

############################################################
multiqc 01_raw -n 01_raw -o ./
multiqc 02_clean -n 02_clean -o ./
multiqc 03_rmrRNA -n 03_rmrRNA -o ./
multiqc 04_star -n 04_star -o ./
multiqc 05_hisat2 -n 05_hisat2 -o ./
multiqc 07_macs2 -n 07_macs2 -o ./

echo "multiqc: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/run.time.log

echo "Analysis process ends: $(date +"%Y-%m-%d %H:%M:%S")" \
    >> logs/run.time.log
