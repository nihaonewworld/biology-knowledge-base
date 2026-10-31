---
Title: Chromatin Accessibility
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2022-04-12
Modified: 2025-05-02
Tags:
  - ATAC-seq
---
# Introduction

## 1. Definition

**Chromatin accessibility** refers to the extent to which genomic DNA is exposed and available for interaction with regulatory proteins, including transcription factors, RNA polymerase II, and chromatin-associated factors. It is primarily governed by chromatin architecture, including nucleosome positioning, histone modifications, chromatin remodeling, and higher-order chromatin organization. Accessible chromatin is typically enriched at active cis-regulatory elements, such as promoters and enhancers, facilitating transcription factor binding and transcriptional activation. In contrast, inaccessible chromatin is generally associated with compact chromatin states and transcriptional repression.

## 2. Regulation Mechanism

<figure style="text-align: center; margin: 1em 0;">
	<img 
		src="https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fs41392-024-02030-9/MediaObjects/41392_2024_2030_Fig5_HTML.png" 
		alt="The principal methods to measure chromatin accessibility"
		style="background: white; max-width: 100%; height: auto; border-radius: 4px;" />
	<figcaption style="font-size: 1em; margin-top: 8px;">
		The primary remodellers of chromatin accessibility. 
		Adapted from 
		<a href="https://www.nature.com/articles/s41392-024-02030-9" target="_blank">
			Chen, Y. et al. Signal Transduction and Targeted Therapy (2024)
		</a>
	</figcaption>
</figure>

> The chromatin accessibility is determined by multiple regulators, mainly including chromatin remodellers (a), DNA methylation (b), histone modifications (c, d), pioneer transcription factors (e), non-coding RNAs (f), DNA sequence (g), and chromatin 3D structure (h).
> 1. Nucleosome remodeling
> 1. DNA methylationHistone modification
> 1. Pioneer transcription factors
> 1. Non-coding RNAs
> 1. Cis-regulatory element
> 1. Structure of chromatin
> 1. Environmental factors

<figure style="text-align: center;">
	<img 
		src="https://media.springernature.com/full/springer-static/image/art%3A10.1186%2F1756-8935-7-33/MediaObjects/13072_2014_Article_338_Fig1_HTML.jpg" 
		alt="The principal methods to measure chromatin accessibility"
		style="max-width: 100%; height: auto;"
	>
	<figcaption>
		Schematic diagram of current chromatin accessibility assays performed with typical experimental conditions. 
		Adapted from 
		<a href="" target="_blank">
			?
		</a>
	</figcaption>
</figure>

## 3. Biological Functions

---

# Experimental design

1. Experiments should have two or more biological replicates.
2. 25 million non-duplicate, non-mitochondrial aligned reads/fragments for single/paired-ended sequencing.
3. Alignment rate > 80% (more 95%)
4. Replicate concordance is measured by calculating IDR values (Irreproducible Discovery Rate). The experiment passes if both rescue and self consistency ratios are less than 2.
5. Library complexity is measured using the Non-Redundant Fraction (NRF) and PCR Bottlenecking Coefficients 1 and 2, or PBC1 and PBC2. The preferred values are as follows: NRF>0.9, PBC1>0.9, and PBC2>3.
6. The number of peaks within a replicated peak file should be >150,000, though values >100,000 may be acceptable. 
7. The number of peaks within an IDR peak file should be >70,000, though values >50,000 may be acceptable.
8. A nucleosome free region (NFR) must be present.
9. A mononucleosome peak must be present in the fragment length distribution. These are reads that span a single nucleosome, so they are longer than 147 bp but shorter than 147*2 bp. Good ATAC-seq datasets have reads that span nucleosomes (which allows for calling nucleosome positions in addition to open regions of chromatin).
10. The fraction of reads in called peak regions (FRiP score) should be >0.3
11. Transcription start site (TSS) enrichment

## Sequencing Technologies

<figure style="text-align: center;">
    <img 
        src="https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fs41392-024-02030-9/MediaObjects/41392_2024_2030_Fig3_HTML.png" 
        alt="The principal methods to measure chromatin accessibility"
        style="max-width: 100%; height: auto;"
    >
    <figcaption>
        The principal methods to measure chromatin accessibility. 
        Adapted from 
        <a href="https://www.nature.com/articles/s41392-024-02030-9" target="_blank">
            Chen, Y. et al. Signal Transduction and Targeted Therapy (2024)
        </a>
	</figcaption>
