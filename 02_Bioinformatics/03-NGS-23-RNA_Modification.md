---
Title: RNA Modification
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2021-10-15
Modified: 2022-06-11
Tags:
  - MeRIP-seq
  - BS-seq
  - BID-seq
---
# Introduction

**RNA modification** refers to the diverse range of chemical alterations that occur post-transcriptionally across all RNA species. With over 160 distinct types identified to date—most notably $N^6$-methyladenosine (m6A), pseudouridine (Ψ), and 5-methylcytosine (m5C)—these modifications constitute the epitranscriptome. They are dynamically orchestrated by specialized proteins categorized as **"writers" (methyltransferases), "erasers" (demethylases), and "readers" (binding proteins)**. By modulating essential RNA metabolic processes—such as **splicing, nuclear export, stability, and translation efficiency**—RNA modifications serve as a sophisticated regulatory layer of gene expression, critical to both homeostatic development and the pathogenesis of diverse diseases.

## RNA Modification Type

### Features

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fs41392-022-01175-9/MediaObjects/41392_2022_1175_Fig1_HTML.png" 
        alt="Experimental workflow and methodology overview from Signal Transduction and Targeted Therapy publication"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> Overview of the experimental workflow and methodology. 
        Adapted from <a href="https://doi.org/10.1038/s41392-022-01175-9" target="_blank" rel="noopener noreferrer">Signal Transduction and Targeted Therapy (2022)</a>.
    </figcaption>
</figure>

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://ars.els-cdn.com/content/image/1-s2.0-S2667325823001413-gr1.jpg" 
        alt="Experimental workflow and methodology overview from Elsevier publication"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> Overview of the experimental workflow and methodology. 
        Adapted from <a href="https://doi.org/10.1016/j.xhgg.2023.100236" target="_blank" rel="noopener noreferrer">Cell Press / Elsevier</a>.
    </figcaption>
</figure>

| RNA Modification | Full Name                 | Writer                                                                                                            | Erasers             | Reader                                        | Feature           | mRNA Abundance | Motif                |
| ---------------- | ------------------------- | ----------------------------------------------------------------------------------------------------------------- | ------------------- | --------------------------------------------- | ----------------- | -------------- | -------------------- |
| **m6A**          | $N^6$-methyladenosine     | m6A methyltransferase complex (**METTL3**, **METTL14**, WTAP, VIRMA(KIAA1429), ZC3H13, RBM15/15B), HAKAI, METTL16 | FTO, ALKBH5         | YTHDC1/2, YTHDF1-3, HNRNPA2B1, HNRNPC, HNRNPG | 3' UTR            | 0.4 ~ 0.7%     | DRACH                |
| m6Am             | N6,2′-O-dimethyladenosine | PCIF1                                                                                                             | FTO                 |                                               | mRNA caps         | 0.02 ~ 0.05%   |                      |
| m1A              | $N^1$-methyladenosine     | TRMT6-TRMT61A complex, TRMT61B-TRMT10C (Mito mRNA)                                                                | ALKBH1, ALKBH3, FTO |                                               | YTHDF3            | 0.01 ~ 0.05%   | GUUCNA               |
| **m5C**          | 5-methylcytosine          | DNMT2, NSUN1, NSUN2                                                                                               | TETs                | ALYREF, YBX1, YBX2                            |                   | 0.02 ~ 0.09%   |                      |
| **ac4C**         | N4-acetylcytidine         | NAT10                                                                                                             |                     |                                               | mRNA caps, 3' UTR | ~ 0.2%         |                      |
| Ψ                | Pseudouridine             | **TRUB1**, TRUB2, PUS1, PUS3, PUS7, PUS7L, PUSL1, PUS10, RPUSD1-4, DKC1                                           |                     |                                               | CDS, 3' UTR       | 0.2 ~ 0.6%     | GUΨCN, USΨAG, poly‑U |
| Nm               | Ribose methylation        | FBL, ribonucleoprotein complex (enzyme, C/D-box snoRNA), CMTR1, CMTR2                                             |                     |                                               |                   | 0.012 ~ 0.15%  |                      |
| m7G              | N7-methylguanosine        | RNMT, METTL1-WDR4 complex                                                                                         |                     | eIF4E                                         | mRNA caps         | 0.002 ~ 0.05%  |                      |
| I                | Inosine                   | ADARs                                                                                                             |                     | NONO, ENDOV                                   |                   |                |                      |

