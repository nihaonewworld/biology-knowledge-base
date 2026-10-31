# ==============================================================================
# Example config (place in config.yaml)
# ==============================================================================
# input_dir: "01_fastq"
# output_dir: "02_output"
# genome: "~/reference/Mus_musculus/mm10"
# blacklist: "~/reference/Database/Blacklist/lists/mm10-blacklist.v2.bed"
# motifs: "~/reference/Database/Motifs/Homer/custom.motifs"
# threads: 6

# trim_tool: "trim_galore"
# min_read_len: 36
# max_read_len: 
# adapters: 
# trim_params: 

# align_tool: "bowtie2"
# # bowtie2, bwa
# align_params: "--very-sensitive"

# filter_chrm: true
# remove_dups: true

# callpeak_tool:
#   - macs2
# #  - hmmratac
# macs_gsize: "mm"
# # hs, mm, 1.3e8
# macs_keepdup: "all"
# macs_qvalue: 0.01
# macs_model:
# # "--nomodel --shift -75 --extsize 150" # for -f BAM
# macs_bdg: false

# binSize: 10
# normalize: "RPKM"

# conda_env: "ngstools"
# ------------------------------------------------------------------------------

# ==============================================================================
# Snakefile: ATAC-seq Snakemake Pipeline (V1)
# ==============================================================================

# -*- coding: utf-8 -*-
from snakemake.utils import min_version
min_version("9.6")

import os
from snakemake.io import glob_wildcards, expand

shell.executable("/bin/bash")

# ==============================================================================
# 1. VALIDATE CONFIGURATION
# ==============================================================================
configfile: "config.yaml"

# Ensure all necessary parameters are provided in config.yaml
required_keys = ["input_dir", "output_dir", "genome", "conda_env"]

missing = [k for k in required_keys if k not in config]
if missing:
    raise ValueError("Missing config keys: " + ", ".join(missing))

INPUT_DIR = os.path.expanduser(config.get("input_dir"))
OUTPUT_DIR = os.path.expanduser(config.get("output_dir"))
GENOME = os.path.expanduser(config.get("genome"))
THREADS = config.get("threads", 6)

TRIM_TOOL = config.get("trim_tool")
ALIGN_TOOL = config.get("align_tool")
CALLPEAK_TOOL = config.get("callpeak_tool") or []
if isinstance(CALLPEAK_TOOL, str): 
    CALLPEAK_TOOL = [CALLPEAK_TOOL]

# ==============================================================================
# 2. SAMPLE DETECTION & DYNAMIC PAIRING
# ==============================================================================
SAMPLES, = glob_wildcards(os.path.join(INPUT_DIR, "{sample}_R1.fq.gz"))

if not SAMPLES:
    raise ValueError(f"No FASTQ files detected in {INPUT_DIR}")
else:
    print("Detected samples:\n" + "\n".join(SAMPLES))

# ==============================================================================
# 3. RULES DEFINITION
# ==============================================================================
TARGET_PEAKS = []
TARGET_FRIP = []
TARGET_MOTIFS = []
SUPPORTED_CALLPEAK_TOOLS = ["macs2", "macs3", "hmmratac"]

for tool in CALLPEAK_TOOL:
    tool = tool.strip().lower()
    if tool not in SUPPORTED_CALLPEAK_TOOLS:
        raise ValueError(
            f"Unsupported CALLPEAK_TOOL: '{tool}'. "
            f"Supported tools are {SUPPORTED_CALLPEAK_TOOLS}."
        )
    if tool in ["macs2", "macs3"]:
        TARGET_PEAKS.extend(expand(os.path.join(
            OUTPUT_DIR, "05_peaks", "{sample}_peaks.narrowPeak"
            ), sample=SAMPLES))
        TARGET_FRIP.extend(expand(os.path.join(
            OUTPUT_DIR, "05_peaks", "{sample}.frip.txt"), sample=SAMPLES))
        TARGET_MOTIFS.extend(expand(os.path.join(
            OUTPUT_DIR, "06_motif", "{sample}"), sample=SAMPLES))
    elif tool == "hmmratac":
        TARGET_PEAKS.extend(expand(os.path.join(
            OUTPUT_DIR, "05_hmmratac", "{sample}_accessible_regions.narrowPeak"
            ), sample=SAMPLES))