</figure>

### 1. ATAC-seq

> ATAC-seq (Assay for Transposase-Accessible Chromatin using sequencing) is a powerful, high-throughput method used to assess global chromatin accessibility. Its principle relies on the action of a hyperactive Tn5 transposase, which simultaneously fragments DNA and inserts sequencing adapters (tagmentation) into regions of the genome that are "open" or nucleosome-free. The workflow is remarkably streamlined, involving cell lysis to isolate nuclei, followed by Tn5-mediated tagmentation, PCR amplification, and Next-Generation Sequencing (NGS). Its primary characteristics include high sensitivity and low input requirements (typically 50,000 cells or fewer), providing a comprehensive view of active regulatory elements, nucleosome positioning, and transcription factor occupancy (footprinting).
> 1. OMNI-ATACseq

### 2. Others

> 1. Micrococcal nuclease sequencing (MNase-seq)
> 2. DNase I hypersensitive site sequencing (DNase-seq)
> 3. Formaldehyde-assisted isolation of regulatory elements sequencing (FAIRE-seq)
> 4. Nucleosome occupancy and methylome sequencing (NOMe-seq)

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

## 3. Peak Calling

### a). [MACS](https://github.com/macs3-project/MACS)

```shell
# PE Mode:
macs3 callpeak -f BAMPE --keep-dup all -g {params.gsize} \
    -q 0.01 --cutoff-analysis -B -n {params.prefix} \
    -t {input.bam} --outdir {output.dir}

# SE Mode:
macs3 callpeak -f BAM --keep-dup all -g {params.gsize} \
	--nomodel --shift -75 --extsize 150 \
    -q 0.01 --cutoff-analysis -B -n {params.prefix} \
    -t {input.bam} --outdir {output.dir}
# --nomodel --shift -37 --extsize 73 (ENCODE pipeline) 
# --nomodel --shift -75 --extsize 150 (Paper)
# --nomodel --shift -100 --extsize 200 (Histone)
```

### b). [HMMRATAC](https://github.com/LiuLabUB/HMMRATAC)

> HMMRATAC (**macs3 `hmmratac`**) is a dedicated peak calling algorithm based on Hidden Markov Model for ATAC-seq data. The basic idea behind HMMRATAC is to digest ATAC-seq data according to the fragment length of read pairs into four signal tracks: short fragments, mono-nucleosomal fragments, di-nucleosomal fragments and tri-nucleosomal fragments. Then integrate the four tracks using Hidden Markov Model to consider three hidden states: open region, nucleosomal region, and background region.
> - Evan D Tarbell, Tao Liu, HMMRATAC: a Hidden Markov ModeleR for ATAC-seq, *Nucleic Acids Research*, Volume 47, Issue 16, 19 September 2019, Page e91, https://doi.org/10.1093/nar/gkz533
> - **? Thread limits**

```shell
# Explicitly export thread limits to prevent underlying math libraries (OpenMP/MKL/OpenBLAS) from dominating all CPU cores.
export OMP_NUM_THREADS={threads}
export MKL_NUM_THREADS={threads}
export OPENBLAS_NUM_THREADS=1
        
macs3 hmmratac -f BAMPE -c 1.2 -n {input.prefix}  \
	--binsize 10 -u 20 -l 10 --hmm-type gaussian \
	-i {input.bam} --outdir {output.dir}
# -e {input.blacklist}
# -l 10k peaks & average length 500-1000 bp
# -u hundreds of extremely high enrichment and unusually wide peaks
```

### c). Others