### Function

> - m6A
> 	1. YTHDC1: Inhibit splicing factors to promote pre-mRNA splicing.
> 	2. YTHDC1 - SRSF3 - NXF1: Promotes m6A-labeled mRNA nuclear export
> 	3. YTHDC1 - eIF3 - translation initiation complex: Promote translation initiation
> 	4. YTHDC2 + METTL3: Improve mRNA translation efficiency.
> 	5. YTHDC2 + YTHDF2: Promotes m6A-labeled mRNA degradation.
> 	6. YTHDF1 (binding with the stop codon): Promotes cap-dependent translation initiation and enhances translational efficiency.
> 	7. YTHDF2 recruits the CCR4-NOT complex to accelerate the degradation of m6A-labeled mRNA.
> 	8. YTHDF2 expression was significantly increased; subsequently, YTHDF2 entered the nucleus and protected m6A-labeled mRNA from FTO degradation.
> 	9. YTHDF3 interacts with YTHDF1 or YTHDF2 to perform related functions.
> 	10. HNRNPA2B1: Mediates m6A-dependent pri-miRNA processing and regulates alternative splicing of pre-mRNA.
> - m6Am (Mammalian)
> 	1. regulate translation
> - m1A
> 	1. YTHDF3: Promotes m1A-labeled mRNA degradation.
> - m5C
> 	1. ALYREF: Promotes mRNA nuclear export
> 	1. YBX1-ELAVL1: Improve mRNA stability
> 	1. YBX2: Promotes liquid-liquid phase separation of RNA
> - ac4C
> 	1. improve mRNA translation efficiency and RNA stability
> - Ψ
> 	1. Promotes mRNA processing and translation.
> - Nm
> 	1. 
> - m7G
> 	1. eIF4E: Promotes translation
> - I
> 	1. NONO (p54nrb): Maintaining RNA modification
> 	1. ENDOV (hEndoV): Promotes the degradation of Inosine-containing transcripts

## Library Strategy

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://ars.els-cdn.com/content/image/1-s2.0-S2667325823001413-gr2.jpg" 
        alt="Experimental workflow, schematic model, or results overview from Elsevier publication"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> Detailed structural or methodological overview. 
        Adapted from <a href="https://doi.org/10.1016/j.xhgg.2023.100236" target="_blank" rel="noopener noreferrer">Cell Press / Elsevier</a>.
    </figcaption>
</figure>

### RIP-seq (m6A, ac4C)

MeRIP-seq is a foundational epitranscriptomic approach that employs antibody-based affinity enrichment to map RNA modifications—including m⁶A, m⁶Am, m¹A, m⁵C, m⁷G, and ac⁴C—across the transcriptome. The workflow entails RNA fragmentation followed by immunoprecipitation using a modification-specific antibody to enrich modified RNA fragments (IP fraction), which are then sequenced in parallel with a non-enriched input control. This method is characterized by high sensitivity and its ability to generate a transcriptome-wide landscape of RNA modifications; however, its resolution is typically restricted to peak-level (~100 nt) rather than single-nucleotide precision. Furthermore, owing to the relatively low enrichment efficiency of antibodies, MeRIP-seq and other antibody-based approaches generally require substantial input amounts of RNA.

### RNA Bisulfite Sequencing (m5C)

RNA bisulfite sequencing (RNA BS-seq) is widely regarded as the gold standard for transcriptome-wide detection of 5-methylcytosine (m⁵C) at single-nucleotide resolution. The method is based on sodium bisulfite–mediated deamination, whereby unmethylated cytosines (C) are converted to uracils (U), while methylated cytosines (m⁵C) are resistant to conversion and remain unchanged. The workflow typically includes RNA fragmentation, bisulfite treatment, reverse transcription into cDNA, and high-throughput sequencing. The principal advantage of this technique is its single-nucleotide resolution; however, the harsh chemical treatment can cause substantial RNA degradation, necessitating high-quality input RNA and carefully optimized conversion conditions.

### BID-seq (Ψ)

