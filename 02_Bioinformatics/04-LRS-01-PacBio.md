---
Title: PacBio SMRT Sequencing
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2021-01-07
Modified: 2026-10-24
tags:
  - PacBio
---
# 1. Introduction

## 1.1 Overview

> Single Molecule, Real-Time (SMRT) sequencing from Pacific Biosciences (PacBio).
> - John Eid _et al., Real-Time DNA Sequencing from Single Polymerase Molecules._Science_**323**,133-138(2009).DOI:[10.1126/science.1162986](https://doi.org/10.1126/science.1162986)

<figure style="text-align: center; margin: 2rem 0;">
    <!-- Embedded YouTube video container with responsive 16:9 aspect ratio -->
    <div style="width: 100%; max-width: 725px; margin: 0 auto;">
        <div style="position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; border-radius: 8px;">
            <iframe
                src="https://www.youtube-nocookie.com/embed/7yYPHatccgw"
                title="PacBio sequencing: how it works"
                style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: 0;"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                allowfullscreen>
            </iframe>
        </div>
    </div>
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.75rem;">
        <strong>Video.</strong> PacBio sequencing: how it works.
        Video courtesy of
        <a href="https://www.pacb.com/videos/pacbio-sequencing-how-it-works/"
           target="_blank" rel="noopener noreferrer">PacBio</a>
        (<a href="https://youtu.be/7yYPHatccgw"
            target="_blank" rel="noopener noreferrer">Watch on YouTube</a>).
    </figcaption>
</figure>

## 1.2 Principle

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://www.jstage.jst.go.jp/article/biophysico/19/0/19_e190032/_html/-char/Graphics/19ie32f2.jpg" 
        alt="Principles of PacBio SMRT sequencing and modified-base detection"
        style="max-width: 100%; height: auto;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure 1.</strong> Principles of PacBio SMRT sequencing and IPD-based modification detection. 
        Source: <a href="https://doi.org/10.2142/biophysico.bppb-v19.0032" target="_blank" rel="noopener noreferrer">Iizuka et al. (2022)</a>, <i>Biophysics and Physicobiology</i>.
    </figcaption>
</figure>

## 1.3 Zero-Mode Waveguide (ZMW)

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://ars.els-cdn.com/content/image/1-s2.0-S0167779908002047-gr3.jpg" 
        alt="Zero-Mode Waveguide (ZMW) structure and single-molecule real-time sequencing mechanism"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure 2.</strong> Structure of Zero-Mode Waveguides (ZMWs) and the detection volume in real-time DNA sequencing. 
        Adapted from <a href="https://doi.org/10.1016/j.tibtech.2008.08.004" target="_blank" rel="noopener noreferrer">Trends in Biotechnology (2008)</a>.
    </figcaption>
</figure>

## 1.4 Sequencing Mode

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://biobasic-asia.com/wp-content/uploads/2022/10/Iso-Sequencing-on-PacBio-IMAGE.png" 
        alt="Workflow of PacBio Isoform Sequencing (Iso-Seq) for full-length transcript profiling"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure 3.</strong> Workflow of PacBio Isoform Sequencing (Iso-Seq) for full-length transcriptome profiling. 
        Source: <a href="https://biobasic-asia.com" target="_blank" rel="noopener noreferrer">Bio Basic Asia</a>.
    </figcaption>
</figure>

### 1.4.1 CCS

> Circular Consensus Sequencing (CCS) sequences the same circular DNA template multiple times to generate multiple reads of the same sequence and produces a highly accurate consensus sequence. The subreads from multiple passes are combined to produce a consensus sequence. CCS is used to produce High-Fidelity (HiFi) reads that provide high-accuracy, long-read data. It uses smaller DNA inserts to assemble into SMRTbell templates, which allows the polymerase to make multiple passes through the template. CCS is used to enhance the accuracy of sequencing by generating a highly accurate consensus sequence.
> - Kevin J. Travers, Chen-Shan Chin, David R. Rank, John S. Eid, Stephen W. Turner, A flexible and efficient template format for circular consensus sequencing and SNP detection, _Nucleic Acids Research_, Volume 38, Issue 15, 1 August 2010, Page e159, [https://doi.org/10.1093/nar/gkq543](https://doi.org/10.1093/nar/gkq543).
> - Wenger, A.M., Peluso, P., Rowell, W.J. _et al._ Accurate circular consensus long-read sequencing improves variant detection and assembly of a human genome. _Nat Biotechnol_ **37**, 1155–1162 (2019). https://doi.org/10.1038/s41587-019-0217-9.

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://cdn-ileaamc.nitrocdn.com/saCGjhfsnHihUCILLZSxgfOXwdfXxtMy/assets/images/source/rev-f409d61/www.pacb.com/wp-content/uploads/HiFi-reads-img.svg" 
        alt="PacBio HiFi reads generation mechanism through circular consensus sequencing"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure 4.</strong> Generation of high-accuracy PacBio HiFi reads via Circular Consensus Sequencing (CCS). 
        Source: <a href="https://www.pacb.com" target="_blank" rel="noopener noreferrer">Pacific Biosciences (PacBio)</a>.
    </figcaption>
</figure>

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://ccs.how/img/ccs-workflow.png" 
        alt="Workflow diagram of Circular Consensus Sequencing (CCS)"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure 5.</strong> Circular Consensus Sequencing (CCS) workflow. 
        Source: <a href="https://ccs.how" target="_blank" rel="noopener noreferrer">CCS.how</a>.
    </figcaption>
</figure>

### 1.4.2 CLRs

> Continuous Long Reads (CLRs) are the raw, unprocessed reads generated from single-pass sequencing of circular DNA templates in PacBio sequencing. They provide long read lengths but may have higher error rates. CLRs are generated by using DNA inserts of large size to construct SMRTbell templates. Due to the large insert size, the polymerase makes only one pass through the template.

## 1.5 Applications

> 1. De novo genome assembly and genome finishing
> 2. Genetic variant detection: SNVs, Indels, and structural variants
> 3. Haplotype phasing and allele-specific analysis
> 4. DNA methylation and other base modification analysis
> 5. Transcript reconstruction and isoform identification
> 6. Gene and isoform expression analysis
> 7. Alternative splicing and fusion transcript detection
> 8. Single-cell isoform analysis
> 9. Rapid microbial identification and metagenomic profiling
> 10. Plasmid and extrachromosomal circular DNA characterization

## 1.6 PacBio Sequencing Systems

> 1. 2011, PacBio RS
> 2. 2013, PacBio RS II
> 3. 2015, Sequel
> 4. 2019, Sequel II
> 5. 2020, Sequel IIe
> 6. ...

---
# 2. Experimental Design

## 2.1 DNA Sequencing

> 1. Whole-genome sequencing
> 2. Targeted sequencing

## 2.2 RNA Sequencing (cDNA)

> 1. Isoform sequencing (Iso-Seq)
> 	- Sharon, D., Tilgner, H., Grubert, F. _et al._ A single-molecule long-read survey of the human transcriptome. _Nat Biotechnol_ **31**, 1009–1014 (2013). https://doi.org/10.1038/nbt.2705.
> 2. Multiplexed arrays isoform sequencing (MAS-Iso-Seq). Kinnex kits utilize the MAS-Seq method, where **small amplicons are concatenated in an ordered array into larger fragments to fully utilize HiFi long read lengths and increase throughput**.
> 	- Al’Khafaji, A.M., Smith, J.T., Garimella, K.V. _et al._ High-throughput RNA isoform sequencing using programmed cDNA concatenation. _Nat Biotechnol_ **42**, 582–586 (2024). https://doi.org/10.1038/s41587-023-01815-7.

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://pacbio.cn/wp-content/uploads/Figure-KinnexRNA-LibraryWorkflow-2048x1116.png" 
        alt="PacBio Kinnex full-length RNA library preparation workflow"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure 6.</strong> PacBio Kinnex full-length RNA library preparation workflow. 
        Source: <a href="https://pacbio.cn" target="_blank" rel="noopener noreferrer">Pacific Biosciences (PacBio)</a>.
    </figcaption>
</figure>

---
# 3. Fundamentals

### [PacBio & Bioconda](https://github.com/PacificBiosciences/pbbioconda)

> PacBio® tools distributed via [Bioconda](https://bioconda.github.io/)

# 4. Primary Processing

## 4.1 HiFi Read Generation

### [CCS](https://github.com/PacificBiosciences/ccs)

> CCS combines multiple subreads of the same SMRTbell molecule using a statistical model to produce one highly accurate consensus sequence, also called a HiFi read, along with base quality values.

```shell
ccs --reportFile {output.report} {input.subreads.bam} {output.hifi.bam}
```

# 5. DNA Sequencing Analysis

## 5.1. Genome Assembly

### 5.1.1 De Nove Assembly

#### a). [Canu](https://github.com/marbl/canu)

> Canu is a fork of the [Celera Assembler](http://wgs-assembler.sourceforge.net/wiki/index.php?title=Main_Page), designed for high-noise single-molecule sequencing (such as the PacBio RS II/Sequel or Oxford Nanopore MinION). (v2.3, 2024-12-18)

```shell
samtools fastq {input.bam} > {output.fq}

# PacBio
canu -p ecoli -d ecoli-pacbio genomeSize=4.8m -pacbio {input.fq}

# PacBio HiFi Reads
canu -p asm -d ecoli_hifi genomeSize=4.8m -pacbio-hifi {input.fq}
```

#### b). [Flye](https://github.com/mikolmogorov/Flye)

> Flye is a de novo assembler for single-molecule sequencing reads, such as those produced by PacBio and Oxford Nanopore Technologies. It is designed for a wide range of datasets, from small bacterial projects to large mammalian-scale assemblies. The package represents a complete pipeline: it takes raw PacBio / ONT reads as input and outputs polished contigs.

```shell
# PacBio
flye --threads {threads} --pacbio-raw {input.fq} --out-dir {output.dir}

# PacBio HiFi Reads
flye --threads {threads} --pacbio-hifi {input.fq} --out-dir {output.dir}
```

#### c). [hifiasm](https://github.com/chhylp123/hifiasm)

> hifiasm is a fast haplotype-resolved de novo assembler initially designed for PacBio HiFi reads. Its latest release could support the telomere-to-telomere assembly by utilizing ultralong Oxford Nanopore reads.

```shell
# PacBio HiFi Reads
hifiasm -t {threads} -o {output.prefix}
```

#### d). [Verkko](https://github.com/marbl/verkko)

> Verkko is a hybrid genome assembly pipeline developed for telomere-to-telomere assembly of accurate long reads (PacBio HiFi, Oxford Nanopore Duplex, HERRO corrected Oxford Nanopore Simplex) and Oxford Nanopore ultra-long reads.

#### e). [IPA](https://github.com/PacificBiosciences/pbipa)

> PacBio official HiFi assembly tool, based on HiFiasm core.

```shell
ipa local -t {threads} -i {input.fq} -o {output.dir}
```

### 5.1.2 Assembly Polishing

#### a). [pbmm2](https://github.com/PacificBiosciences/pbmm2)

```shell
pbmm2 align --preset SUBREAD -j 32 asm.p_ctg.fa input.subreads.bam mapped.bam
gcpp -j 32 -r asm.p_ctg.fa -o polished.fasta mapped.bam
```

```shell
minimap2 -ax map-pb asm.fasta input.subreads.fastq > aln.sam
samtools view -bS aln.sam > aln.bam
samtools sort -o aln.sorted.bam aln.bam
samtools index aln.sorted.bam

racon -t 32 input.subreads.fastq aln.sorted.bam asm.fasta > polished1.fasta
```

```shell
bwa mem -t 32 asm_polished.fasta illumina_R1.fastq illumina_R2.fastq > illumina.sam
samtools sort -o illumina.bam illumina.sam
samtools index illumina.bam
java -Xmx100G -jar pilon.jar --genome asm_polished.fasta --frags illumina.bam --output pilon_polished
```

#### Others

> 1. [FMLRC](https://github.com/holtjma/fmlrc) and [FMLRC2](https://github.com/HudsonAlpha/fmlrc2), or FM-index Long Read Corrector, is a tool for performing hybrid correction of long read sequencing using the BWT and FM-index of short-read sequencing data. Wang, J.R., Holt, J., McMillan, L. _et al._ FMLRC: Hybrid long read error correction using an FM-index. _BMC Bioinformatics_ **19**, 50 (2018). https://doi.org/10.1186/s12859-018-2051-3. Q X Charles Mak, Ryan R Wick, James Matthew Holt, Jeremy R Wang, Polishing De Novo Nanopore Assemblies of Bacteria and Eukaryotes With FMLRC2, _Molecular Biology and Evolution_, Volume 40, Issue 3, March 2023, msad048, [https://doi.org/10.1093/molbev/msad048](https://doi.org/10.1093/molbev/msad048).
> 2. [LoRDEC](http://atgc.lirmm.fr/lordec) is a program to correct sequencing errors in long reads from 3rd generation sequencing with high error rate, and is especially intended for PacBio reads. It uses a hybrid strategy, meaning that it uses two sets of reads: the reference read set, whose error rate is assumed to be small, and the PacBio read set, which is then corrected using the reference set. Typically, the reference set contains Illumina reads. Leena Salmela, Eric Rivals, LoRDEC: accurate and efficient long read error correction, _Bioinformatics_, Volume 30, Issue 24, December 2014, Pages 3506–3514, [https://doi.org/10.1093/bioinformatics/btu538](https://doi.org/10.1093/bioinformatics/btu538).
> 3. etc.

### 5.1.3 Evaluate Assembly

 >1. [QUAST](https://github.com/ablab/quast): QUAST stands for QUality ASsessment Tool. It evaluates genome/metagenome assemblies by computing various metrics. (v5.3.0, 2024-11-10)
> 2. [BUSCO](https://gitlab.com/ezlab/busco): Assessing genome assembly and annotation completeness with single-copy orthologs. (v6.0.0, 2025-08-01)
> 3. [MUMmer](https://github.com/mummer4/mummer): MUMmer is a versatile alignment tool for DNA and protein sequences. (v4.0.1, 2025-02-04)
> 4. [dotPlotly](https://github.com/tpoorten/dotPlotly): Create an interactive dot plot from mummer output OR PAF format. R script (v, 2018)
> 5. [BRIG - BLAST Ring Image Generator](https://github.com/happykhan/BRIG): BRIG is a cross-platform (Windows/Mac/Linux) application that displays circular comparison images of multiple genomes using BLAST. It is designed to handle genome assembly data and can show similarity, coverage, annotations and more as concentric rings around a reference sequence. (GUI, v1.0.0, 2026-02-23)

### 5.1.4 Genome Annotation

> 1. Genome Structure Annotation: 
> 	1. [Augustus](https://github.com/Gaius-Augustus/Augustus)
> 	2. [RepeatMasker](https://github.com/Dfam-consortium/RepeatMasker) is a program that screens DNA sequences for interspersed repeats and low complexity DNA sequences.
> 	3. [RepeatModeler](https://github.com/Dfam-consortium/RepeatModeler) is a de novo transposable element family identification and modeling package.
> 2. Gene function annotation

## 5.2 Variant Detection

### a). [pdsv](https://github.com/PacificBiosciences/pbsv)

> pbsv is a suite of tools to call and analyze structural variants in diploid genomes from PacBio single molecule real-time sequencing (SMRT) reads.

```shell
pbmm2 align --preset HIFI -j 32 reference.fa output.ccs.bam aln_hifi.bam
samtools index aln_hifi.bam

pbsv discover aln_hifi.bam svsig.gz
pbsv call reference.fa svsig.gz sv_hifi.vcf
```

### b). [DeepVariant](https://github.com/google/deepvariant)

> DeepVariant is a deep learning-based variant caller that takes aligned reads (in BAM or CRAM format), produces pileup image tensors from them, classifies each tensor using a convolutional neural network, and finally reports the results in a standard VCF or gVCF file.

### c). [WhatsHap](https://github.com/whatshap/whatshap)

> WhatsHap is a software for phasing genomic variants using DNA sequencing reads, also called _read-based phasing_ or _haplotype assembly_. It is especially suitable for long reads, but works also well with short reads.

### d). [SVIM](https://github.com/eldariont/svim)

> SVIM is a structural variant caller for third-generation sequencing reads. It is able to detect and classify the following six classes of structural variation: deletions, insertions, inversions, tandem duplications, interspersed duplications and translocations.

## 5.3 DNA Modification

### a). [Jasmine](https://github.com/PacificBiosciences/jasmine)

### b). [pb-CpG-tools](https://github.com/PacificBiosciences/pb-CpG-tools)

## 5.4 Other

---
# 6. RNA Sequencing Analysis

> 1. Transcript reconstruction and isoform identification
> 2. Gene and isoform quantification
> 3. Alternative splicing
> 4. Fusion transcript detection
> 5. Single-cell Sequencing

## 6.1 Full-length Transcript Processing
### 6.1.1 Segmented Reads

#### [Skera](https://github.com/PacificBiosciences/skera)

> Skera splits Kinnex PacBio HiFi reads at adapter positions generating segmented reads (S-reads).

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://skera.how/img/segmented-read.png" 
        alt="PacBio Skera segmented read workflow and principle"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> PacBio Skera segmented read workflow and principle. 
        Source: <a href="https://skera.how" target="_blank" rel="noopener noreferrer">Skera.how</a>.
    </figcaption>
</figure>

```shell
# Splits Kinnex HiFi reads at adapter positions to generate S-reads.
skera split {input.hifi.bam} {adapters.fasta} {output.skera.bam}
# Reconstitutes the original parent read from input S-reads.
skera undo {input.skera.bam} {output.undo.bam}
```

### 6.1.2 Primer Removal And Demultiplexing

#### [lima](https://github.com/PacificBiosciences/barcoding)

> lima is the standard tool to identify barcode and primer sequences in PacBio single-molecule sequencing data.

```shell
#
lima --isoseq -j {threads} {input.hifi.bam} \
	{barcoded_primers.fasta} {output.fl.bam}

#
lima --isoseq --peek-guess -j {threads} {input.hifi.bam} \
	{barcoded_primers.fasta} {output.fl.bam}

# 
lima --isoseq --peek-guess -j {threads} \
	--overwrite-biosample-names {input.hifi.bam} \
	{barcoded_primers.fasta} {output.fl.bam}
```

### 6.1.3 Refine Reads

#### [isoseq]()

> 1. Trimming of poly(A) tails
> 2. Rapid concatemer identification and removal

```shell
isoseq refine --require-polya {input.fl.bam} {primers.fasta} {output.flnc.bam}
```

### 6.1.4 Clustering Reads

```shell
# Single bam file
isoseq cluster2 {input.flnc.bam} {output.clustered.bam}
# Multiple bam files separated by spaces.
isoseq cluster2 {flnc.fofn} {output.clustered.bam}
```

## 6.2 Transcript Mapping, Collapse and Classification

### 6.2.1 Alignment

### [Minimap2](https://github.com/lh3/minimap2)

> Minimap2 is a versatile sequence alignment program that aligns DNA or mRNA sequences against a large reference database. Typical use cases include: (1) mapping PacBio or Oxford Nanopore genomic reads to the human genome; (2) finding overlaps between long reads with error rate up to ~15%; (3) splice-aware alignment of PacBio Iso-Seq or Nanopore cDNA or Direct RNA reads against a reference genome; (4) aligning Illumina single- or paired-end reads; (5) assembly-to-assembly alignment; (6) full-genome alignment between two closely related species with divergence below ~15%.
> - [pbmm2](https://github.com/PacificBiosciences/pbmm2) is a SMRT C++ wrapper for minimap2's C API.
> - Dorado uses the `minimap2` aligner to align basecalled sequences to a reference and supports aligning existing basecalls or producing aligned output directly.

```shell
pbmm2 align -j {threads} --preset ISOSEQ --sort --bam-index \
    {input.clustered.bam} {genome.fa} {output.mapped.bam}
```

### 6.2.2 Collapse

```shell
# Bulk Iso-Seq
isoseq collapse --do-not-collapse-extra-5exons \
    {input.mapped.bam} {input.flnc.bam} {output.collapsed.gff}

# Single-cell Iso-Seq
isoseq collapse {input.mapped.bam} {output.collapsed.gff}
```

### 6.2.3 Prepare reference files for pigeon

> Pigeon is a PacBio Transcript Toolkit that contains tools to classify and filter full-length transcript isoforms into categories against a reference annotation.

```shell
# Prepare reference files for pigeon
pigeon prepare {genome.gtf} {genome.fa} {cage.bed} {intropolis.tsv}
# Sort and index the genome annotation, (optional) CAGE peak, and (optional) intropolis files before classification.

# Prepare input transcript GFF
pigeon prepare {input.collapsed.gff}
```

### 6.2.4 Classify Isoforms

```shell
pigeon classify {input.collapsed.sort.gff} {genome.gtf} {genome.fa}
```

```shell
# Classify transcripts against annotation
pigeon classify <collapsed.sorted.gff> $genomeAnno $genomeFa
# Adding supplemental reference information to classification output
pigeon classify <collapsed.sorted.gff> $genomeAnno $genomeFa --cage-peak refTSS.bed --poly-a polyA.list
pigeon classify <collapsed.sorted.gff> --ref Human_hg38_Gencode_v39.referenceset.xml
# Adding FLNC counts to classification output
pigeon classify <collapsed.sorted.gff> $genomeAnno $genomeFa --fl flnc_count.txt
```

```shell
# Filter transcripts for potential artifacts
pigeon filter classification.txt --isoforms <collapsed.sorted.gff>
```

```shell
# Report gene saturation
pigeon report --exclude-singletons <classification.filtered_lite_classification.txt> <saturation.txt>
```

### 6.2.5 Quantification

#### [IsoQuant](https://github.com/ablab/Isoquant)

> IsoQuant is a tool for the genome-based analysis of long RNA reads, such as PacBio or Oxford Nanopores.
> 1. Quantification
> 2. Isoform and gene discovery
> 3. Single-cell and spatial transcriptomic analysis
> - Prjibelski, A.D., Mikheenko, A., Joglekar, A. _et al._ Accurate isoform discovery with IsoQuant using long reads. _Nat Biotechnol_ **41**, 915–918 (2023). https://doi.org/10.1038/s41587-022-01565-y.

```shell
conda install -c bioconda isoquant

# PacBio CCS reads
isoquant -t {threads} --data_type pacbio_ccs \
	--reference {input.ref.fa} --genedb {input.ref.gtf} \
	--fastq {input.fq.gz} -o {output.dir} --prefix {params.prefix}

# NPacBio FL reads
isoquant -t {threads} --data_type pacbio_ccs --fl_data \
	--reference {input.ref.fa} --genedb {input.ref.gtf} \
	--fastq {input.fq.gz} -o {output.dir} --prefix {params.prefix}

# --fastq {input.fq.gz}
# --bam {input.aligned.bam}
```

## 6.3 Alternative Splicing

## 6.4 Single-cell Iso-Seq

## 6.5 Others

[SQANTI3](https://github.com/ConesaLab/SQANTI3): SQANTI3 constitutes the first module of the [Functional IsoTranscriptomics (FIT)](https://tappas.org/) pipeline, which is an end-to-end strategy to perform isoform-level bioinformatics analyses.

---
# Database

---
# Reference
