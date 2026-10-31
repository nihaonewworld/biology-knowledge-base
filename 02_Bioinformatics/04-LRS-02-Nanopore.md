---
Title: Oxford Nanopore Sequencing
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2020-11-26
Modified: 2026-10-24
tags:
  - Nanopore
---
# 1. Introduction

## 1.1 Overview

> Oxford Nanopore has developed a new generation of DNA/RNA sequencing technology.

<figure style="text-align: center; margin: 2rem 0;">
    <!-- Embedded YouTube video container with responsive 16:9 aspect ratio -->
    <div style="position: relative; width: 100%; max-width: 725px; margin: 0 auto; padding-bottom: 56.25%; height: 0; overflow: hidden; border-radius: 8px;">
        <iframe 
            src="https://www.youtube-nocookie.com/embed/VxGliKyYuFQ" 
            title="How Oxford Nanopore sequencing works" 
            style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: 0;" 
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" 
            allowfullscreen>
        </iframe>
    </div>
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.75rem;">
        <strong>Video.</strong> How Oxford Nanopore sequencing works. 
        Video courtesy of <a href="https://nanoporetech.com" target="_blank" rel="noopener noreferrer">Oxford Nanopore Technologies</a> 
        (<a href="https://youtu.be/VxGliKyYuFQ" target="_blank" rel="noopener noreferrer">Watch on YouTube</a>).
    </figcaption>
</figure>

## 1.2 Principles

<figure style="text-align: center; margin: 2rem 0;">
    <img
        src="https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fs41587-021-01108-x/MediaObjects/41587_2021_1108_Fig1_HTML.png"
        alt="Principle of nanopore sequencing, showing nucleic acid translocation, ionic current detection, and MinION flow cell architecture"
        style="max-width: 100%; height: auto;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure 1.</strong> Principle of nanopore sequencing.<br>
        Source: <a href="https://doi.org/10.1038/s41587-021-01108-x" target="_blank" rel="noopener noreferrer">Wang <i>et al.</i>, 2021</a>, Figure 1.
    </figcaption>
</figure>

## 1.3. Nanopores

<figure style="text-align: center; margin: 2rem 0;">
    <img
        src="https://mdpi-res.com/d_attachment/micromachines/micromachines-14-00459/article_deploy/html/images/micromachines-14-00459-g001.png"
        alt="Structures of biological nanopores: MspA, alpha-hemolysin, aerolysin, OmpG, and CsgG–CsgF, highlighting pore architecture and constriction sites"
        style="max-width: 100%; height: auto;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure 2.</strong> Structural features of representative biological nanopores.
        (A) MspA; (B) α-hemolysin; (C) aerolysin; (D) OmpG; and
        (E) CsgG–CsgF with two constriction sites.<br>
        Reproduced from
        <a href="https://doi.org/10.3390/mi14020459" target="_blank" rel="noopener noreferrer">MacKenzie and Argyropoulos, 2023</a>,
        Figure 1.
    </figcaption>
</figure>

## 1.4. Applications

> 1. De novo genome assembly and genome finishing
> 2. Genetic variant detection: SNVs, Indels, and structural variants
> 3. Haplotype phasing and allele-specific analysis
> 4. DNA methylation and other base modification analysis
> 5. Transcript reconstruction and isoform identification
> 6. Gene and isoform expression analysis
> 7. Alternative splicing and fusion transcript detection
> 8. RNA modification and Poly(A) tail analysis
> 9. Single-cell isoform analysis
> 10. Rapid microbial identification and metagenomic profiling
> 11. Plasmid and extrachromosomal circular DNA characterization

## 1.5 Flow Cell Comparison Table

| Flow Cell Model          | Platform Compatibility              | Active Channels / Pores            | Typical Data Yield (DNA) | Typical Data Yield (Direct RNA) | Estimated Price (USD)* |
| :----------------------- | :---------------------------------- | :--------------------------------- | :----------------------- | :------------------------------ | :--------------------- |
| **Flongle Flow Cell**    | Flongle Adapter on MinION / GridION | 126 channels                       | Up to 1.8 – 2.6 Gb       | N/A *(Not supported for dRNA)*  | ~$90                   |
| **MinION Flow Cell**     | MinION, MinION Mk1C, GridION        | 512 channels<br>(~2,048 pores)     | 10 to 30 Gb              | 0.5 to 2 Gb                     | ~$700 – $840           |
| **PromethION Flow Cell** | PromethION 2 / 24 / 48              | ~3,000 channels<br>(~10,700 pores) | 100 to 300+ Gb           | 5 to 15+ Gb                     | ~$3,600 – $4,160       |
> Note:
> 1. Direct RNA sequencing inherently yields fewer Gigabases (Gb) than DNA sequencing. This is due to lower trans-pore translocation speed, molecular complexity, and the absence of PCR amplification.
> 2. Flow Cell Chemistry Compatibility
> 	- `R10.4.1` (`FLO-MIN114` / `FLO-PRO114M`) is used for DNA/cDNA sequencing.
> 	- `RNA004` (`FLO-MIN004RA` / `FLO-PRO004RA`) is specially engineered for Direct RNA sequencing.

