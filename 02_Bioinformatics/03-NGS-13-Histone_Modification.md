---
Title: Histone Modification
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2020-11-01
Modified: 2023-05-11
Tags:
  - ChIP-seq
  - CUTTag
  - CUTRUN
---
# Introduction

## 1. Definition

**Histone modifications** are covalent post-translational modifications (PTMs) of histone proteins that regulate chromatin structure and gene expression without altering the underlying DNA sequence. These modifications, including **acetylation, methylation, phosphorylation, ubiquitination, and sumoylation**, occur primarily on the N-terminal histone tails and are dynamically added, removed, and recognized by histone-modifying enzymes and effector proteins, commonly referred to as "writers," "erasers," and "readers." **Histone modifications influence chromatin accessibility, nucleosome stability, and the recruitment of transcriptional and chromatin-regulatory complexes, thereby regulating transcription, DNA replication, DNA repair, and other genome-associated processes.** Distinct combinations of histone modifications constitute a complex regulatory landscape that contributes to cell identity, development, and cellular responses to physiological and environmental cues.

## 2. Regulation Mechanism

## 3. Biological Functions

| Histone Mark | Function | Distribution | Hallmark | Writers | Readers | Erasers | Effect |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **H3K4me3** | Transcription initiation | Promoters, CpG islands | Active promoter | SET1A/B, MLL1-4 (COMPASS) | CHD1, TAF3, BPTF (PHD/WD40) | KDM5 (JARID1) | Activation |
| **H3K4me2** | Intermediate transition | Promoters, Enhancers | Poised/Active enhancer | SET1A/B, MLL1-4 | PHD domain proteins | LSD1 (KDM1A), KDM5 | Activation |
| **H3K4me1** | Enhancer priming | Enhancers | Primed enhancer | MLL3/4 (KMT2C/D) | BPTF, Chromodomain | LSD1 (KDM1A) | Activation |
| **H3K27me3** | Polycomb silencing | Polycomb domains | Facultative heterochromatin | PRC2 (EZH2) | PRC1 (CBX proteins) | KDM6A (UTX), KDM6B | Repression |
| **H3K9me3** | Heterochromatin formation | Pericentric, Telomeres | Constitutive heterochromatin | SUV39H1/2, SETDB1 | HP1 (CBX1/3/5) | KDM4 (JMJD2) | Repression |
| **H3K9me2** | Euchromatic silencing | Gene poor regions, Repressed genes | Silenced euchromatin | G9a (EHMT2), GLP (EHMT1) | HP1β | KDM3A/B, KDM4 | Repression |
| **H3K9me1** | Precursor state | Promoters, Gene bodies | - | G9a, SETDB1, SUV39H1 | HP1, CDYL | KDM3A, PHF8 | Repression |
| **H3K36me3** | Transcription elongation | Gene bodies (Exons) | Active transcription | SETD2 | LEDGF, PWWP domain | KDM4, KDM2A/B | Activation |
| **H3K27ac** | Enhancer/Promoter activation | Promoters, Enhancers | Active enhancer/promoter | p300/CBP (KAT3A/B) | BRD4 (BET family) | HDAC1/2/3 | Activation |
| **H3K9ac** | Transcription activation | Promoters | Active promoter | GCN5, PCAF (KAT2A/B) | Bromodomains | HDACs | Activation |
| **H2AK119ub** | Polycomb repression | Polycomb target genes | PRC1-mediated silencing | PRC1 (RING1A/B) | PRC2 (JARID2, AEBP2) | BAP1, USP16 | Repression |
| **H2BK120ub** | Elongation & Crosstalk | Gene bodies | H3K4/H3K79me crosstalk | RNF20/40 | COMPASS, FACT complex | USP22, USP51 | Activation |

---

# Experimental Design

For more details, please see: [[3-NGS-13-Epigenomics-HistoneModification]]

---

# Preprocessing

## 1. Quality Control

### [FastQC](https://github.com/s-andrews/FastQC)

## 2. Trimming Reads

### [Trim Galore](https://github.com/FelixKrueger/TrimGalore)

For more details, please see: [[2-GEN-03-Bioinformatics-Toolkit]]

---

# Upstream Processing

For more details, please see: [[3-NGS-13-Epigenomics-HistoneModification]]

