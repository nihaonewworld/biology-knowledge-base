---
Title: DNA-Binding Protein
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2020-11-01
Modified: 2025-05-11
Tags:
  - ChIP-seq
  - CUTTag
  - CUTRUN
  - DAP-seq
---
# Introduction

## 1. Definition

**DNA binding** refers to the physical interaction between DNA and DNA-binding proteins (DBPs), including **transcription factors, histones, polymerases, and chromatin-associated regulatory proteins**. These interactions are mediated by conserved DNA-binding domains (DBDs), such as zinc fingers, leucine zippers, helix-turn-helix motifs, and homeodomains, which recognize specific DNA sequences or structural features through non-covalent interactions (hydrogen bonds, van der Waals forces, and electrostatic interactions) within the major or minor grooves of the DNA helix. DNA-binding interactions vary in affinity, specificity, and cooperativity, enabling **the precise regulation of gene expression, DNA replication, DNA repair, recombination, and higher-order chromatin organization**.

### Transcription factor

**Transcription factors (TFs)** are sequence-specific DNA-binding proteins that regulate gene transcription by recognizing cis-regulatory elements, such as promoters and enhancers, and modulating the recruitment or activity of the transcriptional machinery. **TFs bind specific DNA motifs through conserved DNA-binding domains (DBDs) and regulate transcription via activation or repression domains that recruit RNA polymerase II, transcriptional cofactors, chromatin-remodeling complexes, and epigenetic modifiers.** The combinatorial and context-dependent activities of TFs enable the integration of multiple intracellular and extracellular signals, thereby establishing precise spatiotemporal patterns of gene expression that are essential for cell identity, development, differentiation, and responses to environmental stimuli.

### Histones

For more details, please see: [[3-NGS-13-Epigenomics-HistoneModification]]

## 2. Regulation Mechanism

## 3. Biological Functions

---

# Experimental Design

## Sequencing Technologies

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fs41596-020-0373-x/MediaObjects/41596_2020_373_Fig1_HTML.png" 
        alt="Steps in antibody-targeted chromatin profiling strategies from Nature Protocols"
        style="max-width: 100%; height: auto; border-radius: 4px; background: white;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> Steps in antibody-targeted chromatin profiling strategies. 
        Adapted from <a href="https://doi.org/10.1038/s41596-020-0373-x" target="_blank" rel="noopener noreferrer">Nature Protocols (2020)</a>.
    </figcaption>
</figure>

### (1). ChIP-seq

> **ChIP-seq** (Chromatin Immunoprecipitation sequencing) is the gold-standard technology for mapping the global binding sites of DNA-associated proteins, such as transcription factors and histones, across the entire genome. The principle involves the use of specific antibodies to selectively enrich DNA fragments that are physically bound to a target protein. The workflow typically begins with **cross-linking** (to "freeze" protein-DNA interactions), followed by **chromatin fragmentation** (via sonication or enzymatic digestion), **immunoprecipitation** of the protein-DNA complexes, and subsequent high-throughput sequencing of the purified DNA. Its primary characteristic is the ability to identify precise interaction "peaks" with high sensitivity and genome-wide coverage, providing a comprehensive view of gene regulatory networks and the epigenetic landscape.
>
> Protocol:
> 
> 1. Crosslinking: Formaldehyde is applied to crosslink proteins and DNA, thereby preserving their native biochemical interactions.
> 2. Cell lysis: Cells are lysed in a detergent‐based buffer to release soluble cellular contents, including crosslinked protein–DNA complexes.
> 3. Chromatin preparation: Chromatin is fragmented to 200-700 base pairs by sonication or by enzymatic digestion (e.g., micrococcal nuclease, MNase)
> 4. Immunoprecipitation: Target‐specific antibodies are used to capture genomic loci associated with the protein or histone modification of interest, and the resulting protein–DNA complexes are retrieved with magnetic or agarose beads.
> 5. Reversal of crosslinking: Crosslinks are reversed by incubating the samples with Proteinase K, which hydrolyzes peptide bonds adjacent to aliphatic, aromatic, or hydrophobic residues.
> 6. Purification of DNA: DNA is purified using phenol–chloroform extraction or a silica‐based column method.
> 7. Library construction: Sequencing libraries are prepared by end‐repair, A‐tailing, adapter ligation, and limited‐cycle PCR amplification.

### (2). CUT&RUN

> **Cleavage Under Targets and Release Using Nuclease (CUT&RUN)** is a chromatin profiling strategy in which antibody-targeted controlled cleavage by micrococcal nuclease releases specific protein-DNA complexes into the supernatant for paired-end DNA sequencing.

### (3). CUT&Tag

> **Cleavage Under Targets and Tagmentation (CUT&Tag)** is an enzyme-tethering strategy that provides efficient high-resolution sequencing libraries for profiling diverse chromatin components.

### (4). DAP-seq (Plant)

> **DNA affinity purification sequencing (DAP-seq)** is a high-throughput method for discovering transcription factor binding sites that analyzes genomic DNA with in vitro-expressed TFs.

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fnprot.2017.055/MediaObjects/41596_2017_Article_BFnprot2017055_Fig1_HTML.jpg" 
        alt="Experimental workflow and methodology overview from Nature Protocols publication"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> Overview of the experimental workflow and methodology. 
        Adapted from <a href="https://doi.org/10.1038/nprot.2017.055" target="_blank" rel="noopener noreferrer">Nature Protocols (2017)</a>.
    </figcaption>
</figure>

### (5). Others

> 1. MeDIP-seq: measure methylated DNA.
> 2. DNase-seq: detect DNase I hypersensitive sites.
> 3. GRO-seq: map the position, amount and orientation of transcriptionally engaged RNA polymerases.

### Negative controls

