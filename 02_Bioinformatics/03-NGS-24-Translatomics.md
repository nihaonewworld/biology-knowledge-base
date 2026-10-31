---
Title: Translatomics
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2022-06-06
Modified: 2023-07-10
Tags:
  - RNA-seq
  - Ribo-seq
  - Polysome-seq
---
# Introduction

**Translatomics** is the comprehensive study of all RNA molecules being translated into proteins within a cell at a specific time. While transcriptomics measures total mRNA levels, translatomics focuses on the **actively translating mRNA** pool, providing a more accurate proxy for protein abundance. Its principle is to isolate mRNA-ribosome complexes to determine which transcripts are efficiently utilized by the cellular machinery. The workflow typically employs specialized techniques such as **Ribo-seq** (Ribosome Profiling) or **Polysome Profiling**, followed by high-throughput sequencing. A defining feature of translatomics is its ability to bridge transcription and protein synthesis, enabling the investigation of regulatory mechanisms, including translational efficiency, ribosome pausing or stalling, and the use of alternative open reading frames (ORFs).

## Library Strategy

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://media.springernature.com/full/springer-static/image/art%3A10.1186%2Fs40364-024-00562-4/MediaObjects/40364_2024_562_Fig1_HTML.png" 
        alt="Experimental workflow and methodology overview from Biomarker Research publication"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> Overview of the experimental workflow and methodology. 
        Adapted from <a href="https://doi.org/10.1186/s40364-024-00562-4" target="_blank" rel="noopener noreferrer">Biomarker Research (2024)</a>.
    </figcaption>
</figure>

### (1). Ribo-Seq

Ribo-seq (ribosome profiling, ribosome footprinting) is a powerful sequencing-based approach that captures a high-resolution snapshot of the translatome at near single-codon resolution. The method exploits the fact that ribosomes bound to mRNA protect a short region—approximately 28–30 nucleotides—from RNase digestion. These protected RNA fragments, termed ribosome-protected fragments (RPFs) or “footprints,” are isolated and sequenced to precisely delineate regions of the transcriptome undergoing active translation. The typical workflow includes cell lysis, RNase digestion, ribosome isolation (via ultracentrifugation or affinity-based purification), RPF recovery, and library preparation for next-generation sequencing (NGS). Key features of Ribo-seq include its ability to accurately define translated open reading frames (ORFs), identify translation initiation and termination sites, and quantify translational efficiency with substantially higher precision than conventional RNA-seq.

Active ribosome profiling (Active Ribo-seq) selectively captures ribosomes that are actively engaged in peptide elongation, thereby distinguishing translationally active ribosomes from stalled or inactive populations. This refinement provides a more accurate assessment of translational efficiency and dynamic ribosome behavior.

> - Active ribosome profiling procedure
>   1. Cell harvesting, following rapid arrest of ribosome translocation using elongation inhibitors (e.g., cycloheximide) or flash freezing to preserve ribosome positions;
>   2. RNase digestion of cell lysates, followed by isolation of ribosome-protected RNA fragments via ultracentrifugation using sucrose gradient fractionation or a sucrose cushion;
>   3. rRNA depletion to minimize mapping bias, and dissociation of ribosomes to recover ribosome-protected fragments (RPFs), also referred to as ribosome footprints;
>   4. Library preparation for sequencing;
>   5. Deep sequencing of RPFs and downstream bioinformatic analysis to generate translatomic profiles.

### (2). Polysome Profiling

Polysome-seq (Polysome Profiling followed by sequencing) is a classical translatomics technique used to measure the translational activity of mRNAs by physical separation based on their ribosome "loading." The principle relies on sucrose gradient ultracentrifugation, where mRNA-ribosome complexes are separated by density; mRNAs bound by multiple ribosomes (polysomes) sediment faster and are considered to be under high translational activity, whereas those bound by zero or one ribosome (monosomes) represent low activity. The workflow includes stabilizing ribosomes with cycloheximide (CHX), cell lysis, ultracentrifugation, and continuous fractionation with ultraviolet ($A_{254}$) monitoring, followed by RNA extraction and sequencing of the "heavy" polysome fractions. Its primary characteristic is the ability to provide a macro-view of translational efficiency for full-length transcripts, making it ideal for studying global shifts in protein synthesis during stress or development.