---

# Downstream Analysis

## 1. Handling Replicates

## 2. Differential Peaks

## 3. Peaks Annotation

## 4. Motif Discovery

## 5. Visualization

## 6. Chromatin Status

### a). [ChromHMM](https://github.com/jernst98/ChromHMM)

ChromHMM is a Java program for the learning and characterizing chromatin states using a multivariate Hidden Markov Model that models the combinatorial and spatial patterns in data from multiple chromatin marks.

```shell
# Converts a set of bam files of aligned reads into binarized data files for model learning.
java -jar ChromHMM.jar BinarizeBam \
	-paired -b 200 -f 0 -g 0 -p 0.0001 -gzip \
	{input.chrom.size} {input.bam.dir} \
	{input.cellmarkfiletable} \
	{output.binarization.dir}

# Receives a set of binary data files and learns a model of chromatin states.
java -jar ChromHMM.jar LearnModel -p {threads} \
	-b 200 -color 0,0,255 -d 0.001 -gzip \
	{input.binarization.dir} {output.dir} 15 mm10
```

### b). [Segway](https://github.com/hoffmangroup/segway)

Segway is a software package for learning and characterizing chromatin states using a Dynamic Bayesian network (DBN) or a mixture of Gaussians model, enabling it to analyze the entire genome at 1-bp resolution even in the face of heterogeneous patterns of missing data.

## 7.Super-Enhancer

### a). [ROSE](https://github.com/stjude/ROSE)

Rank ordering of super-enhancers (ROSE): To create stitched enhancers, and to separate super-enhancers from typical enhancers using sequencing data (.bam) given a file of previously identified constituent enhancers (.gff). Releases: v1.3.2 (2024-05-02)

```shell
cat <path_of_narrowPeak> | \
	awk '{print $1"\t"$4"\t"" ""\t"$2"\t"$3"\t"" ""\t"$6"\t"" ""\t"$4}' > <path_of_gff>
samtools index <path_of_bam>
python ROSE_main.py -g <gtf> -i <path_of_gff> -r <path_of_bam> -o <output>
python ROSE_main.py -g <gtf> -i <path_of_gff> -r <path_of_IP_bam> -c <path_of_Input_bam> -o <output>

cat peaks.narrowPeak | awk '{print $1"\t"$4"\t"" ""\t"$2"\t"$3"\t"" ""\t"$6"\t"" ""\t"$4}'| cat > test.gff
	python ROSE_main.py -g hg38 -i peaks.gff -r IP.bam -c Input.bam -o {output.dir} -s 12500 -t 2500
```

```shell
ROSEPATH=/path/to/ROSE
export PYTHONPATH="$PYTHONPATH:$ROSEPATH/lib"
export PATH="$PATH:$ROSEPATH/bin"

ROSE_main.py --custom {input.refseq.ucsc} -i {input.peaks.bed} \
	-r {input.IP.bam} -c {input.Input.bam} \
	-o {output.dir} -s 12500 -t 2500
# -g {params.genome}
```

### b). Others

> 1. [imPROSE](https://github.com/asntech/improse): integrated methods for prediction of super-enhancers is a computational workflow to predict super-enhancers or constituents of super-enhancers from a list of candidate enhancers.
> 2. [CREAM](https://github.com/bhklab/CREAM): Clustering of genomic REgions Analysis Method is a new method for identification of clusters of genomic regions within chromosomes. Primarily, it is used for calling Clusters of cis-Regulatory Elements (COREs).

## 8. Multi-omics Analysis

> 1. [BETA](http://cistrome.org/BETA/)
> Binding and Expression Target Analysis (BETA) is a software package that integrates ChIP-seq of transcription factors or chromatin regulators with differential gene expression data to infer direct target genes.
> 2. [S3V2_IDEAS_ESMP](https://github.com/guanjue/S3V2_IDEAS_ESMP): a package for normalizing, denoising and integrating epigenomic datasets across different cell types

---

# Reference
1. https://hbctraining.github.io/Intro-to-ChIPseq/schedule/2-day.html
2. https://github.com/crazyhottommy/ChIP-seq-analysis
3. https://yezhengstat.github.io/CUTTag_tutorial/index.html