BID-seq (bisulfite-induced deletion sequencing) is an advanced method for transcriptome-wide mapping and quantitative profiling of pseudouridine (Ψ) at single-nucleotide resolution. The approach is based on the selective reaction between bisulfite and Ψ under optimized conditions, resulting in the formation of a stable bisulfite–Ψ adduct. During reverse transcription, this adduct acts as a steric lesion that causes reverse transcriptase to bypass the modified nucleotide, thereby generating a characteristic deletion signature at the corresponding position. The workflow typically includes RNA bisulfite treatment, library preparation using high-fidelity polymerases, and high-throughput sequencing. Key features of BID-seq include its ability to discriminate Ψ from uridine (U) with high sensitivity and the use of deletion frequency as a quantitative digital readout to accurately determine site-specific modification stoichiometry.

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fs41596-023-00917-5/MediaObjects/41596_2023_917_Fig1_HTML.png" 
        alt="Experimental workflow and methodology overview from Nature Protocols publication"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> Overview of the experimental workflow and methodology. 
        Adapted from <a href="https://doi.org/10.1038/s41596-023-00917-5" target="_blank" rel="noopener noreferrer">Nature Protocols (2023)</a>.
    </figcaption>
</figure>

### Summary

| Target               | Method              | Principle                                                    | Resolution | Advantages | Limit |
| -------------------- | ------------------- | ------------------------------------------------------------ | ---------- | ---------- | ----- |
| m6A                  | MeRIP-seq / m6A-seq | Immunoprecipitation                                          | peak       |            |       |
| m6A                  | PA-m6A-seq          | UV light cross-linking strategy                              |            |            |       |
| m6A                  | miCLIP              | UV light cross-linking strategy                              |            |            |       |
| m6A                  | m6A-LAIC-seq        | Enrichment of full-length mRNA using an m6A antibody         |            |            |       |
| m6A                  | MAZTER-seq          | MazF endonuclease                                            |            |            |       |
| m6A                  | m6A-REF-seq         | MazF endonuclease                                            |            |            |       |
| m6A                  | m6A-SEAL            | FTO-assisted chemically labeled m6A                          |            |            |       |
| m6A                  | m6A-label-seq       | Metabolic-labeling m6A                                       |            |            |       |
| m6A                  | m6ACE-seq           | Identify m6A by exonuclease                                  |            |            |       |
| m6A                  | DART-seq            | APOBEC1-YTH fusion protein                                   |            |            |       |
| m6A                  | m6A-SAC-seq         |                                                              |            |            |       |
| m6A                  | GLORI               |                                                              |            |            |       |
| m6Am                 | m6A-seq             | Comparing peaks between wild-type and PCIF1 knockout samples | peak       |            |       |
| m6Am                 | m6Am-Exo-seq        | Exonuclease                                                  |            |            |       |
| m6Am                 | m6Am-seq            | The m6Am modification was selectively removed using the FTO process |            |            |       |
| m1A                  | m1A-ID-seq          |                                                              |            |            |       |
| m1A                  | m1A-seq-TGIRT       |                                                              |            |            |       |
| m1A                  | m1A-MAP             |                                                              |            |            |       |
| m1A                  | m1A-quant-seq       |                                                              |            |            |       |
| m1A                  | m1A-IP-seq          |                                                              |            |            |       |
| I                    | ICE-seq             |                                                              |            |            |       |
| I                    | EndoVIPER-seq       |                                                              |            |            |       |
| m5C                  | BS-seq              |                                                              | base       |            |       |
| m5C                  | Aza-IP              |                                                              |            |            |       |
| m5C                  | m5C-RIP             |                                                              | peak       |            |       |
| m5C, Ψ, m1A          | RBS-seq             |                                                              | base       |            |       |
| ac4C                 | acRIP-seq           | Immunoprecipitation                                          | peak       |            |       |
| Ψ                    | ψ-seq               |                                                              |            |            |       |
| Ψ                    | Pseudo-seq          |                                                              | base       |            |       |
| Ψ                    | PSI-seq             |                                                              |            |            |       |
| Ψ                    | CeU-seq             | N3-CMC–enriched pseudouridine sequencing                     |            |            |       |
| Ψ                    | BID-seq             |                                                              | base       |            |       |
| m7G                  | m7G-MeRIP-seq       |                                                              | peak       |            |       |
| m7G                  | m7G-miCLIP-seq      |                                                              |            |            |       |
| m7G                  | m7G-seq             |                                                              |            |            |       |
| Nm                   | Nm-seq              |                                                              |            |            |       |
| Nm                   | MeTH-seq            |                                                              |            |            |       |
| tRNA (m¹A, m³C, m¹G) | ARM-seq             | AlkB-facilitated RNA methylation sequencing                  |            |            |       |

