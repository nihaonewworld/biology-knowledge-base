# ==============================================================================
# Example config (place in config.yaml)
# ==============================================================================
# input_dir: "01_fastq"
# output_dir: "02_output"
# genome: "~/reference/Mus_musculus/mm10"
# threads: 6

# is_rm_rna: false
# rna_type: "rrna"
# # rrna, ncrna
# library_strand: "unstranded"
# # unstranded, fr_firststrand, fr_secondstrand
# ercc: false

# trim_tool: "trim_galore"
# # trimmomatic, trim_galore, cutadapt, fastp
# min_read_len: 36
# max_read_len: 
# adapters: 
# trim_params: 

# align_tool: "star"
# # star, hisat2
# align_params: 

# count_tool:
#   - featureCounts
#   - htseq
# count_params: "-B"

# quant_tool: 
#   - salmon
#   - kallisto

# denovo_tool:
# # stringtie

# conda_env: "ngstools"
# ------------------------------------------------------------------------------

# ==============================================================================
# Snakefile: RNA-seq and Polysome-seq Analysis Pipeline (V1)
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
RNA_TYPE = config.get("rna_type") or ''

TRIM_TOOL = config.get("trim_tool")
ALIGN_TOOL = config.get("align_tool")
COUNT_TOOL = config.get("count_tool") or []
if isinstance(COUNT_TOOL, str): 
    COUNT_TOOL = [COUNT_TOOL]
QUANT_TOOL = config.get("quant_tool") or []
if isinstance(QUANT_TOOL, str): 
    QUANT_TOOL = [QUANT_TOOL]

DENOVO_TOOL = config.get("denovo_tool")

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

TARGET_QUANT = []
SUPPORTED_TOOLS = ["salmon", "kallisto"]

for tool in QUANT_TOOL:
    tool = tool.strip()
    if tool in SUPPORTED_TOOLS:
        TARGET_QUANT.extend(
            expand(os.path.join(OUTPUT_DIR, f"05_{tool}", "{sample}"
                ), sample=SAMPLES))
    else:
        raise ValueError(
            f"Unsupported QUANT_TOOL: {tool}. Supported tools are {SUPPORTED_TOOLS}.")

TARGET_DENOVO = []
if DENOVO_TOOL == "stringtie":
    TARGET_DENOVO = expand(os.path.join(
        OUTPUT_DIR, "07_stringtie", "{sample}"), sample=SAMPLES)
elif DENOVO_TOOL is not None:
    raise ValueError(f"Unsupported DENOVO_TOOL: {DENOVO_TOOL}.")

rule all:
    input:
        os.path.join(OUTPUT_DIR, "01_stats", "raw_reads.stats.tsv"),
        expand(os.path.join(OUTPUT_DIR, "02_clean", "{sample}_R1_fastqc.html"
            ), sample=SAMPLES),
        TARGET_COUNTS,
        TARGET_QUANT,
        TARGET_DENOVO,
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

# ------------------------------------------------------------------------------
# Rule: cutadapt
# Description: Remove adapters, low-quality bases and extract UMI from reads.
# ------------------------------------------------------------------------------
elif TRIM_TOOL == "cutadapt":
    rule cutadapt:
        input:
            multiext(
                os.path.join(INPUT_DIR, "{sample}"), 
                fq1 = "_R1.fq.gz", fq2 = "_R2.fq.gz")
        output:
            fq1 = temp(os.path.join(OUTPUT_DIR, "02_clean", "{sample}_R1.fq.gz")),
            fq2 = temp(os.path.join(OUTPUT_DIR, "02_clean", "{sample}_R2.fq.gz"))
        params:
            trim_R1 = os.path.join(
                OUTPUT_DIR, "02_clean", "{sample}_trim_R1.fq.gz"),
            trim_R2 = os.path.join(
                OUTPUT_DIR, "02_clean", "{sample}_trim_R2.fq.gz"),
            adapters = config.get("adapters") or '',
            min_len = config.get("min_read_len", 36),
            outdir = os.path.join(OUTPUT_DIR, "02_clean")
        log:
            os.path.join(OUTPUT_DIR, "logs", "cutadapt.{sample}.log")
        benchmark:
            os.path.join(OUTPUT_DIR, "benchmark", "cutadapt.{sample}.txt")
        threads: THREADS
        conda: config["conda_env"]
        shell:
            """
            # Trim adapters
            cutadapt -j {threads} -q 20 --trim-n -m 25 -M 150 \
                -a AGATCGGAAGAGCACACGTCTGAACTCCAG \
                -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAG \
                -o {params.trim_R1} -p {params.trim_R2} \
                {input.fq1} {input.fq2} > {log} 2>&1
            # -a CTGTCTCTTATACACATCT -A CTGTCTCTTATACACATCT \

            # Extracting the umi sequence
            cutadapt -j {threads} -q 20 -m 20 --action=trim \
                -u 8 -u -4 -U -8 -U 4 \
                --rename='{{id}}_{{r1.cut_prefix}} {{comment}}' \
                -o {output.clean_R1} -p {output.clean_R2} \
                {params.trim_R1} {params.trim_R2} >> {log} 2>&1
            """