---
# 2. Experimental Design

## 2.1 DNA Sequencing

> 1. Whole-genome sequencing
> 2. Targeted sequencing

## 2.2 RNA Sequencing

> 1. cDNA sequencing
> 2. Direct RNA sequencing (DRS)

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://advanced.onlinelibrary.wiley.com/cms/asset/7d26e73c-25e5-4b94-b1f9-250a5e843d48/ggn270011-fig-0002-m.jpg" 
        alt="Figure 2 from Wiley Advanced Science publication"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure 3.</strong> Overview of the experimental design and molecular mechanism. 
        Adapted from <a href="https://advanced.onlinelibrary.wiley.com" target="_blank" rel="noopener noreferrer">Wiley Online Library</a>.
    </figcaption>
</figure>

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://www.cell.com/cms/10.1016/j.molcel.2024.12.014/asset/9dc4018a-cd86-4f52-973d-09f11bb04e27/main.assets/gr2_lrg.jpg" 
        alt="Figure 2 from Molecular Cell publication (DOI: 10.1016/j.molcel.2024.12.014)"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure 4.</strong> Schematic representation of the mechanistic insights and pathways. 
        Adapted from <a href="https://doi.org/10.1016/j.molcel.2024.12.014" target="_blank" rel="noopener noreferrer">Molecular Cell (2024)</a>.
    </figcaption>
</figure>

---
# 3. Fundamentals

## 3.1 Data Format