> * **Input control:** Input DNA is prepared from chromatin prior to immunoprecipitation and serves as a reference for the genomic background. It corrects for technical biases introduced during chromatin fragmentation, library preparation, sequencing, and uneven genome representation, but does not account for nonspecific interactions associated with the immunoprecipitation procedure or antibody binding.
> * **Mock IP (IgG) control:** Mock immunoprecipitation is performed using a nonspecific IgG antibody or without the target-specific antibody, thereby lacking specific antibody–antigen interactions. It is designed to measure nonspecific DNA recovery arising from the immunoprecipitation process, including nonspecific antibody binding and bead-associated background. Although Mock IP can theoretically correct for both fragmentation-related and immunoprecipitation-related biases, it is less commonly used because of its low DNA yield, reduced signal-to-noise ratio, and greater susceptibility to technical variability.

## Sequencing depth

> - 20-40M reads as standard for TFs and narrow marks (H3K27ac, H3K4me2/3, H3K9ac)
> - 45M reads for broad marks (H3K27me3, H3K36me3, H3K4me1, H3K79me2/3, H3K9me1/2, H4K20me1)
> - 45M reads for exceptions (H3K9me3)

---

# Preprocessing

## 1. Quality Control

### [FastQC](https://github.com/s-andrews/FastQC)

## 2. Trimming Reads

### [Trim Galore](https://github.com/FelixKrueger/TrimGalore)

For more details, please see: [[2-GEN-03-Bioinformatics-Toolkit]]

---

# Upstream Processing

## 1. Alignment

### a). [Bowtie2](https://github.com/BenLangmead/bowtie2)

```shell
# Paired-end sequencing
bowtie2 -p {threads} -x {params.index} --very-sensitive -I 25 -X 1000 \
	--no-mixed --no-discordant -1 {input.fq1} -2 {input.fq2} | \
	samtools sort -@ {threads} -o {output.bam}
# Single-end sequencing
bowtie2 -p {threads} -x {params.index} --very-sensitive -U {input.fq} | \
	samtools sort -@ {threads} -o {output.bam}
```

### b). [BWA](https://github.com/lh3/bwa)

```shell
# Paired-end sequencing
bwa mem -t {threads} -M {params.index} {input.fq1} {input.fq2} | \
	samtools sort -@ {threads} -o {output.bam}
# Single-end sequencing
bwa mem -t {threads} -M {params.index} {input.fq} | \
	samtools sort -@ {threads} -o {output.bam}
```

### c). [Bowtie](https://github.com/BenLangmead/bowtie)

```shell
# Paired-end sequencing
bowtie -p {threads} -x {input.index} -S -I 25 -X 1000 \
	-1 {input.fq1} -2 {input.fq2} | \
	samtools sort -@ {threads} -o {output.bam}
# Single-end sequencing
bowtie -p {threads} -x {input.index} -S -U {input.fq} | \
	samtools sort -@ {threads} -o {output.bam}
```

## 2. Filtering of Reads

```shell
# Pipeline 1
samtools index {input.bam} {output.bai}
samtools stats {input.bam} > {output.stats}
samtools idxstats {input.bam} > {output.idxstats}

samtools view -q 30 -f 2 -F 1804 -u -e 'rname != "chrM"' {input.bam} | \
	samtools sort -@ {threads} -o {output.bam}

picard -Xmx4G AddOrReplaceReadGroups -I {input.bam} -O {output.rg_bam} \
	--RGID 1 --RGLB {params.lib_id} --RGSM {params.lib_id} \
	--RGPL ILLUMINA --RGPU unit --TMP_DIR {resources.tmpdir}

picard -Xmx4G MarkDuplicates \
	--VALIDATION_STRINGENCY LENIENT --ASSUME_SORT_ORDER coordinate \
	--REMOVE_DUPLICATES true --TMP_DIR {resources.tmpdir} \
	-I {input.rg_bam} -M {output.rmdup} -O {output.bam}

samtools index {input.bam} {output.bai}
```

```shell
# Pipeline 2
picard -Xmx4G EstimateLibraryComplexity -I {input.bam} \
	-O {output.complexity.txt}

samtools collate -@ 1 -u -O {input.bam} | \
	samtools fixmate -@ 1 -m -u - - | \
	samtools sort -@ 2 -u - | \
	samtools markdup -@ 2 -r -f {output.rmdup.txt} - - | \
	samtools view -@ 1 -h -u -q 30 -f 2 -F 1804 -e 'rname != "chrM"' - | \
	samtools sort -@ 2 -o {output.bam}

samtools index {input.bam} {output.bai}
samtools stats {input.bam} > {output.stats.txt}
samtools idxstats {input.bam} > {output.idxstats}
```

### 1). Unique Mapping Reads

```shell
samtools view -q 30 -f 2 -F 1804 -u {input.bam} | \
	samtools sort -@ {threads} -o {output.bam}
```

### 2). Mitochondrial Reads

```shell
samtools view -e 'rname != "chrM"' {input.bam} -o {output.bam}
samtools view -h {input.bam} | grep -v chrM | samtools view -b -o {output.bam}
```

### 3). PCR Duplicates Reads

#### a). [Picard](https://broadinstitute.github.io/picard/index.html)

```shell
# Sort by coordinates (required)
samtools sort -@ {threads} {input.bam} -o {output.sorted.bam}
# Add Read Group information (sourced from SRA)
picard -Xmx4G AddOrReplaceReadGroups -I {input.sorted.bam} -O {output.rg_bam} \
	--RGID 1 --RGLB {params.lib_id} --RGSM {params.lib_id} \
	--RGPL ILLUMINA --RGPU unit --TMP_DIR {resources.tmpdir}
# Remove PCR duplicates
picard -Xmx4G MarkDuplicates \
	--VALIDATION_STRINGENCY LENIENT --ASSUME_SORT_ORDER coordinate \
	--REMOVE_DUPLICATES true --TMP_DIR {resources.tmpdir} \
	-I {input.rg_bam} -M {output.rmdup} -O {output.bam}
# --REMOVE_DUPLICATES false: Mark PCR duplicates
```

