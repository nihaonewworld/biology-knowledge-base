# ==============================================================================
# Example config (place in config.yaml)
# ==============================================================================
# input_dir: "01_fastq"
# output_dir: "02_output"
# genome: "~/reference/Mus_musculus/mm10"
# threads: 6

# is_rrbs: false

# trim_tool: "trim_galore"
# min_read_len: 36
# max_read_len: 
# adapters: 
# trim_params: 
# trim_NuGEN: false

# align_tool: "bismark"
# # bismark, bsmap
# align_params: 

# remove_dups: true
# output_no_cpg: false

# methylation_filter:
#   min_cov: 5

# conda_env: "ngstools"
# conda_py2: "py2"
# ------------------------------------------------------------------------------

# ==============================================================================
# Snakefile: WGBS / RRBS Snakemake Pipeline (V1)
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

IS_RRBS = config.get("is_rrbs", False)
TRIM_NUGEN = config.get("trim_NuGEN", False)
REMOVE_DUPS = config.get("remove_dups", False)

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
rule all:
    input:
        os.path.join(OUTPUT_DIR, "01_stats", "raw_reads.stats.tsv"),
        expand(os.path.join(OUTPUT_DIR, "02_clean", "{sample}_R1_fastqc.html"
            ), sample=SAMPLES),
        os.path.join(OUTPUT_DIR, "01_stats", "fragment_size.tsv"),
        expand(os.path.join(
            OUTPUT_DIR, "04_bismark", "{sample}.bismark.cov.gz"
            ), sample=SAMPLES),
        expand(os.path.join(
            OUTPUT_DIR, "04_bismark", "{sample}.CpG_report.merged_CpG_evidence.cov.gz"
            ), sample=SAMPLES),
        expand(os.path.join(
            OUTPUT_DIR, "04_bismark", "{sample}.CHG.gz.bismark.cov.gz"
            ), sample=SAMPLES) if config.get("output_no_cpg", False) else [],
        expand(os.path.join(
            OUTPUT_DIR, "04_bismark", "{sample}.CHH.gz.bismark.cov.gz"
            ), sample=SAMPLES) if config.get("output_no_cpg", False) else [],
        expand(os.path.join(OUTPUT_DIR, "05_bigwig", "{sample}.bw"
            ), sample=SAMPLES),
        expand(os.path.join(OUTPUT_DIR, "06_deeptools", "{sample}.TSS.png"
            ), sample=SAMPLES),
        expand(os.path.join(OUTPUT_DIR, "06_deeptools", "{sample}.Genebody.png"
            ), sample=SAMPLES),
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
            fq1 = temp(os.path.join(OUTPUT_DIR, "02_clean", 
                "{sample}_R1" + ("_trimmed" if TRIM_NUGEN else "") + ".fq.gz")),
            fq2 = temp(os.path.join(OUTPUT_DIR, "02_clean",
                "{sample}_R2" + ("_trimmed" if TRIM_NUGEN else "") + ".fq.gz"))
        params:
            adapters = config.get("adapters") or '',
            min_len = config.get("min_read_len", 36),
            max_len_arg = (
                f"--max_length {config.get('max_read_len')}" 
                if config.get("max_read_len") else ''),
            trim_params = config.get("trim_params") or '',
            rrbs = ("--rrbs" if IS_RRBS and not TRIM_NUGEN else ''),
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
                --length {params.min_len} {params.max_len_arg} {params.rrbs} \
                {params.trim_params} --basename {wildcards.sample} \
                -o {params.outdir} {input.fq1} {input.fq2} &> {log}

            mv {params.outdir}/{wildcards.sample}_val_1.fq.gz {output.fq1}
            mv {params.outdir}/{wildcards.sample}_val_2.fq.gz {output.fq2}
            """
else:
    raise ValueError(f"Unrecognized trim_tool '{TRIM_TOOL}' in config")

# ------------------------------------------------------------------------------
# Rule: NuMetRRBS
# Description: NuGEN library post-processing, trimming reads.
# ------------------------------------------------------------------------------
if TRIM_NUGEN:
    rule NuMetRRBS:
        input:
            fq1 = rules.trim_galore.output.fq1,
            fq2 = rules.trim_galore.output.fq2
        output:
            fq1 = temp(os.path.join(OUTPUT_DIR, "02_clean", "{sample}_R1.fq.gz")),
            fq2 = temp(os.path.join(OUTPUT_DIR, "02_clean", "{sample}_R2.fq.gz"))
        params:
            outdir = os.path.join(OUTPUT_DIR, "02_clean")
        log:
            os.path.join(OUTPUT_DIR, "logs", "NuMetRRBS.{sample}.log")
        benchmark:
            os.path.join(OUTPUT_DIR, "benchmark", "NuMetRRBS.{sample}.txt")
        conda:
            config["conda_py2"]
        shell:
            """
            python ~/software/NuGen/NuMetRRBS/trimRRBSdiversityAdaptCustomers.py \
                -1 {input.fq1} -2 {input.fq2} &> {log}

            mv {params.outdir}/{wildcards.sample}_R1_trimmed.fq_trimmed.fq.gz {output.fq1}
            mv {params.outdir}/{wildcards.sample}_R2_trimmed.fq_trimmed.fq.gz {output.fq2}
            """

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
# Rule: Bismark (bowtie2)
# Description: Align paired-end reads to the reference genome.
# ------------------------------------------------------------------------------
rule bismark_align:
    input:
        multiext(
            os.path.join(OUTPUT_DIR, "02_clean", "{sample}"), 
            fq1 = "_R1.fq.gz", fq2 = "_R2.fq.gz")
    output:
        temp(os.path.join(OUTPUT_DIR, "03_align", "{sample}_bismark_bt2_pe.bam"))
    params:
        index = os.path.join(GENOME, "index/bismark_index"),
        align_params = config.get("align_params") or '',
        outdir = os.path.join(OUTPUT_DIR, "03_align")
    log:
        os.path.join(OUTPUT_DIR, "logs", "bismark_align.{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "bismark_align.{sample}.txt")
    priority: 100
    threads: 12
    resources: mem_mb=40000
    conda: config["conda_env"]
    shell:
        """
        bismark --parallel 4 --bowtie2 --bam --nucleotide_coverage \
            --genome {params.index} --temp_dir {params.outdir} \
            {params.align_params} -1 {input.fq1} -2 {input.fq2} \
            -o {params.outdir} &> {log}

        for file in {params.outdir}/{wildcards.sample}*bismark*
        do
            new=$(sed -E 's/_R1//' <<< "$file")
            mv "$file" $new
        done
        """

# ------------------------------------------------------------------------------
# Rule: bismark_rmdup
# Description: Remove PCR duplicates.
# ------------------------------------------------------------------------------
rule bismark_rmdup:
    input:
        rules.bismark_align.output
    output:
        temp(os.path.join(OUTPUT_DIR, "03_align", "{sample}.deduplicated.bam"))
    params:
        outdir = os.path.join(OUTPUT_DIR, "03_align")
    log:
        os.path.join(OUTPUT_DIR, "logs", "bismark_rmdup.{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "bismark_rmdup.{sample}.txt")
    conda:
        config["conda_env"]
    shell:
        """
        deduplicate_bismark --bam --output_dir {params.outdir} \
            -o {wildcards.sample} {input} &> {log}
        """

# ------------------------------------------------------------------------------
# Rule: insert_sizes
# Description: Calculate and plot the fragment size distribution.
# ------------------------------------------------------------------------------
rule insert_sizes:
    input:
        expand(
            os.path.join(OUTPUT_DIR, "03_align", "{sample}.deduplicated.bam") if REMOVE_DUPS 
            else os.path.join(OUTPUT_DIR, "03_align", "{sample}_bismark_bt2_pe.bam"), 
            sample=SAMPLES)
    output:
        multiext(
            os.path.join(OUTPUT_DIR, "01_stats", "fragment_size"), 
            table = ".tsv", summary = ".summary.tsv", 
            plot = ".histogram.png")
    params:
        prefix = " ".join(SAMPLES),
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
            --outRawFragmentLengths {output.table} &> {log}
        """