> 1. [FAST5](https://github.com/nanoporetech/ont_fast5_api) is Oxford Nanopore Technologies’ legacy data format, built on **HDF5** and organized hierarchically. It can **store raw signal data and run metadata**, and some FAST5 files also contain basecalling results. FAST5 supports single-read and multi-read file layouts but is now deprecated.
>
> 2. [POD5 ](https://github.com/nanoporetech/pod5-file-format) is a data format developed by Oxford Nanopore Technologies for storing nanopore sequencing data. It stores **raw signal data and associated metadata** in tables based on **Apache Arrow**, enabling efficient data access. Compared with FAST5, POD5 files are typically smaller and faster to read. The format also supports **streaming writes**, allowing sequencing instruments to write data directly as sequencing proceeds.

## 3.2 Analysis Roadmap

> 1. [EPI2ME](https://epi2me.nanoporetech.com/) is an intuitive bioinformatics platform and desktop application developed by Oxford Nanopore Technologies, designed to **analyze nanopore sequencing data**. It **provides pre-configured workflows for various applications**—such as human genomics, metagenomics, and transcriptomics—enabling researchers to efficiently **process raw sequencing reads and generate interactive reports.** [GitHub](https://github.com/epi2me-labs)
>
> 2. Command-line bioinformatics tools for expert analysis.

# 4. Primary Processing

## 4.1 Basecalling

> Basecalling is the computational process of translating ionic current signals, recorded by a nanopore sequencing device, into nucleotide sequences (A, C, G, and T). These raw signal data are typically stored in POD5 or legacy FAST5 formats.

### [Dorado](https://github.com/nanoporetech/dorado)

> Dorado is a high-performance, easy-to-use, open source analysis engine for Oxford Nanopore reads.
> [Dorado Documentation](https://software-docs.nanoporetech.com/dorado/latest/)
> - POD5 formats (v2.1.2, 2026-08-26)
> - FAST5 formats (v0.9.6, 2025-04-17)

```shell
# List all available basecalling models
dorado download --list

# Download the specified model to the target directory
dorado download --model {input.model.id} --models-directory {output.dir}
```

```shell
# Simplex Basecalling
# Perform basecalling and write the output in BAM format
dorado basecaller {input.model} {input.pod5} > {output.bam}
# Perform basecalling with a minimum quality score and generate a sequencing summary
dorado basecaller {input.model} {input.pod5} \
	--min-qscore 10 --emit-summary -o {output.dir}
# Perform basecalling, align reads to the reference genome, and generate a sequencing summary
dorado basecaller {input.model} {input.pod5} \
	--reference {input.ref.fa} --mm2-opts {params.opts} \
	--min-qscore 10 --emit-summary -o {output.dir}
# Perform basecalling with modified base detection, align reads to the reference genome, and generate a sequencing summary
dorado basecaller {input.model} {input.pod5} \
	--reference {input.ref.fa} --mm2-opts {params.opts} \
	--modified-bases {params.modified} \
	--min-qscore 10 --emit-summary -o {output.dir}
# Example modified bases: m6A, 5mC

# Duplex Basecalling
dorado duplex {input.model} {input.pod5} > {output.bam}

# Common Options
# --device auto: Automatically select the compute device (CPU or GPU).
# --trim all: Trim all detected adapters, primers, and barcodes. (Default)
# --estimate-poly-a: Estimate the lengths of poly(A)/poly(T) tails.
# --min-qscore {int}: Discard reads with mean Q-score below this threshold.
```

### Others

> 1. [Guppy](https://github.com/nanoporetech/pyguppyclient) is a data processing toolkit that includes Oxford Nanopore Technologies' production basecalling algorithms and several bioinformatic post-processing features. This software is no longer supported (v6.5.7, 2023-11-15) and has been superseded by Dorado, Oxford Nanopore Technologies' next-generation basecalling software.
> 2. [Chiron](https://github.com/haotianteng/Chiron) is a deep learning-based basecalling tool for nanopore sequencing that uses a CNN–RNN–CTC architecture to perform end-to-end conversion of raw nanopore signals into nucleotide sequences.
> 3. [SACall](https://github.com/huangnengCSU/SACall-basecaller) is a neural network basecaller for Oxford Nanopore sequencing data based on self-attention mechanism.

## 4.2 Alignment

### [Minimap2](https://github.com/lh3/minimap2) (Dorado)

> Minimap2 is a versatile sequence alignment program that aligns DNA or mRNA sequences against a large reference database. Typical use cases include: (1) mapping PacBio or Oxford Nanopore genomic reads to the human genome; (2) finding overlaps between long reads with error rate up to ~15%; (3) splice-aware alignment of PacBio Iso-Seq or Nanopore cDNA or Direct RNA reads against a reference genome; (4) aligning Illumina single- or paired-end reads; (5) assembly-to-assembly alignment; (6) full-genome alignment between two closely related species with divergence below ~15%.
> 
> Dorado uses the `minimap2` aligner to align basecalled sequences to a reference and supports aligning existing basecalls or producing aligned output directly.

```shell
# Align reads to the reference and output alignments in PAF format (default)
minimap2 {input.ref.fa} {input.fq.gz} > {output.paf}

# Nanopore genomic reads (use ordinary minimizers as seeds)
minimap2 -a -x map-ont {input.ref.fa} {input.fq.gz} > {output.sam}
# PacBio CLR reads (use homopolymer-compressed minimizers as seeds)
minimap2 -a -x map-pb {input.ref.fa} {input.fq.gz} > {output.sam}
# Illumina Complete Long Reads (ICLR)
minimap2 -a -x map-iclr {input.ref.fa} {input.fq.gz} > {output.sam}

# PacBio Iso-Seq / conventional cDNA reads (high-quality spliced alignment)
minimap2 -a -x splice:hq -uf {input.ref.fa} {input.fq.gz} > {output.sam}
# Nanopore cDNA reads (spliced alignment)
minimap2 -a -x splice {input.ref.fa} {input.fq.gz} > {output.sam}
# Nanopore Direct RNA Sequencing (DRS; spliced alignment)
minimap2 -a -x splice -uf -k 14 {input.ref.fa} {input.fq.gz} > {output.sam}
# Align SIRV control reads using spliced alignment without splice-flank handling
minimap2 -a -x splice --splice-flank=no SIRV.fa SIRV-seq.fa > {output.sam}

# Convert the reference GTF annotation to BED format for splice-junction-aware alignment
paftools.js gff2bed {input.ref.gtf} > {output.junc.bed}
# Align Nanopore Direct RNA reads using annotated splice junctions
minimap2 -a -x splice -uf -k 14 --junc-bed {output.junc.bed} \
	{input.ref.fa} {input.fq.gz} > {output.sam}

# Generate a minimap2 genome index (optional; automatic indexing is available).
# Note: Indexing parameters (-k, -w, -H, -I) are fixed; different data types may require separate indexes.
# Therefore, generating an index separately is not recommended.
minimap2 -d {output.index.mmi} {input.ref.fa}
```

```shell
# Streamed output from dorado aligner is unsorted and must be sorted explicitly.
dorado aligner {input.ref.fa} {input.basecalls.bam} | \
	samtools sort -@ {threads} -o {output.aligned.bam} -

# Generate a sequencing summary from the aligned BAM file.
dorado summary {input.aligned.bam} > {output.aligned.summary.txt}

# Dorado automatically produces sorted BAM output when writing to a directory.
dorado aligner {input.ref.fa} {input.basecalls.bam} \
	-t {threads} --mm2-opts {params.opts} \
	--emit-summary -o {output.dir}

# DRS rRNA
dorado aligner {input.rRNA.fa} {input.basecalls.bam} \
	-t {threads} --mm2-opts "-x map-ont -k 14 -w 5" \
	--emit-summary -o {output.dir}
```

### Others

> 1. [ngmlr](https://github.com/philres/ngmlr): CoNvex Gap-cost alignMents for Long Reads (ngmlr) is a long-read mapper designed to sensitively align PacBio or Oxford Nanopore to (large) reference genomes. It was designed to quickly and correctly align the reads, including those spanning (complex) structural variations. (v0.2.7, 2018-06-05)

## 4.3 Quality Control

> 1. [minion_qc](https://github.com/roblanf/minion_qc): Fast and effective quality control for MinION and PromethION sequencing data. R script (v1.4.2, 2020-06-03)
> 2. [NanoPack](https://github.com/wdecoster/nanopack): Overview of my long read processing and analysis tools.
>     - [NanoPlot](https://github.com/wdecoster/NanoPlot): Plotting tool for long read sequencing data and alignments.
>     - [NanoComp](https://github.com/wdecoster/nanocomp): Compare multiple runs of long read sequencing data and alignments.
>     - [nanoQC](https://github.com/wdecoster/nanoQC): Quality control tools for long read sequencing data.
>     - [Cramino](https://github.com/wdecoster/cramino): A tool for quick quality assessment of cram and bam files, intended for long read sequencing.
>     - [chopper](https://github.com/wdecoster/chopper): Rust implementation of [NanoFilt](https://github.com/wdecoster/nanofilt)+[NanoLyse](https://github.com/wdecoster/nanolyse), filters and trims a fastq file.
>     - [phasius](https://github.com/wdecoster/phasius): A tool to visualize phase block structure from (many) BAM, CRAM or VCF files together with BED annotation.
>     - [kyber](https://github.com/wdecoster/kyber): Tool to quickly make a minimalistic 600x600 pixels heatmap image of read length (log-transformed) and read accuracy.
>     - etc.
> 3. [Filtlong](https://github.com/rrwick/filtlong) is a tool for filtering long reads by quality. (v0.3.1, 2025-09-17)
> 4. [pycoQC](https://github.com/a-slide/pycoQC): pycoQC computes metrics and generates interactive QC plots for Oxford Nanopore technologies sequencing data.  (v2.5.2, 2020-12-17)
> 5. [NanoPlot](https://github.com/wdecoster/NanoPlot): Plotting tool for long read sequencing data and alignments.
> 6. [fastpLong](https://github.com/OpenGene/fastpLong): Ultrafast preprocessing and quality control for long reads (Nanopore, PacBio, Cyclone, etc.).

```shell
conda install -c conda-forge -c bioconda fastplong nanoplot

# NanoPlot
NanoPlot --summary {input.sequencing_summary.txt} --loglength \
	--dpi 300 -o {output.dir} -p {params.prefix}

# fastplong
samtools fastq -@ {threads} {input.basecalls.bam} | \
	pigz -p {threads} > {output.fq.gz}
samtools fastq -@ {threads} -F 0x900 \
	-0 {output.fq.gz} {input.aligned.bam}

fastplong -w {threads} -A -Q -L -i {input.fq.gz} \
	--ont_summary {input.sequencing_summary.txt} \
	-h {output.report.html} -j {output.report.json}
```

# 5. DNA Sequencing Analysis
## 5.1 Genome Assembly

### 5.1.1 De Nove Assembly

#### a). [Canu](https://github.com/marbl/canu)

> Canu is a fork of the Celera Assembler, designed for high-noise single-molecule sequencing (such as the PacBio or Oxford Nanopore). Canu has reached END OF LIFE (v2.3, 2024-12-18)

```shell
samtools fastq {input.bam} > {output.fq}

# Nanopore
canu -p ecoli -d ecoli-oxford genomeSize=4.8m maxInputCoverage=100 \
   -nanopore {input.fq}
```

#### b). [Flye](https://github.com/mikolmogorov/Flye)

> Flye is a de novo assembler for single-molecule sequencing reads, such as those produced by PacBio and Oxford Nanopore Technologies. It is designed for a wide range of datasets, from small bacterial projects to large mammalian-scale assemblies. The package represents a complete pipeline: it takes raw PacBio / ONT reads as input and outputs polished contigs. (v2.9.6, 2025-05-03)

```shell
# Nanopore
flye --threads {threads} --nano-raw {input.fq} --out-dir {output.dir}
```

#### c). [Hifiasm](https://github.com/chhylp123/hifiasm)

> Hifiasm is a fast haplotype-resolved de novo assembler initially designed for PacBio HiFi reads. Its latest release could support the telomere-to-telomere assembly by utilizing ultralong Oxford Nanopore reads.

```shell
# Nanopore
hifiasm -t {threads} --ont -o {output.prefix} {input.fq}
```

#### Others

> 1. [Verkko](https://github.com/marbl/verkko) is a hybrid genome assembly pipeline developed for telomere-to-telomere assembly of accurate long reads (PacBio HiFi, Oxford Nanopore Duplex, [HERRO](https://github.com/lbcb-sci/herro) or [Hifiasm](https://github.com/chhylp123/hifiasm) corrected Oxford Nanopore Simplex) and Oxford Nanopore ultra-long reads.
> 2. [Miniasm](https://github.com/lh3/miniasm) is a very fast OLC-based *de novo* assembler for noisy long reads. (v0.3, 2024-06-24)
> 3. [SMARTdenovo](https://github.com/ruanjue/smartdenovo) is a *de novo* assembler for PacBio and Oxford Nanopore data. (v, 2018)
> 4. [Wtdbg2](https://github.com/ruanjue/wtdbg2) is a *de novo* sequence assembler for long noisy reads produced by PacBio or Oxford Nanopore Technologies (v2.5, 2019-09-13)
> 5. [NextDenovo](https://github.com/nextomics/nextdenovo) is a string graph-based *de novo* assembler for long reads. (v2.5.2, 2023-05-17)

### 5.1.2 Assembly Polishing

#### a). [Medaka](https://github.com/nanoporetech/medaka)

> `medaka` is a tool to create consensus sequences and variant calls from nanopore sequencing data. This task is performed using neural networks applied a pileup of individual sequencing reads against a reference sequence, mostly commonly either a draft assembly or a database reference sequence.

```shell
medaka_consensus -i {input.basecalls.fq} -d {input.assembly.draft.fa} \
	-o {output.dir} >{log}
```
#### b). Dorado Polish

> Dorado `polish` is a high accuracy assembly polishing tool which outperforms similar tools for most ONT-based assemblies.
> [Medaka](https://github.com/nanoporetech/medaka) and Dorado `polish` are both assembly polishing tools. They accept the same input formats and produce the same output formats, and in principle they could run the same polishing model to produce equivalent results. However, Dorado `polish` is optimized for higher performance, and can support more accurate models with more computationally intensive architectures. For use cases in low-resource settings (small genomes such as bacteria with CPUs only available) Medaka remains the recommended tool. For large genomes or in other instances where speed is important, we suggest trying Dorado `polish`.
#### Others

> 1. [Nanopolish](https://github.com/jts/nanopolish): Software package for signal-level analysis of Oxford Nanopore sequencing data. Nanopolish can calculate an improved consensus sequence for a draft genome assembly, detect base modifications, call SNPs and indels with respect to a reference genome. (v, 2023)
> 2. [NextPolish](https://github.com/Nextomics/NextPolish): NextPolish is used to fix base errors (SNV/Indel) in the genome generated by noisy long reads, it can be used with short read data only or long read data only or a combination of both. (v1.4.1, 2022-07-07)
> 3. [Pilon](https://github.com/broadinstitute/pilon): Automatically improve draft assemblies, find variation among strains, including large event detection. (v1.24, 2021-01-29)
> 4. [Racon](https://github.com/lbcb-sci/racon): Consensus module for raw de novo DNA assembly of long uncorrected reads. (v1.5.0, 2021-12-20)

### 5.1.3 Evaluate Assembly

> 1. [QUAST](https://github.com/ablab/quast): QUAST stands for QUality ASsessment Tool. It evaluates genome/metagenome assemblies by computing various metrics. (v5.3.0, 2024-11-10)
> 2. [BUSCO](https://gitlab.com/ezlab/busco): Assessing genome assembly and annotation completeness with single-copy orthologs. (v6.0.0, 2025-08-01)
> 3. [MUMmer](https://github.com/mummer4/mummer) is a versatile alignment tool for DNA and protein sequences. (v4.0.1, 2025-02-04)
> 4. [dotPlotly](https://github.com/tpoorten/dotPlotly): Create an interactive dot plot from mummer output OR PAF format. R script (v, 2018)
> 5. [BRIG](https://github.com/happykhan/BRIG) (BLAST Ring Image Generator) is a cross-platform (Windows/Mac/Linux) application that displays circular comparison images of multiple genomes using BLAST. It is designed to handle genome assembly data and can show similarity, coverage, annotations and more as concentric rings around a reference sequence. (GUI, v1.0.0, 2026-02-23)

### 5.1.4 Genome Annotation
## 5.2 Variant Detection

### a). [Longshot](https://github.com/pjedge/longshot)

> Longshot is a variant calling tool for diploid genomes using long error prone reads such as Pacific Biosciences (PacBio) SMRT and Oxford Nanopore Technologies (ONT). (v1.0.0, 2024-05-16)

### b). [Medaka](https://github.com/nanoporetech/medaka)

```shell
python medaka tools get_alignment_params \
	--model r941_min_hac_g507_model.tar.gz

python medaka tools list_models

bash medaka_consensus -i final_reads.fa -d reference_regions.fa \
	-o medaka_consensus -m r941_min_hac_g507
```

### Other

> 1. [Sniffles](https://github.com/fritzsedlazeck/Sniffles): A fast structural variant caller for long-read sequencing, Sniffles2 accurately detect SVs on germline, somatic and population-level for PacBio and Oxford Nanopore read data. (v2.7.3, 2026-03-01)
> 2. [NanoSV](https://github.com/mroosmalen/nanosv): NanoSV is a software package that can be used to identify structural genomic variations in long-read sequencing data. (v, 2019-04-09)

## 5.3 DNA Modifications

### a). [Remora](https://github.com/nanoporetech/remora)

> Remora models predict methylation/modified base status separated from basecalling. (v3.2.0, 2024-05-21)

### b). [Tombo](https://github.com/nanoporetech/tombo)

> Tombo is a suite of tools primarily for the identification of modified nucleotides from nanopore sequencing data. (v, 2020-02-20)

## 5.4 Other

### 5.4.1 Extrachromosomal Circular DNA

> [CReSIL](https://github.com/visanuwan/cresil): Accurate Identification of Extrachromosomal Circular DNA from Long-read Sequences.

### 5.4.2 Plasmids

### 5.4.3 Microbial Genomes

### 5.4.4 Metagenomics

---

# 6. RNA Sequencing Analysis

> 1. Transcript reconstruction and isoform identification
> 2. Gene and isoform quantification
> 3. Alternative splicing
> 4. Fusion transcript detection
> 5. Poly(A) tail length (direct RNA)
> 6. RNA Modifications (direct RNA)
## 6.1 Transcript Structure & Quantification

### a) [Bambu](https://github.com/goekelab/bambu)

> bambu is a R package for multi-sample transcript discovery and quantification using long read RNA-Seq data. You can use bambu after read alignment to obtain expression estimates for known and novel transcripts and genes. The output from bambu can directly be used for visualization and downstream analysis such as differential gene expression or transcript usage.
> 
> - Chen, Y., Sim, A., Wan, Y.K. _et al._ Context-aware transcript quantification from long-read RNA-seq data with Bambu. _Nat Methods_ **20**, 1187–1195 (2023). https://doi.org/10.1038/s41592-023-01908-w.

```R
library(bambu)
```

### b). [IsoQuant](https://github.com/ablab/Isoquant)

> IsoQuant is a tool for the genome-based analysis of long RNA reads, such as PacBio or Oxford Nanopores.
> 1. Quantification
> 2. Isoform and gene discovery
> 3. Single-cell and spatial transcriptomic analysis
> - Prjibelski, A.D., Mikheenko, A., Joglekar, A. _et al._ Accurate isoform discovery with IsoQuant using long reads. _Nat Biotechnol_ **41**, 915–918 (2023). https://doi.org/10.1038/s41587-022-01565-y.

```shell
conda install -c bioconda isoquant

# Nanopore cDNA reads
isoquant -t {threads} --data_type nanopore \
	--reference {input.ref.fa} --genedb {input.ref.gtf} --complete_genedb \
	--bam {input.aligned.bam} --sqanti_output \
	--report_novel_unspliced true \
	-o {output.dir} --prefix {params.prefix}

# Nanopore Direct RNA stranded reads
isoquant -t {threads} --data_type nanopore --stranded forward \
	--reference {input.ref.fa} --genedb {input.ref.gtf} --complete_genedb \
	--bam {input.aligned.bam} --sqanti_output \
	--report_novel_unspliced true \
	-o {output.dir} --prefix {params.prefix}

# --fastq {input.fq.gz}
# --bam {input.aligned.bam}
# --unmapped_bam {input.basecalls.bam}
```

### c). [StringTie](https://github.com/gpertea/stringtie)

> Stringtie employs efficient algorithms for transcript structure recovery and abundance estimation from bulk RNA-Seq reads aligned to a reference genome.
> 
> - Kovaka, S., Zimin, A.V., Pertea, G.M. _et al._ Transcriptome assembly from long-read RNA-seq alignments with StringTie2. _Genome Biol_ **20**, 278 (2019). https://doi.org/10.1186/s13059-019-1910-1.
> - Shinder, I., Pertea, G., Hu, R. _et al._ StringTie3 improves total RNA-seq assembly by resolving nascent and mature transcripts. _Nat Methods_ **23**, 1126–1137 (2026). https://doi.org/10.1038/s41592-026-03080-3.

### d). [SQANTI3](https://github.com/ConesaLab/SQANTI3)

> SQANTI3 tool is designed to enable **quality control and filtering** of long read-defined transcriptomes, which are often rich in artifacts and false-positive isoforms.
> 
> - Pardo-Palacios, F.J., Arzalluz-Luque, A., Kondratova, L. et al. SQANTI3: curation of long-read transcriptomes for accurate identification of known and novel isoforms. Nat Methods 21, 793–797 (2024). https://doi.org/10.1038/s41592-024-02229-2.

```shell

```

### e). [FLAIR](https://github.com/BrooksLabUCSC/flair)

> FLAIR (Full-Length Alternative Isoform analysis of RNA) for the correction, isoform definition, and alternative splicing analysis of noisy reads. FLAIR has primarily been used for nanopore cDNA, native RNA, and PacBio sequencing reads.
> 
> - Tang, A.D., Soulette, C.M., van Baren, M.J. _et al._ Full-length transcript characterization of _SF3B1_ mutation in chronic lymphocytic leukemia reveals downregulation of retained introns. _Nat Commun_ **11**, 1438 (2020). https://doi.org/10.1038/s41467-020-15171-6.

### Others

> 1. [TALON](https://github.com/mortazavilab/TALON) is a Python package for identifying and quantifying known and novel genes/isoforms in long-read transcriptome data sets. 
> 	- Dana Wyman, Gabriela Balderrama-Gutierrez, et al. A technology-agnostic long-read analysis pipeline for transcriptome discovery and quantification. bioRxiv 672931; doi: https://doi.org/10.1101/672931.
> 2. etc.

## 6.2 RNA Modifications

> Across RNA002 and RNA004 datasets, m⁶A detection tools generally achieved high accuracy in biological samples, whereas non-m⁶A tools struggled with precision–recall balance, quantification accuracy, and biological validity. Retraining with combined in vitro transcription and biological data improved accuracy and generalizability, particularly for Ψ, m⁵C, and A-to-I editing. Nevertheless, reliable discrimination between modification types at single-base resolution remains a key challenge. ([Luo et al., 2026](https://doi.org/10.1038/s41592-025-02974-y))

### a). [Dorado](https://github.com/nanoporetech/dorado) & [Modkit](https://github.com/nanoporetech/modkit)

> Modkit is a bioinformatics tool for working with modified bases from Oxford Nanopore. It is specifically designed to quickly convert modBAM to bedMethyl files using best practices, and it also supports manipulating modBAM files and generating summary statistics.

```shell
# Nanopore Direct RNA Sequencing (DRS; spliced alignment)
dorado basecaller {input.model} {input.pod5} \
	--models-directory {parmas.models.dir} \
	--modified-bases {params.modified} \
#	--modified-bases-models {input.m6A.model},{input.m5C.model} \
	--emit-summary \
	--estimate-poly-a \
	--reference {input.ref.fa} \
	--mm2-opts "-x splice -k 14 --junc-bed {input.junc.bed}" \
	-o {output.dir}
```

```shell
conda install nanoporetech::modkit

# Constructing bedMethyl tables
modkit pileup {input.aligned.bam} {output.bed.gz} \
	-t {thread} --reference {input.ref.fa} --header --bgzf \
	--modified-bases m6A m5C pseU --log {log}
```

### b). [m6Anet](https://github.com/GoekeLab/m6anet)

> m6Anet is a python tool that leverages Multiple Instance Learning framework to detect m6A modifications from Nanopore Direct RNA Sequencing data. 
> - Hendra, C., Pratanwanich, P.N., Wan, Y.K. _et al._ Detection of m6A from direct RNA sequencing using a multiple instance learning framework. _Nat Methods_ **19**, 1590–1598 (2022). https://doi.org/10.1038/s41592-022-01666-1.

```shell
conda install -c bioconda m6anet
# python >=3.7,<3.9

# Align raw nanopore signals to reference positions and generate event-level data.
nanopolish eventalign --threads {threads} \
    --scale-events --signal-index --genome {input.ref.fa} \
    --reads {input.basecalls.fq} --bam {input.aligned.bam} \
    --summary {output.summary.txt} > {output.eventalign.txt}

# Prepare event-level data for m6A detection with m6Anet.
m6anet dataprep --n_processes {threads} \
    --eventalign {input.eventalign.txt} \
    --out_dir {output.dataprep.dir}

# Predict m6A sites using a pretrained model (default: Hct116_RNA002).
m6anet inference --n_processes {threads} \
    --num_iterations 1000 \
    --input_dir {input.dataprep.dir} \
    --out_dir {output.inference.dir}

# Available pretrained models (specify with --pretrained_model):
# Hct116_RNA002      - HCT116 cells, Nanopore RNA002 (default)
# HEK293T_RNA004     - HEK293T cells, Nanopore RNA004
# arabidopsis_RNA002 - Arabidopsis, Nanopore RNA002
```

### c). [m5Cnet](https://github.com/xuzhBioinfor/Detecting-m5C-sites-using-Nanopore-direct-RNA-sequencing)

> m5Cnet is a computational framework for detecting and quantifying m5C modifications in the host transcriptome.
> - Zihe Xu, Xiaoqi Zheng, et al. Microbiome-induced reprogramming in post-transcriptional landscape using nanopore direct RNA sequencing. Cell Reports, Volume 43, Issue 10, 2024, 114798, ISSN 2211-1247, https://doi.org/10.1016/j.celrep.2024.114798.

```shell
# Extract features for candidate sites.
python data.prep -t {threads} --n_neighbor 1 --min_reads 20 \
	-i {eventalgin.txt} -o {output.prep.dir}

# Predict m5C sites and estimate methylation ratios and probabilities.
python inference.py -i {output.prep.dir} -o {output.inference.dir}
```

### Others
> 1. [EpiNano](https://github.com/novoalab/EpiNano): Detection of RNA modifications (m6A) from Oxford Nanopore direct RNA sequencing reads.
> 	- Liu, H., Begik, O., Lucas, M.C. et al. Accurate detection of m6A RNA modifications in native RNA sequences. Nat Commun 10, 4079 (2019). https://doi.org/10.1038/s41467-019-11713-9.
> 2. [Eligos2](https://gitlab.com/piroonj/eligos2) is developed to identify the position of modification on the native RNA sequences from the distinction of error at specific base (ESB) between the native RNA sequences with the reference.
> 	- Piroon J., Thidathip W., et al. Decoding the epitranscriptional landscape from native RNA sequences, Nucleic Acids Research, Volume 49, Issue 2, 25 January 2021, Page e7, https://doi.org/10.1093/nar/gkaa620.
> 3. etc.

## 6.3 Single-cell Sequencing

---
# Database

> 1. [DirectRMDB](https://www.rnamd.org/directRMDB/index.html) is the first ONT-based quantitative RNA modification database, featuring 904,712 sites across 16 types and 25 species from 39 studies. Yuxin Zhang, Daiyun Huang, Zhen Wei, Kunqi Chen, Primary sequence-assisted prediction of m6A RNA methylation sites from Oxford nanopore direct RNA sequencing data, Methods, Volume 203, 2022, Pages 62-69, ISSN 1046-2023, https://doi.org/10.1016/j.ymeth.2022.04.003.

---
# Reference

> 1. [The discovery of nanopore sequencing technology](https://www.whatisbiotechnology.org/index.php/science/summary/nanopore/nanopore-sequencing-makes-it-possible-to-decode-the)
> 2. Wang, Y., Zhao, Y., Bollas, A. _et al._ Nanopore sequencing technology, bioinformatics and applications. _Nat Biotechnol_ **39**, 1348–1365 (2021). https://doi.org/10.1038/s41587-021-01108-x.
> 3. Y. Liu, Y. Li, and Q. Sun, “ _Advances in Detecting RNA Modifications Using Direct RNA Nanopore Sequencing_.” _Advanced Genetics_ 6, no. 4 (2025): e00041. [https://doi.org/10.1002/ggn2.202500041](https://doi.org/10.1002/ggn2.202500041).
> 4. Diensthuber G, Novoa E. Charting the epitranscriptomic landscape across RNA biotypes using native RNA nanopore sequencing. Molecular Cell, 85, 276-289. https://doi.org/10.1016/j.molcel.2024.12.014.
> 5. Luo, T., Xu, M., Wang, M. _et al._ Systematic evaluation of computational tools for multitype RNA modification detection using nanopore direct RNA sequencing. _Nat Methods_ **23**, 438–450 (2026). https://doi.org/10.1038/s41592-025-02974-y.
> 6. Pardo-Palacios, F.J., Wang, D., Reese, F. _et al._ Systematic assessment of long-read RNA-seq methods for transcript identification and quantification. _Nat Methods_ **21**, 1349–1363 (2024). https://doi.org/10.1038/s41592-024-02298-3.
