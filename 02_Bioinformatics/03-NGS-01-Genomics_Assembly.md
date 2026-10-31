---
Title: Genome Assembly
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2022-02-20
Modified: 2024-11-02
Tags:
  - WGS
  - LRS
---
# Introduction

Genome assembly represents the process of putting a large number of short DNA sequences back together to recreate the original chromosomes from which the DNA originated.

1. De novo genome assembly
2. Reference based alignment

Genome annotation is the process of identifying and labeling the functional elements of a genome.

1. Structural Annotation: Identifies genes, exons, introns, regulatory sequences and repeat elements. Prediction of coding regions and annotation of genomic elements.
2. Functional Annotation: Biological role assignment for identified features by similarity to known genes, protein domains and pathways.

# Data Preprocessing

# Genome Assembly Pipeline

### Short-read Assembly

#### [SOAPdenovo2](https://github.com/aquaskyline/SOAPdenovo2)
SOAPdenovo is a novel short-read assembly method that can build a de novo draft assembly for the human-sized genomes.
- Luo, R., Liu, B., Xie, Y. et al. SOAPdenovo2: an empirically improved memory-efficient short-read de novo assembler. GigaSci 1, 18 (2012). https://doi.org/10.1186/2047-217X-1-18

```shell
# Complete in one step
SOAPdenovo all -s lib.cfg -K 29 -D 1 -o ant >>ass.log
# Step by step
SOAPdenovo pregraph -s lib.cfg -d 1 -K 29 -o ant >pregraph.log
SOAPdenovo contig -g ant -D 1 -M 3 >contig.log
SOAPdenovo map -s lib23.cfg -g ant >map.log
SOAPdenovo scaff -g ant -F >scaff.log
```

#### [MEGAHIT](https://github.com/voutcn/megahit)
MEGAHIT is an ultra-fast and memory-efficient NGS assembler. It is optimized for metagenomes, but also works well on generic single genome assembly (small or mammalian size) and single-cell assembly.
- Dinghua Li, Chi-Man Liu, Ruibang Luo, Kunihiko Sadakane, Tak-Wah Lam, MEGAHIT: an ultra-fast single-node solution for large and complex metagenomics assembly via succinct de Bruijn graph, Bioinformatics, Volume 31, Issue 10, May 2015, Pages 1674–1676, https://doi.org/10.1093/bioinformatics/btv033

```shell
megahit -1 pe_1.fq -2 pe_2.fq -o out
```

#### [SPAdes](https://github.com/ablab/spades)
SPAdes is the most widely used tool for small genome assembly. SPAdes is primarily developed for Illumina sequencing data, but can be used for IonTorrent as well. Most of SPAdes pipelines support hybrid mode, i.e. allow using long reads (PacBio and Oxford Nanopore) as a supplementary data.

#### [Velvet](https://github.com/dzerbino/velvet)
Velvet was one of the first tools built for the short-read assembly and is still a very readable choice for moderately complex genome projects.

### Long-read Assembly

#### [Flye](https://github.com/mikolmogorov/Flye)
Flye is a de novo assembler for single-molecule sequencing reads, such as those produced by PacBio and Oxford Nanopore Technologies. It is designed for a wide range of datasets, from small bacterial projects to large mammalian-scale assemblies.

#### [Hifiasm](https://github.com/chhylp123/hifiasm)
Hifiasm is a fast haplotype-resolved de novo assembler initially designed for PacBio HiFi reads. Its latest release could support the telomere-to-telomere assembly by utilizing ultralong Oxford Nanopore reads.

#### [Verkko](https://github.com/marbl/verkko)
Verkko is a hybrid genome assembly pipeline developed for telomere-to-telomere assembly of accurate long reads (PacBio HiFi, Oxford Nanopore Duplex, HERRO corrected Oxford Nanopore Simplex) and Oxford Nanopore ultra-long reads.

#### [Canu](https://github.com/marbl/canu)
Canu is a fork of the Celera Assembler, designed for high-noise single-molecule sequencing (such as the PacBio RS II/Sequel or Oxford Nanopore MinION).

#### [Shasta](https://github.com/paoloshasta/shasta)
De novo assembler for long reads, optimized for Oxford Nanopore (ONT) reads.

### Hybrid Assembly

#### [MaSuRCA](https://github.com/alekseyzimin/masurca)
The MaSuRCA (Maryland Super Read Cabog Assembler) genome assembly and analysis toolkit contains of MaSuRCA genome assembler, QuORUM error corrector for Illumina data, POLCA genome polishing software, Chromosome scaffolder, jellyfish mer counter, and MUMmer aligner.
- Aleksey V. Zimin, Guillaume Marçais, Daniela Puiu, Michael Roberts, Steven L. Salzberg, James A. Yorke, The MaSuRCA genome assembler, Bioinformatics, Volume 29, Issue 21, November 2013, Pages 2669–2677, https://doi.org/10.1093/bioinformatics/btt476

#### [SPAdes](https://github.com/ablab/spades)
SPAdes Hybrid Mode

#### [Unicycler](https://github.com/rrwick/Unicycler)
Unicycler is an assembly pipeline for bacterial genomes.
- Wick RR, Judd LM, Gorrie CL, Holt KE (2017) Unicycler: Resolving bacterial genome assemblies from short and long sequencing reads. PLOS Computational Biology 13(6): e1005595. https://doi.org/10.1371/journal.pcbi.1005595

## Genome Annotation Pipeline

### Repeat Masking

### Gene Prediction

### Functional Annotation

### High-Value Manual Review








# Genome Assembly And Annotation
[TOC]
***




```shell
conda install -c bioconda augustus
```

### Gene prediction
#### [AUGUSTUS](https://github.com/Gaius-Augustus/Augustus)

##### (3). [Augustus](https://github.com/Gaius-Augustus/Augustus)
AUGUSTUS is a gene prediction program.
```shell

```

##### (4). [SOAPdenovo](https://www.animalgenome.org/bioinfo/resources/manuals/SOAP.html)
SOAPdenovo is a novel short-read assembly method that can build a de novo draft assembly for the human-sized genomes. The program is specially designed to assemble Illumina GA short reads. It creates new opportunities for building reference sequences and carrying out accurate analyses of unexplored genomes in a cost effective way.


```shell
augustus --species=$SPECIES $inputSequence.fa --outfile=$output.gff
```

#### [SNAP](https://github.com/KorfLab/SNAP)
SNAP is a general purpose gene finding program suitable for both eukaryotic and prokaryotic genomes. SNAP is an acroynm for Semi-HMM-based Nucleic Acid Parser.

### Gene Family Analysis
1. Download HMM model by protein motif id from **Pfam** database
    Download genome from Ensemble, JGI, NCBI
2. Search protein with motif by **hmmsearch**
3. Construct evolutionary tree by MEGA-X
4. Search motif by MEME to reveal gene function
5. Draw gene chromosome location map
7. Gene structure analysis
8. Ka/Ks calculator

#### [hmmer](https://github.com/EddyRivasLab/hmmer)
[HMMER](http://hmmer.org/) searches biological sequence databases for homologous sequences, using either single sequences or multiple sequence alignments as queries.
```shell
hmmsearch --cut_tc --domtblout NB-ARC-PF00931.txt NB-ARC-PF00931.hmm Arabidopsis_thaliana.TAIR10.pep.all.fa
```