rule all:
    input:
        os.path.join(OUTPUT_DIR, "01_stats", "raw_reads.stats.tsv"),
        expand(os.path.join(OUTPUT_DIR, "02_clean", "{sample}_R1_fastqc.html"
            ), sample=SAMPLES),
        os.path.join(OUTPUT_DIR, "01_stats", "fragment_size.tsv"),
        TARGET_PEAKS,
        TARGET_FRIP,
        TARGET_MOTIFS,
        expand(os.path.join(OUTPUT_DIR, "07_bigwig", "{sample}.bw"
            ), sample=SAMPLES),
        expand(os.path.join(OUTPUT_DIR, "08_deeptools", "{sample}.TSS.png"
            ), sample=SAMPLES),
        expand(os.path.join(OUTPUT_DIR, "08_deeptools", "{sample}.Genebody.png"
            ), sample=SAMPLES),
        os.path.join(OUTPUT_DIR, "09_count", "bins_10kb.counts.tsv"),
        os.path.join(OUTPUT_DIR, "multiqc_report.html")

# ------------------------------------------------------------------------------
# Rule: seqkit
# Description: Generate basic statistics for raw FASTQ files.
# ------------------------------------------------------------------------------
rule seqkit:
    input:
        expand(os.path.join(INPUT_DIR, "{sample}_{read}.fq.gz"
            ), sample=SAMPLES, read=["R1", "R2"])
    output:
        os.path.join(OUTPUT_DIR, "01_stats", "raw_reads.stats.tsv")
    threads: lambda wc: min(len(SAMPLES) * 2, 4)
    conda: config["conda_env"]
    shell:
        """
        seqkit stats -j {threads} -a -b -T --quiet {input} >{output}
        """

# ------------------------------------------------------------------------------
# Rule: trim_galore
# Description: Remove adapters and low-quality bases. Processes all libraries.
# ------------------------------------------------------------------------------
if TRIM_TOOL == "trim_galore":
    rule trim_galore:
        input:
            multiext(
                os.path.join(INPUT_DIR, "{sample}"), 
                fq1 = "_R1.fq.gz", fq2 = "_R2.fq.gz")
        output:
            fq1 = temp(os.path.join(OUTPUT_DIR, "02_clean", "{sample}_R1.fq.gz")),
            fq2 = temp(os.path.join(OUTPUT_DIR, "02_clean", "{sample}_R2.fq.gz"))
        params:
            adapters = config.get("adapters") or '',
            min_len = config.get("min_read_len", 36),
            max_len_arg = (
                f"--max_length {config.get('max_read_len')}" 
                if config.get("max_read_len") else ''),
            trim_params = config.get("trim_params") or '',
            outdir = os.path.join(OUTPUT_DIR, "02_clean"),
        log:
            os.path.join(OUTPUT_DIR, "logs", "trim_galore.{sample}.log")
        benchmark:
            os.path.join(OUTPUT_DIR, "benchmark", "trim_galore.{sample}.txt")
        threads: THREADS
        conda: config["conda_env"]
        shell:
            """
            trim_galore --cores $(({threads} - 2)) {params.adapters} \
                --paired --phred33 --gzip -q 20 --stringency 1 -e 0.1 \
                --length {params.min_len} {params.max_len_arg} \
                {params.trim_params} --basename {wildcards.sample} \
                -o {params.outdir} {input.fq1} {input.fq2} &> {log}

            mv {params.outdir}/{wildcards.sample}_val_1.fq.gz {output.fq1}
            mv {params.outdir}/{wildcards.sample}_val_2.fq.gz {output.fq2}
            """