> - Polysome profiling procedure
>   1. Translational arrest and cell lysis: Elongation inhibitors such as cycloheximide or emetine are added to prevent ribosome run-off from mRNA transcripts. Cells—typically harvested during the proliferative phase—are lysed, and the cytoplasmic fraction is isolated from total cell lysates.
>   2. Sucrose gradient fractionation: Cytoplasmic extracts are subjected to sucrose gradient ultracentrifugation to separate mRNAs according to the number of associated ribosomes (monosomes versus polysomes).
>   3. Fraction collection and monitoring: Gradients are passed through an automated fractionation system equipped with UV absorbance detection (e.g., Biocomp density gradient fractionation systems) to monitor ribosomal particle distribution and collect discrete fractions.
>   4. RNA recovery: mRNAs are purified from individual sucrose fractions for downstream analysis.
>   5. Downstream analysis: The distribution of specific transcripts is assessed using reverse transcription quantitative PCR (RT-qPCR) or northern blotting, while genome-wide translational activity can be evaluated using microarray analysis or RNA sequencing (RNA-seq).

### (3). Others

> 1. TRAP-seq (Translating ribosome affinity purification sequencing)
> 2. RNC-seq (Ribosome nascent chain complex sequencing)
> 3. enhanced Ribo-seq / Ribo-lite
> 4. scRibo-seq (Single-cell ribosome sequencing)

---

# Data Preprocessing

For more details, please see: [[NGS-21-Transcriptomics-GeneExpression]]

---

# Upstream Processing

## *Workflow 1:* Ribo-Seq

### 1. Alignment

#### (1). [STAR](https://github.com/alexdobin/STAR)

```shell
# Single-end sequencing
STAR --runThreadN {threads} --genomeDir {input.index} \
    --readFilesIn {input.fq} --readFilesCommand zcat \
    --outSAMattributes All --outSAMtype BAM Unsorted \
    --alignEndsType EndToEnd --outFilterMultimapNmax 1 \
    --quantMode TranscriptomeSAM \
    --outFileNamePrefix {params.prefix}

# --outFilterScoreMinOverLread 0.33
# --outFilterMatchNminOverLread 0.33
```

#### (2). [HISAT2](https://daehwankimlab.github.io/hisat2)

```shell
# Single-end sequencing
hisat2 -p {threads} -x {input.index} -U {input.fq} \
    --new-summary --summary-file {output.summary} | \
    samtools sort -@ 2 -n -O bam -o {output.bam}
```

### 2. Quantification

#### (1). [featureCounts](https://subread.sourceforge.net)

```shell
featureCounts -T {threads} --primary --ignoreDup \
    -g gene_id -t CDS --extraAttributes gene_name,gene_type \
    -a {input.gtf} -o {output} {input.bam}
```

#### (2). [HTseq](https://htseq.readthedocs.io/en/latest)

```shell
htseq-count -f bam -r name -a 10 -m union --nonunique none \
    --additional-attr=gene_name --additional-attr=gene_type \
    --secondary-alignments=ignore --supplementary-alignments=ignore \
    -t CDS -i gene_id -c {output} {input.bam} {input.gtf}
```

### 3. Quality Control

1. length of clean reads or mapped reads
    - 26~34 nt

```shell
zcat {input.fq} | awk 'NR % 4 == 2 { print length($0) }' | \
    sort -n | uniq -c | awk '{print $2, $1}' > {output.txt}
```

2. Distribution of reads in the reference genome

