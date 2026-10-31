---
Title: Transcriptomics
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2020-04-20
Modified: 2023-07-01
Tags:
  - RNA-seq
---
# Introduction

**Transcriptomics** is the study of the complete set of RNA transcripts produced by a cell or tissue under specific conditions, including mRNA, lncRNA, and miRNA. Its main goal is to understand how gene expression is regulated across different times, tissues, or physiological states, thereby revealing gene functions and biological processes. Depending on the research focus, transcriptomics can include **total RNA-seq, mRNA-seq, small RNA-seq, and single-cell RNA-seq (scRNA-seq)**. Common techniques include the **microarray** and **high throughput RNA sequencing (RNA-seq)**. Among these, RNA-seq has become the dominant approach due to its high sensitivity, wide dynamic range, and ability to detect novel transcripts and alternative splicing events.

## RNA Type

|   Type   |             Name              |             Function             | Mass (%)  | Size (nt) |
| :------: | :---------------------------: | :------------------------------: | :-------: | :-------: |
|   mRNA   |         Messenger RNA         |          Coding protein          |   ~ 1-5   | 200-30000 |
| pre-mRNA |        Precursor mRNA         |        Splicing precursor        | Transient |  introns  |
|   rRNA   |         Ribosomal RNA         |           Translation            |   ~ 80    | 120-5000  |
|   tRNA   |         Transfer RNA          |           Translation            |  ~ 10-15  |   75-95   |
|  lncRNA  |      Long non-coding RNA      | Regulation of gene transcription |    < 1    |   > 200   |
|  miRNA   |           Micro RNA           | Post-transcriptional regulators  |   < 0.1   |   21-25   |
|  siRNA   |     Small interfering RNA     |         RNA interference         |   < 0.1   |   20-25   |
|  piRNA   |     PIWI-interacting RNA      |       Transposon silencing       |   < 0.1   |   24-32   |
|  snRNA   |       Small nuclear RNA       |         re-mRNA splicing         |    ~ 1    |  100-300  |
|  snoRNA  |      Small nucleolar RNA      |     Nucleotide modification      |    < 1    |  60-170   |
|  scaRNA  | Small cajal body-specific RNA |        snRNA modification        |   < 0.1   |  60-300   |
| circRNA  |         Circular RNA          |  Regulation of gene expression   |   < 0.1   | 100-2000  |
|   eRNA   |         Enhancer RNA          |        Enhancer activity         |   < 0.1   |  50-2000  |
|   tRFs   |    tRNA-derived fragments     |            Regulation            |   < 0.1   |     -     |

## Experimental Design

### Sample

> 1. Biological replicates
> 	- All experiments should be conducted with at least two biological replicates.
> 	- A biological replicate is defined as an independently cultivated cell or tissue sample subjected to separate downstream analyses.
> 	- At the gene level, quantification must yield a Spearman’s rank correlation coefficient exceeding 0.9 for isogenic replicates and 0.8 for anisogenic replicates.
> 2. Technical Replicates: Not very meaningful

### RNA Extraction

> 1. RNA input amounts
> 	- Common: 10 ng to 1 µg
> 	- Ultra-low input: 1 ng
> 2. RNA is isolated from the sample and contaminating DNA is removed with DNase.
> 3. RNA QC
>	- RNA concentration
>	- RNA purity (A260/A280 ratio)
>	- RNA integrity (RNA integrity number, RIN)
>	- DV200 (the percentage of fragments >200 nt)
> 4. RNA Extraction
> 	- **mRNAs** are selected via hybridisation to oligo-dT, which uses oligo-dT magnetic beads to selectively recover mature mRNA by forming a duplex with their polyadenylated (poly-A)tails. (mRNAs, poly-A non-coding RNAs, some mitochondrial mRNAs)
> 	- Ribosomal sequences are removed via hybridisation, whereby complementary oligos bind to and remove the rRNA. RNase H can selectively degrade ribosomal RNA (rRNA) and remove it from the total RNA. (poly-A RNAs, immature mRNAs and non-polyadenylated ncRNAs)
> 	- Small RNAs can be enriched by size selection. This can be achieved through the electrophoretic separation of total RNA on agarose or acrylamide gels or via solid-phase extraction. (small ncRNAs such as miRNA, siRNA, and piRNAs)
> 	- circular RNA, RNase R is a 3′→5′ exoribonuclease that efficiently degrades most linear RNAs, leaving circular RNAs intact due to their lack of free ends.
> 	- Copy-number normalisation via duplex-specific nuclease digestion (DSN) is a technique that partially normalises the concentrations of each mRNA by selectively removing many of the most abundant transcripts. This effectively increases the relative concentration of low abundance transcripts. (Low abundance transcripts)
> 	- Targeted RNA: Targeted RNA-seq involves the use of custom-designed probes or primers to selectively enrich particular transcripts or regions of interest within a complex RNA sample.
> 	- tRNA-seq: Hydro-tRNAseq, ARM-seq
> 	- rRNA-seq
> 5. Fragmentation and size selection: 40~400 bp
> 	- **Enzymatic**: The most commonly used enzymatic reaction is that of E. coli RNase III, which randomly cleaves double-stranded regions of RNA, resulting in the formation of a 5′ phosphate group and a 3′ hydroxyl group.
> 	- **Metal ion**: The most commonly used ions are Zn²⁺ and Mg²⁺. Fragmentation is performed at high temperatures (70-90 °C) and a slightly alkaline pH (pH 8–9). The reaction can easily be stopped by adding a metal chelator, such as EDTA.
> 	- **Heat**: Heating RNA in water at 95 °C for 30 minutes can fragment it.
> 	- **Sonication**: RNA can be fragmented using sonication. This process uses high-intensity sound waves to produce micro-bubbles that, when they collapse, release large amounts of energy capable of breaking RNA bonds.

### Library Preparation

> 1. Strand-specific protocol
> 	- Non-stranded library
> 	- Strand-specific library
> 		- **Reverse strand-specific library, fr-firststrand, RF**: Read 1 is antisense to the original RNA, while Read 2 is sense to it.
> 		- Forward strand-specific library, fr-secondstrand, FR: Read 1 is sense to the original RNA, while Read 2 is antisense to it.
> 2. UMI library
> 3. PCR amplification, run as few amplification cycles as possible to avoid PCR artefacts.