> Note: When the input is coordinate-sorted, unmapped mates of mapped records and supplementary/secondary alignments are not marked as duplicates. However, when the input is query-sorted (actually query-grouped), then unmapped mates and secondary/supplementary reads are not excluded from the duplication test and can be marked as duplicate reads.

#### b). [samtools](https://github.com/samtools/samtools)

```shell
# Sort by query name (required)
samtools collate -@ 1 -u -O {input.bam} | \
	samtools fixmate -@ 1 -m -u - - | \
	samtools sort -@ 2 -u - | \
	samtools markdup -@ 2 -r -f {output.rmdup.txt} - - | \
	samtools sort -@ 2 -o {output.bam}
```

#### c). [sambamba](https://github.com/biod/sambamba)

```shell
sambamba markdup -t {threads} -r {input.bam} {output.rmdup.bam}
sambamba view -t {threads} -f bam \
	-F "mapping_quality >= 30 and not unmapped and not duplicate" \
	{input.bam} > {output.rmdup.bam}
# [XS] == null:		filtered out multimappers for Bowtie2 result
# mapping_quality >= 30
# not unmapped:		filtered out unmapped reads
# not duplicate:	filtered out duplicates reads
```

### 4). ENCODE Blacklist Regions

> [The ENCODE blacklist](https://github.com/Boyle-Lab/Blacklist): A comprehensive set of regions in the human, mouse, worm, and fly genomes that have anomalous, unstructured, or high signal in next-generation sequencing experiments independent of cell line or experiment.

```shell
bedtools intersect -nonamecheck -v -b {input.blacklist.bed} \
	-abam {input.bam} > {output.bam}
```

## 3. Peaks Calling

> Different data types have different peak shapes
> 1. narrow marks: Most TF peaks, CTCF, H3K4me2/3, H3K27ac, H3K9ac
> 2. broad marks: H3K27me3, H3K36me3, H3K4me1, H3K79me2/3, H3K9me1/2, H4K20me1, HP1, Lamins, HMGA
> 3. mixed marks: Pol II, nucleosome-free regions (NFRs, ATAC-seq)
> 4. exceptions marks: H3K9me3
> 5. ATAC-seq, 147bp

### a). [MACS](https://github.com/macs3-project/MACS)

> With the improvement of sequencing techniques, chromatin immunoprecipitation followed by high throughput sequencing (ChIP-Seq) is getting popular to study genome-wide protein-DNA interactions. To address the lack of powerful ChIP-Seq analysis method, we presented the **M**odel-based **A**nalysis of **C**hIP-**S**eq (MACS), for identifying transcript factor binding sites. MACS captures the influence of genome complexity to evaluate the significance of enriched ChIP regions and MACS improves the spatial resolution of binding sites through combining the information of both sequencing tag position and orientation. MACS can be easily used for ChIP-Seq data alone, or with a control sample with the increase of specificity. Moreover, as a general peak-caller, MACS can also be applied to any "DNA enrichment assays" if the question to be asked is simply: _where we can find significant reads coverage than the random background_. Releases: v3.0.4 (2026-02-24)
>
> - MACS2: Model-based Analysis for ChIP-Seq, python 3.8
> - MACS3: Latest version

```shell
# ChIP-seq
# PE Mode, narrow peaks:
macs3 callpeak -f BAMPE --keep-dup all -g {params.gsize} \
    -q 0.01 --cutoff-analysis -B -n {params.prefix} \
	-t {input.ip.bam} -c {input.input.bam} --outdir {output.dir}

# SE Mode, narrow peaks:
macs3 callpeak -f BAM --keep-dup all -g {params.gsize} \
    -q 0.01 --cutoff-analysis -B -n {params.prefix} \
    -t {input.ip.bam} -c {input.input.bam} --outdir {output.dir}

# PE Mode, broad peaks:
macs3 callpeak -f BAMPE --keep-dup all -g {params.gsize} \
	-q 0.01 --cutoff-analysis -B -n {params.prefix} \
	--broad --broad-cutoff 0.05 \
	-t {input.ip.bam} -c {input.input.bam} --outdir {output.dir}
# --max-gap 2500
```

```shell
# CUT&Tag & CUT&RUN
# PE Mode, narrow peaks:
macs3 callpeak -f BAMPE --keep-dup all -g {params.gsize} \
    -q 0.01 --cutoff-analysis -B -n {params.prefix} \
    -t {input.bam} --outdir {output.dir}

# SE Mode, narrow peaks:
macs3 callpeak -f BAM --keep-dup all -g {params.gsize} \
    -q 0.01 --cutoff-analysis -B -n {params.prefix} \
    --nomodel --shift -100 --extsize 200 \
    -t {input.bam} --outdir {output.dir}
# --nolambda: for broad peaks (optional)
```

> Notes:
> 1. In MACS2, single-end (SE) and paired-end (PE) data are processed with entirely different pileup algorithms. For SE data, the sequencer captures only the 5' coordinate, leaving the 3' boundary unknown. MACS2 typically fits a bimodal model to estimate the global fragment length ($d$). The `--nomodel` flag bypasses this step, requiring the user to specify arbitrary fragment extensions and offsets with `--extsize` and `--shift`. Conversely, specifying `-f BAMPE` enables a deterministic parsing mode for PE data, in which the exact genomic coordinates of both boundaries are provided by the template length (TLEN) field. MACS2 directly extracts these empirical coordinates to compute the true, variable physical length of each molecule. Because the algorithm constructs the signal track from the absolute boundaries of every read pair, the bimodal model is redundant. Furthermore, manually overriding the fragment size with `--extsize` or `--shift` would corrupt the high-resolution, biologically accurate coordinates derived from the alignment. Consequently, MACS2 restricts these single-end parameters in the BAMPE pipeline to preserve analytical integrity.
> 2. The `--nolambda` flag forces MACS2 to apply a uniform, genome-wide background instead of dynamic local thresholds, causing a significant increase in false-positive peak calls at highly accessible or biased genomic regions.
> 3. `--call-summits` will invoke SPP-like way to 'refine' the summits and sometimes it doesn't provide better results than the default behavior.

### b). [RSEG](http://smithlabresearch.org/software/rseg/)

RSEG is aimed to analyze ChIP-Seq data, especially for identifying genomic regions and their boundaries marked by diffusive histone modification markers, such as H3K36me3 and H3K27me3. 
```shell
rseg-diff -mode 2 -bam -i 20 -c {input.chrom.sizes} -d {input.Deadzone.bed} \
	-o {output.bed} {input.input.bam} {input.ip.bam}
```

### c). [SEACR](https://github.com/FredHutch/SEACR)

Sparse Enrichment Analysis for CUT&RUN
```shell
samtools sort -@ {threads} -n -u {input.bam} | \
	bedtools bamtobed -bedpe -i - | \
	awk 'BEGIN{{OFS="\t"}} $1==$4 && $6-$2 < 1000 {{print $1, $2, $6}}' | \
	sort -k1,1 -k2,2n -k3,3n | \
	bedtools genomecov -bg -i stdin -g {input.chrom_sizes} > {output.bdg}

bash SEACR_1.3.sh {input.ip.bdg} 0.05 norm stringent {params.prefix}
bash SEACR_1.3.sh {input.ip.bdg} {input.input.bdg} non stringent {params.prefix}
```

### d). Others

> 1. [HOMER](http://homer.ucsd.edu/homer/ngs/peaks.html): HOMER contains a program called findPeaks that performs all of the peak calling and transcript identification analysis.
> 2. [SICER2](https://github.com/zanglab/SICER2): Redesigned and improved ChIP-seq broad peak calling tool SICER.
> 3. [epic2](https://github.com/biocore-ntnu/epic2): is an ultraperformant reimplementation of SICER. It focuses on speed, low memory overhead and ease of use.
> 4. [csaw](https://bioconductor.org/packages/release/bioc/html/csaw.html): Detection of differentially bound regions in ChIP-seq data with sliding windows, with methods for normalization and proper FDR control.
> 5. [Genrich](https://github.com/jsh58/Genrich) is a peak-caller for genomic enrichment assays (e.g. ChIP-seq, ATAC-seq). It analyzes alignment files generated following the assay and produces a file detailing peaks of significant enrichment.

## 4. Coverage Track

### a). [deepTools](https://github.com/deeptools/deepTools)

> deepTools addresses the challenge of handling the large amounts of data that are now routinely generated from DNA sequencing centers. deepTools contains useful modules to process the mapped reads data for multiple quality checks, creating **normalized coverage files** in standard bedGraph and bigWig file formats, that allow comparison between different files (for example, treatment and control). Finally, using such normalized and standardized files, deepTools can create many publication-ready **visualizations** to identify enrichments and for functional annotations of the genome. Releases: v3.5.6 (2025-06-20)

```shell
# Generate genome coverage track
bamCoverage -p {threads} -bs 10 --normalizeUsing RPKM \
	--exactScaling --extendReads \
	-b {input.bam} -o {output.bw}
bamCoverage -p {threads} -bs 10 --normalizeUsing RPGC \
	--effectiveGenomeSize 2.1e9 -exactScaling --extendReads \
	-b {input.bam} -o {output.bw}
# spike-in
sf = 1 000 000 / (Number of spike-in reads)
bamCoverage -p {threads} -bs 10 --normalizeUsing RPKM \
	--exactScaling --extendReads --scaleFactor {params.sf} \
	-b {input.bam} -o {output.bw}
# -bl {params.blacklist}
```

```shell
# Generate genome IP/Input coverage track
bamCompare -p {threads} -bs 10 --normalizeUsing RPKM --operation log2 \
	--exactScaling --extendReads --scaleFactorsMethod None \
	-b1 {input.ip.bam} -b2 {input.input.bam} -o {output.bw}
```

### b) [MACS-pileup ](https://github.com/macs3-project/MACS)

```shell
# Generate the fold-change bedGraph
macs2 bdgcmp -t {input.treat_pileup.bdg} -c {input.control_lambda.bdg} \
	-m logFE -o {output.logfe.bdg}
bedGraphToBigWig {input.logfe.bdg} {input.chrom.sizes} {output.logfe.bw}

# Generate the p-value bedGraph
macs2 bdgcmp -t {input.treat_pileup.bdg} -c {input.control_lambda.bdg} \
	-m ppois -o {output.pval.bdg}
bedGraphToBigWig {input.pval.bdg} {input.chrom.sizes} {output.pval.bw}

# Generate genome coverage track
macs2 pileup -f BAMPE -i {input.bam} -o {output.bdg}
bedGraphToBigWig {input.bdg} {input.chrom.sizes} {output.bw}
```

## 5. Evaluate Library Quality

> 1. [ChIPQC](https://www.bioconductor.org/packages/release/bioc/html/ChIPQC.html): Quality metrics for ChIP-seq data, Bioconductor R package
> 1. [phantompeakqualtools](https://github.com/kundajelab/phantompeakqualtools): This R package computes informative enrichment and quality measures for ChIP-seq/DNase-seq/FAIRE-seq/MNase-seq data.

```R
library(ChIPQC)
# Create ChIPQC object
chipObj <- ChIPQC(samples, annotation = "hg38")
QCresult <- ChIPQCsample(
	reads = "/pathTo/myChIPreads.bam", genome = "mm10", 
	blacklist = "/pathTo/mm10_Blacklist.bed")
# Create ChIPQC report
ChIPQCreport(
	chipObj, reportName = "ChIP QC report: Sample", reportFolder = "ChIPQCreport")

# QC of multiple samples
bamsToQC <- c(
    "Sorted_Myc_Ch12_1.bam", "Sorted_Myc_Ch12_2.bam", "Sorted_Myc_MEL_1.bam", 
    "Sorted_Myc_MEL_2.bam", "Sorted_Input_MEL.bam", "Sorted_Input_Ch12.bam")

myQC <- bplapply(
    bamsToQC, ChIPQCsample, annotation = "mm10", blacklist = toBlkList, 
    chromosomes = paste0("chr", 1:10))
names(myQC) <- bamsToQC
QCmetrics(myQC)
```

### 1). Alignment Results

> 1. Uniquely mapped rate
> 2. PCR duplicate rate
> 3. Mitochondrial reads

### 2). Library Structure

> 1. Estimate Library Complexity
>   - PCR bottleneck coefficient (PBC): `Preseq` & `preseqR`, $ \frac {N_1} {N_d} $
> 2. Fragment Size Distribution

```shell
# Estimate the library complexity
picard EstimateLibraryComplexity I={input.bam} O={output.complexity.txt}
preseq lc_extrap -B {input.bam} -o {output.complexity.txt}
```

```shell
# Fragment Size Distribution
# deeptools
bamPEFragmentSize -p {threads} --maxFragmentLength 1000 \
	-b {input.bam} --samplesLabel {input.sample} \
	-T "Fragment Size Distribution" \
	-hist {output.fragment_size_histogram.png} \
	--table {output.fragment_size_summary.txt} \
	--outRawFragmentLengths {output.fragment_size.txt}
# shell
echo -e "insert_size\tcount" > {output}
samtools view {input.bam} | \
	awk '{if ($9 > 0) print $9}' | \
	awk -v Min=20 -v Max=1000 '{if($9 >= Min & $9 <= Max) print $9}' | \
	sort -n -S 2G | uniq -c | \
	awk '{print $2 "\t" $1}' >> {output}
```

### 3). Peaks Result

> 1. Fraction of reads in peaks (FRiP) score
> 	- $ Fraction\; of\; reads\; in\; peaks\; (FRiP) = \frac {reads\; \in \; peaks} {total\; reads} $
> 	- A typical good quality **TF (sharp / narrow peaks)** with successful enrichment would exhibit a FRiP around **5% or higher**.
> 	- A good quality **Pol2 (mix of sharp/narrow and dispersed/broad peaks)** would exhibit a FRiP of **30% or higher**.
> 	- There are also known examples of good datasets with FRiP < 1% (i.e. RNAPIII or a protein that binds few sites).
> 2. Reads overlapping in Blacklisted Regions

```shell
# Fraction of reads in peaks (FRiP)
samtools view -c -L {input.peaks} {input.bam}
bedtools intersect -u -a {input.bam} -b {input.peaks} | samtools view -c

plotEnrichment -b {input.bam} --BED {input.peaks} --smartLabels -o enrichment.png
```

Cross-correlation metric

[phantompeakqualtools](https://github.com/kundajelab/phantompeakqualtools): This package computes informative enrichment and quality measures for ChIP-seq/DNase-seq/FAIRE-seq/MNase-seq data. It can also be used to obtain robust estimates of the predominant fragment length or characteristic tag shift values in these assays.

---

# Downstream Analysis

## 1. Handling Replicates

### 1). Finding Overlapping Peaks

#### a). [bedtools](https://bedtools.readthedocs.io/en/latest)

```shell
# Union peaks
cat {input.peaks.bed} | \
	sort -k1,1 -k2,2n -k3,3n - | \
	bedtools merge -d 0 -c 5 -o max -i - | \
	awk 'BEGIN{OFS="\t"} {print $1, $2, $3, "peak"NR, $4, "."}' \
		> {output.bed}

# Overlap peaks
bedtools intersect -a {input.peaks1.bed} {input.peaks2.bed} \
	-wo >{output.overlaps.bed}

# Identifies common intervals among multiple
sort -k1,1 -k2,2n -k3,3n {input.bed} > {output.bed}
bedtools multiinter -i {input.peaks1} {input.peaks2} ... {input.peaksn}
```

>  Extended methods for high confidence peak identification
>  - After initial peak calling with MACS2, a multi-step filtering process was used to create a high-confidence consensus peak set. Briefly, peak summits were extended to 500 bp fixed-width windows and filtered against ENCODE blacklisted regions. To account for differences in sequencing depth and signal-to-noise ratios, MACS2 scores ($-log_{10}(p	ext{-value})$) were converted to "Score Per Million" (SPM) by dividing each peak score by the total sum of peak scores within the sample and scaling by $10^6$. High-confidence peaks were defined as those with an $SPM 	extgreater= 3$ that were consistently observed in at least two biological replicates with a minimum of 50% reciprocal overlap.
>  - M. Ryan Corces et al. ,The chromatin accessibility landscape of primary human cancers.Science362,eaav1898(2018). DOI:10.1126/science.aav1898

```shell
# Extract summits, slop to 500bp, filter blacklists, and resolve intra-sample redundancy
awk 'BEGIN{OFS="\t"} $1 ~ /^chr([1-9]|[1-2][0-9]|X|Y)$/ { 
		summit = $2 + $10
		print $1, summit, summit+1, $4, $8, $6 
	}' {input.narrowPeak} | \
	bedtools slop -b 250 -g {input.chrom.sizes} | \
	bedtools intersect -v -a - -b {input.blacklist.bed} | \
	sort -k1,1 -k2,2n | \
	bedtools cluster -i - | \
	sort -k7,7n -k5,5nr | \
	awk 'BEGIN{OFS="\t"} !seen[$7]++ {print $1,$2,$3,$4,$5,$6}' \
	> {output.bed}

# Calculate the sum of all peak scores for normalization
SUM_SCORE=$(awk '{s += $5} END {print s}' {input.bed})
awk -v sum="$SUM_SCORE" 'BEGIN{OFS="\t"} {
	spm = $5 * 1e6 / sum
	if (spm >= 3) {
		$5 = spm
		print $0
	}
}' output.bed > output.spm.bed

# Filter peaks present in at least 2 replicates (min 50% reciprocal overlap)
bedtools intersect -a {input.rep1.bed} \
	-b {input.rep2.bed} {input.rep3.bed} \
	-f 0.5 -r -u > {output.rep1.validated.bed}
bedtools intersect -a {input.rep2.bed} \
	-b {input.rep1.bed} {input.rep3.bed} \
	-f 0.5 -r -u > {output.rep2.validated.bed}
bedtools intersect -a {input.rep1.bed} \
	-b {input.rep1.bed} {input.rep2.bed} \
	-f 0.5 -r -u > {output.rep3.validated.bed}

# Combine all validated peaks and select the one with the highest SPM for overlapping regions
cat {input.validated.bed} | \
	sort -k1,1 -k2,2n | \
	bedtools cluster -i - | \
	sort -k7,7n -k5,5nr | \
	awk 'BEGIN{OFS="\t"} !seen[$7]++ {print $1,$2,$3,$4,$5,$6}' \
	> {output.high_confidence_consensus_peaks.bed}
```

```shell
# Script
~/Workflow/script/get_high_confidence_consensus_peaks.sh \
	-g {input.chrom.sizes} -b {input.blacklist.bed} \
	-o {output.prefix} {input.narrowPeak}
```

#### b). [GenomicRanges](https://bioconductor.org/packages/release/bioc/html/GenomicRanges.html)

```R
# Finding unique peaks
UniquePeaks <- peaks_rep1[!peaks_rep1 %over% peaks_rep2]

# Finding common peaks
CommonPeaks <- peaks_rep1[peaks_rep1 %over% peaks_rep2]

# Define a consensus, nonredundant set
allPeaksSet_Overlapping <- unlist(macsPeaks_GRL)
allPeaksSet_nR <- reduce(allPeaksSet_Overlapping)
commonPeaks <- allPeaksSet_nR[
    allPeaksSet_nR %over% peaks_rep1 & allPeaksSet_nR %over% peaks_rep2]

# Define a logical matrix describing in which samples our nonredundant peaks were present.
overlap <- list()
for (i in 1:length(macsPeaks_GRL)) {
    overlap[[i]] <- allPeaksSet_nR %over% macsPeaks_GRL[[i]]
}
overlapMatrix <- do.call(cbind, overlap)
colnames(overlapMatrix) <- names(macsPeaks_GRL)
mcols(allPeaksSet_nR) <- overlapMatrix
```

### 2). [IDR](https://github.com/nboley/idr) (ENCODE)

> The IDR (Irreproducible Discovery Rate) framework is a uniﬁed approach to measure the reproducibility of ﬁndings identiﬁed from replicate experiments and provide highly stable thresholds based on reproducibility. 
> Limitation: **Only two replicate** experiments can be performed. **Pairwise IDR** for 3 replicates.
>
> - Harvard Chan Bioinformatics Core (HBC): [Handling replicates with IDR](https://hbctraining.github.io/Intro-to-ChIPseq/lessons/07_handling-replicates-idr.html)
> - `idr`: Python (Github) or R package (CRAN)

```shell
# Sort peak by -log10(p-value)
sort -k8,8nr {input.narrowPeak} > {output.narrowPeak} 
# Peak consistency between true replicates (narrowPeak, broadPeak, bed)
idr --samples {input.peak1.bed} {input.peak2.bed} \
	--input-file-type narrowPeak --rank p.value \
	--plot -l {log} -o {output.idr.txt}
```

### 3). [MSPC](https://genometric.github.io/MSPC) & [rMSPC](https://www.bioconductor.org/packages/release/bioc/html/rmspc.html)

> MSPC: uses combined evidence from replicated experiments to evaluate peak calling output, rescuing peaks, and reduce false positives. It takes any number of replicates as input and improves sensitivity and specificity of peak calling on each, and identifies consensus regions between the input samples. MSPC comparatively evaluates ChIP-seq peaks and combines the statistical significance of repeated evidences, with the aim of lowering the minimum significance required to “rescue” weak peaks; hence reducing false-negatives.
>
> The rmspc package runs MSPC (Multiple Sample Peak Calling) software using R.

```shell
mspc -i {input.peak1.bed} {input.peak2.bed} {input.peak3.bed} \
	-r bio -w 0.05 -s 0.01 -c 3 -d {threads} -o {output.bed}
mspc -i {input.peak1.bed} {input.peak2.bed} {input.peak3.bed} \
	-r bio -w 0.05 -s 0.01 -c 3 -d {threads} \
	-p parser_config_for_MSPC.json -o {output.bed}
```

### 4). Pooling

> Pooling refers to the strategy of combining sequencing reads from multiple biological replicates into a single dataset before peak calling. In ATAC-seq or ChIP-seq analysis, pooling increases the effective sequencing depth, which improves the detection of weak regulatory signals that may not reach significance in individual replicates. Peaks identified from the pooled data often represent a comprehensive set of accessible regions shared across samples. However, pooling can obscure biological variability between replicates and may introduce peaks driven by a single outlier sample. Therefore, pooled peak sets are typically used as a reference peak universe, while replicate-level data are still used for reproducibility assessment and downstream differential accessibility analysis.
> 1. HOMER
> 2. Genrich

### 5). Others

> 1. [ChIP-R](https://github.com/rhysnewell/ChIP-R): ChIP-R uses an adaptation of the rank product statistic to assess the reproducibility of ChIP-seq peaks by incorporating information from multiple ChIP-seq replicates and "fragmenting" peak locations to better combine the information present across the replicates.

## 2. Differential Peaks

> The conventional pipeline involves **pre-defining regions** (such as, promoter, enhancer, genebody, etc.), **identifying consensus peaks** or **genomic bins** (such as, sliding windows), quantifying fragment counts within these regions, and performing differential analysis across conditions.
> 1. **Pre-defining Regions**
>     - `bedtools`, `csaw`
> 2. **Consensus Peaks**
>     - `bedtools`,
> 3. **Genomic Bins**: 
>   - Transcription factor (TF) analyses typically employ narrow window sizes (e.g., 10–20 bp) to maximize spatial resolution for detecting localized enrichment. In contrast, a minimum width of 150 bp is recommended for histone marks, reflecting the DNA length wrapped around a single nucleosome—the fundamental unit of histone enrichment. For diffuse marks, which manifest as continuous chains of adjacent histones, the combined footprint may extend across several kilobases (1–10 kbp). We propose an initial differential binding (DB) analysis using small windows to preserve resolution, whereby the dimensions of the resulting merged regions can subsequently guide the selection of an optimal final window size.
>   - `bedtools`, `csaw`

### 1). Define Enrichment Matrix

#### a). featureCount

```shell
featureCounts -T {threads} -a {input.saf} -F SAF \
	-o {output.counts} {input.bam}
```

#### b). deepTools

```shell
# Bins
multiBamSummary bins -p {threads} -bs 10000 --extendReads \
	-b {input.bam} --smartLabels --scalingFactors {output.sf} \
	-o {output.npz} --outRawCounts {output.count}
multiBigwigSummary bins -p {threads} -bs 10000 \
	-b {input.bw} --smartLabels -o {output.npz} \
	--outRawCounts {output.count}
# Peaks
multiBamSummary BED-file -p {threads} --BED {input.bed} --extendReads \
	-b {input.bam} --smartLabels --scalingFactors {output.sf} \
	-o {output.npz} --outRawCounts {output.count}
multiBigwigSummary BED-file -p {threads} --BED {input.bed} \
	-b {input.bam} --smartLabels -o {output.npz} \
	--outRawCounts {output.count}
# -bl {params.blacklist}
```

```shell
# Correlation
plotCorrelation -c spearman -p heatmap --skipZeros \
	-T "Spearman Correlation of Read Counts" -l prefix1 prefix2 ... \
	--colorMap RdYlBu --plotNumbers --plotWidth 9 --plotHeight 6 \
	-in {input.npz} -o {output.plot} --outFileCorMatrix {output.cor}
# PCA
plotPCA -T "PCA of read counts" -in {input.npz} -o {output.plot}
```

#### c). bedtools

```shell
bedtools multicov -bams {input.bam} -bed {input.bed} > {output.counts}
```

### 2). Differential Analysis

#### a). DESeq2 / edgeR

```R
metadata <- data.frame(row.names = c("WT_rep1", "WT_rep2", "KO_rep1", "KO_rep2"), "Group" = rep(c("WT", "KO"), each = 2), "Rep" = rep(c("rep1", "rep2")))
metadata

mapped_reads <- data.frame(row.names = c("WT_rep1", "WT_rep2", "KO_rep1", "KO_rep2"), "total_reads" = c(1231312, 12123123, 12312312, 12312323), 
"mapped_reads" = c(12323, 213123, 1231231, 12312312),"spikein_reads" = c(123123, 1233123, 1232, 2131))
mapped_reads$scaleFactor <- 1000000 / mapped_reads$spikein_reads
mapped_reads

matrix_spikein <- mat * mapped_reads[colnames(mat),]$scaleFactor
matrix_spikein <- round(matrix_spikein)
head(matrix_spikein)

dds <- DESeqDataSetFromMatrix(count = matrix_spikein, colData = metadata, design = ~Group)
dds <- estimateSizeFactors(dds)
print(dds$sizeFactor)

sizeFactor <- mapped_reads$mapped_reads / prod(mapped_reads$mapped_reads)^(1/length(mapped_reads$mapped_reads))
sizeFactors(dds) <- sizeFactor
print(dds$sizeFactor)
dds <- DESeq(dds)
```

#### b). [DiffBind](https://bioconductor.org/packages/release/bioc/html/DiffBind.html)

> Detection of differentially bound regions in peak data with peaks.
> Peaks counts + DESeq2 / edgeR
>
> - Ross-Innes, C., Stark, R., Teschendorff, A. *et al.* Differential oestrogen receptor binding is associated with clinical outcome in breast cancer. *Nature* **481**, 389–393 (2012). https://doi.org/10.1038/nature10730

#### c). [csaw](https://www.bioconductor.org/packages/release/bioc/html/csaw.html)

> Detection of differentially bound regions in peak data with sliding windows.
> Bins counts + edgeR
>
> - Aaron T.L. Lun, Gordon K. Smyth, *De novo* detection of differentially bound regions for ChIP-seq data using peaks and windows: controlling error rates correctly, *Nucleic Acids Research*, Volume 42, Issue 11, 17 June 2014, Page e95, https://doi.org/10.1093/nar/gku351
> - Aaron T.L. Lun, Gordon K. Smyth, csaw: a Bioconductor package for differential binding analysis of ChIP-seq data using sliding windows, *Nucleic Acids Research*, Volume 44, Issue 5, 18 March 2016, Page e45, https://doi.org/10.1093/nar/gkv1191

#### d). Others

> 1. Homer
> 1. DBChIP
> 1. [MASC2-bdgdiff](https://macs3-project.github.io/MACS/docs/bdgdiff.html): Differential peak detection based on paired four bedGraph files.
> 1. PePr
> 1. DiffReps
> 1. ChIPDiff

## 3. Peaks Annotation

1. bedtools: manual annotation

```shell
bedtools intersect -nonamecheck  -wa -wb \
	-a <(sortBed -i $prefix.bed) -b <(sortBed -i $annotation.bed) | \
	bedtools groupby -g 1-5 -c 9 -o collapse | \
	awk -v M=$type 'BEGIN{OFS="\t"}{print $0"\t"M}' >> {output.txt}
```

2. GenomicRanges: R package, manual annotation

3. ChIPseeker: R package, `annotatePeak`: peaks annotation

4. ChIPpeakAnno: R package, `assignChromosomeRegion`: peaks annotation

5. csaw: R package, `detailRanges`: peaks annotation

6. HOMER: `annotatePeaks.pl`: The process of annotating peaks/regions is divided into two primary parts. The first determines the distance to the nearest TSS and assigns the peak to that gene. The second determines the genomic annotation of the region occupied by the center of the peak/region.

```shell
annotatePeaks.pl <peak/BED file> <genome/-gtf <gtf filename> > <output file>
annotatePeaks.pl ${chip_peaks}.homer.tmp mm10 1>${chip_peaks}.peakAnn.xls 2>${chip_peaks}.annLog.txt
```

7. [GREAT](http://great.stanford.edu/public/html/): Web site, Functional enrichment, predicts functions of cis-regulatory regions
8. [rGREAT](https://www.bioconductor.org/packages/release/bioc/html/rGREAT.html): GREAT Analysis - Functional Enrichment on Genomic Regions

## 4. Motif Discovery

For details, please see: [[NGS-07 Motif Analysis]]

## 5. Visualization

### a). deepTools

```shell
# TSS
computeMatrix reference-point -p {threads} --sortRegions keep \
	--referencePoint TSS -b 3000 -a 3000 -bs 10 \
	-R {input.bed} -S {input.bw} --samplesLabel {params.sample} \
	-o {output.npz} --outFileNameMatrix {output.matrix}
```

```shell
# Genebody
awk '$3 == "gene" && $0 ~ /gene_type "protein_coding"/ {match($0, /gene_name "([^"]+)"/, name); print $1 "\t" $4-1 "\t" $5 "\t" name[1] "\t" "." "\t" $7}' {input.gtf} > {output.protein_coding_genes.bed}

computeMatrix scale-regions -p {threads} --sortRegions keep \
	--startLabel TSS --endLabel TES -m 3000 -b 2000 -a 2000 -bs 10 \
	-S {input.bw} -R {input.bed} --samplesLabel {params.sample} \
	-o {output.npz} --outFileNameMatrix {output.matrix}
# --skipZeros
# --missingDataAsZero
```

```shell
plotHeatmap --colorMap RdBu_r --boxAroundHeatmaps no \
	--heatmapHeight 18 --heatmapWidth 6 --dpi 300 \
	-m {input.npz} -out {output.png}

plotProfile --perGroup --colors green purple \
	--plotTitle "" --samplesLabel "Rep1" "Rep2" \
	--refPointLabel "TSS" -T "ChIP read density" -z "" \
	--plotFileFormat pdf --heatmapHeight 9 --heatmapWidth 6 --dpi 300 \
	-m {input.npz} -out {output.pdf}
# --whatToShow 'heatmap and colorbar'
# --zMin -4
# --zMax 4
# --startLabel "TES"
# --endLabel "TSS"
```

### b). EnrichedHeatmap

### c). Genomics Browser

> 1. [Integrative Genomics Viewer (IGV)](https://igv.org/)
> 2. [WashU Epigenome Browser](https://epigenomegateway.wustl.edu/)
> 3. [Gviz](https://bioconductor.org/packages/release/bioc/html/Gviz.html)

## 6. Toolkit

### a). [RGT](https://github.com/CostaLab/reg-gen)

> Regulatory Genomics Toolbox (RGT) is an open source python library for analysis of regulatory genomics. RGT is programmed in an oriented object fashion and its core classes provide functionality for handling regulatory genomics data.
> 1. `THOR`: ChIP-Seq differential peak caller
> 1. `HINT`: ATAC/DNase-seq footprinting method
> 1. `Motif Analysis`: TBFS match and enrichment
> 1. `RGT-Viz`: Visualization tool
> 1. `TDF`: DNA/RNA triplex domain finder



---

# Reference

1. O'Malley RC, Huang SC, Song L, Lewsey MG, Bartlett A, Nery JR, Galli M, Gallavotti A, Ecker JR. Cistrome and Epicistrome Features Shape the Regulatory DNA Landscape. Cell. 2016 May 19;165(5):1280-1292. doi: 10.1016/j.cell.2016.04.038. Erratum in: Cell. 2016 Sep 8;166(6):1598. doi: 10.1016/j.cell.2016.08.063.
2. Bartlett, A., O'Malley, R., Huang, Ss. _et al._ Mapping genome-wide transcription-factor binding sites using DAP-seq. _Nat Protoc_ **12**, 1659–1672 (2017). https://doi.org/10.1038/nprot.2017.055
3. Peter J SkeneSteven Henikoff (2017) An efficient targeted nuclease strategy for high-resolution mapping of DNA binding sites eLife 6:e21856.
4. Skene, P., Henikoff, J. & Henikoff, S. Targeted in situ genome-wide profiling with high efficiency for low cell numbers. Nat Protoc 13, 1006–1019 (2018). https://doi.org/10.1038/nprot.2018.015
5. Kaya-Okur, H.S., Wu, S.J., Codomo, C.A. et al. CUT&Tag for efficient epigenomic profiling of small samples and single cells. Nat Commun 10, 1930 (2019). https://doi.org/10.1038/s41467-019-09982-5
6. Kaya-Okur, H.S., Janssens, D.H., Henikoff, J.G. et al. Efficient low-cost chromatin profiling with CUT&Tag. Nat Protoc 15, 3264–3283 (2020). https://doi.org/10.1038/s41596-020-0373-x
7. Jinrui Xu, Michelle M Kudron, Alec Victorsen, Jiahao Gao, Haneen N Ammouri, Fabio C P Navarro, Louis Gevirtzman, Robert H Waterston, Kevin P White, Valerie Reinke, Mark Gerstein, To mock or not: a comprehensive comparison of mock IP and DNA input for ChIP-seq, Nucleic Acids Research, Volume 49, Issue 3, 22 February 2021, Page e17, https://doi.org/10.1093/nar/gkaa1155
