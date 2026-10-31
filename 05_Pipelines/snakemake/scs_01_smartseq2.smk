# ==============================================================================
# Example config (place in config.yaml)
# ==============================================================================
# input_dir: "01_fastq"
# output_dir: "02_output"
# genome: "~/reference/Mus_musculus/mm10"
# threads: 6

# library_strand: "unstranded"
# # unstranded, fr_firststrand, fr_secondstrand
# ercc: false

# trim_tool: "trim_galore"
# min_read_len: 25
# max_read_len: 
# adapters: 
# trim_params: 

# align_tool: "star"
# align_params: 

# count_tool:
#   - featureCounts
#   - htseq
# count_params:

# conda_env: "ngstools"
# ------------------------------------------------------------------------------

# ==============================================================================
# Snakefile: Smart-seq2 Analysis Pipeline (V1)
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

LIB_STRAND = config.get("library_strand", "unstranded")

TRIM_TOOL = config.get("trim_tool")
ALIGN_TOOL = config.get("align_tool")
COUNT_TOOL = config.get("count_tool") or []
if isinstance(COUNT_TOOL, str): 
    COUNT_TOOL = [COUNT_TOOL]

# ==============================================================================
# 2. SAMPLE DETECTION & DYNAMIC PAIRING
# ==============================================================================
SAMPLES, = glob_wildcards(os.path.join(INPUT_DIR, "{sample}.fq.gz"))

if not SAMPLES:
    raise ValueError(f"No FASTQ files detected in {INPUT_DIR}")
else:
    print("Detected samples:\n" + "\n".join(SAMPLES))

# ==============================================================================
# 3. RULES DEFINITION
# ==============================================================================
TARGET_COUNTS = []
SUPPORTED_COUNT_TOOLS = ["featureCounts", "htseq"]

for tool in COUNT_TOOL:
    tool = tool.strip()
    if tool == "featureCounts":
        TARGET_COUNTS.append(os.path.join(
            OUTPUT_DIR, "04_counts", "featureCounts.tsv"))
    elif tool == "htseq":
        TARGET_COUNTS.extend(expand(os.path.join(
            OUTPUT_DIR, "04_counts", "{sample}.tsv"), sample=SAMPLES))        
    else:
        raise ValueError(
            f"Unsupported COUNT_TOOL: '{tool}'. Supported tools are {SUPPORTED_COUNT_TOOLS}.")

rule all:
    input:
        os.path.join(OUTPUT_DIR, "01_stats", "raw_reads.stats.tsv"),
        TARGET_COUNTS,
        os.path.join(OUTPUT_DIR, "multiqc_report.html")

# ------------------------------------------------------------------------------
# Rule: seqkit
# Description: Generate basic statistics for raw FASTQ files.
# ------------------------------------------------------------------------------
rule seqkit:
    input:
        expand(os.path.join(INPUT_DIR, "{sample}.fq.gz"), sample=SAMPLES)
    output:
        os.path.join(OUTPUT_DIR, "01_stats", "raw_reads.stats.tsv")
    threads: lambda wc: min(len(SAMPLES), 6)
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
            os.path.join(INPUT_DIR, "{sample}.fq.gz")
        output:
            temp(os.path.join(OUTPUT_DIR, "02_clean", "{sample}.fq.gz"))
        params:
            adapters = config.get("adapters") or '',
            min_len = config.get("min_read_len", 25),
            max_len_arg = (
                f"--max_length {config.get('max_read_len')}" 
                if config.get("max_read_len") else ''),
            trim_params = config.get("trim_params") or [],
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
                --phred33 --gzip -q 20 --stringency 1 -e 0.1 \
                --length {params.min_len} {params.max_len_arg} \
                {params.trim_params} --basename {wildcards.sample} \
                -o {params.outdir} {input} &> {log}

            mv {params.outdir}/{wildcards.sample}_trimmed.fq.gz {output}
            """

# ------------------------------------------------------------------------------
# Rule: trimmomatic
# Description: Remove adapters and low-quality bases from reads.
# ------------------------------------------------------------------------------
elif TRIM_TOOL == "trimmomatic":
    rule trimmomatic:
        input:
            os.path.join(INPUT_DIR, "{sample}.fq.gz")
        output:
            temp(os.path.join(OUTPUT_DIR, "02_clean", "{sample}.fq.gz"))
        params:
            adapters = config.get("adapters") or os.path.expanduser(
                "~/miniconda3/envs/ngstools/share/trimmomatic/adapters/TruSeq3-PE-2.fa"),
            min_len = config.get("min_read_len", "20"),
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
            trimmomatic SE -phred33 -threads {threads} \
                -summary {params.summary} {input} {output} \
                ILLUMINACLIP:{params.adapters}:2:30:10 \
                SLIDINGWINDOW:5:20 LEADING:20 TRAILING:20 {params.trim_params} \
                MINLEN:{params.min_len} {params.max_len_arg} &> {log}
            """