---

# Data Preprocessing

For more details, please see: [[NGS-21-Transcriptomics-GeneExpression]]

---

# Upstream Processing

## RIP-seq

For more details, please see: [[NGS-23-Transcriptomics-RNABindingProtein]]

## RNA-BS-seq

### [meRanTK](https://github.com/icbi-lab/meRanTK)

There are differences between the results of versions 1.2.1b and 1.3.0 (recommended)

```shell
meRanGh align -t {threads} -id {input.index} -GTF {input.gtf} \
	-deleteSAM -deleteBAMus -MM -un -f {input.fq1} -r {input.fq2} \
	-o {output.dir} -ud {output.unmapped.dir} -S {output.sam}

# Keep uniquely mapped reads
samtools view -@ {threads} -b -f 2 -q 10 {input.sam} | \
	samtools sort -@ {threads} -o {output.unique_bam}
samtools index {input.bam}

# v1.2.1b
meRanCall -p {threads} -fs5 6 -f -mr 0.1 -mcov 30 -minC 5 \
	-sc 10 -cr 0.99 -fdr 0.05 -mBQ 20 -bed63 -np -gref \
	{input.fa} -bam {input.bam} -o {output}

# v1.3.0
meRanCall -p {threads} -fs5 6 -f -mr 0.1 -mcov 30 -minC 5 \
	-sc 10 -cr 0.99 -fdr 0.01 -Cco 3 -snr 0.9 -ei 0.1 -bed63 -np -gref \
	{input.fa} -bam {input.bam} -o {output}
```

```shell
# align RNA-BS-seq reads to a set of reference transcripts
meRanT mkbsidx -t {threads} -fa {input.fa} -bwt2b {params.bowtie2} \
	-x {params.prefix} -id {params.index}
mkRefSeq2GeneMap.pl –f {input.fa} –m {output.map}

meRanT align -t {threads} -k 10 -un -ra -MM -mbp -i2g {input.map} \
	-x {input.index} -bwt2 {params.bowtie2} -f {input.fq1} -r {input.fq2} \
	-o {params.dir} -S {output.sam} -ud {output.unmapped.fq}

# align RNA-BS-seq reads to the genome using STAR
meRanGs mkbsidx -t {threads} -fa {input.fa} -GTF {input.gtf} \
	-star {params.STAR} -GTFtagEPT Parent -GTFtagEPG gene -sjO 149 \
	-id {params.index}

meRanGs align -t {threads} -un -MM -bg -mbgc 10 -mbp -star_outFilterMultimapNmax 20 \
	-id {input.index} -star {params.STAR} -f {input.fq1} -r {input.fq2} \
	-o {params.dir} -S {output.sam} -ud {output.unmapped.fq}

# align RNA-BS-seq reads to the genome using HiSat2
meRanGh mkbsidx -t {threads} -fa {input.fa} -hs2b {params.hisat2} \
	-id {params.index}

meRanGh align -t {threads} -un -MM -bg -mbgc 10 -mbp -star_outFilterMultimapNmax 20 \
	-id {input.index} -hisat2 {params.hisat2} -f {input.fq1} -r {input.fq2} \
	-o {params.dir} -S {output.sam} -ud {output.unmapped.fq}
```