# ------------------------------------------------------------------------------
# Rule: trimmomatic
# Description: Remove adapters and low-quality bases from reads.
# ------------------------------------------------------------------------------
elif TRIM_TOOL == "trimmomatic":
    rule trimmomatic:
        input:
            multiext(
                os.path.join(INPUT_DIR, "{sample}"), 
                fq1 = "_R1.fq.gz", fq2 = "_R2.fq.gz")
        output:
            fq1 = temp(os.path.join(OUTPUT_DIR, "02_clean", "{sample}_R1.fq.gz")),
            fq2 = temp(os.path.join(OUTPUT_DIR, "02_clean", "{sample}_R2.fq.gz")),
            unpaired_R1 = temp(os.path.join(
                OUTPUT_DIR, "02_clean", "{sample}_unpaired_R1.fq.gz")),
            unpaired_R2 = temp(os.path.join(
                OUTPUT_DIR, "02_clean", "{sample}_unpaired_R2.fq.gz"))
        params:
            adapters = config.get("adapters") or os.path.expanduser(
                "~/miniconda3/envs/ngstools/share/trimmomatic/adapters/TruSeq3-PE-2.fa"),
            min_len = config.get("min_read_len", 36),
            max_len_arg = (
                f"CROP:{config.get('max_read_len')}" 
                if config.get("max_read_len") else ''),
            trim_params = config.get("trim_params") or '',
            summary = os.path.join(OUTPUT_DIR, "02_clean", "{sample}.summary")
        log:
            os.path.join(OUTPUT_DIR, "logs", "trimmomatic.{sample}.log")
        benchmark:
            os.path.join(OUTPUT_DIR, "benchmark", "trimmomatic.{sample}.txt")
        threads: THREADS
        conda: config["conda_env"]
        shell:
            """
            trimmomatic PE -phred33 -threads {threads} \
                -summary {params.summary} {input.fq1} {input.fq2} \
                {output.fq1} {output.unpaired_R1} \
                {output.fq2} {output.unpaired_R2} \
                ILLUMINACLIP:{params.adapters}:2:30:10:2:True \
                SLIDINGWINDOW:5:20 LEADING:20 TRAILING:20 {params.trim_params} \
                MINLEN:{params.min_len} {params.max_len_arg} &> {log}
            """
else:
    raise ValueError(f"Unrecognized trim_tool '{TRIM_TOOL}' in config")

# ------------------------------------------------------------------------------
# Rule: fastqc
# Description: Perform quality control checks on clean reads.
# ------------------------------------------------------------------------------
rule fastqc:
    input:
        multiext(
            os.path.join(OUTPUT_DIR, "02_clean", "{sample}"), 
            fq1 = "_R1.fq.gz", fq2 = "_R2.fq.gz")
    output:
        multiext(
            os.path.join(OUTPUT_DIR, "02_clean", "{sample}"), 
            "_R1_fastqc.html", "_R2_fastqc.html")
    params:
        outdir = os.path.join(OUTPUT_DIR, "02_clean")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "fastqc.{sample}.txt")
    threads: 2
    conda: config["conda_env"]
    shell:
        """
        fastqc -t {threads} -q -o {params.outdir} {input.fq1} {input.fq2}
        """

