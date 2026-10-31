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
# min_read_len: 25
# max_read_len:
# adapters:
# trim_params:

# align_tool: "bowtie2"
# # bowtie2, bwa
# align_params: "--very-sensitive"

# filter_chrm: false
# remove_dups: true

# callpeak_tool:
#   - macs2
# callpeak_control: "input"
# macs_gsize: "mm"
# # hs, mm, 1.3e8
# macs_keepdup: "all"
# macs_qvalue: 0.01
# macs_model:
# # "--nomodel --shift -100 --extsize 200" # for -f BAM
# macs_bdg: false

# binSize: 10
# normalize: "RPKM"

# conda_env: "ngstools"
# ------------------------------------------------------------------------------

# ==============================================================================
# Snakefile: ChIP-seq Snakemake Pipeline (V1)
# ==============================================================================
# -*- coding: utf-8 -*-
import os
import re
from snakemake.utils import min_version
from snakemake.io import glob_wildcards, expand

min_version("9.6")
shell.executable("/bin/bash")

# ==============================================================================
# 1. Validate Configuration
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

# ==============================================================================
# 2. SAMPLE DETECTION & DYNAMIC PAIRING
# ==============================================================================
# Extract sample and library IDs from FASTQ files
LIB_IDS, = glob_wildcards(os.path.join(INPUT_DIR, "{lib_id}.fq.gz"))

if not LIB_IDS:
    raise ValueError(f"No FASTQ files detected in {INPUT_DIR}")

# Read control type from config.yaml (default: input, optional: igg)
PREFERRED_CTRL = config.get("callpeak_control", "input").lower()

# Build a mapping dictionary to track IP vs Input/IgG for each biological sample
SAMPLE_MAP = {}

for lib_id in LIB_IDS:
    lib_id_lower = lib_id.lower()
    
    if "input" in lib_id_lower:
        group = re.sub(r'_input$', '', lib_id, flags=re.IGNORECASE)
        if group not in SAMPLE_MAP:
            SAMPLE_MAP[group] = {"IP": [], "Input": [], "IgG": []}
        SAMPLE_MAP[group]["Input"].append(lib_id)
    
    elif "igg" in lib_id_lower:
        group = re.sub(r'_igg$', '', lib_id, flags=re.IGNORECASE)
        if group not in SAMPLE_MAP:
            SAMPLE_MAP[group] = {"IP": [], "Input": [], "IgG": []}
        SAMPLE_MAP[group]["IgG"].append(lib_id)

valid_groups = sorted(SAMPLE_MAP.keys(), key=len, reverse=True)

for lib_id in LIB_IDS:
    lib_id_lower = lib_id.lower()
    
    if "input" not in lib_id_lower and "igg" not in lib_id_lower:
        matched_group = None
        
        for group in valid_groups:
            if lib_id.startswith(group):
                matched_group = group
                break
                
        if matched_group:
            SAMPLE_MAP[matched_group]["IP"].append(lib_id)
        else:
            print(f"Warning: No matching Input/IgG found for IP: {lib_id}")
            fallback_group = re.split(r'_rep\d+', lib_id, flags=re.IGNORECASE)[0]
            if fallback_group not in SAMPLE_MAP:
                SAMPLE_MAP[fallback_group] = {"IP": [], "Input": [], "IgG": []}
            SAMPLE_MAP[fallback_group]["IP"].append(lib_id)

IP_LIB_IDS = []
for group, types in SAMPLE_MAP.items():
    IP_LIB_IDS.extend(types["IP"])

print(f"\n[Sample Pairing] Preferred Control Type: {PREFERRED_CTRL.upper()}")
for group, types in SAMPLE_MAP.items():
    print(f"Group: {group}")
    print(f"  Inputs: {types['Input']}")
    print(f"  IgGs:   {types['IgG']}")
    print(f"  IPs:    {types['IP']}")