> 1. [Genrich](https://github.com/jsh58/Genrich) is a peak-caller for genomic enrichment assays (e.g. ChIP-seq, ATAC-seq). It analyzes alignment files generated following the assay and produces a file detailing peaks of significant enrichment.
> 2. [NucleoATAC](https://github.com/GreenleafLab/NucleoATAC) is a Python package for calling nucleosomes from ATAC-seq data.

## 4. Coverage Track

### a). [deepTools](https://deeptools.readthedocs.io/en/develop/index.html)

```shell
# Generate genome coverage track
bamCoverage -p {threads} -bs 10 --normalizeUsing RPKM \
	--exactScaling --extendReads \
	-b {input.bam} -o {output.bw}
bamCoverage -p {threads} -bs 10 --normalizeUsing RPGC \
	--effectiveGenomeSize 2.1e9 -exactScaling --extendReads \
	-b {input.bam} -o {output.bw}
# -bl {params.blacklist}
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

### ENCODE Current Standards

> 1. **Replication:** A minimum of two biological replicates per condition.
> 2. **Sequencing Depth:** At least 25 million high-quality, non-duplicate, non-mitochondrial, and uniquely mapped fragments.
> 3. **Mapping Rate:** A mapping rate ranging from 80% to 95%+.
> 4. Library complexity
>     	- Non-Redundant Fraction (NRF): NRF > 0.9
>     	- PCR Bottlenecking Coefficients 1 (PBC1): PBC1 > 0.9
>
>      - PCR Bottlenecking Coefficients 2 (PBC2): PBC2 > 3
> 5. Fraction of reads in peaks (FRiP) score: FRiP > 0.2~0.3+, $FRiP = \frac { reads\ \in \ peaks } { total\ reads } $
> 6. Transcription Start Site (TSS) Enrichment Score
>     - GRCh38: TSS score > 5~7+
>     - mm10: TSS score > 10~15+
> 7. Fragment Size Distribution: Nucleosome periodicity
> 8. Nucleosome Free Regions (NFR) score: $NFR= \frac { fragments (<150bp) } { total\ fragments } $
> 9. etc.

### Tools & Code

> 1. [ATACseqQC](https://www.bioconductor.org/packages/release/bioc/html/ATACseqQC.html): ATAC-seq quality control, Bioconductor R package
> 2. [ataqv](https://github.com/ParkerLab/ataqv): ATAC-seq quality control and visualization
>     - Orchard, Peter et al. Quantification, Dynamic Visualization, and Validation of Bias in ATAC-Seq Data with ataqv. Cell Systems, Volume 10, Issue 3, 298 - 306.e4

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

```shell
# Fraction of reads in peaks (FRiP)
samtools view -c -L {input.peaks} {input.bam}
bedtools intersect -u -a {input.bam} -b {input.peaks} | samtools view -c

# Transcription Start Site (TSS) Enrichment
Picard CollectTssMetrics
```

---

# Downstream Analysis

> Notes:
>
> 1. reads should be shifted + 4 bp and − 5 bp for positive and negative strand respectively, to account for the 9-bp duplication created by DNA repair of the nick by Tn5 transposase and achieve base-pair resolution of **TF footprint** and **motif-related** analyses.

## 1. Handling Replicates

## 2. Differential Accessibility

## 3. Peaks Annotation

## 4. Motif Discovery

## 5. Visualization 

## 6. TF Footprinting

### a). [HINT-ATAC](https://github.com/CostaLab/reg-gen)

> HINT (Hmm-based IdeNtification of Transcription factor footprints) is a framework that uses open chromatin data to identify the active transcription factor binding sites
> - Since HINT-ATAC does not support duplicate samples, data from biological duplicates are usually combined before analysis.
> - Li, Z., Schulz, M.H., Look, T. et al. Identification of transcription factor binding sites using ATAC-seq. Genome Biol 20, 45 (2019). https://doi.org/10.1186/s13059-019-1642-2

```shell
# rgt v1.0.2 (2023-01-31)
# python v3.7
conda create -n rgt -y -c bioconda rgt
pip install RGT
```

```shell
# ATAC-seq
# Call footprint (force the use of all computing cores, ~ 40 min)
rgt-hint footprinting --atac-seq --paired-end --organism mm10 \
	--output-prefix {output.prefix} --output-location {output.dir} \
	{input.bam} {input.narrowPeak}
# output: {output.footprint.bed}

# Output signals for visualization in a genome browser (~ 20 min)
# libpng12.so.0
rgt-hint tracks --bc --bigWig --organism mm10 \
	--output-prefix {output.prefix} --output-location {output.dir} \
	{input.bam} {input.narrowPeak}

# Match motif for footprints (~ 20 min)
rgt-motifanalysis matching --organism mm10 \
	--motif-dbs {input.motif.dir} --output-location {output.dir} \
	--input-files {input.treat.footprint.bed} {input.ctrl.footprint.bed}
# --motif-dbs {input.motif.dir} error
# output: {output.mpbs.bed}

# Differential footprints (~ 60 min)
rgt-hint differential --nc {threads} --organism mm10 \
	--bc --lfc 0.1 --fdr 0.05 --window-size 200 \
	--mpbs-files {input.treat.mpbs.bed},{input.ctrl.mpbs.bed} \
	--reads-files {input.treat.bam},{input.ctrl.bam} \
	--conditions {input.treat.names},{input.ctrl.names} \
	--output-prefix {output.prefix} --output-location {output.dir}
```

```shell
# DNase-seq
rgt-hint footprinting --dnase-seq --bias-correction --organism mm10 \
	--output-location {output.dir} --output-prefix {output.prefix} \
	{input.bam} {input.bed}
# Histone
rgt-hint footprinting --histone {input.bam} {input.bed}
```

### b). [TOBIAS](https://github.com/loosolab/TOBIAS)

> Transcription factor Occupancy prediction By Investigation of ATAC-seq Signal.
> - Since TOBIAS does not support duplicate samples, data from biological duplicates are usually combined before analysis.
> - Bentsen, M., Goymann, P., Schultheis, H. et al. ATAC-seq footprinting unravels kinetics of transcription factor binding during zygotic genome activation. Nat Commun 11, 4267 (2020). https://doi.org/10.1038/s41467-020-18035-1

```shell
# tobias v0.17.3 (2025-12-03)
# python 3.12, pandas < v3.0
conda create -n tobias -y -c bioconda tobias pandas=2.3
```

```shell
# Correct reads for Tn5 sequence bias (~ 20 min)
TOBIAS ATACorrect --cores {threads} --genome {input.genome.fa} \
	--bam {input.bam} --peaks {input.bed} --prefix {output.prefix} \
	--blacklist {input.blacklist.bed} --outdir {output.dir}

# Calculate footprint scores per condition (~ 10 min)
TOBIAS ScoreBigwig --cores {threads} --score footprint \
	--signal {input.corrected.bw} --regions {input.bed} \
	--output {output.footprints.bw}

# Merge peaks
cat {input.bed} | sort -k1,1 -k2,2n | \
	bedtools cluster -i - | sort -k7,7n -k5,5nr | \
	awk 'BEGIN{OFS="\t"} !seen[$7]++ {print $1,$2,$3,$4,$5,$6}' > {output.merge.bed}
# Estimate differential binding between treat and ctrl. (~ 30 min)
TOBIAS BINDetect --cores {threads} --genome {input.genome.fa} \
	--motifs {input.motif} --signals {input.ctrl.bw} {input.treat.bw} \
	--peaks {input.merge.bed} --peak_header {input.bed_header.txt} \
	--cond_names {input.ctrl} {input.treat} \
	--prefix {output.prefix} --outdir {output.dir}
# Estimate bound sites from scored file
TOBIAS BINDetect --cores {threads} --genome {input.genome.fa} \
	--motifs {input.motif} --signals {input.footprints.bw} \
	--peaks {input.bed} --peak_header {input.bed_header.txt} \
	--cond_names {input.prefix} --prefix {output.prefix} \
	--outdir {output.dir}
# motif: PFM, JASPAR or MEME format
```

```shell
# Visualization
TOBIAS PlotAggregate --TFBS {input.bed} --signals {input.bw} \
	--share_y both --plot_boundaries --signal-on-x \
	--output {output.footprint_comparison_all.pdf}
```

### c). Others

> 1. [diffTF](https://git.embl.org/grp-zaugg/diffTF)
> 	- diffTF to calculate differential TF activity (basic mode) and classify TFs into putative transcriptional activators or repressors (classification mode).
> 	- Berest, Ivan et al. Quantification of Differential Transcription Factor Activity and Multiomics-Based Classification into Activators and Repressors: diffTF. Cell Reports, Volume 29, Issue 10, 3147 - 3159.e12.
> 2. [chromVAR](https://github.com/GreenleafLab/chromVAR)
> 	- chromVAR is an R package for the analysis of sparse chromatin accessibility data from single cell or bulk ATAC or DNAse-seq data. The package aims to identify motifs or other genomic annotations associated with variability in chromatin accessibility between individual cells or samples. [Bioconductor R package](https://bioconductor.org/packages/release/bioc/html/chromVAR.html)
> 	- Schep, A., Wu, B., Buenrostro, J. et al. chromVAR: inferring transcription-factor-associated accessibility from single-cell epigenomic data. Nat Methods 14, 975–978 (2017). https://doi.org/10.1038/nmeth.4401
> 3. [pyDNase](https://github.com/jpiper/pyDNase)
> 	- pyDNase is a suite of tools for analysing DNase-seq data - pyDNase comes with several analysis scripts covering several common use cases of DNase-seq analysis, and also an implementation of the Wellington, Wellington 1D, and Wellington-boostrap footprinting algorithms.
> 	- Jason Piper, Markus C. Elze, et al. Wellington: a novel method for the accurate identification of digital genomic footprints from DNase-seq data, *Nucleic Acids Research*, Volume 41, Issue 21, 1 November 2013, Page e201, https://doi.org/10.1093/nar/gkt850

## 7. Nucleosome Positions & Occupancy

### a). [NucleoATAC](https://github.com/GreenleafLab/NucleoATAC)

> NucleoATAC is a python (v2.7) package for calling nucleosome positions and occupancy using ATAC-Seq data.
> - Schep AN, Buenrostro JD, Denny SK, Schwartz K, Sherlock G, Greenleaf WJ. Structured nucleosome fingerprints enable high-resolution mapping of chromatin architecture within regulatory regions. Genome Res. 2015 Nov;25(11):1757-70. doi: 10.1101/gr.192294.115.

```shell
nucleoatac run --fasta {input.genome.fa} --bam {input.bam} \
	--bed {input.bed} --out {output.prefix}
```

---

# Reference

1. Albert, I., Mavrich, T., Tomsho, L. et al. Translational and rotational settings of H2A.Z nucleosomes across the Saccharomyces cerevisiae genome. Nature 446, 572–576 (2007). https://doi.org/10.1038/nature05632
2. Boyle, Alan P. et al. High-Resolution Mapping and Characterization of Open Chromatin across the Genome. Cell, Volume 132, Issue 2, 311-322 (2008).
3. Gaulton, K., Nammo, T., Pasquali, L. et al. A map of open chromatin in human pancreatic islets. Nat Genet 42, 255–259 (2010). https://doi.org/10.1038/ng.530
4. Liu Y, Lay FD, Liang G, Berman BP, Jones PA, Kelly T. Genome-wide Mapping of Nucleosome Positioning and DNA Methylation Within Individual DNA Molecules. J Biomol Tech. 2012;23
5. Buenrostro, J., Giresi, P., Zaba, L. et al. Transposition of native chromatin for fast and sensitive epigenomic profiling of open chromatin, DNA-binding proteins and nucleosome position. Nat Methods 10, 1213–1218 (2013). https://doi.org/10.1038/nmeth.2688
6. Klemm, S.L., Shipony, Z. & Greenleaf, W.J. Chromatin accessibility and the regulatory epigenome. Nat Rev Genet 20, 207–220 (2019). https://doi.org/10.1038/s41576-018-0089-8
7. Chen, Y., Liang, R., Li, Y. et al. Chromatin accessibility: biological functions, molecular mechanisms and therapeutic application. Sig Transduct Target Ther 9, 340 (2024). https://doi.org/10.1038/s41392-024-02030-9 
8. Tsompana, M., Buck, M.J. Chromatin accessibility: a window into the genome. Epigenetics & Chromatin 7, 33 (2014). https://doi.org/10.1186/1756-8935-7-33
9. Buenrostro, J.D. , Wu, B. , Chang, H.Y. , and Greenleaf, W.J. , 2015. ATAC-seq: A Method for Assaying Chromatin Accessibility Genome-Wide. Curr. Protoc. Mol. Biol. 109: 21.29.1-21.29.9. doi: 10.1002/0471142727.mb2129s109
10. Smith, J. P., & Sheffield, N. C. (2020). Analytical approaches for ATAC-seq data analysis. Current Protocols in Human Genetics, 106, e101. doi: 10.1002/cphg.101
11. Grandi, F.C., Modi, H., Kampman, L. et al. Chromatin accessibility profiling by ATAC-seq. Nat Protoc 17, 1518–1552 (2022). https://doi.org/10.1038/s41596-022-00692-9
12. Jason P Smith, M Ryan Corces, Jin Xu, Vincent P Reuter, Howard Y Chang, Nathan C Sheffield, PEPATAC: an optimized pipeline for ATAC-seq data analysis with serial alignments, *NAR Genomics and Bioinformatics*, Volume 3, Issue 4, December 2021, lqab101, https://doi.org/10.1093/nargab/lqab101
13. [Cebola lab pipeline for the analysis of ATAC-seq data](https://github.com/CebolaLab/ATAC-seq)
14. [ENCODE ATAC-seq pipeline](https://github.com/ENCODE-DCC/atac-seq-pipeline)
15. [Harvard Informatics ATAC-seq pipeline](https://github.com/harvardinformatics/ATAC-seq)