# ------------------------------------------------------------------------------
# Rule: bismark_extractor
# Description: methylation extraction.
# ------------------------------------------------------------------------------
rule bismark_extractor:
    input:
        rules.bismark_rmdup.output if REMOVE_DUPS else rules.bismark_align.output
    output:
        cpg = os.path.join(OUTPUT_DIR, "04_bismark", "{sample}.bismark.cov.gz"),
        chg = os.path.join(OUTPUT_DIR, "04_bismark", "CHG_context_{sample}.txt.gz"),
        chh = os.path.join(OUTPUT_DIR, "04_bismark", "CHH_context_{sample}.txt.gz")
    params:
        index = os.path.join(GENOME, "index/bismark_index"),
        rrbs = (
            "--ignore 3 --ignore_r2 3 --ignore_3prime 2 --ignore_3prime_r2 2" 
            if IS_RRBS else ''),
        bufferSize = ("20G" if IS_RRBS else "60G"),
        outdir = os.path.join(OUTPUT_DIR, "04_bismark")
    log:
        os.path.join(OUTPUT_DIR, "logs", "bismark_extractor.{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "bismark_extractor.{sample}.txt")
    threads: 6
    conda:
        config["conda_env"]
    shell:
        """
        bismark_methylation_extractor --parallel 2 --paired-end \
            --comprehensive --no_overlap --bedGraph --counts \
            --gzip --buffer_size {params.bufferSize} \
            {params.rrbs} --genome_folder {params.index} \
            -o {params.outdir} {input} &> {log}

        for file in {params.outdir}/*{wildcards.sample}*
        do
            new=$(sed -E 's/\\.deduplicated//; s/_bismark_bt2_pe//' <<< "$file")
            mv "$file" $new
        done
        """

# ------------------------------------------------------------------------------
# Rule: bismark_mergeCpG
# Description: CpG aggregation
# ------------------------------------------------------------------------------
rule bismark_mergeCpG:
    input:
        rules.bismark_extractor.output.cpg
    output:
        os.path.join(
            OUTPUT_DIR, "04_bismark", 
            "{sample}.CpG_report.merged_CpG_evidence.cov.gz")
    params:
        index = os.path.join(GENOME, "index/bismark_index"),
        outdir = os.path.join(OUTPUT_DIR, "04_bismark")
    log:
        os.path.join(OUTPUT_DIR, "logs", "bismark_mergeCpG.{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "bismark_mergeCpG.{sample}.txt")
    threads: 1
    resources: mem_mb=4000
    conda:
        config["conda_env"]
    shell:
        """
        coverage2cytosine --merge_CpG --gzip --genome_folder {params.index} \
            --dir {params.outdir} -o {wildcards.sample} {input} &> {log}
        """

# ------------------------------------------------------------------------------
# Rule: bismark_extract_CH
# Description: 
# ------------------------------------------------------------------------------
rule bismark_extract_CHG:
    input:
        rules.bismark_extractor.output.chg
    output:
        os.path.join(OUTPUT_DIR, "04_bismark", "{sample}.CHG.gz.bismark.cov.gz")
    params:
        outdir = os.path.join(OUTPUT_DIR, "04_bismark")
    log:
        os.path.join(OUTPUT_DIR, "logs", "bismark2bedGraph_CHG.{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "bismark2bedGraph_CHG.{sample}.txt")
    threads: 1
    resources: mem_mb=4000
    conda:
        config["conda_env"]
    shell:
        """
        bismark2bedGraph --CX --buffer_size 60G --dir ${params.outdir} \
            -o {wildcards.sample}.CHG {input} &> {log}
        """

rule bismark_extract_CHH:
    input:
        rules.bismark_extractor.output.chh
    output:
        os.path.join(OUTPUT_DIR, "04_bismark", "{sample}.CHH.gz.bismark.cov.gz")
    params:
        outdir = os.path.join(OUTPUT_DIR, "04_bismark")
    log:
        os.path.join(OUTPUT_DIR, "logs", "bismark2bedGraph_CHH.{sample}.log")
    benchmark:
        os.path.join(OUTPUT_DIR, "benchmark", "bismark2bedGraph_CHH.{sample}.txt")
    threads: 1
    resources: mem_mb=4000
    conda:
        config["conda_env"]
    shell:
        """
        bismark2bedGraph --CX --buffer_size 60G --dir ${params.outdir} \
            -o {wildcards.sample}.CHG {input} &> {log}
        """

# ------------------------------------------------------------------------------
# Rule: bismark_cov_to_bw
# Description: Convert Bismark COV files to BigWig signal files.
# ------------------------------------------------------------------------------
rule bismark_cov_to_bw:
    input:
        cov = rules.bismark_mergeCpG.output,
        chrom_sizes = os.path.join(GENOME, "index/genome.chrom.sizes")
    output:
        os.path.join(OUTPUT_DIR, "05_bigwig", "{sample}.bw")
    params:
        min_cov = config.get("methylation_filter", {}).get("min_cov", 5),
        max_cov = config.get("methylation_filter", {}).get("max_cov", 99999999)
    threads: 4
    shell:
        """
        zcat {input.cov} | \
        awk -v min_c={params.min_cov} -v max_c={params.max_cov} \
            'BEGIN{{OFS="\\t"}} {{
                depth = $5 + $6; 
                if (depth >= min_c && depth <= max_c) 
                    print $1, $2, $3, $4
            }}' | \
        sort --parallel={threads} -k1,1 -k2,2n | \
        ~/software/ucsc/bedGraphToBigWig stdin {input.chrom_sizes} {output}
        """

# ------------------------------------------------------------------------------
# Rule: computeMatrix_TSS
# Description: Calculate bigWig enrichment scores around 
#   Transcription Start Sites (TSS) and plot heatmap.
# ------------------------------------------------------------------------------
rule computeMatrix_TSS:
    input:
        bw = rules.bismark_cov_to_bw.output,
        bed = os.path.join(GENOME, "protein_coding_genes.bed")
    output:
        multiext(
            os.path.join(OUTPUT_DIR, "06_deeptools", "{sample}"), 
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
        bw = rules.bismark_cov_to_bw.output,
        bed = os.path.join(GENOME, "protein_coding_genes.bed")
    output:
        multiext(
            os.path.join(OUTPUT_DIR, "06_deeptools", "{sample}"), 
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
        expand(os.path.join(
            OUTPUT_DIR, "04_bismark", "{sample}.bismark.cov.gz"
            ), sample=SAMPLES),
        expand(os.path.join(
            OUTPUT_DIR, "04_bismark", "{sample}.CpG_report.merged_CpG_evidence.cov.gz"
            ), sample=SAMPLES),
        expand(os.path.join(
            OUTPUT_DIR, "04_bismark", "{sample}.CHG.gz.bismark.cov.gz"
            ), sample=SAMPLES) if config.get("output_no_cpg", False) else [],
        expand(os.path.join(
            OUTPUT_DIR, "04_bismark", "{sample}.CHH.gz.bismark.cov.gz"
            ), sample=SAMPLES) if config.get("output_no_cpg", False) else [],
        expand(os.path.join(OUTPUT_DIR, "05_bigwig", "{sample}.bw"
            ), sample=SAMPLES),
        expand(os.path.join(OUTPUT_DIR, "06_deeptools", "{sample}.TSS.png"
            ), sample=SAMPLES),
        expand(os.path.join(OUTPUT_DIR, "06_deeptools", "{sample}.Genebody.png"
            ), sample=SAMPLES)
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