[Ribo-seQC](https://github.com/ohlerlab/RiboseQC) is an R package that performs quality control analysis of small RNA-seq data, with a focus on Ribo-seq and related techniques.

3. Identification Of The Ribosome P-site

[riboWaltz](https://github.com/LabTranslationalArchitectomics/riboWaltz) is an R package for calculation of optimal P-site offsets, diagnostic analysis and visual inspection of ribosome profiling data. Taking advantage of a two-step algorithm where offset information is passed through populations of reads with different length in order to maximize offset coherence, riboWaltz computes with high precision the P-site offset. riboWaltz also provides a variety of graphical representations, laying the foundations for further accurate RiboSeq analyses and improved interpretation of positional information.

4. Predicts Ribosomal Pause Sites

[Pausepred](https://github.com/romikasaini/Pausepred_offline) predicts ribosomal pause sites using mapped Ribo-seq data (in sorted BAM format).


```shell
# Step 1: Convert binary BAM alignment file to text-based BED format
bedtools bamtobed -i {input.bam} > {output.bed}

# Step 2: Calculate individual read lengths by subtracting start coordinate ($2) from end coordinate ($3)
# Output the lengths as a single-column CSV file for downstream length distribution analysis (QC)
awk 'BEGIN{FS=OFS="\t"} {print $3-$2}' {input.bed} > {output.reads.length.csv}

# Step 3: Annotate alignments with genomic features (CDS, UTRs, Introns)
# Each matching read in the BAM file will be tagged with a custom attribute (e.g., YB:Z:CDS)
bedtools tag -i {input.bam} \
    -files CDS.bed five_prime_utr.bed three_prime_utr.bed intron.bed \
    -labels CDS 5UTR 3UTR Introns > {output.tmp.bam}

# Step 4: Quantify and summarize the distribution of reads across different genomic features
# 1. 'samtools view' converts the tagged BAM back to SAM text stream
# 2. 'awk' filters lines containing the feature tag ("YB:Z:") and extracts the feature name (e.g., CDS, 5UTR)
# 3. 'sort | uniq -c' counts the occurrences of each genomic feature
# 4. 'sort -n' sorts the final counts in ascending order for the quality control report
samtools view {input.tmp.bam} | \
    awk -F"YB:Z:" '/YB:Z:/{split($2, a, ";"); print a[1]}' | \
    sort | uniq -c | sort -n > {output.feature.stat.txt}
```

## *Workflow 2:* Polysome-Seq

For more details, please see: [[NGS-21-Transcriptomics-GeneExpression]]

---

# Downstream Analysis

## 1. Translation Efficiency Analysis

1. DESeq2
2. [anota2seq](https://www.bioconductor.org/packages/release/bioc/html/anota2seq.html): Generally applicable transcriptome-wide analysis of translational efficiency using anota2seq
3. [deltaTE](https://github.com/SGDDNB/translational_regulation): Detection of Translationally Regulated Genes by Integrative Analysis of Ribo-seq and RNA-seq Data
4. [RiboDiff](https://github.com/ratschlab/RiboDiff) is a statistical tool to detect the protein translation efficiency change from ribosome footprint profiling data and RNA-Seq data under two different experimental conditions. require Python 2
5. [Xtail](https://github.com/xryanglab/xtail): Genome-wide assessment of differential translations with ribosome profiling data

## 2. ORFs Analysis

> 1. main open reading frame (mORF)
> 2. upstream open reading frame (uORF)
>   - produce proteins called uPeptides
>   - regulatory role related to translation control of main ORF
> 3. downstream open reading frame (dORF)

1. [Ribo-TISH](https://github.com/zhpn1024/ribotish) identifying translation activities using ribosome profiling data.

```shell
ribotish quality -p {threads} -l 25,35 \
    -b {input.bam} -g {input.gtf} \
    -o {output.qual.txt} \
    -f {output.qual.pdf} \
    -r {output.para.py}

ribotish predict -p {threads} \
    --longest --seq --inframecount \
    -g {input.gtf} -f {input.fa} \
    -b {input.bam} --ribopara {input.para.py} \
    -o {output.pred.longest.txt}
```

2. [RiboCode](https://github.com/xryanglab/RiboCode) is a very simple but high-quality computational algorithm to identify genome-wide translated ORFs using ribosome-profiling data. Zhengtao Xiao, Rongyao Huang, Xudong Xing, Yuling Chen, Haiteng Deng, Xuerui Yang, _De novo_ annotation and characterization of the translatome with ribosome profiling data, _Nucleic Acids Research_, Volume 46, Issue 10, 1 June 2018, Page e61, [https://doi.org/10.1093/nar/gky179](https://doi.org/10.1093/nar/gky179).
3. [Plastid](https://github.com/joshuagryphon/plastid)
4. [PRICE](https://github.com/erhard-lab/price) (Probabilistic inference of codon activities by an EM algorithm) is a method to identify ORFs using Ribo-seq experiments embedded in a pipeline for data analysis.
5. [ribotricer](https://github.com/smithlabcode/ribotricer): Accurate detection of short and long active ORFs using Ribo-seq data
6. [RibORF](https://github.com/zhejilab/RibORF): Identifying genome-wide translated open reading frames using ribosome profiling.
7. [RiboWave](https://github.com/lulab/Ribowave) is a funtional Ribo-seq analysis tool to identify translated ORF based on Ribo-seq data.
8. [RiboTaper](https://github.com/boboppie/RiboTaper): Detecting actively translated open reading frames in ribosome profiling data

---

# Reference

1. Su, D., Ding, C., Qiu, J. et al. Ribosome profiling: a powerful tool in oncological research. Biomark Res 12, 11 (2024). https://doi.org/10.1186/s40364-024-00562-4
2. Kotaro Tomuro, Shintaro Iwasaki; Advances in ribosome profiling technologies. Biochem Soc Trans 30 June 2025; 53 (03): 555–564. doi: https://doi.org/10.1042/BST20253061
3. Nicholas T. Ingolia et al. ,Genome-Wide Analysis in Vivo of Translation with Nucleotide Resolution Using Ribosome Profiling.Science324,218-223(2009).DOI:10.1126/science.1168978
4. Nicholas T. Ingolia, Liana F. Lareau, Jonathan S. Weissman, Ribosome Profiling of Mouse Embryonic Stem Cells Reveals the Complexity and Dynamics of Mammalian Proteomes, Cell, Volume 147, Issue 4, 2011, Pages 789-802, https://doi.org/10.1016/j.cell.2011.10.002.
5. Hsieh, A., Liu, Y., Edlind, M. et al. The translational landscape of mTOR signalling steers cancer initiation and metastasis. Nature 485, 55–61 (2012). https://doi.org/10.1038/nature10912
6. Ingolia, N., Brar, G., Rouskin, S. et al. The ribosome profiling strategy for monitoring translation in vivo by deep sequencing of ribosome-protected mRNA fragments. Nat Protoc 7, 1534–1550 (2012). https://doi.org/10.1038/nprot.2012.086
7. Inada T, Winstall E, Tarun SZ Jr, Yates JR 3rd, Schieltz D, Sachs AB. One-step affinity purification of the yeast ribosome and its associated proteins and mRNAs. RNA. 2002 Jul;8(7):948-58. doi: 10.1017/s1355838202026018.
8. Tong Wang, Yizhi Cui, Jingjie Jin, Jiahui Guo, Guibin Wang, Xingfeng Yin, Qing-Yu He, Gong Zhang, Translating mRNAs strongly correlate to proteins in a multivariate manner and their translation ratios are phenotype specific, Nucleic Acids Research, Volume 41, Issue 9, 1 May 2013, Pages 4743–4754, https://doi.org/10.1093/nar/gkt178
9. VanInsberghe, M., van den Berg, J., Andersson-Rolf, A. et al. Single-cell Ribo-seq reveals cell cycle-dependent translational pausing. Nature 597, 561–565 (2021). https://doi.org/10.1038/s41586-021-03887-4