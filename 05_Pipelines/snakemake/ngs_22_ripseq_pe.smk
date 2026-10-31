# ==============================================================================
# Example config (place in config.yaml)
# ==============================================================================
# input_dir: "01_fastq"
# output_dir: "02_output"
# genome: "~/reference/Mus_musculus/mm10"
# threads: 6

# is_rm_rna: false
# rm_rna_type: "rrna"
# # rrna, ncrna
# library_strand: "unstranded"
# # unstranded, fr_firststrand, fr_secondstrand
# ercc: false

# trim_tool: "trim_galore"
# min_read_len: 36
# max_read_len: 
# adapters: 
# trim_params: 

# align_tool: "star"
# # star, hisat2
# align_params: 

# filter_chrm: false
# remove_dups: true

# callpeak_tool: 
#   - macs2
#   - exomePeak2
# callpeak_control: "input"
# macs_gsize: "mm"
# # hs, mm, 1.3e8
# macs_keepdup: "all"
# macs_qvalue: 0.01
# macs_model: "--nomodel --shift 0 --extsize 150"
# macs_bdg: false

# exomePeak2_genome: "mm10"
# exomePeak2_fragment_length: 100
# exomePeak2_pvalue: 1e-05

# binSize: 10
# normalize: "RPKM"

# count_tool:
#   - featureCounts
#   - htseq
# featurecounts_params: "-B"

# conda_env: "ngstools"
# conda_r_env: "r452"
# ------------------------------------------------------------------------------

# ==============================================================================
# Snakefile: RIP-seq Analysis Pipeline (V1)
# ==============================================================================
# -*- coding: utf-8 -*-
import os
import re
from snakemake.utils import min_version
from snakemake.io import glob_wildcards, expand

min_version("9.6")
shell.executable("/bin/bash")

# ==============================================================================
# 1. VALIDATE CONFIGURATION
# ==============================================================================
configfile: "config.yaml"

# Ensure all necessary parameters are provided in config.yaml
required_keys = ["input_dir", "output_dir", "genome", "conda_env"]

missing = [k for k in required_keys if k not in config]
if missing:
    raise ValueError(
        "Missing config keys: " + ",".join(missing)
    )

INPUT_DIR = os.path.expanduser(config.get("input_dir"))
OUTPUT_DIR = os.path.expanduser(config.get("output_dir"))
GENOME = os.path.expanduser(config.get("genome"))
THREADS = config.get("threads", 6)

LIB_STRAND = config.get("library_strand", "unstranded")
RNA_TYPE = config.get("rm_rna_type") or ''

# ==============================================================================
# 2. SAMPLE DETECTION & DYNAMIC PAIRING
# ==============================================================================
# Extract sample and library IDs from FASTQ files
SAMPLES, ASSAYS = glob_wildcards(
    os.path.join(INPUT_DIR, "{sample}_{assay}_R1.fq.gz")
)

if not SAMPLES:
    raise ValueError(f"No FASTQ files detected in {INPUT_DIR}")

SAMPLE_MAP = {}

for sample, assay in zip(SAMPLES, ASSAYS):
    if sample not in SAMPLE_MAP:
        SAMPLE_MAP[sample] = {"IP": [], "Input": [], "IgG": []}

    assay_lower = assay.lower()
    if "input" in assay_lower:
        SAMPLE_MAP[sample]["Input"].append(assay)
    elif "igg" in assay_lower:
        SAMPLE_MAP[sample]["IgG"].append(assay)
    else:
        SAMPLE_MAP[sample]["IP"].append(assay)

LIB_IDS = [
    f"{sample}_{assay}"
    for sample, assay in zip(SAMPLES, ASSAYS)
]

IP_LIB_IDS = [
    f"{sample}_{assay}"
    for sample, types in SAMPLE_MAP.items()
    for assay in types["IP"]
]

INPUT_LIB_IDS = [
    f"{sample}_{assay}"
    for sample, types in SAMPLE_MAP.items()
    for assay in types["Input"]
]

print(f"\n[RIP-seq Sample Pairing]")
for sample, types in SAMPLE_MAP.items():
    print(f"Sample: {sample}")
    print(f"  Inputs: {types['Input']}")
    print(f"  IgGs:   {types['IgG']}")
    print(f"  IPs:    {types['IP']}")

# ==============================================================================
# 3. RULES DEFINITION
# ==============================================================================
TRIM_TOOL = config.get("trim_tool")
ALIGN_TOOL = config.get("align_tool")

TARGET_FASTQC = expand(
    os.path.join(OUTPUT_DIR, "02_clean", "{lib_id}_R1_fastqc.html"), 
    lib_id=LIB_IDS
)

