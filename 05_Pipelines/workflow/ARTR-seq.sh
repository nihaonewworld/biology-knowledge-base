cutadapt -j {threads} --nextseq-trim=20 --action=trim \
    -a AGATCGGAAGAGCACACGTCTGAACTCCAG \
    -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAG \
    -o {output.fq1} -p {output.fq2} \
    {input.fq1} {input.fq2}

cutadapt -j 6 -q 20 -m 20 --action=trim \
    -u 8 -u -4 -U -8 -U 4 \
    --rename='{id}_{r1.cut_prefix} {comment}' \
    -o {output.fq1} -p {output.fq2} \
    {input.fq1} {input.fq2}

STAR --runMode alignReads --runThreadN {threads} \
    --genomeDir {params.index} \
    --readFilesIn {input.fq1} {input.fq2} \
    --readFilesCommand zcat \
    --alignMatesGapMax 15000 --outFilterMultimapNmax 1 \
    --outFilterScoreMin 10 --outFilterMatchNmin 24 \
    --alignEndsType EndToEnd --quantMode TranscriptomeSAM \
    --outFilterType BySJout --outReadsUnmapped Fastx \
    --outSAMattributes All --outSAMtype BAM SortedByCoordinate \
    --outFileNamePrefix {params.prefix}

samtools index {input.bam}

umi_tools dedup --method unique \
    -I {input.bam} -S {output.bam} \
    --output-stats {output.dedup.txt} \
    -L {log} --temp-dir {input.temp.dir}