# ------------------------------------------------------------------------------
# Rule: bowtie2
# Description: Align paired-end reads to the reference genome.
# Align with high sensitivity, excluding mixed/discordant alignments
# ------------------------------------------------------------------------------
rule bowtie2:
    input:
        multiext(
            os.path.join(OUTPUT_DIR, "02_clean", "{sample}"), 
            fq1 = "_R1.fq.gz", fq2 = "_R2.fq.gz")
    output:
        bam = temp(os.path.join(OUTPUT_DIR, "03_align", "{sample}.bam")),
        bai = os.path.join(OUTPUT_DIR, "03_align", "{sample}.bam.bai"),
        stats = os.path.join(OUTPUT_DIR, "03_align", "{sample}.stats.txt"),
        idxstats = os.path.join(OUTPUT_DIR, "03_align", "{sample}.idxstats.txt")
    params:
        index = os.path.join(GENOME, "index/bowtie2_index/genome"),
        align_params = config.get("align_params") or '',
    log:
        os.path.join(OUTPUT_DIR, "03_align", "{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "bowtie2.{sample}.txt")
    priority: 100
    threads: THREADS + 1
    conda: config["conda_env"]
    shell:
        """
        bowtie2 -p $(({threads} - 1)) {params.align_params} \
            -I 25 -X 1000 --no-mixed --no-discordant \
            -x {params.index} -1 {input.fq1} -2 {input.fq2} \
            2> {log} | samtools sort -@ 2 -o {output.bam}

        samtools index {output.bam} {output.bai}
        samtools stats {output.bam} > {output.stats}
        samtools idxstats {output.bam} > {output.idxstats}
        """

# ------------------------------------------------------------------------------
# Rule: bwa
# Description: Align paired-end reads to the reference genome.
# ------------------------------------------------------------------------------
rule bwa:
    input:
        multiext(
            os.path.join(OUTPUT_DIR, "02_clean", "{sample}"), 
            fq1 = "_R1.fq.gz", fq2 = "_R2.fq.gz")
    output:
        bam = temp(os.path.join(OUTPUT_DIR, "03_bwa", "{sample}.bam")),
        bai = os.path.join(OUTPUT_DIR, "03_bwa", "{sample}.bam.bai"),
        stats = os.path.join(OUTPUT_DIR, "03_bwa", "{sample}.stats.txt"),
        idxstats = os.path.join(OUTPUT_DIR, "03_bwa", "{sample}.idxstats.txt")
    params:
        index = os.path.join(GENOME, "index/bwa_index/genome"),
        align_params = config.get("align_params") or '',
    log:
        os.path.join(OUTPUT_DIR, "03_bwa", "{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "bwa.{sample}.txt")
    priority: 100
    threads: THREADS + 1
    conda: config["conda_env"]
    shell:
        """
        bwa mem -t $(({threads} - 1)) {params.align_params} \
            -M {params.index} {input.fq1} {input.fq2} \
            2> {log} | samtools sort -@ 2 -o {output.bam}

        samtools index {output.bam} {output.bai}
        samtools stats {output.bam} > {output.stats}
        samtools idxstats {output.bam} > {output.idxstats}
        """

# ------------------------------------------------------------------------------
if ALIGN_TOOL == "bowtie2":
    BAM = os.path.join(OUTPUT_DIR, "03_align", "{sample}.bam")
elif ALIGN_TOOL == "bwa":
    BAM = os.path.join(OUTPUT_DIR, "03_bwa", "{sample}.bam")
else:
    BAM = os.path.join(OUTPUT_DIR, "03_align", "{sample}.bam")

# ------------------------------------------------------------------------------
# Rule: samtools
# Description: Filter by mapQ, remove mitochondrial reads, and sort BAM files.
# ------------------------------------------------------------------------------
rule samtools:
    input:
        BAM
    output:
        bam = temp(os.path.join(OUTPUT_DIR, "04_bam", ".temp", "{sample}.filter.bam"))
    params:
        filter_expr = lambda wildcards: (
            '' if not config.get("filter_chrm") 
            else " -e 'rname != \"chrM\"'" if config.get("filter_chrm") is True 
            else f" -e 'rname != \"{config.get('filter_chrm')}\"'")
    log:
        os.path.join(OUTPUT_DIR, "logs", "samtools.{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "samtools.{sample}.txt")
    priority: 50
    threads: 5
    resources:
        tmpdir = os.path.join(OUTPUT_DIR, "04_bam", ".temp")
    conda: config["conda_env"]
    shell:
        """
        samtools view -q 30 -f 2 -F 1804 -u {params.filter_expr} {input} 2> {log} | \
            samtools sort -@ 4 -o {output.bam} 2>> {log}
        """

# ------------------------------------------------------------------------------
# Rule: picard
# Description: Mark and remove PCR duplicates conditionally via Picard
# ------------------------------------------------------------------------------
rule picard:
    input:
        bam = os.path.join(OUTPUT_DIR, "04_bam", ".temp", "{sample}.filter.bam")
    output:
        rg_bam = temp(os.path.join(OUTPUT_DIR, "04_bam", ".temp", "{sample}.bam")),
        bam = os.path.join(OUTPUT_DIR, "04_bam", "{sample}.bam"),
        bai = os.path.join(OUTPUT_DIR, "04_bam", "{sample}.bam.bai"),
        rmdup = os.path.join(OUTPUT_DIR, "04_bam", "{sample}.rmdup.txt")
    params:
        rmdup = "true" if config.get("remove_dups", True) else "false"
    log:
        os.path.join(OUTPUT_DIR, "logs", "picard.{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "picard.{sample}.txt")
    priority: 50
    threads: 1
    resources:
        mem_mb = 4000,
        tmpdir = os.path.join(OUTPUT_DIR, "04_bam", ".temp")
    conda: config["conda_env"]
    shell:
        """
        picard -Xmx4G AddOrReplaceReadGroups -I {input} -O {output.rg_bam} \
            --RGID 1 --RGLB {wildcards.sample} --RGSM {wildcards.sample} \
            --RGPL ILLUMINA --RGPU unit --TMP_DIR {resources.tmpdir} 2> {log}

        picard -Xmx4G MarkDuplicates \
            --VALIDATION_STRINGENCY LENIENT --ASSUME_SORT_ORDER coordinate \
            --REMOVE_DUPLICATES {params.rmdup} --TMP_DIR {resources.tmpdir} \
            -I {output.rg_bam} -M {output.rmdup} -O {output.bam} 2>> {log}

        samtools index {output.bam} {output.bai}
        """

# ------------------------------------------------------------------------------
# Rule: insert_sizes
# Description: Calculate and plot the fragment size distribution.
# ------------------------------------------------------------------------------
rule insert_sizes:
    input:
        expand(os.path.join(OUTPUT_DIR, "04_bam", "{sample}.bam"
            ), sample=SAMPLES)
    output:
        multiext(
            os.path.join(OUTPUT_DIR, "01_stats", "fragment_size"), 
            table = ".tsv", summary = ".summary.tsv", 
            plot = ".histogram.png")
    params:
        prefix = SAMPLES
    log:
        os.path.join(OUTPUT_DIR, "logs", "bamPEFragmentSize.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "bamPEFragmentSize.txt")
    threads: lambda wc: min(len(SAMPLES) * 2, 6)
    conda: config["conda_env"]
    shell:
        """
        bamPEFragmentSize -p {threads} --maxFragmentLength 1000 \
            -b {input} --samplesLabel {params.prefix} \
            -T "Fragment Size Distribution" \
            -hist {output.plot} --table {output.summary} \
            --outRawFragmentLengths {output.table} > {log} 2>&1
        """

# ------------------------------------------------------------------------------
# Rule: macs
# Description: Call enrichment peaks (protein-DNA binding sites or open chromatin)
#              from IP library BAM file using MACS3 callpeak algorithm.
# ------------------------------------------------------------------------------
rule macs:
    input:
        rules.picard.output.bam
    output:
        multiext(
            os.path.join(OUTPUT_DIR, "05_peaks", "{sample}"), 
            peaks = "_peaks.narrowPeak", 
            summits = "_summits.bed")
    params:
        gsize = config.get("macs_gsize", "hs"),
        keepdup = config.get("macs_keepdup", "all"),
        qvalue = config.get("macs_qvalue", 0.01),
        model = config.get("macs_model") or '',
        bdg = ("-B" if config.get("macs_bdg", True) else ''),
        outdir = os.path.join(OUTPUT_DIR, "05_peaks")
    log:
        os.path.join(OUTPUT_DIR, "logs", "macs.{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "macs.{sample}.txt")
    priority: 90
    conda: config["conda_env"]
    shell:
        """
        macs3 callpeak -f BAMPE --keep-dup {params.keepdup} -g {params.gsize} \
            -q {params.qvalue} --cutoff-analysis {params.bdg} {params.model} \
            -n {wildcards.sample} -t {input} --outdir {params.outdir} &> {log}
        """

# ------------------------------------------------------------------------------
# Rule: hmmratac
# Description: Call high-confidence accessible regions (peaks) from ATAC-seq 
#              paired-end BAM using the MACS3 HMMRATAC unsupervised model.
# Developer Note: Explicitly exports thread limits to prevent underlying math 
#                 libraries (OpenMP/MKL/OpenBLAS) from dominating all CPU cores.
# ------------------------------------------------------------------------------
rule hmmratac:
    input:
        rules.picard.output.bam
    output:
        os.path.join(OUTPUT_DIR, "05_hmmratac", 
            "{sample}_accessible_regions.narrowPeak")
    params:
        outdir = os.path.join(OUTPUT_DIR, "05_hmmratac"),
    log:
        os.path.join(OUTPUT_DIR, "logs", "hmmratac.{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "hmmratac.{sample}.txt")
    threads: 4
    resources: mem_mb = 10000
    conda: config["conda_env"]
    shell:
        """
        export OMP_NUM_THREADS={threads}
        export MKL_NUM_THREADS={threads}
        export OPENBLAS_NUM_THREADS=1

        macs3 hmmratac -f BAMPE -c 1.2 -n {wildcards.sample}  \
            --binsize 10 -u 20 -l 10 --hmm-type gaussian \
            -i {input} --outdir {params.outdir} &> {log}
        """

# ------------------------------------------------------------------------------
# Rule: frip_score
# Description: Calculate the Fraction of Reads in Peaks (FRiP) score.
# ------------------------------------------------------------------------------
rule frip_score:
    input:
        bam = rules.picard.output.bam,
        peaks = rules.macs.output.peaks
    output:
        os.path.join(OUTPUT_DIR, "05_peaks", "{sample}.frip.txt")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "frip_score.{sample}.txt")
    conda: config["conda_env"]
    shell:
        """
        temp_bed=$(mktemp)
        awk 'BEGIN{{OFS="\\t"}} {{print $1, $2, $3}}' {input.peaks} > $temp_bed

        TOTAL_READS=$(samtools view -c {input.bam})
        READS_IN_PEAKS=$(samtools view -c -L $temp_bed {input.bam})

        FRiP=$(awk -v rip="$READS_IN_PEAKS" -v tot="$TOTAL_READS" \
            'BEGIN {{printf "%.4f", rip/tot}}')

        echo -e "Sample\\tTotalReads\\tReadsInPeaks\\tFRiP" \
            > {output}
        echo -e "{wildcards.sample}\\t$TOTAL_READS\\t$READS_IN_PEAKS\\t$FRiP" \
            >> {output}

        rm $temp_bed
        """

# ------------------------------------------------------------------------------
# Rule: homer
# Description: Perform motif enrichment analysis on peak summits using Homer.
# ------------------------------------------------------------------------------
rule homer:
    input:
        bed = rules.macs.output.summits,
        genome = os.path.join(GENOME, "index/genome.fa"),
        blacklist = os.path.expanduser(config.get("blacklist")),
        motifs = os.path.expanduser(config.get("motifs"))
    output:
        temp1 = temp(os.path.join(OUTPUT_DIR, "06_motif", "{sample}.temp1.bed")),
        temp2 = temp(os.path.join(OUTPUT_DIR, "06_motif", "{sample}.temp2.bed")),
        outdir = directory(os.path.join(OUTPUT_DIR, "06_motif", "{sample}"))
    log:
        os.path.join(OUTPUT_DIR, "logs", "homer.{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "homer.{sample}.txt")
    threads: 4
    conda: config["conda_env"]
    shell:
        """
        bedtools intersect -v -a {input.bed} -b {input.blacklist} > {output.temp1} 2> {log}
        
        sort -k5,5nr {output.temp1} | sed -n '1,3000p' > {output.temp2}

        findMotifsGenome.pl {output.temp2} {input.genome} {output.outdir} \
            -p {threads} -mask -size 50 -len 6,8,10,12 -S 25 \
            -mknown {input.motifs} &>> {log}
        """

# ------------------------------------------------------------------------------
# Rule: bamCoverage
# Description: Convert BAM files to normalized BigWig coverage files.
# ------------------------------------------------------------------------------
rule bamCoverage:
    input:
        rules.picard.output.bam
    output:
        os.path.join(OUTPUT_DIR, "07_bigwig", "{sample}.bw")
    params:
        binSize = config.get("binSize", 10),
        normalize = config.get("normalize", "RPKM")
    log:
        os.path.join(OUTPUT_DIR, "logs", "bamCoverage.{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "bamCoverage.{sample}.txt")
    priority: 50
    threads: 4
    conda: config["conda_env"]
    shell:
        """
        bamCoverage -p {threads} -bs {params.binSize} --exactScaling \
            --normalizeUsing {params.normalize} --extendReads \
            -b {input} -o {output} &> {log}
        """

# ------------------------------------------------------------------------------
# Rule: computeMatrix_TSS
# Description: Calculate bigWig enrichment scores around 
#   Transcription Start Sites (TSS) and plot heatmap.
# ------------------------------------------------------------------------------
rule computeMatrix_TSS:
    input:
        bw = rules.bamCoverage.output,
        bed = os.path.join(GENOME, "protein_coding_genes.bed")
    output:
        multiext(
            os.path.join(OUTPUT_DIR, "08_deeptools", "{sample}"), 
            npz = ".TSS.gz", matrix = ".TSS.tsv", png = ".TSS.png")
    benchmark:
        os.path.join(
            OUTPUT_DIR, "benchmark", "computeMatrix_TSS.{sample}.txt")
    threads: 2
    conda: config["conda_env"]
    shell:
        """
        computeMatrix reference-point -p {threads} --sortRegions keep \
            --referencePoint TSS -b 2000 -a 2000 -bs 10 \
            -R {input.bed} -S {input.bw} --smartLabels \
            -o {output.npz} --outFileNameMatrix {output.matrix}

        plotHeatmap --colorMap RdBu_r --boxAroundHeatmaps no \
            --heatmapHeight 18 --heatmapWidth 6 --dpi 300 \
            -m {output.npz} -out {output.png}
        """

# ------------------------------------------------------------------------------
# Rule: computeMatrix_Genebody
# Description: Calculate bigWig enrichment across scaled 
#   gene bodies and plot heatmap.
# ------------------------------------------------------------------------------
rule computeMatrix_Genebody:
    input:
        bw = rules.bamCoverage.output,
        bed = os.path.join(GENOME, "protein_coding_genes.bed")
    output:
        multiext(
            os.path.join(OUTPUT_DIR, "08_deeptools", "{sample}"), 
            npz = ".Genebody.gz", matrix = ".Genebody.tsv", 
            png = ".Genebody.png")
    benchmark:
        os.path.join(
            OUTPUT_DIR, "benchmark", "computeMatrix_Genebody.{sample}.txt")
    threads: 2
    conda: config["conda_env"]
    shell:
        """
        computeMatrix scale-regions -p {threads} --sortRegions keep \
            --startLabel TSS --endLabel TES -m 3000 -b 2000 -a 2000 -bs 10 \
            -R {input.bed} -S {input.bw} --smartLabels \
            -o {output.npz} --outFileNameMatrix {output.matrix}

        plotHeatmap --colorMap RdBu_r --boxAroundHeatmaps no \
            --heatmapHeight 18 --heatmapWidth 6 --dpi 300 \
            -m {output.npz} -out {output.png}
        """

# ------------------------------------------------------------------------------
# Rule: multiBamSummary_bins
# Description: Compute read counts across consecutive genomic bins.
# ------------------------------------------------------------------------------
rule multiBamSummary:
    input:
        bam = expand(os.path.join(OUTPUT_DIR, "04_bam", "{sample}.bam"
            ), sample=SAMPLES)
    output:
        multiext(
            os.path.join(OUTPUT_DIR, "09_count", "bins_10kb"), 
            npz = ".npz", counts = ".counts.tsv", 
            sf = ".scaleFactor.tsv")
    log:
        os.path.join(OUTPUT_DIR, "logs", "multiBamSummary_bins.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "multiBamSummary_bins.txt")
    threads:
        lambda wc: min(len(SAMPLES), THREADS)
    conda: config["conda_env"]
    shell:
        """
        multiBamSummary bins -p {threads} -bs 10000 \
            --extendReads --samFlagInclude 64 -b {input.bam} \
            --smartLabels --scalingFactors {output.sf} \
            --outRawCounts {output.counts} -o {output.npz} &> {log}
        """

# ------------------------------------------------------------------------------
# Rule: multiqc
# Description: Aggregate results from bioinformatics analyses 
#   across many samples into a single report.
# ------------------------------------------------------------------------------
rule multiqc:
    input:
        os.path.join(OUTPUT_DIR, "01_stats", "raw_reads.stats.tsv"),
        expand(os.path.join(OUTPUT_DIR, "02_clean", "{sample}_R1_fastqc.html"
            ), sample=SAMPLES),
        os.path.join(OUTPUT_DIR, "01_stats", "fragment_size.tsv"),
        TARGET_PEAKS,
        TARGET_FRIP,
        TARGET_MOTIFS,
        expand(os.path.join(OUTPUT_DIR, "07_bigwig", "{sample}.bw"
            ), sample=SAMPLES),
        expand(os.path.join(OUTPUT_DIR, "08_deeptools", "{sample}.TSS.png"
            ), sample=SAMPLES),
        expand(os.path.join(OUTPUT_DIR, "08_deeptools", "{sample}.Genebody.png"
            ), sample=SAMPLES),
        os.path.join(OUTPUT_DIR, "09_count", "bins_10kb.counts.tsv")
    output:
        os.path.join(OUTPUT_DIR, "multiqc_report.html")
    params:
        outdir = OUTPUT_DIR
    log:
        os.path.join(OUTPUT_DIR, "logs", "multiqc.log")
    conda: config["conda_env"]
    shell:
        """
        multiqc {params.outdir} -f -x logs -o {params.outdir} > {log} 2>&1
        """

# ==============================================================================
# End of pipeline definition
# ==============================================================================