TARGET_PEAKS = []
TARGET_MOTIFS = []
SUPPORTED_CALLPEAK_TOOLS = ["macs2", "macs3", "exomePeak2"]

CALLPEAK_TOOL = config.get("callpeak_tool") or []
if isinstance(CALLPEAK_TOOL, str): 
    CALLPEAK_TOOL = [CALLPEAK_TOOL]

for tool in CALLPEAK_TOOL:
    # tool = tool.strip().lower()
    if tool not in SUPPORTED_CALLPEAK_TOOLS:
        raise ValueError(
            f"Unsupported CALLPEAK_TOOL: '{tool}'. "
            f"Supported tools are {SUPPORTED_CALLPEAK_TOOLS}."
        )
    for ip_lib in IP_LIB_IDS:
        if tool in ["macs2", "macs3"]:
            TARGET_PEAKS.append(os.path.join(
                OUTPUT_DIR, "05_peaks", f"{ip_lib}_peaks.narrowPeak"))
            TARGET_MOTIFS.append(os.path.join(
                OUTPUT_DIR, "06_motif", ip_lib))
        elif tool == "exomePeak2":
            TARGET_PEAKS.append(os.path.join(
                OUTPUT_DIR, "05_exomePeak2", f"{ip_lib}"))

TARGET_BIGWIGS = []

if LIB_STRAND == "unstranded":
    for lib_id in LIB_IDS:
        TARGET_BIGWIGS.append(os.path.join(
            OUTPUT_DIR, "07_bigwig", f"{lib_id}.bw"))
elif LIB_STRAND in ["fr_firststrand", "fr_secondstrand"]:
    for lib_id in LIB_IDS:
        TARGET_BIGWIGS.append(os.path.join(
            OUTPUT_DIR, "07_bigwig", f"{lib_id}_plus.bw"))
        TARGET_BIGWIGS.append(os.path.join(
            OUTPUT_DIR, "07_bigwig", f"{lib_id}_minus.bw"))
else:
    raise ValueError(f"Unrecognized library_layout '{LIB_STRAND}' in config")

TARGET_COUNTS = []
SUPPORTED_COUNT_TOOLS = ["featureCounts", "htseq"]

COUNT_TOOL = config.get("count_tool") or []
if isinstance(COUNT_TOOL, str): 
    COUNT_TOOL = [COUNT_TOOL]

for tool in COUNT_TOOL:
    tool = tool.strip()
    if tool == "featureCounts":
        TARGET_COUNTS.append(os.path.join(
            OUTPUT_DIR, "08_counts", "featureCounts.tsv"))
    elif tool == "htseq":
        TARGET_COUNTS.extend(expand(os.path.join(
            OUTPUT_DIR, "08_counts", "{lib_id}.tsv"), lib_id=INPUT_LIB_IDS))
    else:
        raise ValueError(
            f"Unsupported COUNT_TOOL: '{tool}'. "
            f"Supported tools are {SUPPORTED_COUNT_TOOLS}.")


PIPELINE_TARGETS = (
    [
        os.path.join(OUTPUT_DIR, "01_stats", "raw_reads.stats.tsv"),
        os.path.join(OUTPUT_DIR, "01_stats", "fragment_size.tsv")
    ]
    + TARGET_FASTQC
    + TARGET_PEAKS
    + TARGET_MOTIFS
    + TARGET_BIGWIGS
    + TARGET_COUNTS
)

rule all:
    input:
        PIPELINE_TARGETS,
        os.path.join(OUTPUT_DIR, "multiqc_report.html")

# ------------------------------------------------------------------------------
# Rule: seqkit
# Description: Generate basic statistics for raw FASTQ files.
# ------------------------------------------------------------------------------
rule seqkit:
    input:
        expand(os.path.join(INPUT_DIR, "{lib_id}_{read}.fq.gz"
            ), lib_id=LIB_IDS, read=["R1", "R2"])
    output:
        os.path.join(OUTPUT_DIR, "01_stats", "raw_reads.stats.tsv")
    threads: lambda wc: min(len(SAMPLES) * 2, 6)
    conda: config["conda_env"]
    shell:
        """
        seqkit stats -j {threads} -a -b -T --quiet {input} > {output}
        """