| Method | Library Type | Kits |
| - | - | - |
| Non-stranded Library | fr-unstranded | - |
| dUTPs | fr-firststrand (RF / R) | NEBNext |
| SMART | fr-firststrand (RF / R)  | SMARTer |
| NNSR priming | fr-firststrand (RF / R)  | - |
| RNA Ligation | fr-secondstrand (FR / F) | Illumina |

### Sequencing

> 1. Sequencing depths
>	- mRNA-seq: 10-25 million aligned reads/mate-pairs.
>	- Total RNA-seq: 30 million aligned reads/mate-pairs.
>	- Small RNA-seq: 1~10 million aligned reads/mate-pairs.
>	- Alternative splicing: 60 million aligned reads/mate-pairs.
>	- Transcriptome reconstruction or discovery of novel transcripts: 100~200 million aligned reads/mate-pairs.
> 2. Sequencing read length
> 	- Small RNA-seq: SE50
> 3. Sequencing read types
> 	- Paired-end sequencing (PE)
> 	- Single-end sequencing (SE)
> 4. Sequencing platforms
>	- Illumina systems: 50 ~ 300 bp
>	- Ion Torrent: ~ 600 bp
>	- Pacific Biosciences (PacBio): 10 ~ 25 kb
>	- Oxford Nanopore (ONT): 10 ~ 25 kb

---

# Data Preprocessing

## 1. Evaluate Sequence Quality

> 1. FastQC

## 2. UMI Extraction (Optional)

> 1. UMI-tools
> 2. Cutadapt
> 3. fastp

## 3. Trim Reads

> 1. Trimmomatic
> 2. Trim Galore
> 3. Cutadapt
> 4. fastp

## 4. Remove rRNA (Optional)

### (1). Bowtie2

```shell
# Paired-end sequencing
bowtie2 -p {threads} -x {input.index} --no-unal \
	--un-conc-gz {params.prefix} -1 {input.fq1} -2 {input.fq2} | \
	samtools view -@ 1 -b -o {output.bam}

# Single-end sequencing
bowtie2 -p {threads} -x {input.index} --no-unal \
	--un-gz {output.fq} -U {input.fq} | \
	samtools view -@ 1 -b -o {output.bam}

# ARTR-seq: --seedlen=15
```

### (2). Bowtie

### (3). [SortMeRNA](https://github.com/sortmerna/sortmerna)

SortMeRNA is a local sequence alignment tool for filtering, mapping and clustering. The main application of SortMeRNA is filtering rRNA from metatranscriptomic data.

```shell
sortmerna --ref {rRNA.fa} --reads {input.fq}
sortmerna --ref {rRNA.fa} --reads {input.fq1} --reads {input.fq2}
```

### (4). [RiboDetector](https://github.com/hzi-bifo/RiboDetector)

RiboDetector: Accurate and rapid RiboRNA sequences Detector based on deep learning

```shell
# CPU mode
ribodetector_cpu -e norrna -t {threads} -l {params.length} \
	-i {input.fq1} {input.fq2} -o {output.fq1} {output.fq2}

# GPU mode
ribodetector -e norrna -t {threads} -l {params.length} \
	-i {input.fq1} {input.fq2} -o {output.fq1} {output.fq2}
```

---

# Upstream Processing

## *Workflow 1:* Alignment-Based