# ==============================================================================
# 3. RULES DEFINITION
# ==============================================================================
TRIM_TOOL = config.get("trim_tool")
ALIGN_TOOL = config.get("align_tool")

TARGET_FASTQC = expand(
    os.path.join(OUTPUT_DIR, "02_clean", "{lib_id}_fastqc.html"), 
    lib_id=LIB_IDS
)

TARGET_PEAKS = []
TARGET_FRIP = []
TARGET_MOTIFS = []
SUPPORTED_CALLPEAK_TOOLS = ["macs2", "macs3"]

CALLPEAK_TOOL = config.get("callpeak_tool") or []
if isinstance(CALLPEAK_TOOL, str): 
    CALLPEAK_TOOL = [CALLPEAK_TOOL]


for tool in CALLPEAK_TOOL:
    tool = tool.strip().lower()
    if tool not in SUPPORTED_CALLPEAK_TOOLS:
        raise ValueError(
            f"Unsupported CALLPEAK_TOOL: '{tool}'. "
            f"Supported tools are {SUPPORTED_CALLPEAK_TOOLS}."
        )
    for ip_id in IP_LIB_IDS:
        if tool in ["macs2", "macs3"]:
            TARGET_PEAKS.append(os.path.join(
                OUTPUT_DIR, "05_peaks", f"{ip_id}_peaks.narrowPeak"))
            TARGET_FRIP.append(os.path.join(
                OUTPUT_DIR, "05_peaks", f"{ip_id}.frip.txt"))
            TARGET_MOTIFS.append(os.path.join(
                OUTPUT_DIR, "06_motif", ip_id))