# ------------------------------------------------------------------------------
# Rule: trim_galore
# Description: Remove adapters and low-quality bases. Processes all libraries.
# ------------------------------------------------------------------------------
if TRIM_TOOL == "trim_galore":
    rule trim_galore:
        input:
            fq1 = os.path.join(INPUT_DIR, "{lib_id}_R1.fq.gz"),
            fq2 = os.path.join(INPUT_DIR, "{lib_id}_R2.fq.gz")
        output:
            fq1 = temp(os.path.join(
                OUTPUT_DIR, "02_clean", "{lib_id}_R1.fq.gz")),
            fq2 = temp(os.path.join(
                OUTPUT_DIR, "02_clean", "{lib_id}_R2.fq.gz"))
        params:
            adapters = config.get("adapters") or '',
            min_len = config.get("min_read_len", 36),
            max_len_arg = (
                f"--max_length {config.get('max_read_len')}" 
                if config.get("max_read_len") else ''),
            trim_params = config.get("trim_params") or '',
            outdir = os.path.join(OUTPUT_DIR, "02_clean")
        log:
            os.path.join(OUTPUT_DIR, "logs", "trim_galore.{lib_id}.log")
        benchmark:
            os.path.join(OUTPUT_DIR, "benchmark", "trim_galore.{lib_id}.txt")
        threads: THREADS
        conda: config["conda_env"]
        shell:
            """
            trim_galore --cores $(({threads} - 2)) {params.adapters} \
                --paired --phred33 --gzip -q 20 --stringency 1 -e 0.1 \
                --length {params.min_len} {params.max_len_arg} \
                {params.trim_params} --basename {wildcards.lib_id} \
                -o {params.outdir} {input.fq1} {input.fq2} &> {log}

            mv {params.outdir}/{wildcards.lib_id}_val_1.fq.gz {output.fq1}
            mv {params.outdir}/{wildcards.lib_id}_val_2.fq.gz {output.fq2}
            """

# ------------------------------------------------------------------------------
# Rule: trimmomatic
# Description: Remove adapters and low-quality bases from reads.
# ------------------------------------------------------------------------------
elif TRIM_TOOL == "trimmomatic":
    rule trimmomatic:
        input:
            fq1 = os.path.join(INPUT_DIR, "{lib_id}_R1.fq.gz"),
            fq2 = os.path.join(INPUT_DIR, "{lib_id}_R2.fq.gz")
        output:
            fq1 = temp(os.path.join(
                OUTPUT_DIR, "02_clean", "{lib_id}_R1.fq.gz")),
            fq2 = temp(os.path.join(
                OUTPUT_DIR, "02_clean", "{lib_id}_R2.fq.gz")),
            unpaired_R1 = temp(os.path.join(
                OUTPUT_DIR, "02_clean", "{lib_id}_unpaired_R1.fq.gz")),
            unpaired_R2 = temp(os.path.join(
                OUTPUT_DIR, "02_clean", "{lib_id}_unpaired_R2.fq.gz"))
        params:
            adapters = config.get("adapters") or os.path.expanduser(
                "~/miniconda3/envs/ngstools/share/trimmomatic/adapters/TruSeq3-PE-2.fa"),
            min_len = config.get("min_read_len", 36),
            max_len_arg = (
                f"CROP:{config.get('max_read_len')}" 
                if config.get("max_read_len") else ''),
            trim_params = config.get("trim_params") or '',
            summary = os.path.join(OUTPUT_DIR, "02_clean", "{lib_id}.summary")
        log:
            os.path.join(OUTPUT_DIR, "logs", "trimmomatic.{lib_id}.log")
        benchmark:
            os.path.join(OUTPUT_DIR, "benchmark", "trimmomatic.{lib_id}.txt")
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
        fq1 = os.path.join(OUTPUT_DIR, "02_clean", "{lib_id}_R1.fq.gz"),
        fq2 = os.path.join(OUTPUT_DIR, "02_clean", "{lib_id}_R2.fq.gz")
    output:
        os.path.join(OUTPUT_DIR, "02_clean", "{lib_id}_R1_fastqc.html"),
        os.path.join(OUTPUT_DIR, "02_clean", "{lib_id}_R2_fastqc.html")
    params:
        outdir = os.path.join(OUTPUT_DIR, "02_clean")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "fastqc.{lib_id}.txt")
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
        fq1 = os.path.join(OUTPUT_DIR, "02_clean", "{lib_id}_R1.fq.gz"),
        fq2 = os.path.join(OUTPUT_DIR, "02_clean", "{lib_id}_R2.fq.gz")
    output:
        fq1 = temp(os.path.join(
            OUTPUT_DIR, "02_clean_remove", "{lib_id}_R1.fq.gz")),
        fq2 = temp(os.path.join(
            OUTPUT_DIR, "02_clean_remove", "{lib_id}_R2.fq.gz")),
        bam = temp(os.path.join(
            OUTPUT_DIR, "02_clean_remove", "{lib_id}.rRNA.bam"))
    params:
        index = lambda wc: os.path.join(
            GENOME, f"index/bowtie2_index/{config.get("rm_rna_type", "rrna")}"),
        prefix = os.path.join(OUTPUT_DIR, "02_clean_remove", "{lib_id}_R%.fq.gz")
    log:
        os.path.join(OUTPUT_DIR, "02_clean_remove", "{lib_id}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "bowtie2.{lib_id}.txt")
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
        os.path.join(OUTPUT_DIR, "02_clean_remove", "{lib_id}"), 
        "_R1.fq.gz", "_R2.fq.gz")