# ------------------------------------------------------------------------------
# Rule: fastp
# Description: Remove adapters, low-quality bases and extract UMI from reads.
# ------------------------------------------------------------------------------

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
# Rule: rm_rna_bowtie2
# Description: Remove rRNA reads using Bowtie2 (if enabled)
# ------------------------------------------------------------------------------
rule rm_rna_bowtie2:
    input:
        multiext(
            os.path.join(OUTPUT_DIR, "02_clean", "{sample}"), 
            fq1 = "_R1.fq.gz", fq2 = "_R2.fq.gz")
    output:
        fq1 = temp(os.path.join(OUTPUT_DIR, "02_clean_remove", "{sample}_R1.fq.gz")),
        fq2 = temp(os.path.join(OUTPUT_DIR, "02_clean_remove", "{sample}_R2.fq.gz")),
        bam = temp(os.path.join(OUTPUT_DIR, "02_clean_remove", "{sample}.rRNA.bam"))
    params:
        index = lambda wc: os.path.join(
            GENOME, f"index/bowtie2_index/{config.get("rna_type", "rrna")}"),
        prefix = os.path.join(OUTPUT_DIR, "02_clean_remove", "{sample}_R%.fq.gz")
    log:
        os.path.join(OUTPUT_DIR, "02_clean_remove", "{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "bowtie2.{sample}.txt")
    threads: THREADS + 1
    conda: config["conda_env"]
    shell:
        """
        bowtie2 -p $(({threads} - 1)) -x {params.index} \
            --no-unal --un-conc-gz {params.prefix} \
            -1 {input.fq1} -2 {input.fq2} 2> {log} | \
            samtools view -@ 1 -b -o {output.bam}
        """

# ------------------------------------------------------------------------------
if config.get("is_rm_rna", False):
    READS_R1, READS_R2 = multiext(
        os.path.join(OUTPUT_DIR, "02_clean_remove", "{sample}"), 
        "_R1.fq.gz", "_R2.fq.gz")
else:
    READS_R1, READS_R2 = multiext(
        os.path.join(OUTPUT_DIR, "02_clean", "{sample}"), 
        "_R1.fq.gz", "_R2.fq.gz")

# ------------------------------------------------------------------------------
# Rule: star_align
# Description: Align cleaned reads to the reference genome.
# ------------------------------------------------------------------------------
rule star_align:
    input:
        fq1 = READS_R1,
        fq2 = READS_R2
    output:
        os.path.join(OUTPUT_DIR, "03_align", "{sample}.Aligned.out.bam")
    params:
        index = (os.path.join(GENOME, "index/star_ercc_index") 
            if config.get("ercc", False) 
            else os.path.join(GENOME, "index/star_index")),
        prefix = os.path.join(OUTPUT_DIR, "03_align", "{sample}."),
        align_params = config.get("align_params") or '',
        tag = ("--outSAMstrandField intronMotif" if DENOVO_TOOL else []),
        tmp_dir = os.path.expanduser("~/tmp/STAR_{sample}")
    log:
        os.path.join(OUTPUT_DIR, "logs", "star.{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "star.{sample}.txt")
    priority: 100
    threads: 8
    conda: config["conda_env"]
    shell:
        """
        STAR --runThreadN {threads} --genomeDir {params.index} \
            --readFilesIn {input.fq1} {input.fq2} {params.align_params} \
            --outSAMattributes All --outSAMtype BAM Unsorted {params.tag} \
            --readFilesCommand zcat --outTmpDir {params.tmp_dir} \
            --outFileNamePrefix {params.prefix} &> {log}
        """
# --genomeLoad LoadAndRemove 

# ------------------------------------------------------------------------------
# Rule: hisat2_align
# Description: Align cleaned reads to the reference genome.
# ------------------------------------------------------------------------------
rule hisat2_align:
    input:
        fq1 = READS_R1,
        fq2 = READS_R2
    output:
        bam = os.path.join(OUTPUT_DIR, "03_align", "{sample}.bam"),
        summary = os.path.join(OUTPUT_DIR, "03_align", "{sample}.summary")
    params:
        index = os.path.join(GENOME, "index/hisat2_index/genome"),
        strand = ("--rna-strandness RF" if LIB_STRAND == "fr_firststrand"
            else "--rna-strandness FR" if LIB_STRAND == "fr_secondstrand"
            else ''),
        align_params = config.get("align_params") or '',
        dta = "--dta" if DENOVO_TOOL == "stringtie" else []
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
            {params.strand} {params.align_params} {params.dta} \
            -1 {input.fq1} -2 {input.fq2} \
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
        region = ("exon" if RNA_TYPE != "ncrna" else "CDS"),
        count_params = config.get("count_params") or ''
    log:
        os.path.join(OUTPUT_DIR, "logs", "featureCounts.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "featureCounts.txt")
    threads: lambda wc: min(len(SAMPLES), THREADS)
    conda: config["conda_env"]
    shell:
        """
        featureCounts -T {threads} --primary -p --countReadPairs -C \
            {params.count_params} {params.strand} \
            -g gene_id -t {params.region} \
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
            else "-s no"),
        region = ("exon" if RNA_TYPE != "ncrna" else "CDS")
    log:
        os.path.join(OUTPUT_DIR, "logs", "htseq.{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "htseq.{sample}.txt")
    threads: 1
    conda: config["conda_env"]
    shell:
        """
        htseq-count -f bam -r name -a 10 -m union --nonunique none \
            -t {params.region} -i gene_id {params.strand} \
            --additional-attr=gene_name --additional-attr=gene_type \
            --secondary-alignments=ignore --supplementary-alignments=ignore \
            -c {output} {input.bam} {input.gtf} &> {log}
        """

# ------------------------------------------------------------------------------
# Rule: salmon
# Description: Quantify transcript abundance using Salmon.
# Salmon automatically detects strand specificity by default
# ------------------------------------------------------------------------------
rule salmon:
    input:
        fq1 = READS_R1,
        fq2 = READS_R2
    output:
        directory(os.path.join(OUTPUT_DIR, "05_salmon", "{sample}"))
    params:
        index = os.path.join(GENOME, "index/salmon_index"),
        strand = ("-l ISR" if LIB_STRAND == "fr_firststrand"
            else "-l ISF" if LIB_STRAND == "fr_secondstrand"
            else "-l IU")
    log:
        os.path.join(OUTPUT_DIR, "05_salmon", "{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "salmon.{sample}.txt")
    threads: THREADS
    conda: config["conda_env"]
    shell:
        """
        salmon quant -p {threads} -i {params.index} -l A --gcBias \
            -1 {input.fq1} -2 {input.fq2} -o {output} &> {log}
        """

# ------------------------------------------------------------------------------
# Rule: kallisto
# Description: Quantify transcript abundance usingc Kallisto.
# ------------------------------------------------------------------------------
rule kallisto:
    input:
        fq1 = READS_R1,
        fq2 = READS_R2
    output:
        directory(os.path.join(OUTPUT_DIR, "05_kallisto", "{sample}"))
    params:
        index = os.path.join(GENOME, "index/kallisto_index/transcriptome"),
        strand = ("--rf-stranded" if LIB_STRAND == "fr_firststrand"
            else "--fr-stranded" if LIB_STRAND == "fr_secondstrand"
            else '')
    log:
        os.path.join(OUTPUT_DIR, "05_kallisto", "{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "kallisto.{sample}.txt")
    threads: THREADS
    conda: config["conda_env"]
    shell:
        """
        kallisto quant -t {threads} -i {params.index} {params.strand} \
            -o {output} {input.fq1} {input.fq2} &> {log}
        """

# ------------------------------------------------------------------------------
# Rule: Assemble transcripts and estimate abundances using StringTie
# ------------------------------------------------------------------------------
if ALIGN_TOOL == "star":
    BAM = os.path.join(OUTPUT_DIR, "03_align", "{sample}.Aligned.out.bam")
elif ALIGN_TOOL == "hisat2":
    BAM = os.path.join(OUTPUT_DIR, "03_align", "{sample}.bam")
else:
    BAM = os.path.join(OUTPUT_DIR, "03_align", "{sample}.bam")

rule stringtie:
    input:
        bam = BAM
    output:
        bam = os.path.join(OUTPUT_DIR, "07_stringtie", "{sample}.bam"),
        gtf = os.path.join(OUTPUT_DIR, "07_stringtie", "{sample}.gtf")
    params:
        gtf = os.path.join(GENOME, "index/genome.gtf"),
        strand = ("--rf" if LIB_STRAND == "fr_firststrand"
            else "--fr" if LIB_STRAND == "fr_secondstrand"
            else '')
    log:
        os.path.join(OUTPUT_DIR, "logs", "stringtie.{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "stringtie.{sample}.txt")
    threads: THREADS + 1
    conda: config["conda_env"]
    shell:
        """
        samtools sort -@ 1 -O bam -o {output.bam} {input}
        stringtie -p $(({threads} - 1)) -G {params.gtf} {params.strand} \
            -o {output.gtf} {output.bam} &>> {log}
        """

rule stringtie_merge:
    input:
        expand(
            os.path.join(
                OUTPUT_DIR, "07_stringtie", "{sample}.gtf"
                ), sample=SAMPLES)
    output:
        os.path.join(OUTPUT_DIR, "07_stringtie", "merge.gtf")
    params:
        gtf = os.path.join(GENOME, "index/genome.gtf"),
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "stringtie_merge.txt")
    conda: config["conda_env"]
    shell:
        """
        stringtie --merge -G {params.gtf} -o {output} {input}
        """

rule stringtie_count:
    input:
        bam = os.path.join(OUTPUT_DIR, "07_stringtie", "{sample}.bam"),
        gtf = os.path.join(OUTPUT_DIR, "07_stringtie", "merge.gtf")
    output:
        outdir = directory(os.path.join(OUTPUT_DIR, "07_stringtie", "{sample}")),
        gtf = os.path.join(OUTPUT_DIR, "07_stringtie", "{sample}.count.gtf")
    params:
        strand = ("--rf" if LIB_STRAND == "fr_firststrand"
            else "--fr" if LIB_STRAND == "fr_secondstrand"
            else '')
    log:
        os.path.join(OUTPUT_DIR, "logs", "stringtie_count.{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "stringtie_count.{sample}.txt")
    threads: THREADS
    conda: config["conda_env"]
    shell:
        """
        stringtie -p {threads} -e -G {input.gtf} {params.strand} \
            -b {output.outdir} -o {output.gtf} {input.bam} > {log} 2>&1
        """

# ------------------------------------------------------------------------------
# Rule: Run MultiQC to summarize QC and quantification
# ------------------------------------------------------------------------------
rule multiqc:
    input:
        os.path.join(OUTPUT_DIR, "01_stats", "raw_reads.stats.tsv"),
        expand(os.path.join(OUTPUT_DIR, "02_clean", "{sample}_R1_fastqc.html"
            ), sample=SAMPLES),
        TARGET_COUNTS,
        TARGET_QUANT,
        TARGET_DENOVO
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