[ERCC RNA Spike-In Control Mixes](https://documents.thermofisher.com/TFS-Assets/LSG/manuals/ERCC92.zip)
### 1. Alignment

#### (1). [STAR](https://github.com/alexdobin/STAR)

```shell
# Paired-end sequencing
STAR --runThreadN {threads} --genomeDir {input.index} \
	--readFilesIn {input.fq1} {input.fq2} --readFilesCommand zcat \
	--outSAMattributes All --outSAMtype BAM Unsorted \
	--outFileNamePrefix {params.prefix}.

# Single-end sequencing
STAR --runThreadN {threads} --genomeDir {input.index} \
	--readFilesIn {input.fq} --readFilesCommand zcat \
	--outSAMattributes All --outSAMtype BAM Unsorted \
	--outFileNamePrefix {params.prefix}.

# --outFilterType BySJout # for leafcutter
```

ENCODE-DCC: [rna-seq-pipeline](https://github.com/ENCODE-DCC/rna-seq-pipeline)

```shell
# ENCODE standard options for RNA-seq pipeline
STAR --runThreadN {threads} --genomeDir {input.index} \
	--readFilesIn {input.fq1} {input.fq2} --readFilesCommand zcat \
	--outFilterMultimapNmax 20 --alignSJoverhangMin 8 \
	--alignSJDBoverhangMin 1 --outFilterMismatchNmax 999 \
	--outFilterMismatchNoverReadLmax 0.04 --alignIntronMin 20 \
	--alignIntronMax 1000000 --alignMatesGapMax 1000000 \
	--outSAMunmapped Within --outFilterType BySJout \
	--outSAMattributes All --outSAMtype BAM Unsorted \
	--quantMode TranscriptomeSAM --sjdbScore 1 \
	--outFileNamePrefix {params.prefix} --outTmpDir {params.temp_dir}.
```

#### (2). [HISAT2](https://daehwankimlab.github.io/hisat2)

```shell
# Paired-end sequencing
hisat2 -p {threads} -x {input.index} -1 {input.fq1} -2 {input.fq2} \
	--new-summary --summary-file {output.summary} | \
	samtools sort -@ 2 -n -O bam -o {output.bam}

# Single-end sequencing
hisat2 -p {threads} -x {input.index} -U {input.fq} \
	--new-summary --summary-file {output.summary} | \
	samtools sort -@ 2 -n -O bam -o {output.bam}

# --rna-strandness <RF|FR>
```

#### (3). [TopHat](https://ccb.jhu.edu/software/tophat/index.shtml)

#### (4). [Subread](http://subread.sourceforge.net)

```shell
subread-buildindex -o {output.index} {input.fa}
subjunc -T {threads} -i {input.index} -r {input.fq1} -R {input.fq2} \
	-o {output.bam}
```

### 2. Quantification

#### (1). [featureCounts](https://subread.sourceforge.net)

A software program developed for counting reads to genomic features such as genes, exons, promoters and genomic bins.

```shell
# Paired-end sequencing
featureCounts -T {threads} -p --countReadPairs -C {params.strand} \
	-g gene_id -t exon --extraAttributes gene_name,gene_type \
	-a {input.gtf} -o {output} {input.bam}

# Single-end sequencing
featureCounts -T {threads} {params.strand} \
	-g gene_id -t exon --extraAttributes gene_name,gene_type \
	-a {input.gtf} -o {output} {input.bam}

# -s <2|1|0> # strand-specific library
# --countReadPairs not support hisat2 bam
# -B: Only count read pairs that have both ends aligned (filter out Singleton)
# --ignoreDup need to mark PCR duplicates
```

> Note on Computational Efficiency:
> When running paired-end quantification with featureCounts and the --countReadPairs option on unsorted alignments, a high frequency of singleton reads (where one mate is unmapped and omitted from the BAM file) can cause a severe runtime penalty, typically increasing execution time from ~1 minute to over 30 minutes. To match read pairs, featureCounts caches unmatched mates in an internal hash table. The indefinite accumulation of these orphaned reads greatly expands the hash table size, leading to significant lookup latency and computational overhead. To restore optimal processing efficiency, it is highly recommended to explicitly enforce strict name-sorting (e.g., via samtools sort -n) before quantification. This standardizes the queryname order and allows the software to efficiently flush singleton reads from the memory buffer during the streaming process.

#### (2). [HTseq](https://github.com/htseq/htseq)

HTSeq is a Python package for analysis of high-throughput sequencing data. Releases: v2.1.2 (2026-02-04)

```shell
# For paired-end data, the alignment have to be sorted either by read name
# Sorting by name can reduce resource consumption
htseq-count -f bam -r name -a 10 -m union --nonunique none \
	--additional-attr=gene_name --additional-attr=gene_type \
	--secondary-alignments=ignore --supplementary-alignments=ignore \
	-t exon -i gene_id -c {output} {input.bam} {input.gtf}
# -s <no|reverse|yes> # strand-specific library
```

#### (3). [RSEM](https://github.com/deweylab/RSEM)

RSEM is a software package for estimating gene and isoform expression levels from RNA-Seq data.

```shell
rsem-calculate-expression -p {threads} --paired-end --bam \
	--seed 123 --calc-ci --estimate-rspd --no-bam-output \
	{input.bam} {input.rsem_index} {output.prefix}

# --strandedness <none|forward|reverse>
```

#### (4). [Cufflinks](http://cole-trapnell-lab.github.io/cufflinks/)

Cufflinks assembles transcripts, estimates their abundances, and tests for differential expression and regulation in RNA-Seq samples. It accepts aligned RNA-Seq reads and assembles the alignments into a parsimonious set of transcripts. Cufflinks then estimates the relative abundances of these transcripts based on how many reads support each one, taking into account biases in library preparation protocols.

```shell
cufflinks -g {input.gtf} {input.bam}
```

#### (5). [megadepth](https://github.com/ChristopherWilks/megadepth) (recount3)

```shell
megadepth --threads {threads} --op sum --auc \
	--no-auc-stdout --annotation {input.bed} \
	--prefix {prefix} {input.bw} >{output.bed}
```

### 3. Quantification by UMI

```shell
# Remove PCR duplicates by UMI
umi_tools dedup --method unique --output-stats {output.dir} \
	-I {input.bam} -L {log} -S {output.rmdup.bam}
```

## *Workflow 2:* Alignment-Free

Some advantages of using the above methods for transcript abundance estimation are: 
- (i) this approach corrects for potential changes in gene length across samples (e.g. from differential isoform usage) (Trapnell et al. 2013), 
- (ii) some of these methods (*Salmon*, *Sailfish*, *kallisto*) are substantially faster and require less memory and disk usage compared to alignment-based methods that require creation and storage of BAM files.
- (iii) it is possible to avoid discarding those fragments that can align to multiple genes with homologous sequence, thus increasing sensitivity (Robert and Watson 2015).

### Quantification

#### (1). [Salmon](https://github.com/COMBINE-lab/salmon)

Salmon is a wicked-fast program to produce a highly-accurate, transcript-level quantification estimates from RNA-seq data. Releases: v1.11.4 (2026-03-11)

```shell
# build index
salmon index -p $threads -k 31 -t <ref_transcripts.fa> -i <index_dir>
# use Salmon in mapping-based mode
salmon index -p $threads -k 31 -t <ref_transcripts.fa> \
	-i <index_dir> --decoys <decoys.txt>

# decoys.txt: populating the decoys.txt file with the chromosome names.
grep "^>" <(gunzip -c GRCm38.primary_assembly.genome.fa.gz) | \
	cut -d " " -f 1 > decoys.txt
sed -i.bak -e 's/>//g' decoys.txt
# Download reference genomic index from http://refgenomes.databio.org
```

```shell
# Quantifying in mapping-based mode
# Paired-end sequencing
salmon quant -p {threads} -i {input.index} -l A --gcBias \
	-1 {input.fq1} -2 {input.fq2} -o {output}

# Single-end sequencing
salmon quant -p {threads} -i {input.index} -l A --gcBias \
	-r {input.fq} -o {output}

# Quantifying in alignment-based mode
salmon quant -p {threads} -t <ref_transcripts.fa> \
	-l A -a <ngs.bam> -o <output_dir>
```

#### (2). [Kallisto](https://github.com/pachterlab/kallisto)

kallisto is a program for quantifying abundances of transcripts from RNA-Seq data, or more generally of target sequences using high-throughput sequencing reads. Releases: v0.52.0 (2026-02-26)

```shell
# builds an index from a FASTA formatted file of target sequences.
kallisto index -i <index_dir> <ref_transcripts.fa>
```

```shell
# Paired-end sequencing
# recommended: kallisto v0.50.0
kallisto quant -t {threads} -i {input.index} --plaintext \
	-o {output} {input.fq1} {input.fq2}
# "forward": "--fr-stranded", "reverse": "--rf-stranded"
# kallisto v0.48.0
kallisto quant -t {threads} -i {input.index} --plaintext \
	--bias --pseudobam --genomebam --gtf {params.gtf} \
	-o {output} {input.fq1} {input.fq2}

# Single-end sequencing
kallisto quant -t {threads} -i {input.index} --plaintext \
	--single -l 200 -s 20 -o {output} {input.fq}
```

#### (3). [Sailfish](https://github.com/kingsfordgroup/sailfish)

Sailfish is a tool for transcript quantification from RNA-seq data.

#### (4). [RSEM](https://github.com/deweylab/RSEM)

RSEM is a software package for estimating gene and isoform expression levels from RNA-Seq data.

## *Workflow 3:* Transcriptome assembly

### Genome guided Assembly

#### (1). [StringTie](https://github.com/gpertea/stringtie)

StringTie is a fast and highly efficient assembler of RNA-Seq alignments into potential transcripts. It uses a novel network flow algorithm as well as an optional *de novo* assembly step to assemble and quantitate full-length transcripts representing multiple splice variants for each gene locus. Its input can include not only alignments of short reads that can also be used by other transcript assemblers, but also alignments of longer sequences that have been assembled from those reads. Releases: v3.0.3 (2025-11-14)

```shell
# Alignment
hisat2 -p {threads} -x {input.index} --dta {params.strand} \
	--new-summary --summary-file {output.summary} \
	-1 {input.fq1} -2 {input.fq2} | \
	samtools sort -@ 2 -n -O bam -o {output.bam}

# Reconstruct contiguous transcript
stringtie -p {threads} -G {input.gtf} {params.strand} \
	-o {output.gtf} {input.bam}

# Merging transcripts from multiple samples
stringtie --merge -G {input.gtf} -o {output} {input}

# Quantification of transcripts
stringtie -p {threads} -e -G {input.gtf} {params.strand} \
	-A {geneAboudances.tsv} -b {output.outdir} \
	-o {output.gtf} {input.bam}
```

#### (2). [Cufflinks](https://github.com/cole-trapnell-lab/cufflinks)

Cufflinks assembles transcripts, estimates their abundances, and tests for differential expression and regulation in RNA-Seq samples. It accepts aligned RNA-Seq reads and assembles the alignments into a parsimonious set of transcripts. Cufflinks then estimates the relative abundances of these transcripts based on how many reads support each one, taking into account biases in library preparation protocols. (Last updated in 2019)

- Trapnell, C., Roberts, A., Goff, L. *et al.* Differential gene and transcript expression analysis of RNA-seq experiments with TopHat and Cufflinks. *Nat Protoc* **7**, 562–578 (2012). https://doi.org/10.1038/nprot.2012.016

```shell
# Reconstruct contiguous transcript
cufflinks -g {input.gtf} -M {params.rRNA.gtf} {params.strand} \
	-o {output.gtf} {input.bam}?
# –library-type <fr-unstranded|fr-firststrand|fr-secondstrand>

# Merging transcripts from multiple samples
cuffmerge -p {threads} -s {params.fa} -g {params.gtf} \
	-o {output} {input.assembly_list.txt}

# Quantification of transcripts
cuffquant -p {threads} {params.strand} -o {output} \
	{input.gtf} {input.bam}
# –library-type <fr-unstranded|fr-firststrand|fr-secondstrand>
```

### De Novo Assembly

It is recommended that next-generation sequencing be combined with long-read sequencing for transcript assembly.

#### (1). [Trinity](https://github.com/trinityrnaseq/trinityrnaseq)

Trinity assembles transcript sequences from Illumina RNA-Seq data.

```shell
Trinity --seqType fq --CPU {threads} --max_memory 32G \
	--SS_lib_type RF --left {input.fq1} --right {input.fq2} 
```

#### (2). [SPAdes (rnaSPAdes)](https://github.com/ablab/spades)

rnaSPAdes is designed primarily for eukaryotic transcriptome assembly from short reads. It can be also used to assemble prokaryotic transcriptomes and meta-transcriptomes. rnaSPAdes take as an input at least one paired-end or single-end library. For hybrid assembly you can use PacBio or Oxford Nanopore reads.

#### (3). Others

1. [Oases](https://github.com/dzerbino/oases): De novo transcriptome assembler based on the Velvet genome assembler core. (Last updated in 2015)
2. [Bridger](https://github.com/fmaguire/Bridger_Assembler): Bridger is an efficient de novo trascriptome assembler for RNA-Seq data. (Last updated in 2015)

### Evaluate the accuracy of transcript assemblers

#### [GffCompare](https://github.com/gpertea/gffcompare)

The gffcompare program has been developed to facilitate the comparison, merging, annotation, and estimation of accuracy of one or more GFF files against a reference annotation.
[CuffCompare](https://github.com/gpertea/CuffCompare) is an early version of GffCompare and is also part of the Cufflinks suite. GffCompare, however, is released as part of Stringtie.

- Compare and evaluate the accuracy of RNA-Seq transcript assemblers.
- Collapse (merge) duplicate transcripts from multiple GTF/GFF3 files.
- Classify transcripts from one or multiple GTF/GFF3 files as they relate to reference transcripts provided in a annotation file.

```shell
cuffcompare {input.gtf}
gffcompare -R -r mm10.gff -o {prefix} {input.gtf}
```

## Strand-specific Parameter

| Tool | Parameter | RF/fr-firststrand stranded (dUTP) | FR/fr-secondstrand stranded (Ligation) | Unstranded |
| - | - | - | - | - |
| TopHat | -library-type | fr-firststrand | fr-secondstrand | fr-unstranded |
| HISAT2 | -rna-strandness | R/RF | F/FR | - |
| HTSeq | -stranded/-s | reverse | yes | no |
| STAR | - | - | - | - |
| Kallisto quant | - | -rf-stranded | -fr-stranded | - |
| StringTie | - | -rf | -fr | - |
| FeatureCounts | -s | 2 | 1 | 0 |
| RSEM | –forward-prob | 0 | 1 | 0.5 |
| Salmon | -libType | ISR | ISF | IU |
| Trinity | –SS_lib_type | RF | FR | - |
| RegTools | -s | RF | FR | XS |

---

# Downstream Analysis

## 1. Differential Expression

### 1). Evaluate Batch effects (optional)

1. Check for batch effects
	- PCA
	- Hierarchical Clustering Heatmap
2. Handling batch effects
	- limma
	- sva

| Criteria | Annotation | Differential Gene Expression |
| - | - | - |
| Biological replicates | Not necessary but can be useful | Essential |
| Coverage across the transcript | Important for de Novo transcript assembly and identifying transcriptional isoforms | Not as important; however the only reads that can be used are those that are uniquely mappable. |
| Depth of sequencing | High enough to maximize coverage of rare transcripts and transcriptional isoforms | High enough to infer accurrate statistics |
| Role of sequencing depth | Obtain reads that overlap along the length of the transcript | Get enough counts of each transcript such that statistical inferences can be made |
| DSN | Useful for removing abundant transcripts so that more reads come from rarer transcripts | Not recommended since it can skew counts |
| Stranded library prep | Important for de Novo transcript assembly and identifying true anti-sense trancripts | Not generally required especially if there is a reference genome |
| Long reads (>80 bp) | Important for de Novo transcript assembly and identifying transcriptional isoforms | Not generally required especially if there is a reference genome |
| Paired-end reads | Important for de Novo transcript assembly and identifying transcriptional isoforms | Not important |

### 2). Normalization Method

| Normalization method                                                                          | Description                                                                                                                  | Accounted factors                                  | Recommendations for use                                                                                                 |
| --------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| **CPM** (counts per million)                                                                  | counts scaled by total number of reads                                                                                       | sequencing depth                                   | gene count comparisons between replicates of the same samplegroup; **NOT for within sample comparisons or DE analysis** |
| **TPM** (transcripts per kilobase million)                                                    | counts per length of transcript (kb) per million reads mapped                                                                | sequencing depth and gene length                   | gene count comparisons within a sample or between samples of the same sample group; **NOT for DE analysis**             |
| **RPKM / FPKM** (reads / fragments per kilobase of exon per million reads / fragments mapped) | similar to TPM                                                                                                               | sequencing depth and gene length                   | gene count comparisons between genes within a sample; **NOT for between sample comparisons or DE analysis               |
| DESeq2’s **median of ratios**                                                                 | counts divided by sample-specific size factors determined by median ratio of gene counts relative to geometric mean per gene | sequencing depth and RNA composition               | gene count comparisons between samples and for **DE analysis**; **NOT for within sample comparisons**                   |
| edgeR’s **trimmed mean of M values (TMM)**                                                    | uses a weighted trimmed mean of the log expression ratios between samples                                                    | sequencing depth, RNA composition, and gene length | gene count comparisons between and within samples and for **DE analysis**                                               |

 >- Total count (TC): Gene counts are divided by the total number of mapped reads (or library size) associated with their lane and multiplied by the mean total count across all the samples of the dataset.
 >- Upper Quartile (UQ): Very similar in principle to TC, the total counts are replaced by the upper quartile of counts different from 0 in the computation of the normalization factors.
 >- Median (Med): Also similar to TC, the total counts are replaced by the median counts different from 0 in the computation of the normalization factors. That is, the median is calculated as the median of gene counts of all runs.
 >- DESeq: This normalization method is included in the DESeq Bioconductor package and is based on the hypothesis that most genes are not DE. The method is based on a negative binomial distribution model, with variance and mean linked by local regression, and presents an implementation that gives scale factors. Within the DESeq package, and with the estimateSizeFactorsForMatrixfunction, scaling factors can be calculated for each run. After dividing gene counts by each scaling factor, DESeq values are calculated as the total of rescaled gene counts of all runs.
 >- Trimmed Mean of M-values (TMM): This normalization method is implemented in the edgeR Bioconductor package (Robinson et al., 2010). It is also based on the hypothesis that most genes are not DE. Scaling factors are calculated using the calcNormFactors function in the package, and then rescaled gene counts are obtained by dividing gene counts by each scaling factor for each run. TMM is the sum of rescaled gene counts of all runs.
 >- Quantile (Q): First proposed in the context of microarray data, this normalization method consists in matching distributions of gene counts across lanes.
 >- Reads Per Kilobase per Million mapped reads (RPKM): This approach was initially introduced to facilitate comparisons between genes within a sample and combines between- and within-sample normalization. This approach quantifies gene expression from RNA-Seq data by normalizing for the total transcript length and the number of sequencing reads.

### 3). Different Gene Expression

1. `DESeq2`
2. `edgeR`
3. `limma - voom`
	- limma is an R package that was originally developed for differential expression (DE) analysis of microarray data.
	- voom is a function in the limma package that modifies RNA-Seq data for use with limma.
4. Wilcoxon rank-sum test (Mann-Whitney U test)

### 4). Time Course Analysis

1. Mfuzz
2. maSigPro
3. TCseq
4. ImpulseDE2

### 5). Coexpression Networks

Coexpression networks are data-derived representations of genes behaving in a similar way across tissues and experimental conditions. The primary function of these genes is the generation of hypotheses and the employment of guilt-by-association approaches to infer the functions of previously unidentified genes.

#### [WGCNA](https://github.com/cran/WGCNA)

Weighted correlation network analysis (WGCNA) can be used for finding clusters (modules) of highly correlated genes, for summarizing such clusters using the module eigengene or an intramodular hub gene, for relating modules to one another and to external sample traits (using eigengene network methodology), and for calculating module membership measures. WGCNA is based on correlation and not differential expression comparisons.

### 6). Gene function analysis

- Analysis Method
	1. Over-representation analysis / Enrichment analysis
	2. Gene set enrichment analysis (GSEA)
	3. Gene set variation analysis (GSVA)
	4. Pathway topology tools
- Gene function database
	1. GO: http://geneontology.org/
	2. KEGG: https://www.genome.jp/kegg/
	3. MSigDB: https://www.gsea-msigdb.org/gsea/msigdb/
- Toolkit
	1. clusterProfiler
		1. https://zhuanlan.zhihu.com/p/35510434
		2. https://zhuanlan.zhihu.com/p/259894818
	2. [`metascape`](https://metascape.org/gp/index.html): A Gene Annotation & Analysis Resource
	3. gProfiler
	4. fgsea
	5. topGO
	6. SPIA
	7. gage
- Website
	1. Metascape: http://metascape.org/gp/index.html
	2. Enrichr: https://maayanlab.cloud/Enrichr
	3. GSEA: https://www.gsea-msigdb.org/gsea/index.jsp
	4. DAVID Bioinformatics Resources: https://david.ncifcrf.gov/
	5. g:Profiler: http://biit.cs.ut.ee/gprofiler/index.cgi
	6. GeneMANIA: http://www.genemania.org/
	7. GenePattern(need to register)
	8. WebGestalt  http://www.webgestalt.org/ (need to register)
	9. AmiGO: http://amigo.geneontology.org/amigo
	10. ReviGO (visualizing GO analysis, input is GO terms): http://revigo.irb.hr/

### 7). Protein Interaction Network Analysis (PINA)

- Database
  1. [STRING](https://string-db.org): Protein-protein interaction networks and functional enrichment analysis.
  2. [PINA](https://omics.bjcancer.org/pina): Protein Interaction Network Analysis (PINA) platform is an integrated platform for protein interaction network construction, filtering, analysis, visualization, and management. It integrates protein-protein interaction (PPI) data from public curated databases and builds a complete, non-redundant protein interaction dataset for six model organisms.
  3. [BioGRID](https://thebiogrid.org): A biomedical interaction repository with data compiled through comprehensive curation efforts.
  4. [IntAct](https://www.ebi.ac.uk/intact/home): IntAct provides a free, open source database system and analysis tools for molecular interaction data.
  5. [DIP](https://dip.doe-mbi.ucla.edu/dip/Main.cgi): The DIP database catalogs experimentally determined interactions between proteins.
  6. [MINT](https://mint.bio.uniroma2.it/): a public and open source database focusing on experimentally verified protein-protein interactions mined from the scientific literature by expert curators.
  7. [HIPPIE](https://cbdm-01.zdv.uni-mainz.de/~mschaefer/hippie/index.php): A web tool to generate reliable and meaningful human protein-protein interaction networks.
- Toolkit
  1. [STRINGdb](https://www.bioconductor.org/packages/release/bioc/html/STRINGdb.html): Protein-protein interaction networks and functional enrichment analysis.
  2. [Cytoscape](https://cytoscape.org): An open source software platform for visualizing complex networks and integrating these with any type of attribute data.

## 2. Alternative Splicing

Alternative splicing of eukaryotic pre-mRNA is a pervasive mechanism that increases proteomic diversity and regulates gene expression by selectively including or excluding specific exons or intron segments during transcript maturation. Depending on the cellular context and developmental cues, decisions regarding splicing — such as exon skipping, mutually exclusive exon usage, alternative 5′ or 3′ splice-site selection, and intron retention — are orchestrated by the dynamic interplay of core spliceosomal components and ancillary RNA-binding proteins (e.g. SR proteins and hnRNPs), which recognise cis-acting splicing enhancers and silencers. This finely tuned process enables the generation of multiple protein isoforms with distinct functional domains, and also modulates mRNA stability, localisation, and translation efficiency. Dysregulation of alternative splicing is implicated in a wide range of human diseases, including cancer, neurodegenerative disorders, and inherited syndromes, underscoring its pivotal role in cellular homeostasis and organismal complexity.

### a). [rMATS](https://rnaseq-mats.sourceforge.io/)

> Multivariate Analysis of Transcript Splicing (MATS) is a computational tool to detect differential alternative splicing events from RNA-Seq data. The statistical model of MATS calculates the P-value and false discovery rate that the difference in the isoform ratio of a gene between two conditions exceeds a given user-defined threshold.
> 1. [rMATS turbo](https://github.com/Xinglab/rmats-turbo): rMATS turbo is the C/Cython version of rMATS. The major difference between rMATS turbo and rMATS is speed and space usage. *Releases: v4.3.0 (2024-05-22)*
> 2. [rmats2sashimiplot](https://github.com/Xinglab/rmats2sashimiplot) produces a sashimiplot visualization of rMATS output.
> 3. [maser](https://www.bioconductor.org/packages/release/bioc/html/maser.html): This package provides functionalities for downstream analysis, annotation and visualizaton of alternative splicing events generated by rMATS.
>
> Citation:
> - S. Shen,J.W. Park,Z. Lu,L. Lin,M.D. Henry,Y.N. Wu,Q. Zhou,& Y. Xing,  rMATS: Robust and flexible detection of differential alternative splicing from replicate RNA-Seq data, Proc. Natl. Acad. Sci. U.S.A. 111 (51) E5593-E5601, https://doi.org/10.1073/pnas.1419161111 (2014).
> - Wang, Y., Xie, Z., Kutschera, E. et al. rMATS-turbo: an efficient and flexible computational tool for alternative splicing analysis of large-scale RNA-seq data. Nat Protoc 19, 1083–1104 (2024). https://doi.org/10.1038/s41596-023-00944-2.

```shell
# v4.3.0
conda install -c bioconda rmats

# Analysis begins with the FASTQ file.
# treat.txt/control.txt: 
# sample1_R1.fq.gz:sample1_R2.fq.gz,sample2_R1.fq.gz:sample2_R2.fq.gz
python rmats.py --nthread {threads} -t paired --libType fr-unstranded \
	--readLength 50 \
	--bi {input.star.index} --gtf {input.gtf} \
	--s1 {input.treat.txt} --s2 {input.control.txt} \
	--od {output.outdir} --tmp {params.temp}

# Analysis begins with the BAM file.
# treat.txt/control.txt: 
# sample1.bam,sample2.bam
python rmats.py --nthread {threads} -t paired --libType fr-unstranded \
	--readLength 150 --variable-read-length --cstat 0.0001 \
	--b1 {input.treat.txt} --b2 {input.control.txt} \
	--gtf {input.gtf} --od {output.outdir} --tmp {params.temp}

# -t <paired|single>
# --libType <fr-unstranded|fr-firststrand|fr-secondstrand>
# --allow-clipping: Allow alignments with soft or hard clipping to be used.
# --paired-stats: Using the paired stats model.
# --novelSS: Enable detection of novel splice sites (unannotated splice sites).
```

<img src="https://github.com/Xinglab/rmats-turbo/raw/master/docs/rmats_diagram.png" alt="rMATS Output" style="max-width: 100%; height: auto;" />

```shell
# rmats parameters for running star
STAR --runThreadN {threads} --genomeDir {params.index} \
	--readFilesIn {input.fq1} {input.fq2} --readFilesCommand zcat \
	--outSAMattributes All --outSAMtype BAM SortedByCoordinate \
	--alignEndsType EndToEnd --outSAMstrandField intronMotif \
	--chimSegmentMin 2 --outFilterMismatchNmax 3 --twopassMode Basic \
	--alignSJDBoverhangMin 1 --alignIntronMax 299999 \
	--outFileNamePrefix {params.prefix}
```

```shell
# BAM files must be sorted
rmats2sashimiplot --exon_s 1 --intron_s 5 \
	--b1 control_rep1.sorted.bam,control_rep2.sorted.bam \
	--b2 treat_rep1.sorted.bam,treat_rep2.sorted.bam \
	--event-type SE -e {input.SE.MATS.JC.txt} \
	--l1 control --l2 treatment -o {output.outdir}
# --event-type {SE,A5SS,A3SS,MXE,RI}

rmats2sashimiplot --exon_s 1 --intron_s 5 \
	--b1 control_rep1.sorted.bam,control_rep2.sorted.bam \
	--b2 treat_rep1.sorted.bam,treat_rep2.sorted.bam \
	-c chr1:+:100000-110000:{input.gtf} \
	--l1 control --l2 treatment -o {output.outdir}
```

### 2). [LeafCutter](https://github.com/davidaknowles/leafcutter)

Leafcutter (v0.2.9) quantifies RNA splicing variation using short-read RNA-seq data. The core idea is to leverage spliced reads (reads that span an intron) to quantify (differential) intron usage across samples.

```R
devtools::install_github("davidaknowles/leafcutter/leafcutter")
# conda install -c davidaknowles r-leafcutter
```

```shell
# leafcutter parameters for running star
STAR --runThreadN {threads} --genomeDir {params.index} \
	--readFilesIn {input.fq1} {input.fq2} --readFilesCommand zcat \
	--twopassMode Basic --outSAMstrandField intronMotif \
	--outSAMattributes All --outSAMtype BAM Unsorted \
	--outFileNamePrefix {params.prefix}
```

- Differential Splicing

[RegTools](https://github.com/griffithlab/regtools): Tools that integrate DNA-seq and RNA-seq data to help interpret mutations in a regulatory and splicing context.

```shell
python2.7 leafcutter_cluster.py -j all_sample_juncfiles.txt -m 50 -o SRR592774_all_sample -r step03_leafcutterOutput -l 500000
```

```shell
# Sort bam
samtools sort -@ 2 -o {output.bam} {input.bam}
samtools index {input.bam}
# Conversion bam to junc
conda install -c bioconda regtools
regtools junctions extract -a 8 -m 50 -M 500000 {input.bam} -o {output.junc}
# Intron clustering
python leafcutter_cluster_regtools.py -j {input.junc} -m 50 -l 500000 -o {output.prefix}
# Differential intron excision analysis
Rscript gtf_to_exons.R {input.gtf} {output}
Rscript leafcutter_ds.R --num_threads {threads} \
	--exon_file {input.exon} {input.count} {input.group}
# Plotting splice junctions
Rscript ds_plots.R -e {input.exon} {input.count} {input.group} \
	{leafcutter_ds_cluster_significance.txt} -f 0.05
```

- Outlier Splicing

```shell
# Converting bams to junc
bash bam2junc.sh {input.bam} {output.junc}
# Intron clustering
python leafcutter_cluster_regtools.py -j {input.junc} -m 50 -l 500000 -o {output.prefix}
# Outlier intron excision analysis
Rscript leafcutterMD.R --num_threads {threads} {input.count}
```

### 3). [SUPPA2](https://github.com/comprna/SUPPA)

SUPPA is a flexible and powerful tool to study splicing at the transcript isoform or at the local alternative splicing event level, across multiple conditions, and at high speed and accuracy.
```shell
# Generates events from an annotation
python3 suppa.py generateEvents -f ioe -e SE SS MX RI FL -i {genome.gtf} -o {output} 

# Merging all ioe files. (optional)
awk 'FNR==1 && NR!=1 { while (/^<header>/) getline; } 1 {print}' *.ioe > gencode.v36.all.events.ioe

# Get the TPM expression matrix for the salmon process
salmon quant -i gencode.v36.transcripts.salmon.index -l ISF --gcBias -p 2\
	-1 XXX_1_val_1.fq.gz -2 XXX_2_val_2.fq.gz -o salmon_output/XXX_output 1>XXX_salmon.log 2>&1
multipleFieldSelection.py -i  salmon_output/XXX*_output/quant.sf -k 1 -f 4 -o iso_tpm.txt
# Simplify gene id
perl -alne '{/(\|.*\|)\t/; ;s/$1//g;s/\|//g;print}' iso_tpm.txt > iso_tpm_formatted.txt

# Calculate psi value matrix
suppa.py psiPerEvent -i gencode.v36.all.events.ioe -e iso_tpm_formatted.txt -o project_events 1>psiPerEvent_log.txt 2>&1
# Splitting data by group, 其实是按列位置拆分
# negative control
cut -f 1-4 project_events.psi > control.psi
cut -f 1-4 iso_tpm_formatted.txt > control.tpm
# siRNA
cut -f 1,5-7 project_events.psi > treat.psi
cut -f 1,5-7 iso_tpm_formatted.txt > treat.tpm

# Differential splicing event analysis
suppa.py diffSplice -m empirical -gc -i gencode.v36.all.events.ioe --save_tpm_events \
	-p treat.psi control.psi -e treat.tpm control.tpm -o project_diffSplice
```

### 4). [MAJIQ](https://majiq.biociphers.org)

Modeling Alternative Junction Inclusion Quantification (MAJIQ) and Voila are two software packages that together detect, quantify, and visualize local splicing variations (LSV) from RNA-Seq data.

```shell
# Defining a splicegraph over local splicing variations.

```

### 5). Others

- [VAST-TOOLS](https://github.com/vastgroup/vast-tools): Vertebrate Alternative Splicing and Transcription Tools (VAST-TOOLS) is a toolset for profiling and comparing alternative splicing events in RNA-Seq data. It is particularly suited for evolutionary comparisons. It works synergistically with the VastDB web server, and Matt, a toolkit for downstream analyses of alternative splicing.
- [SGSeq](https://www.bioconductor.org/packages/release/bioc/html/SGSeq.html): is a software package for analyzing splice events from RNA-seq data. Input data are RNA-seq reads mapped to a reference genome in BAM format.
- [ASpli](https://bioconductor.org/packages/release/bioc/html/ASpli.html): integrative analysis of splicing landscapes through RNA-Seq assays.
- [DEXseq](https://bioconductor.org/packages/release/bioc/html/DEXSeq.html): The package is focused on finding differential exon usage using RNA-seq exon counts between samples with different experimental designs.
- [SeqGSEA](https://bioconductor.org/packages/release/bioc/html/SeqGSEA.html): Gene Set Enrichment Analysis (GSEA) of RNA-Seq Data: integrating differential expression and splicing
- [Whippet](https://github.com/timbitz/Whippet.jl): Whippet is an easy-to-use RNA-seq analysis method that quickly models and quantifies AS events of any complexity without losing accuracy.
- [SpliceWiz](https://github.com/alexchwong/SpliceWiz): SpliceWiz is an R package for exploring differential alternative splicing events in splice-aware alignment BAM files.
- [MISO](https://github.com/yarden/MISO): MISO (Mixture of Isoforms) is a probabilistic framework that quantitates the expression level of alternatively spliced genes from RNA-Seq data, and identifies differentially regulated isoforms or exons across samples. By modeling the generative process by which reads are produced from isoforms in RNA-Seq, the MISO model uses Bayesian inference to compute the probability that a read originated from a particular isoform. MISO is no longer maintained.

## 3. Fusion Gene Detection

A fusion gene is a hybrid gene formed from two previously independent genes. This can occur as a result of translocation, interstitial deletion, or chromosomal inversion. Fusion genes are prevalent in all major types of human neoplasia.

<img src="https://media.springernature.com/full/springer-static/image/art%3A10.1186%2F1471-2105-14-13/MediaObjects/12859_2012_Article_5827_Fig1_HTML.jpg" alt="Example of fusion transcript simulation" style="max-width: 100%; height: auto;" />

### 1). [STAR-Fusion](https://github.com/STAR-Fusion/STAR-Fusion)

STAR-Fusion uses the STAR aligner to identify candidate fusion transcripts supported by Illumina reads. STAR-Fusion further processes the output generated by the STAR aligner to map junction reads and spanning reads to a reference annotation set.

- Haas, B.J., Dobin, A., Li, B. et al. Accuracy assessment of fusion transcript detection via read-mapping and de novo fusion transcript assembly-based methods. Genome Biol 20, 213 (2019). https://doi.org/10.1186/s13059-019-1842-9

### 2). [Arriba](https://github.com/suhrig/arriba)

A command-line tool for the detection of gene fusions from RNA-Seq data.

- Uhrig S, Ellermann J, et al. Accurate and efficient detection of gene fusions from RNA sequencing data. Genome Res. 2021 Mar;31(3):448-460. doi: 10.1101/gr.257246.119

### 3). Others

[TrinityFusion](https://github.com/trinityrnaseq/TrinityFusion)
TrinityFusion leverages chimeric and unmapped reads to assemble fusion transcripts and transcripts of likely foreign origin (microbes and viruses), as a way of facilitating analysis of cancer transcriptomes.

- Haas, B.J., Dobin, A., Li, B. et al. Accuracy assessment of fusion transcript detection via read-mapping and de novo fusion transcript assembly-based methods. Genome Biol 20, 213 (2019). https://doi.org/10.1186/s13059-019-1842-9

[STAR-SEQR](https://github.com/ExpressionAnalysis/STAR-SEQR)
RNA Fusion Detection and Quantification using STAR.

[FusionCatcher](https://github.com/ndaniel/fusioncatcher)
FusionCatcher searches for novel/known somatic fusion genes, translocations, and chimeras in RNA-seq data.

- D. Nicorici, M. Satalan, et al. FusionCatcher – a tool for finding somatic fusion genes in paired-end RNA-sequencing data, bioRxiv, Nov. 2014, DOI:10.1101/011650

### Visualization

<img src="https://media.springernature.com/full/springer-static/image/art%3A10.1186%2Fs12885-021-08635-5/MediaObjects/12885_2021_8635_Fig2_HTML.png" alt="Fusion landscape" style="max-width: 100%; height: auto;" />

## 4. Variant Discovery

### 1). [BCFtools](https://github.com/samtools/bcftools)

BCFtools is a program for variant calling and manipulating files in the Variant Call Format (VCF) and its binary counterpart BCF.

```shell
samtools mpileup -f {fa} -q 10 -Q 20 -o {output} {input.bam}
bcftools call --threads {threads} -m -v -o {output} {input}
```

### 2). GATK HaplotypeCaller

The HaplotypeCaller is capable of calling SNPs and indels simultaneously via local de-novo assembly of haplotypes in an active region.

## 5. RNA Editing

RNA editing, a common and potentially highly functional form of RNA modification, encompasses two different RNA modifications, namely adenosine to inosine (A-to-I) and cytidine to uridine (C-to-U) editing. It can affect the activity, localization, as well as stability of RNAs, and has been linked with human diseases.

### 1). [RNAEditor](https://github.com/djhn75/RNAEditor)

RNAEditor is tool to analyze RNA editing events from RNA-seq data. It accepts Fastq and Bam files as input, handles all the analysis and filter steps for you and outputs comprehensive statistics and editing Islands.
- Lo Giudice, C., Tangaro, M.A., Pesole, G. et al. Investigating RNA editing in deep transcriptome datasets with REDItools and REDIportal. Nat Protoc 15, 1098–1131 (2020). https://doi.org/10.1038/s41596-019-0279-7

### 2). [GATK](https://github.com/broadinstitute/gatk)

ASEReadCounter: Generates table of filtered base counts at het sites for allele specific expression
HaplotypeCaller: Call germline SNPs and indels via local re-assembly of haplotypes

## 6. Transposable element expression analysis

### a). [TEtranscripts](https://github.com/mhammell-laboratory/TEtranscripts)

### b). [SalmonTE](https://github.com/hyunhwan-jeong/SalmonTE)

### c). [REdiscoverTE](https://github.com/ucsffrancislab/REdiscoverTE)

### d). [SQuIRE](https://github.com/wyang17/SQuIRE)

### e). [RepEnrich](https://github.com/nskvir/RepEnrich)/[RepEnrich2](https://github.com/nerettilab/RepEnrich2)

## 7. Multiple Copies Of Genes (Plants)

---

# Reference

1. Antoszewski, Kamil et al. Designing RNA sequencing experiments: A practical guide to reproducible gene expression analysis. Computational and Structural Biotechnology Journal, Volume 31, 101 - 119.
2. Conesa, A., Madrigal, P., Tarazona, S. *et al.* A survey of best practices for RNA-seq data analysis. *Genome Biol* **17**, 13 (2016). https://doi.org/10.1186/s13059-016-0881-8
2. Sahraeian, S.M.E., Mohiyuddin, M., Sebra, R. *et al.* Gaining comprehensive biological insight into the transcriptome by performing a broad-spectrum RNA-seq analysis. *Nat Commun* **8**, 59 (2017). https://doi.org/10.1038/s41467-017-00050-4
3. Li, W.V., Li, J.J. Modeling and analysis of RNA-seq data: a review from a statistical perspective. *Quant Biol* **6**, 195–209 (2018). https://doi.org/10.1007/s40484-018-0144-7
4. Stark, R., Grzelak, M. & Hadfield, J. RNA sequencing: the teenage years. *Nat Rev Genet* **20**, 631–656 (2019). https://doi.org/10.1038/s41576-019-0150-2
5. RNA-seqlopedia is written by the Cresko Lab of the University of Oregon and was funded by grant R24 RR032670 (NIH, National Center for Research Resources). https://rnaseq.uoregon.edu/
5. https://rnaseq.uoregon.edu/#exp-design
6. https://github.com/hbctraining/DGE_workshop_salmon_online
7. https://github.com/hbctraining/Intro-to-rnaseq-hpc-salmon-flipped
8. https://book.ncrnalab.org/teaching/
9. https://learn.gencore.bio.nyu.edu/
10. https://www.jianshu.com/p/a8935adebaae