else:
    READS_R1, READS_R2 = multiext(
        os.path.join(OUTPUT_DIR, "02_clean", "{lib_id}"), 
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
        os.path.join(OUTPUT_DIR, "03_align", "{lib_id}.Aligned.out.bam")
    params:
        index = (os.path.join(GENOME, "index/star_ercc_index") 
            if config.get("ercc", False) 
            else os.path.join(GENOME, "index/star_index")),
        prefix = os.path.join(OUTPUT_DIR, "03_align", "{lib_id}."),
        align_params = config.get("align_params") or '',
        tmp_dir = os.path.expanduser("~/tmp/STAR_{lib_id}")
    log:
        os.path.join(OUTPUT_DIR, "logs", "star.{lib_id}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "star.{lib_id}.txt")
    priority: 100
    threads: 8
    conda: config["conda_env"]
    shell:
        """
        STAR --runThreadN {threads} --genomeDir {params.index} \
            --readFilesIn {input.fq1} {input.fq2} {params.align_params} \
            --outSAMattributes All --outSAMtype BAM Unsorted \
            --readFilesCommand zcat --outTmpDir {params.tmp_dir} \
            --outFileNamePrefix {params.prefix} &> {log}
        """

# ------------------------------------------------------------------------------
# Rule: hisat2_align
# Description: Align cleaned reads to the reference genome.
# ------------------------------------------------------------------------------
rule hisat2_align:
    input:
        fq1 = READS_R1,
        fq2 = READS_R2
    output:
        bam = os.path.join(OUTPUT_DIR, "03_align", "{lib_id}.bam"),
        summary = os.path.join(OUTPUT_DIR, "03_align", "{lib_id}.summary")
    params:
        index = os.path.join(GENOME, "index/hisat2_index/genome"),
        strand = ("--rna-strandness RF" if LIB_STRAND == "fr_firststrand"
            else "--rna-strandness FR" if LIB_STRAND == "fr_secondstrand"
            else ""),
        align_params = config.get("align_params") or ''
    log:
        os.path.join(OUTPUT_DIR, "logs", "hisat2.{lib_id}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "hisat2.{lib_id}.txt")
    priority: 100
    threads: THREADS + 1
    conda: config["conda_env"]
    shell:
        """
        hisat2 -p $(({threads} - 1)) -x {params.index} \
            {params.strand} {params.align_params} \
            -1 {input.fq1} -2 {input.fq2} --new-summary \
            --summary-file {output.summary} 2> {log} | \
            samtools sort -@ 1 -n -O bam -o {output.bam}
        """

# ------------------------------------------------------------------------------
def get_align_output(wildcards):
    if ALIGN_TOOL == "star":
        return os.path.join(
            OUTPUT_DIR, "03_align", f"{wildcards.lib_id}.Aligned.out.bam")
    elif ALIGN_TOOL == "hisat2":
        return os.path.join(
            OUTPUT_DIR, "03_align", f"{wildcards.lib_id}.bam")
    else:
        raise ValueError(
            f"Unsupported ALIGN_TOOL: {ALIGN_TOOL}. Choose 'star' or 'hisat2'.")

# ------------------------------------------------------------------------------
# Rule: samtools
# Description: Filter by mapQ, remove mitochondrial reads, and sort BAM files.
# ------------------------------------------------------------------------------
rule samtools:
    input:
        get_align_output
    output:
        temp(os.path.join(OUTPUT_DIR, "04_bam", ".temp", "{lib_id}.filter.bam"))
    params:
        filter_expr = lambda wildcards: (
            '' if not config.get("filter_chrm") 
            else " -e 'rname != \"chrM\"'" if config.get("filter_chrm") is True 
            else f" -e 'rname != \"{config.get('filter_chrm')}\"'")
    log:
        os.path.join(OUTPUT_DIR, "logs", "samtools.{lib_id}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "samtools.{lib_id}.txt")
    priority: 50
    threads: 5
    resources:
        tmpdir = os.path.join(OUTPUT_DIR, "04_bam", ".temp")
    conda: config["conda_env"]
    shell:
        """
        samtools view -q 30 -f 2 -F 1804 -u {params.filter_expr} {input} 2> {log} | \
            samtools sort -@ 4 -o {output} 2>> {log}
        """

# ------------------------------------------------------------------------------
# Rule: picard
# Description: Mark and remove PCR duplicates conditionally via Picard
# ------------------------------------------------------------------------------
rule picard:
    input:
        bam = os.path.join(OUTPUT_DIR, "04_bam", ".temp", "{lib_id}.filter.bam")
    output:
        rg_bam = temp(os.path.join(
            OUTPUT_DIR, "04_bam", ".temp", "{lib_id}.bam")),
        bam = os.path.join(OUTPUT_DIR, "04_bam", "{lib_id}.bam"),
        bai = os.path.join(OUTPUT_DIR, "04_bam", "{lib_id}.bam.bai"),
        rmdup = os.path.join(OUTPUT_DIR, "04_bam", "{lib_id}.rmdup.txt")
    params:
        rmdup = "true" if config.get("remove_dups", True) else "false"
    log:
        os.path.join(OUTPUT_DIR, "logs", "picard.{lib_id}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "picard.{lib_id}.txt")
    priority: 50
    threads: 1
    resources:
        mem_mb = 4000,
        tmpdir = os.path.join(OUTPUT_DIR, "04_bam", ".temp")
    conda: config["conda_env"]
    shell:
        """
        picard -Xmx4G AddOrReplaceReadGroups -I {input} -O {output.rg_bam} \
            --RGID 1 --RGLB {wildcards.lib_id} --RGSM {wildcards.lib_id} \
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
        expand(os.path.join(
            OUTPUT_DIR, "04_bam", "{lib_id}.bam"), lib_id=LIB_IDS)
    output:
        multiext(
            os.path.join(OUTPUT_DIR, "01_stats", "fragment_size"), 
            table = ".tsv", summary = ".summary.tsv", plot = ".histogram.png")
    params:
        prefix = LIB_IDS
    log:
        os.path.join(OUTPUT_DIR, "logs", "bamPEFragmentSize.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "bamPEFragmentSize.txt")
    threads: lambda wc: min(len(LIB_IDS) * 2, 6)
    conda: config["conda_env"]
    shell:
        """
        bamPEFragmentSize -p {threads} --maxFragmentLength 1000 \
            -b {input} --samplesLabel {params.prefix} \
            -T "Fragment Size Distribution" \
            -hist {output.plot} --table {output.summary} \
            --outRawFragmentLengths {output.table} &> {log}
        """

# ------------------------------------------------------------------------------
# Rule: samtools_split
# Description: Splitting bam based on strand specificity
# ------------------------------------------------------------------------------
if ALIGN_TOOL == "hisat2":
    rule samtools_split:
        input:
            os.path.join(OUTPUT_DIR, "04_bam", "{lib_id}.bam")
        output:
            multiext(
                os.path.join(OUTPUT_DIR, "04_bam", "{lib_id}"), 
                plus_bam = "_plus.bam", minus_bam = "_minus.bam")
        benchmark:
            os.path.join(OUTPUT_DIR, "benchmark", "samtools_split.{lib_id}.txt")
        threads: 4
        conda: config["conda_env"]
        shell:
            """
            echo "Using XS-tag based splitting method..."
            samtools view -@ 1 -h {input} | \
                tee >(awk '/^@/ || /XS:A:\\+/' | \
                samtools view -@ 1 -bS - | \
                samtools sort -@ 2 -o {output.plus_bam}) | \
                awk '/^@/ || /XS:A:\\-/' | \
                samtools view -@ 1 -bS - | \
                samtools sort -@ 2 -o {output.minus_bam}

            samtools index {output.plus_bam}
            samtools index {output.minus_bam}
            """
else:
    rule samtools_split:
        input:
            os.path.join(OUTPUT_DIR, "04_bam", "{lib_id}.bam")
        output:
            multiext(
                os.path.join(OUTPUT_DIR, "04_bam", "{lib_id}"), 
                plus_bam = "_plus.bam", minus_bam = "_minus.bam")
        params:
            p1 = ("-f 80" if LIB_STRAND == "fr_firststrand" else "-f 64 -F 16"),
            p2 = ("-f 128 -F 16" if LIB_STRAND == "fr_firststrand" else "-f 144"),
            m1 = ("-f 64 -F 16" if LIB_STRAND == "fr_firststrand" else "-f 80"),
            m2 = ("-f 144" if LIB_STRAND == "fr_firststrand" else "-f 128 -F 16")
        benchmark:
            os.path.join(OUTPUT_DIR, "benchmark", "samtools_split.{lib_id}.txt")
        threads: 4
        conda: config["conda_env"]
        shell:
            """
            echo "Using FLAG-based splitting method..."
            samtools merge -u - \
                <(samtools view -@ 1 -b {params.p1} {input}) \
                <(samtools view -@ 1 -b {params.p2} {input}) | \
                samtools sort -@ 2 -o {output.plus_bam}

            samtools merge -u - \
                <(samtools view -@ 1 -b {params.m1} {input}) \
                <(samtools view -@ 1 -b {params.m2} {input}) | \
                samtools sort -@ 2 -o {output.minus_bam}

            samtools index {output.plus_bam}
            samtools index {output.minus_bam}
            """

# ------------------------------------------------------------------------------
# Rule: macs
# Description: Pairs specific IP library with its matching Input BAM.
# ------------------------------------------------------------------------------
if LIB_STRAND in ["fr_firststrand", "fr_secondstrand"]:
    rule macs:
        input:
            ip_plus = os.path.join(
                OUTPUT_DIR, "04_bam", "{sample}_{ip_lib}_plus.bam"),
            ip_minus = os.path.join(
                OUTPUT_DIR, "04_bam", "{sample}_{ip_lib}_minus.bam"),
            input_plus = lambda wildcards: [
                os.path.join(
                    OUTPUT_DIR, "04_bam", f"{wildcards.sample}_{ctrl}_plus.bam") 
                for ctrl in SAMPLE_MAP[wildcards.sample]["Input"]
            ],
            input_minus = lambda wildcards: [
                os.path.join(
                    OUTPUT_DIR, "04_bam", f"{wildcards.sample}_{ctrl}_minus.bam") 
                for ctrl in SAMPLE_MAP[wildcards.sample]["Input"]
            ]
        output:
            multiext(
                os.path.join(OUTPUT_DIR, "05_peaks", "{sample}_{ip_lib}"), 
                peaks = "_peaks.narrowPeak", summits = "_summits.bed")
        params:
            gsize = config.get("macs_gsize", "hs"),
            keepdup = config.get("macs_keepdup", "all"),
            qvalue = config.get("macs_qvalue", 0.01),
            model = config.get("macs_model") or '',
            bdg = ("-B" if config.get("macs_bdg", True) else ''),
            outdir = os.path.join(OUTPUT_DIR, "05_peaks"),
            prefix = "{sample}_{ip_lib}"
        log:
            os.path.join(OUTPUT_DIR, "logs", "macs.{sample}_{ip_lib}.log")
        benchmark:
            os.path.join(OUTPUT_DIR, "benchmark", "macs.{sample}_{ip_lib}.txt")
        priority: 100
        conda: config["conda_env"]
        shell:
            """
            macs3 callpeak -f BAM --keep-dup {params.keepdup} -g {params.gsize} \
                -q {params.qvalue} --cutoff-analysis {params.bdg} {params.model} \
                -n {params.prefix}_plus -t {input.ip_plus} -c {input.input_plus} \
                --outdir {params.outdir} &> {log}
            macs3 callpeak -f BAM --keep-dup {params.keepdup} -g {params.gsize} \
                -q {params.qvalue} --cutoff-analysis {params.bdg} {params.model} \
                -n {params.prefix}_minus -t {input.ip_minus} -c {input.input_minus} \
                --outdir {params.outdir} &>> {log}

            cat <(awk 'BEGIN {{OFS="\t"}} {{ $6="+"; print }}' \
                {params.outdir}/{params.prefix}_plus_peaks.narrowPeak) \
                <(awk 'BEGIN {{OFS="\t"}} {{ $6="-"; print }}' \
                {params.outdir}/{params.prefix}_minus_peaks.narrowPeak) \
                > {output.peaks}
            cat <(awk 'BEGIN {{OFS="\t"}} {{ $6="+"; print }}' \
                {params.outdir}/{params.prefix}_plus_summits.bed) \
                <(awk 'BEGIN {{OFS="\t"}} {{ $6="-"; print }}' \
                {params.outdir}/{params.prefix}_minus_summits.bed) \
                > {output.summits}
            """
else:
    rule macs:
        input:
            ip_bam = os.path.join(
                OUTPUT_DIR, "04_bam", "{sample}_{ip_lib}.bam"),
            input_bam = lambda wildcards: [
                os.path.join(
                    OUTPUT_DIR, "04_bam", f"{wildcards.sample}_{ctrl}.bam") 
                for ctrl in SAMPLE_MAP[wildcards.sample]["Input"]
            ]
        output:
            multiext(
                os.path.join(OUTPUT_DIR, "05_peaks", "{sample}_{ip_lib}"), 
                peaks = "_peaks.narrowPeak", summits = "_summits.bed")
        params:
            gsize = config.get("macs_gsize", "hs"),
            keepdup = config.get("macs_keepdup", "all"),
            qvalue = config.get("macs_qvalue", 0.01),
            model = config.get("macs_model") or '',
            bdg = ("-B" if config.get("macs_bdg", True) else ''),
            outdir = os.path.join(OUTPUT_DIR, "05_peaks"),
            prefix = "{sample}_{ip_lib}"
        log:
            os.path.join(OUTPUT_DIR, "logs", "macs.{sample}_{ip_lib}.log")
        benchmark:
            os.path.join(OUTPUT_DIR, "benchmark", "macs.{sample}_{ip_lib}.txt")
        priority: 100
        conda: config["conda_env"]
        shell:
            """
            macs3 callpeak -f BAM --keep-dup {params.keepdup} -g {params.gsize} \
                -q {params.qvalue} --cutoff-analysis {params.bdg} {params.model} \
                -n {params.prefix} -t {input.ip_bam} -c {input.input_bam} \
                --outdir {params.outdir} &> {log}
            """

# ------------------------------------------------------------------------------
# Rule: exomePeak2
# Description: Calls meRIP-seq peaks for each IP-Input pair using exomePeak2.
# ------------------------------------------------------------------------------
rule exomePeak2:
    input:
        ip_bam = os.path.join(
            OUTPUT_DIR, "04_bam", "{sample}_{ip_lib}.bam"),
        input_bam = lambda wildcards: [
            os.path.join(
                OUTPUT_DIR, "04_bam", f"{wildcards.sample}_{ctrl}.bam") 
            for ctrl in SAMPLE_MAP[wildcards.sample]["Input"]
        ],
        gtf = os.path.join(GENOME, "index/genome.gtf")
    output:
        directory(os.path.join(OUTPUT_DIR, "05_exomePeak2", "{sample}_{ip_lib}"))
    params:
        genome = config.get("exomePeak2_genome") or '',
        outdir = os.path.join(OUTPUT_DIR, "05_exomePeak2"),
        prefix = "{sample}_{ip_lib}",
        strandness = ("1st_strand" if LIB_STRAND == "fr_firststrand"
            else "2nd_strand" if LIB_STRAND == "fr_secondstrand"
            else "unstrand"
        ),
        fragment_length = config.get("exomePeak2_fragment_length", 100),
        pvalue = config.get("exomePeak2_pvalue", "1e-05")
    log:
        os.path.join(OUTPUT_DIR, "logs", "exomePeak2.{sample}_{ip_lib}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "exomePeak2.{sample}_{ip_lib}.txt")
    threads: 1
    resources: mem_mb = 16000
    conda: config["conda_r_env"]
    shell:
        """
        Rscript ~/biology_knowledge_base/05_pipelines/scripts/callpeaks_exomePeak2.R \
            --ip {input.ip_bam} --input {input.input_bam} --gtf {input.gtf} \
            --genome {params.genome} --outdir {params.outdir} --prefix {params.prefix} \
            --strandness {params.strandness} --fragment_length {params.fragment_length} \
            --pvalue {params.pvalue} --threads {threads} &> {log}
        """

# ------------------------------------------------------------------------------
# Rule: homer
# Description: Perform motif enrichment analysis on peak summits using Homer.
# ------------------------------------------------------------------------------
rule homer:
    input:
        bed = rules.macs.output.summits,
        genome = os.path.join(GENOME, "index/genome.fa")
    output:
        directory(os.path.join(OUTPUT_DIR, "06_motif", "{sample}_{ip_lib}"))
    log:
        os.path.join(OUTPUT_DIR, "logs", "homer.{sample}_{ip_lib}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "homer.{sample}_{ip_lib}.txt")
    threads: 4
    conda: config["conda_env"]
    shell:
        """
        findMotifsGenome.pl {input.bed} {input.genome} {output} \
            -p {threads} -rna -basic -size 200 -len 5,6,7,8 -S 25 -fdr &> {log}
        """

# ------------------------------------------------------------------------------
# Rule: bamCoverage
# Description: Convert BAM files to normalized BigWig coverage files.
# ------------------------------------------------------------------------------
if LIB_STRAND in ["fr_firststrand", "fr_secondstrand"]:
    rule bamCoverage:
        input:
            plus_bam = os.path.join(OUTPUT_DIR, "04_bam", "{lib_id}_plus.bam"),
            minus_bam = os.path.join(OUTPUT_DIR, "04_bam", "{lib_id}_minus.bam")
        output:
            plus_bw = os.path.join(OUTPUT_DIR, "07_bigwig", "{lib_id}_plus.bw"),
            minus_bw = os.path.join(OUTPUT_DIR, "07_bigwig", "{lib_id}_minus.bw")
        params:
            binSize = config.get("binSize", 10),
            normalize = config.get("normalize", "RPKM")
        log:
            plus = os.path.join(OUTPUT_DIR, "logs", "bamCoverage.{lib_id}.log")
        benchmark:
            os.path.join(OUTPUT_DIR, "benchmark", "bamCoverage.{lib_id}.txt")
        priority: 50
        threads: 4
        conda: config["conda_env"]
        shell:
            """
            bamCoverage -p {threads} -bs {params.binSize} \
                --normalizeUsing {params.normalize} \
                -b {input.plus_bam} -o {output.plus_bw} &> {log}
            bamCoverage -p {threads} -bs {params.binSize} \
                --normalizeUsing {params.normalize} \
                -b {input.minus_bam} -o {output.minus_bw} &>> {log}
            """
else:
    rule bamCoverage:
        input:
            os.path.join(OUTPUT_DIR, "04_bam", "{lib_id}.bam")
        output:
            os.path.join(OUTPUT_DIR, "07_bigwig", "{lib_id}.bw")
        params:
            binSize = config.get("binSize", 10),
            normalize = config.get("normalize", "RPKM")
        log:
            os.path.join(OUTPUT_DIR, "logs", "bamCoverage.{lib_id}.log")
        benchmark:
            os.path.join(OUTPUT_DIR, "benchmark", "bamCoverage.{lib_id}.txt")
        priority: 50
        threads: 4
        conda: config["conda_env"]
        shell:
            """
            bamCoverage -p {threads} -bs {params.binSize} \
                --normalizeUsing {params.normalize} \
                -b {input} -o {output} &> {log}
            """

# ------------------------------------------------------------------------------
def get_final_counts_input(wildcards):
    if ALIGN_TOOL == "star":
        return os.path.join(
            OUTPUT_DIR, "03_align", f"{wildcards.lib_id}.Aligned.out.bam")
    elif ALIGN_TOOL == "hisat2":
        return os.path.join(
            OUTPUT_DIR, "03_align", f"{wildcards.lib_id}.bam")
    else:
        raise ValueError(f"Unsupported ALIGN_TOOL: {ALIGN_TOOL}")

# ------------------------------------------------------------------------------
# Rule: featureCounts
# Description: Quantify expression using featureCounts.
# ------------------------------------------------------------------------------
rule featureCounts:
    input:
        gtf = (os.path.join(GENOME, "index/genome_ercc.gtf") 
            if config.get("ercc", False) 
            else os.path.join(GENOME, "index/genome.gtf")),
        bams = lambda wildcards: [
            get_final_counts_input(
                type('', (), {'lib_id': lib})()) for lib in INPUT_LIB_IDS
        ]
    output:
        os.path.join(OUTPUT_DIR, "08_counts", "featureCounts.tsv")
    params:
        strand = ("-s 2" if LIB_STRAND == "fr_firststrand"
            else "-s 1" if LIB_STRAND == "fr_secondstrand"
            else "-s 0"),
        region = ("exon" if RNA_TYPE != "ncrna" else "CDS"),
        featurecounts_params = config.get("featurecounts_params") or ''
    log:
        os.path.join(OUTPUT_DIR, "logs", "featureCounts.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "featureCounts.txt")
    threads: min(len(INPUT_LIB_IDS), THREADS)
    conda: config["conda_env"]
    shell:
        """
        featureCounts -T {threads} --primary -p --countReadPairs -C \
            {params.featurecounts_params} {params.strand} \
            -g gene_id -t {params.region} --extraAttributes gene_name,gene_type \
            -a {input.gtf} -o {output} {input.bams} &> {log}
        """

# ------------------------------------------------------------------------------
# Rule: htseq_count
# Description: Quantify expression using HTseq.
# ------------------------------------------------------------------------------
rule htseq_count:
    input:
        gtf = (os.path.join(GENOME, "index/genome_ercc.gtf") 
            if config.get("ercc", False) 
            else os.path.join(GENOME, "index/genome.gtf")),
        bam = get_final_counts_input
    output:
        os.path.join(OUTPUT_DIR, "08_counts", "{lib_id}.tsv")
    params:
        strand = ("-s reverse" if LIB_STRAND == "fr_firststrand"
            else "-s yes" if LIB_STRAND == "fr_secondstrand"
            else "-s no"),
        region = ("exon" if RNA_TYPE != "ncrna" else "CDS")
    log:
        os.path.join(OUTPUT_DIR, "logs", "htseq.{lib_id}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "htseq.{lib_id}.txt")
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
# Rule: Run MultiQC to summarize QC and quantification
# ------------------------------------------------------------------------------
rule multiqc:
    input:
        PIPELINE_TARGETS
    output:
        os.path.join(OUTPUT_DIR, "multiqc_report.html")
    params:
        outdir = OUTPUT_DIR
    log:
        os.path.join(OUTPUT_DIR, "logs", "multiqc.log")
    conda: config["conda_env"]
    shell:
        """
        multiqc {params.outdir} -f -x logs -o {params.outdir} &> {log}
        """

# ==============================================================================
# End of pipeline definition
# ==============================================================================