```shell
# Determination of the C→T conversion rate of a RNA-BSseq sample
meRanCall -p {threads} -fs5 6 -fs3 0 -rs5 0 -rs3 0 -rl 150 -ccr -tref \
	-s <path_of_mapped.bam> -f <path_of_fa> -c SeqID UnMethylated_Control

# call methylated cytosines (m5C) from the RNA-BSseq alingments
# methylation calling from RNA-BSseq single end reads mapped with meRanT
meRanCall -p {threads} -fs5 6 -rl 150 -sc 10 -zg -md 5 -ei 0.1 -cr 0.99 -fdr 0.01 -tref \
	-bam <path_of_mapped.bam> -f <path_of_fa> -o <dir_of_output>

# methylation calling from RNA-BSseq single end reads mapped with meRanGs/meRanGh
meRanCall -p {threads} -fs5 6 -rl 150 -sc 10 -zg -md 5 -ei 0.1 -cr 0.99 -fdr 0.01 -bed63 -np -gref \
	-bam <path_of_mapped.bam> -f <path_of_fa> -o <dir_of_output>
```

## BID-seq

### [pseudoU BID-seq](https://github.com/y9c/pseudoU-BIDseq)

```shell
# data.yaml
docker run -it --rm --name bidseq -v "$(pwd)":/workspace -w /workspace $dockerImage
```

```shell
# read merging
fastp --thread {threads} --disable_adapter_trimming --merge --correction \
	--overlap_len_require 10 --overlap_diff_percent_limit 20 \
	-i {input.fq1} -I {input.fq2} --merged_out {output.merge.fq.gz} \
	--out1 {output.u1.fq.gz} --out2 {output.u2.fq.gz} \
	-h {output.fastp.html} -j {output.fastp.json}
# merge fastq
joinFastq {input.merge.fq.gz} {input.u1.fq.gz} {input.u2.fq.gz} {output.fq.gz}
# 

bowtie2 -p {threads} -x {params.index} \
	--sensitive -L 16 --rdg 0,2 \ # defaut
	--local --ma 2 --score-min G,20,8 -D 20 -R 3 -L 16 -N 1 --mp 4 --rdg 0,2 \ # speedy_mapping
	--end-to-end --ma 0 --score-min L,2,-0.5 -D 20 -R 3 -L 16 -N 1 --mp 4 --rdg 0,2 \ # greedy_mapping
	--no-unal --un {output.fq} -U {input.fq} 2>{log} | \
	samtools view -O BAM -o {output.bam}

bowtie2 -p {threads} -x {params.index} \
	--local --ma 2 --score-min G,10,7 -D 20 -R 3 -L 8 -N 1 -i S,1,0.5 --mp 6,3 --rdg 1,2 --rfg 6,3 \ # defaut
	--end-to-end --ma 0 --score-min L,4,-0.5 -D 20 -R 3 -L 8 -N 1 -i S,1,0.5 --mp 6,3 --rdg 1,2 --rfg 6,3 \ # greedy_mapping
	--norc -a --no-unal --un {output.fq} -U {params.fq} 2>{log} | \
	samtools view -e "exists([AS])" -O BAM -o {output.bam}

star --runThreadN {threads} --genomeDir {params.index} \
	--readFilesIn {input.f1},{input.f2} --alignEndsType Local \
	--scoreDelOpen -1 --scoreDelBase -1 \
	--scoreInsOpen -2 --scoreInsBase -2 \
	--outFilterMatchNmin 15 --outFilterMatchNminOverLread 0.8 \
	--outFilterMismatchNmax 10 --outFilterMismatchNoverLmax 0.2 \
	--outFilterIntronMotifs RemoveNoncanonicalUnannotated \
	--alignSJDBoverhangMin 1 --alignSJoverhangMin 5 \
	--chimSegmentMin 20 --chimOutType WithinBAM HardClip \
	--chimJunctionOverhangMin 15 --chimScoreJunctionNonGTAG 0 \
	--outFilterMultimapNmax 10 --outFilterMultimapScoreRange 0 \
	--outSAMmultNmax -1 --outMultimapperOrder Random \
	--outReadsUnmapped Fastx --outSAMtype BAM Unsorted \
	--outStd BAM_Unsorted \
	--outSAMattrRGline ID:{wildcards.sample} SM:{wildcards.sample} LB:RNA PL:Illumina PU:SE \
	--outSAMattributes NH HI AS nM NM MD jM jI MC ch \
	--outFileNamePrefix {params.prefix} > {output.bam}

```

---

# Reference