PIPELINE_TARGETS = (
    [
        os.path.join(OUTPUT_DIR, "01_stats", "raw_reads.stats.tsv"),
        os.path.join(OUTPUT_DIR, "01_stats", "fragment_size.tsv"),
        os.path.join(OUTPUT_DIR, "01_stats", "fingerprint.tsv"),
        os.path.join(OUTPUT_DIR, "09_count", "bins_10kb.counts.tsv")
    ]
    + TARGET_FASTQC
    + TARGET_PEAKS
    + TARGET_FRIP
    + TARGET_MOTIFS
    + expand(os.path.join(
        OUTPUT_DIR, "07_bigwig", "{lib_id}.bw"), lib_id=LIB_IDS)
    + expand(os.path.join(
        OUTPUT_DIR, "08_deeptools", "{lib_id}.TSS.png"), lib_id=LIB_IDS)
    + expand(os.path.join(
        OUTPUT_DIR, "08_deeptools", "{lib_id}.Genebody.png"), lib_id=LIB_IDS)
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
        expand(os.path.join(INPUT_DIR, "{lib_id}.fq.gz"), lib_id=LIB_IDS)
    output:
        os.path.join(OUTPUT_DIR, "01_stats", "raw_reads.stats.tsv")
    threads: lambda wc: min(len(LIB_IDS), 6)
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
            os.path.join(INPUT_DIR, "{lib_id}.fq.gz")
        output:
            temp(os.path.join(OUTPUT_DIR, "02_clean", "{lib_id}.fq.gz"))
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
                --phred33 --gzip -q 20 --stringency 1 -e 0.1 \
                --length {params.min_len} {params.max_len_arg} \
                {params.trim_params} --basename {wildcards.lib_id} \
                -o {params.outdir} {input} &> {log}
            
            mv {params.outdir}/{wildcards.lib_id}_trimmed.fq.gz {output}
            """

# ------------------------------------------------------------------------------
# Rule: trimmomatic
# Description: Remove adapters and low-quality bases from reads.
# ------------------------------------------------------------------------------
elif TRIM_TOOL == "trimmomatic":
    rule trimmomatic:
        input:
            os.path.join(INPUT_DIR, "{lib_id}.fq.gz")
        output:
            temp(os.path.join(OUTPUT_DIR, "02_clean", "{lib_id}.fq.gz"))
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
            trimmomatic SE -phred33 -threads {threads} \
                -summary {params.summary} {input} {output} \
                ILLUMINACLIP:{params.adapters}:2:30:10 \
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
        os.path.join(OUTPUT_DIR, "02_clean", "{lib_id}.fq.gz")
    output:
        os.path.join(OUTPUT_DIR, "02_clean", "{lib_id}_fastqc.html")
    params:
        outdir = os.path.join(OUTPUT_DIR, "02_clean")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "fastqc.{lib_id}.txt")
    threads: 1
    conda: config["conda_env"]
    shell:
        """
        fastqc -t {threads} -q -o {params.outdir} {input}
        """

# ------------------------------------------------------------------------------
# Rule: bowtie2
# Description: Align paired-end reads to the reference genome.
# Align with high sensitivity, excluding mixed/discordant alignments
# ------------------------------------------------------------------------------
rule bowtie2:
    input:
        os.path.join(OUTPUT_DIR, "02_clean", "{lib_id}.fq.gz")
    output:
        bam = temp(os.path.join(OUTPUT_DIR, "03_align", "{lib_id}.bam")),
        bai = os.path.join(OUTPUT_DIR, "03_align", "{lib_id}.bam.bai"),
        stats = os.path.join(OUTPUT_DIR, "03_align", "{lib_id}.stats.txt"),
        idxstats = os.path.join(OUTPUT_DIR, "03_align", "{lib_id}.idxstats.txt")
    params:
        index = os.path.join(GENOME, "index/bowtie2_index/genome"),
        align_params = config.get("align_params") or '',
    log:
        os.path.join(OUTPUT_DIR, "03_align", "{lib_id}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "bowtie2.{lib_id}.txt")
    priority: 100
    threads: THREADS + 1
    conda: config["conda_env"]
    shell:
        """
        bowtie2 -p $(({threads} - 1)) {params.align_params} \
            -x {params.index} -U {input} 2> {log} | \
            samtools sort -@ 2 -o {output.bam}

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
        os.path.join(OUTPUT_DIR, "02_clean", "{lib_id}.fq.gz")
    output:
        bam = temp(os.path.join(OUTPUT_DIR, "03_bwa", "{lib_id}.bam")),
        bai = os.path.join(OUTPUT_DIR, "03_bwa", "{lib_id}.bam.bai"),
        stats = os.path.join(OUTPUT_DIR, "03_bwa", "{lib_id}.stats.txt"),
        idxstats = os.path.join(OUTPUT_DIR, "03_bwa", "{lib_id}.idxstats.txt")
    params:
        index = os.path.join(GENOME, "index/bwa_index/genome"),
        align_params = config.get("align_params") or '',
    log:
        os.path.join(OUTPUT_DIR, "03_bwa", "{lib_id}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "bwa.{lib_id}.txt")
    priority: 100
    threads: THREADS + 1
    conda: config["conda_env"]
    shell:
        """
        bwa mem -t $(({threads} - 1)) {params.align_params} \
            -M {params.index} {input} 2> {log} | \
            samtools sort -@ 2 -o {output.bam}

        samtools index {output.bam} {output.bai}
        samtools stats {output.bam} > {output.stats}
        samtools idxstats {output.bam} > {output.idxstats}
        """

# ------------------------------------------------------------------------------
if ALIGN_TOOL == "bowtie2":
    BAM = os.path.join(OUTPUT_DIR, "03_align", "{lib_id}.bam")
elif ALIGN_TOOL == "bwa":
    BAM = os.path.join(OUTPUT_DIR, "03_bwa", "{lib_id}.bam")
else:
    BAM = os.path.join(OUTPUT_DIR, "03_align", "{lib_id}.bam")

# ------------------------------------------------------------------------------
# Rule: samtools
# Description: Filter by mapQ, remove mitochondrial reads, and sort BAM files.
# ------------------------------------------------------------------------------
rule samtools:
    input:
        BAM
    output:
        bam = temp(os.path.join(
            OUTPUT_DIR, "04_bam", ".temp", "{lib_id}.filter.bam"))
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
        samtools view -q 30 -F 1804 -u {params.filter_expr} {input} 2> {log} | \
            samtools sort -@ 4 -o {output.bam} 2>> {log}
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
        expand(os.path.join(OUTPUT_DIR, "04_bam", "{lib_id}.bam"
            ), lib_id=LIB_IDS)
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
# Rule: fingerprint
# Description: 
# ------------------------------------------------------------------------------
rule fingerprint:
    input:
        expand(os.path.join(
            OUTPUT_DIR, "04_bam", "{lib_id}.bam"), lib_id=LIB_IDS)
    output:
        multiext(
            os.path.join(OUTPUT_DIR, "01_stats", "fingerprint"), 
            table = ".tsv", plot = ".png")
    params:
        prefix = LIB_IDS
    log:
        os.path.join(OUTPUT_DIR, "logs", "plotFingerprint.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "plotFingerprint.txt")
    threads: lambda wc: min(len(LIB_IDS), 6)
    conda: config["conda_env"]
    shell:
        """
        plotFingerprint -p {threads} --numberOfSamples 500000 \
            -b {input} --smartLabels --skipZeros \
            -T "Fingerprints of Different Library" \
            --plotFile {output.plot} \
            --outRawCounts {output.table} &> {log}
        """

# ------------------------------------------------------------------------------
def get_control_bams(wildcards):
    for group, types in SAMPLE_MAP.items():
        if wildcards.ip_id in types["IP"]:
            if PREFERRED_CTRL == "igg":
                ctrls = types["IgG"] if types["IgG"] else types["Input"]
            else:
                ctrls = types["Input"] if types["Input"] else types["IgG"]
            
            return [os.path.join(OUTPUT_DIR, "04_bam", f"{ctrl}.bam") for ctrl in ctrls]
    return []

# ------------------------------------------------------------------------------
# Rule: macs
# Description: Pairs specific IP library with its matching Input BAM.
# ------------------------------------------------------------------------------
rule macs:
    input:
        ip_bam = os.path.join(OUTPUT_DIR, "04_bam", "{ip_id}.bam"),
        input_bam = get_control_bams
    output:
        multiext(
            os.path.join(OUTPUT_DIR, "05_peaks", "{ip_id}"), 
            peaks = "_peaks.narrowPeak", summits = "_summits.bed")
    params:
        gsize = config.get("macs_gsize", "hs"),
        keepdup = config.get("macs_keepdup", "all"),
        qvalue = config.get("macs_qvalue", 0.01),
        model = config.get("macs_model") or '',
        bdg = ("-B" if config.get("macs_bdg", True) else ''),
        outdir = os.path.join(OUTPUT_DIR, "05_peaks")
    log:
        os.path.join(OUTPUT_DIR, "logs", "macs.{ip_id}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "macs.{ip_id}.txt")
    priority: 90
    conda: config["conda_env"]
    shell:
        """
        macs3 callpeak -f BAM --keep-dup {params.keepdup} -g {params.gsize} \
            -q {params.qvalue} --cutoff-analysis {params.bdg} {params.model} \
            -n {wildcards.ip_id} -t {input.ip_bam} -c {input.input_bam} \
            --outdir {params.outdir} &> {log}
        """

# ------------------------------------------------------------------------------
# Rule: frip_score
# Description: Calculate the Fraction of Reads in Peaks (FRiP) score.
# ------------------------------------------------------------------------------
rule frip_score:
    input:
        bam = os.path.join(OUTPUT_DIR, "04_bam", "{ip_id}.bam"),
        bed = os.path.join(OUTPUT_DIR, "05_peaks", "{ip_id}_peaks.narrowPeak")
    output:
        os.path.join(OUTPUT_DIR, "05_peaks", "{ip_id}.frip.txt")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "frip_score.{ip_id}.txt")
    conda: config["conda_env"]
    shell:
        """
        temp_bed=$(mktemp)
        awk 'BEGIN{{OFS="\\t"}} {{print $1, $2, $3}}' {input.bed} > $temp_bed

        TOTAL_READS=$(samtools view -c {input.bam})
        READS_IN_PEAKS=$(samtools view -c -L $temp_bed {input.bam})

        FRiP=$(awk -v rip="$READS_IN_PEAKS" -v tot="$TOTAL_READS" \
            'BEGIN {{printf "%.4f", rip/tot}}')

        echo -e "Sample\\tTotalReads\\tReadsInPeaks\\tFRiP" \
            > {output}
        echo -e "{wildcards.ip_id}\\t$TOTAL_READS\\t$READS_IN_PEAKS\\t$FRiP" \
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
        temp1 = temp(os.path.join(OUTPUT_DIR, "06_motif", "{ip_id}.temp1.bed")),
        temp2 = temp(os.path.join(OUTPUT_DIR, "06_motif", "{ip_id}.temp2.bed")),
        outdir = directory(os.path.join(OUTPUT_DIR, "06_motif", "{ip_id}"))
    log:
        os.path.join(OUTPUT_DIR, "logs", "homer.{ip_id}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "homer.{ip_id}.txt")
    threads: 4
    conda: config["conda_env"]
    shell:
        """
        bedtools intersect -v -a {input.bed} -b {input.blacklist} \
            > {output.temp1} 2> {log}
        
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
        bamCoverage -p {threads} -bs {params.binSize} --exactScaling \
            --normalizeUsing {params.normalize} \
            -b {input} -o {output} &> {log}
        """

# ------------------------------------------------------------------------------
# Rule: computeMatrix_TSS
# Description: Calculate bigWig enrichment scores around 
#   Transcription Start Sites (TSS) and plot heatmap.
# ------------------------------------------------------------------------------
rule computeMatrix_TSS:
    input:
        bw = os.path.join(OUTPUT_DIR, "07_bigwig", "{lib_id}.bw"),
        bed = os.path.join(GENOME, "protein_coding_genes.bed")
    output:
        multiext(
            os.path.join(OUTPUT_DIR, "08_deeptools", "{lib_id}"), 
            npz = ".TSS.gz", matrix = ".TSS.tsv", png = ".TSS.png")
    benchmark:
        os.path.join(
            OUTPUT_DIR, "benchmark", "computeMatrix_TSS.{lib_id}.txt")
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
        bw = os.path.join(OUTPUT_DIR, "07_bigwig", "{lib_id}.bw"),
        bed = os.path.join(GENOME, "protein_coding_genes.bed")
    output:
        multiext(
            os.path.join(OUTPUT_DIR, "08_deeptools", "{lib_id}"), 
            npz = ".Genebody.gz", matrix = ".Genebody.tsv", 
            png = ".Genebody.png")
    benchmark:
        os.path.join(
            OUTPUT_DIR, "benchmark", "computeMatrix_Genebody.{lib_id}.txt")
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
        expand(os.path.join(
            OUTPUT_DIR, "04_bam", "{lib_id}.bam"), lib_id=LIB_IDS)
    output:
        multiext(
            os.path.join(OUTPUT_DIR, "09_count", "bins_10kb"), 
            npz = ".npz", counts = ".counts.tsv", sf = ".scaleFactor.tsv")
    log:
        os.path.join(OUTPUT_DIR, "logs", "multiBamSummary_bins.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "multiBamSummary_bins.txt")
    threads: lambda wc: min(len(LIB_IDS), THREADS)
    conda: config["conda_env"]
    shell:
        """
        multiBamSummary bins -p {threads} -bs 10000 -b {input} \
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