# ------------------------------------------------------------------------------
# Rule: cutadapt
# Description: Remove adapters, low-quality bases and extract UMI from reads.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Rule: fastp
# Description: Remove adapters, low-quality bases and extract UMI from reads.
# ------------------------------------------------------------------------------

else:
    raise ValueError(f"Unrecognized trim_tool '{TRIM_TOOL}' in config")

# ------------------------------------------------------------------------------
# Rule: star_align
# Description: Align cleaned reads to the reference genome.
# ------------------------------------------------------------------------------
rule star_align:
    input:
        os.path.join(OUTPUT_DIR, "02_clean", "{sample}.fq.gz")
    output:
        os.path.join(OUTPUT_DIR, "03_align", "{sample}.Aligned.out.bam")
    params:
        index = (os.path.join(GENOME, "index/star_ercc_index") 
            if config.get("ercc", False) 
            else os.path.join(GENOME, "index/star_index")),
        prefix = os.path.join(OUTPUT_DIR, "03_align", "{sample}."),
        align_params = config.get("align_params") or '',
        tmp_dir = os.path.expanduser("~/tmp/STAR_{sample}")
    log:
        os.path.join(OUTPUT_DIR, "logs", "star.{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "star.{sample}.txt")
    priority: 100
    threads: 4
    conda: config["conda_env"]
    shell:
        """
        STAR --runThreadN {threads} --genomeDir {params.index} \
            --readFilesIn {input} {params.align_params} \
            --outSAMattributes All --outSAMtype BAM Unsorted \
            --readFilesCommand zcat --outTmpDir {params.tmp_dir} \
            --genomeLoad LoadAndKeep --outFilterMultimapNmax 1 \
            --outFilterScoreMinOverLread 0.33 \
            --outFilterMatchNminOverLread 0.33 \
            --outFileNamePrefix {params.prefix} &> {log}
        """

# ------------------------------------------------------------------------------
# Rule: hisat2_align
# Description: Align cleaned reads to the reference genome.
# ------------------------------------------------------------------------------
rule hisat2_align:
    input:
        os.path.join(OUTPUT_DIR, "02_clean", "{sample}.fq.gz")
    output:
        bam = os.path.join(OUTPUT_DIR, "03_align", "{sample}.bam"),
        summary = os.path.join(OUTPUT_DIR, "03_align", "{sample}.summary")
    params:
        index = os.path.join(GENOME, "index/hisat2_index/genome"),
        strand = ("--rna-strandness RF" if LIB_STRAND == "fr_firststrand"
            else "--rna-strandness FR" if LIB_STRAND == "fr_secondstrand"
            else ''),
        align_params = config.get("align_params") or ''
    log:
        os.path.join(OUTPUT_DIR, "logs", "hisat2.{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "hisat2.{sample}.txt")
    priority: 100
    threads: THREADS + 1
    conda: config["conda_env"]
    shell:
        """
        hisat2 -p $(({threads} - 1)) -x {params.index} \
            {params.strand} {params.align_params} -U {input} \
            --new-summary --summary-file {output.summary} 2> {log} | \
            samtools sort -@ 1 -n -O bam -o {output.bam}
        """

# ------------------------------------------------------------------------------
if ALIGN_TOOL == "star":
    BAMS = expand(os.path.join(
        OUTPUT_DIR, "03_align", "{sample}.Aligned.out.bam"), sample=SAMPLES)
elif ALIGN_TOOL == "hisat2":
    BAMS = expand(os.path.join(
        OUTPUT_DIR, "03_align", "{sample}.bam"), sample=SAMPLES)
else:
    BAMS = expand(os.path.join(
        OUTPUT_DIR, "03_align", "{sample}.Aligned.out.bam"), sample=SAMPLES)

# ------------------------------------------------------------------------------
# Rule: featureCounts
# Description: Quantify expression using featureCounts.
# ------------------------------------------------------------------------------
rule featureCounts:
    input:
        gtf = (os.path.join(GENOME, "index/genome_ercc.gtf") 
            if config.get("ercc", False) 
            else os.path.join(GENOME, "index/genome.gtf")),
        bams = BAMS
    output:
        os.path.join(OUTPUT_DIR, "04_counts", "featureCounts.tsv")
    params:
        strand = ("-s 2" if LIB_STRAND == "fr_firststrand"
            else "-s 1" if LIB_STRAND == "fr_secondstrand"
            else "-s 0"),
        count_params = config.get("count_params") or '',
    log:
        os.path.join(OUTPUT_DIR, "logs", "featureCounts.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "featureCounts.txt")
    threads: lambda wc: min(len(SAMPLES), THREADS)
    conda: config["conda_env"]
    shell:
        """
        featureCounts -T {threads} --primary \
            {params.count_params} {params.strand} \
            -g gene_id -t exon \
            --extraAttributes gene_name,gene_type \
            -a {input.gtf} -o {output} {input.bams} &> {log}
        """

# ------------------------------------------------------------------------------
if ALIGN_TOOL == "star":
    BAM = os.path.join(OUTPUT_DIR, "03_align", "{sample}.Aligned.out.bam")
elif ALIGN_TOOL == "hisat2":
    BAM = os.path.join(OUTPUT_DIR, "03_align", "{sample}.bam")
else:
    BAM = os.path.join(OUTPUT_DIR, "03_align", "{sample}.Aligned.out.bam")

# ------------------------------------------------------------------------------
# Rule: htseq_count
# Description: Quantify expression using HTseq.
# ------------------------------------------------------------------------------
rule htseq_count:
    input:
        gtf = (os.path.join(GENOME, "index/genome_ercc.gtf") 
            if config.get("ercc", False) 
            else os.path.join(GENOME, "index/genome.gtf")),
        bam = BAM
    output:
        os.path.join(OUTPUT_DIR, "04_counts", "{sample}.tsv")
    params:
        strand = ("-s reverse" if LIB_STRAND == "fr_firststrand"
            else "-s yes" if LIB_STRAND == "fr_secondstrand"
            else "-s no")
    log:
        os.path.join(OUTPUT_DIR, "logs", "htseq.{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "htseq.{sample}.txt")
    threads: 1
    conda: config["conda_env"]
    shell:
        """
        htseq-count -f bam -r name -a 10 -m union --nonunique none \
            -t exon -i gene_id {params.strand} \
            --additional-attr=gene_name --additional-attr=gene_type \
            --secondary-alignments=ignore --supplementary-alignments=ignore \
            -c {output} {input.bam} {input.gtf} &> {log}
        """

# ------------------------------------------------------------------------------
# Rule: Run MultiQC to summarize QC and quantification
# ------------------------------------------------------------------------------
rule multiqc:
    input:
        os.path.join(OUTPUT_DIR, "01_stats", "raw_reads.stats.tsv"),
        TARGET_COUNTS
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