1. Cui, L., Ma, R., Cai, J. et al. RNA modifications: importance in immune cell biology and related diseases. Sig Transduct Target Ther 7, 334 (2022). https://doi.org/10.1038/s41392-022-01175-9
2. Kai Li, Jinying Peng, Chengqi Yi. Sequencing methods and functional decoding of mRNA modifications. Fundamental Research. Volume 3, Issue 5. 2023. https://doi.org/10.1016/j.fmre.2023.05.010.
3. Dominissini, D., Moshitch-Moshkovitz, S., Schwartz, S. et al. Topology of the human and mouse m6A RNA methylomes revealed by m6A-seq. Nature 485, 201–206 (2012). https://doi.org/10.1038/nature11112
4. Meyer, Kate D. et al. Comprehensive analysis of mRNA methylation reveals enrichment in 3' UTRs and near stop codons. Cell. 2012 Jun 22;149(7):1635-46. doi: 10.1016/j.cell.2012.05.003
5. Linder, B., Grozhik, A., Olarerin-George, A. et al. Single-nucleotide-resolution mapping of m6A and m6Am throughout the transcriptome. Nat Methods 12, 767–772 (2015). https://doi.org/10.1038/nmeth.3453
6. Dominissini, D., Nachtergaele, S., Moshitch-Moshkovitz, S. et al. The dynamic N1-methyladenosine methylome in eukaryotic messenger RNA. Nature 530, 441–446 (2016). https://doi.org/10.1038/nature16998
7. Li, X., Xiong, X., Wang, K. et al. Transcriptome-wide mapping reveals reversible and dynamic N1-methyladenosine methylome. Nat Chem Biol 12, 311–316 (2016). https://doi.org/10.1038/nchembio.2040
8. Jeffrey E. Squires, Hardip R. Patel, Marco Nousch, Tennille Sibbritt, David T. Humphreys, Brian J. Parker, Catherine M. Suter, Thomas Preiss, Widespread occurrence of 5-methylcytosine in human coding and non-coding RNA, Nucleic Acids Research, Volume 40, Issue 11, 1 June 2012, Pages 5023–5033, https://doi.org/10.1093/nar/gks144
9. Edelheit S, Schwartz S, Mumbach MR, Wurtzel O, Sorek R (2013) Transcriptome-Wide Mapping of 5-methylcytidine RNA Modifications in Bacteria, Archaea, and Yeast Reveals m5C within Archaeal mRNAs. PLOS Genetics 9(6): e1003602. https://doi.org/10.1371/journal.pgen.1003602
10. Schwartz, Schraga et al. Transcriptome-wide Mapping Reveals Widespread Dynamic-Regulated Pseudouridylation of ncRNA and mRNA. Cell, Volume 159, Issue 1, 148 - 162.
11. Li, X., Zhu, P., Ma, S. et al. Chemical pulldown reveals dynamic pseudouridylation of the mammalian transcriptome. Nat Chem Biol 11, 592–597 (2015). https://doi.org/10.1038/nchembio.1836
12. Carlile, T., Rojas-Duran, M., Zinshteyn, B. et al. Pseudouridine profiling reveals regulated mRNA pseudouridylation in yeast and human cells. Nature 515, 143–146 (2014). https://doi.org/10.1038/nature13802
13. Dai, Q., Zhang, LS., Sun, HL. et al. Quantitative sequencing using BID-seq uncovers abundant pseudouridines in mammalian mRNA at base resolution. Nat Biotechnol 41, 344–354 (2023). https://doi.org/10.1038/s41587-022-01505-w
14. Zhang, LS., Ye, C., Ju, CW. et al. BID-seq for transcriptome-wide quantitative sequencing of mRNA pseudouridine at base resolution. Nat Protoc 19, 517–538 (2024). https://doi.org/10.1038/s41596-023-00917-5
15. V. Khoddami,A. Yerra,T.L. Mosbruger,A.M. Fleming,C.J. Burrows,& B.R. Cairns,  Transcriptome-wide profiling of multiple RNA modifications simultaneously at single-base resolution, Proc. Natl. Acad. Sci. U.S.A. 116 (14) 6784-6789, https://doi.org/10.1073/pnas.1817334116 (2019).
16. Cozen, A., Quartley, E., Holmes, A. et al. ARM-seq: AlkB-facilitated RNA methylation sequencing reveals a complex landscape of modified tRNA fragments. Nat Methods 12, 879–884 (2015). https://doi.org/10.1038/nmeth.3508