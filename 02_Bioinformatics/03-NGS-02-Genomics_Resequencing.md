---
Title: Genome Resequencing
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2022-02-20
Modified: 2023-05-11
Tags:
  - WGS
  - WES
---
# Introduction

## 1. Definition

---

# Experimental Design

## 1. Array

## 2. Sequencing Technologies

### a). Whole Genome Sequence (WGS)

### b). Whole Exome Sequence (WES)

Whole Exome Sequencing utilizes exome capture technology to enrich exons, and then sequences these regions in a high-throughput manner. To be specific, DNA samples are first fragmented and biotinylated oligonucleotide probes (baits) are used to selectively hybridize to exome in the genome. Magnetic streptavidin beads are then used to bind to the biotinylated probes. The non-targeted portion of the genome is washed away, and the PCR is used to enrich the sample for DNA from the target region. Subsequently, the sample is sequenced by the Illumina HiSeq platform. This strategy can result in up to a 100-fold improvement in gene coverage for the human genome.

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
bwa mem -t {threads} -M -R "@RG\tID:{sample}\tSM:{sample}\tLB:WGS\tPL:Illumina" \ 
	{params.index} {input.fq1} {input.fq2} | \
	samtools sort -@ {threads} -o {output.bam}
# Single-end sequencing
bwa mem -t {threads} -M -R "@RG\tID:{sample}\tSM:{sample}\tLB:WGS\tPL:Illumina" \
	{params.index} {input.fq} | \
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

## 2. Filtering reads

```shell
samtools collate -@ 1 -u -O {input.bam} | \
    samtools fixmate -@ 1 -m -u - - | \
    samtools sort -@ 1 -u - | \
    samtools markdup -@ 1 -r -f {output.rmdupstats} - - | \
    samtools view -@ 1 -h -u -q 30 -f 2 -F 1804 - | \
    samtools sort -@ 1 -o {output.bam}
```

### 1). PCR Duplicates Reads

#### a). [Picard](https://broadinstitute.github.io/picard/index.html)

When the input is coordinate-sorted, unmapped mates of mapped records and supplementary/secondary alignments are not marked as duplicates. However, when the input is query-sorted (actually query-grouped), then unmapped mates and secondary/supplementary reads are not excluded from the duplication test and can be marked as duplicate reads. Spark is used for parallelism in GATK 4 and can speed up the process relative to the serial tools.

```shell
# Sort by coordinates (required)
samtools sort -@ {threads} {input.bam} -o {output.sorted.bam}
# Remove PCR duplicates
picard MarkDuplicates --REMOVE_DUPLICATES true \
    --VALIDATION_STRINGENCY LENIENT -I {input.sorted.bam} \
    -M {output.rmdupstat} -O {output.rmdup.bam}
# Mark PCR duplicates
picard MarkDuplicates --REMOVE_DUPLICATES false \
    --VALIDATION_STRINGENCY LENIENT -I {input.sorted.bam} \
    -M {output.rmdupstat} -O {output.marked.bam}
```

```shell
gatk --java-options "-Xmx20G -Djava.io.tmpdir=./" MarkDuplicates --INPUT <.bam> \
    --OUTPUT ${sample}.marked.bam -M ${sample}.metrics
# Fix Mate Information
gatk --java-options "-Xmx20G -Djava.io.tmpdir=./" FixMateInformation -SO coordinate \
    -I ${sample}.marked.bam -O ${sample}.marked.fixed.bam
samtools index ${sample}.marked.fixed.bam
```

## 3. Base Recalibrator (optional)

1. BaseRecalibrator: Generates recalibration table for Base Quality Score Recalibration (BQSR)
```shell
gatk BaseRecalibrator -I {input.bam} -R {reference.fa} -O {recalibration.table} \
    --known-sites {Homo_sapiens_assembly38.dbsnp138.vcf} \
    --known-sites {Mills_and_1000G_gold_standard.indels.hg38.vcf.gz}    
```
2. ApplyBQSR: Apply base quality score recalibration
```shell
gatk ApplyBQSR -I {input.bam} -R {reference.fa} \
    --bqsr-recal-file {recalibration.table} -O {output.bam}
```
3. AnalyzeCovariates: Evaluate and compare base quality score recalibration (BQSR) tables
```shell
gatk AnalyzeCovariates -bqsr {recalibration.table} \
    -plots {AnalyzeCovariates.pdf}
```

The HaplotypeCaller is capable of calling SNPs and indels simultaneously via local de-novo assembly of haplotypes in an active region.
```shell
gatk HaplotypeCaller -ERC GVCF -R {reference.fa} -I {input.bam} -O {output.vcf.gz}
```
GenomicsDBImport merge GVCFs from multiple samples
```shell
gatk GenomicsDBImport -R {reference.fa} --intervals chr1 \
    -V {input_1.vcf.gz} -V {input_2.vcf.gz} \
    --genomicsdb-workspace-path {output.chr1_gdb} --tmp-dir ./temp \
    --max-num-intervals-to-import-in-parallel 3
```
GenotypeGVCFs: This tool is designed to perform joint genotyping on a single input, which may contain one or many samples.
```shell
gatk GenotypeGVCFs -R {reference.fa} -V {input.chr1_gdb} -O {output.chr1.vcf.gz}
```
GatherVcfs: Gathers multiple VCF files from a scatter operation into a single VCF file.
```shell
picard GatherVcfs  I=chr1.vcf.gz I=chr2.vcf.gz ... O=merged.vcf.gz
```

## 4. Structural Variation

Structural Variant: A genetic alteration of more than 50 base pairs. These include deletions, duplications, insertions, inversions, and translocations, as well as complex rearrangements.

<img src="https://gatk.broadinstitute.org/hc/article_attachments/26023438671003" alt="Structural Variation" style="max-width: 100%; height: auto;" />

### 1). Somatic Short Variant Discovery (SNVs)

#### a). [GATK](https://gatk.broadinstitute.org/hc/en-us)

Genome Analysis Toolkit

### 2). Germline Short Variant Discovery (SNPs)



### 3). CNV

Copy Number Variation (CNV) refers to a type of structural genomic variation in which segments of DNA, typically ranging from kilobases to several megabases in length, are duplicated or deleted, resulting in variation in the number of copies of specific genomic regions among individuals. CNVs can influence gene dosage, disrupt gene structure, or alter gene regulation, thereby contributing to phenotypic diversity, disease susceptibility, and evolutionary processes.

#### a). [CNVkit](https://github.com/etal/cnvkit)

> CNVkit is a Python library and command-line software toolkit to infer and visualize copy number from **hybrid capture** high-throughput DNA sequencing data.
> - Python 3.10
> - Talevich E, Shain AH, Botton T, Bastian BC (2016) CNVkit: Genome-Wide Copy Number Detection and Visualization from Targeted DNA Sequencing. PLOS Computational Biology 12(4): e1004873. https://doi.org/10.1371/journal.pcbi.1004873

```shell
# python v3.10 (recommanded)
pip install cnvkit
# conda
conda create -n cnvkit -y -c bioconda cnvkit
```

```shell
# Calculate the sequence-accessible coordinates in chromosome
cnvkit.py access {input.genome.fa} -o {output.access.bed}
# 
conda install -c bioconda ucsc-gtftogenepred
gtfToGenePred -genePredExt -allErrors -ignoreGroupsWithoutExons -geneNameAsName2 {input.gtf} /dev/stdout | \
    awk 'BEGIN {FS="\t"; OFS="\t"} {print $12, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10}' \
    > {output.refFlat}

skg_convert.py mm39_refFlat.txt -t bed -o refFlat.bed
```

```shell
# Prepare a BED file of baited regions for use with CNVkit
cnvkit.py target {input.baits.bed} --annotate {input.refFlat.txt} \
    --split -o {output.target.bed}
# Derive a BED file off-target/”antitarget” regions.
cnvkit.py antitarget {input.target.bed} -g {input.access.bed} \
    -o {output.antitargets.bed}
# Quickly estimate read counts or depths in a BAM file
cnvkit.py autobin {input.bam} --method hybrid \
    -t {input.target.bed} -g {input.access.bed}
```

```shell
# Hybrid capture (targeted regions), WES
cnvkit.py batch {input.tumor.bam} --normal {input.normal.bam} \
    --fasta {input.genome.fa} --access {input.access.bed} \
    --targets {input.target.bed} --annotate {input.refFlat.txt} \
    --processe {threads} --output-reference {output.reference.cnn} \
    --scatter --diagram --output-dir {output.dir}
# --method hybrid
```

```shell
# WGBS
cnvkit.py batch {input.tumor.bam} -n {input.normal.bam} \
    -m wgs -f {input.genome.fa} -g {input.access.bed} \
    --annotate {input.refFlat.bed} \
    -p {threads} --output-reference {output.reference.cnn} \
    --scatter --diagram -d {output.dir}
```

## HaplotypeCaller (outdated)

```shell
gatk --java-options "-Xmx20G -Djava.io.tmpdir=./" HaplotypeCaller -R <Homo_sapiens_assembly38.fasta>\
    -I ${sample}_bqsr.bam --dbsnp <Homo_sapiens_assembly38.dbsnp138.vcf> -O ${sample}.raw.vcf 1>${sample}.HC.log 2>&1
```
### Mutect2
```shell
gatk --java-options "-Xmx20g" Mutect2 -R <Homo_sapiens_assembly38.fasta> --germline-resource <af-only-gnomad.hg38.vcf.gz> \
    -I SRR12135912_bqsr.bam -tumor SRR12135912 -I SRR12135911_bqsr.bam -normal SRR12135911 \
    --af-of-alleles-not-in-resource 0.0000025 --disable-read-filter MateOnSameContigOrNoMappedMateReadFilter \
    --bam-output HQ461-untreated-Mutect2.bam -O HQ461-untreated.Mutect2.vcf
```

## tumor purity

```shell
# af-only-gnomad.hg38.SNP_biallelic.vcf.gz
gatk SelectVariants -R <Homo_sapiens_assembly38.fasta> -V <af-only-gnomad/af-only-gnomad.hg38.vcf.gz> \
    --select-type-to-include SNP --restrict-alleles-to BIALLELIC -O af-only-gnomad.hg38.SNP_biallelic.vcf.gz
# GetPileupSummaries
germine_biallelic_vcf=/home/gongyuqi/ref/GATK/hg38/af-only-gnomad/af-only-gnomad.hg38.SNP_biallelic.vcf.gz
genomic_intervals=/home/gongyuqi/ref/GATK/hg38/v0/wgs_calling_regions.hg38.interval_list
gatk GetPileupSummaries -L <wgs_calling_regions.hg38.interval_list> -V <af-only-gnomad.hg38.SNP_biallelic.vcf.gz> \
    -I SRR12135911_bqsr.bam -O SRR12135911.pileups.table
gatk GetPileupSummaries -L <wgs_calling_regions.hg38.interval_list> -V <af-only-gnomad.hg38.SNP_biallelic.vcf.gz> \
    -I SRR12135912_bqsr.bam -O SRR12135912.pileups.table
# CalculateContamination
gatk CalculateContamination -I SRR12135912.pileups.table -matched SRR12135911.pileups.table \
    -O HQ461-untreated.calculatecontamination.table
# FilterMutectCalls
nohup gatk FilterMutectCalls  -R <Homo_sapiens_assembly38.fasta> -V HQ461-untreated.Mutect2.vcf \
    --contamination-table HQ461-untreated.calculatecontamination.table -O HQ461-untreated.filtered.Mutect2.vcf
```

### SnpEff & SnpSift注释

```shell
java -jar snpEff.jar databases | less
java -jar snpEff.jar databases | grep -i GRCh38
java -jar snpEff.jar download GRCh38.99

#
java -Xmx16g -jar snpEff.jar -v GRCh38.99 HQ461-untreated.filtered.Mutect2.vcf >HQ461-untreated.filtered.ann.vcf
#保留Filter字段为'PASS'或缺失值的记录
cat HQ461-untreated.filtered.ann.vcf | java -jar SnpSift.jar filter "( na FILTER ) | (FILTER = 'PASS')" > HQ461-untreated.filtered.ann.snpsift.vcf
#保留INFO中ANN字段的IMPACT为'HIGH'或'MODERATE'的记录
cat HQ461-untreated.filtered.ann.snpsift.vcf | java -jar SnpSift.jar filter "(ANN[0].IMPACT has 'HIGH') | (ANN[0].IMPACT has 'MODERATE')" > HQ461-untreated.filtered.ann.snpsift.second.vcf

#第一个`sed`命令打印出所有标记为PASS的位点
#第二个`sed`命令承接上一个管道输出的内容，保留标记为HIGH或者MODERATE的位点
cat HQ461-untreated.filtered.ann.vcf | grep -v "#"| \
sed -n '/PASS/p' - | \
sed -n '/\(HIGH\|MODERATE\)/p' - \
>test_PASS_HIGH_MODERATE.third.vcf
```

## Tumor Purity

### sequenza

* **[Sequenza](https://cran.r-project.org/web/packages/sequenza/vignettes/sequenza.html)** is a software for the estimation and quantification of purity/ploidy and copy number alteration in sequencing experiments of tumor samples. Deep sequence of tumor DNA along with corresponding normal DNA can provide a valuable perspective on the mutations and aberrations that characterize the tumor. However, analysis of this data can be impeded by tumor cellularity and heterogeneity and by unwieldy data. Here we describe Sequenza, an R package that enables the efficient estimation of tumor cellularity and ploidy, and generation of copy number, loss-of-heterozygosity, and mutation frequency profiles.
* **Sequenza-utils** provide command lines programs to transform common NGS file format - such as **BAM, pileup and VCF** - to input files for the R package.

```shell
# Install
pip install sequenza-utils
# Process a FASTA file to produce a GC Wiggle track file:
sequenza−utils gc_wiggle −w 50 --fasta hg19.fa -o hg19.gc50Base.wig.gz
# Process BAM and Wiggle files to produce a seqz file:
sequenza−utils bam2seqz -n normal.bam -t tumor.bam --fasta hg19.fa -gc hg19.gc50Base.wig.gz -o out.seqz.gz
# Post-process by binning the original seqz file:
sequenza−utils seqz_binning --seqz out.seqz.gz -w 50 -o out small.seqz.gz
```

```r
setRepositories(graphics = FALSE, ind = 1:6)
install.packages("sequenza")

library(sequenza)
data.file <-  system.file("extdata", "example.seqz.txt.gz", package = "sequenza")
# sequenza.extract: process seqz data, normalization and segmentation
test <- sequenza.extract(data.file, verbose = FALSE)
# sequenza.fit: run grid-search approach to estimate cellularity and ploidy
CP <- sequenza.fit(test)
# sequenza.results: write files and plots using suggested or selected solution
sequenza.results(sequenza.extract = test, 
                 cp.table = CP, sample.id = "Test", out.dir = "TEST")
```

| Files                          | Description                                                                                                 |
| ------------------------------ | ----------------------------------------------------------------------------------------------------------- |
| Test_alternative_fit.pdf       | Alternative solution fir to the segments. One solution per slide                                            |
| Test_alternative_solutions.txt | List of all ploidy/cellularity alternative solution                                                         |
| Test_chromosome_depths.pdf     | Visualization of sequencing coverage in the normal and in the tumor samples, before and after normalization |
|Test_chromosome_view.pdf | Visualization per chromosome of depth.ratio, B-allele frequency and mutations, using the selected or estimated solution. One chromosome per slide
|Test_CN_bars.pdf | Bar plot representing the percentage of genome in the detected copy number states
|Test_confints_CP.txt | Table of the confidence inerval of the best solution from the model
|Test_CP_contours.pdf | Visualization of the likelihood density for each pair of cellularity/ploidy solution. The local maximum-likelihood points and confidence interval of the best estimate are also visualized
|Test_gc_plots.pdf | Visualization of the GC correction in the normal and in the tumor sample
|Test_genome_view.pdf | Genome-whide visualization of the allele-specific and absolute copy number results, and raw profile of the depth ratio and allele frequency
|Test_model_fit.pdf | model_fit.pdf
|Test_mutations.txt | Table with mutation and estimated number of mutated alleles (Mt)
|Test_segments.txt | Table listing the detected segments, with estimated copy number state at each sement
|Test_sequenza_cp_table.RData | RData object dump of the maxima a posteriori computation
|Test_sequenza_extract.RData | RData object dump of all the sample information
|Test_sequenza_log.txt | Log with version and time information

```r
# plot
cp.plot(CP)
cp.plot.contours(CP, add = TRUE,
   likThresh = c(0.999, 0.95),
   col = c("lightsalmon", "red"), pch = 20)

chromosome.view(mut.tab = test$mutations[[1]], baf.windows = test$BAF[[1]],
                ratio.windows = test$ratio[[1]],  min.N.ratio = 1,
                segments = test$segments[[1]],
                main = test$chromosomes[1],
                cellularity = 0.89, ploidy = 1.9,
                avg.depth.ratio = 1)
```


```shell
#!/bin/bash
#SBATCH -J sequenza
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -o /home/lixinjie/exome_data/fastq/trimclean/bwa/sequenza/sequenza_sort_91_97.log
cd $SLURM_SUBMIT_DIR
sequenza=/usr/local/bin/sequenza-utils
sed -n '91,97p' sortbam.txt | while read id
do
arr=($id)
normal=${arr[1]}
toumr=${arr[0]}
base=${arr[0]/.bam/}
${sequenza} bam2seqz -n ../${normal} -t ../${toumr} \
-S /home/lixinjie/.conda/envs/sam/bin/samtools \
--fasta /home/lixinjie/ref/database/hg19.fa -gc /home/lixinjie/ref/database/hg19.gc50Base.wig.gz \
-o ${base}.out.seqz.gz
${sequenza} seqz_binning --seqz ${base}.out.seqz.gz -w 50 -o out ${base}.small.seqz.gz 
done

```

### TPES

```r
library(TPES)
head(TCGA_A8_A0A7_seg)
head(TCGA_A8_A0A7_maf)
head(TCGA_A8_A0A7_ploidy)

TPES_purity(ID= "TCGA-A8-A0A7", SEGfile = TCGA_A8_A0A7_seg,
            SNVsReadCountsFile =TCGA_A8_A0A7_maf, ploidy = TCGA_A8_A0A7_ploidy,
            RMB = 0.47, maxAF= 0.55, minCov = 10, minAltReads = 5, minSNVs = 10)

TPES_report(ID= "TCGA-A8-A0A7", SEGfile = TCGA_A8_A0A7_seg,
            SNVsReadCountsFile =TCGA_A8_A0A7_maf, ploidy = TCGA_A8_A0A7_ploidy,
            RMB = 0.47, maxAF = 0.55, minCov =10, minAltReads = 5, minSNVs = 10)
```

## CNV and SNV

### method 1

```shell
ref=./hg19.fa
time samtools mpileup -ugf $ref *.bam | bcftools call -vm0 z -o out.vcf.gz

# samtools markdup -r 7E5241.bam 7E5241.rm.bam
# samtools markdup -S 7E5241.bam 7E5241.mk.bam

ref=/public/biosoft/GATK/resources/bundle/hg38/Homo_sapiens_assembly38.fasta
source activate wes
time samtools mpileup -ugf $ref  *.bam | bcftools call -vmO z -o out.vcf.gz
ls *.bam |xargs -i samtools index {}
## 没有去除PCR重复
```

### GATK

#### Download Reference Files

```shell
mkdir -p ~/biosoft/GATK/resources/bundle/hg38
cd ~/biosoft/GATK/resources/bundle/hg38
## ftp://ftp.broadinstitute.org/bundle/hg38/
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/dbsnp_146.hg38.vcf.gz
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/dbsnp_146.hg38.vcf.gz.tbi
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/Homo_sapiens_assembly38.fasta.gz
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/Homo_sapiens_assembly38.fasta.fai
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/Homo_sapiens_assembly38.dict
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/1000G_phase1.snps.high_confidence.hg38.vcf.gz
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi
mkdir bwa_index 
cd bwa_index
~/biosoft/bwa/bwa-0.7.15/bwa index -a bwtsw \
-p gatk_hg38 ../Homo_sapiens_assembly38.fasta \
1>hg38.bwa_index.log 2>&1
```

```shell
|-- [1.8G]  1000G_phase1.snps.high_confidence.hg38.vcf.gz
|-- [2.0M]  1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi
|-- [4.0K]  bwa_index
|   |-- [ 20K]  gatk_hg38.amb
|   |-- [445K]  gatk_hg38.ann
|   |-- [3.0G]  gatk_hg38.bwt
|   |-- [767M]  gatk_hg38.pac
|   |-- [1.5G]  gatk_hg38.sa
|   |-- [6.2K]  hg38.bwa_index.log
|   |-- [   0]  index.129248.err
|   |-- [   0]  index.129248.out
|   `-- [ 566]  run.sh
|-- [3.2G]  dbsnp_146.hg38.vcf.gz
|-- [2.4M]  dbsnp_146.hg38.vcf.gz.tbi
|-- [568K]  Homo_sapiens_assembly38.dict
|-- [3.0G]  Homo_sapiens_assembly38.fasta
|-- [157K]  Homo_sapiens_assembly38.fasta.fai
|-- [ 20M]  Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
|-- [1.4M]  Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi
```

```shell
GATK CreateSequenceDictionary -R hg19.fa -O hg19.dict

GATK BedToIntervalList -I S31285117_Regions.bed -O Exon.Interval.bed -SD ../ref/hg19.dict

# WES
GATK CollectHsMetrics -BI Exon.Interval.bed -TI Exon.Interval.bed -I wes.sorted.bam -O wes.cov.txt
# On targeted bases相对总bases的比例（PCT_USABLE_BASES_ON_BAIT）
# On and near targeted bases相对总bases的比例（PCT_SELECTED_BASES）
# MEAN_TARGET_COVERAGE平均覆盖度

# WGS
GATK CollectWgsMetrics -I wes.sorted.bam -O wgs.metrics -R $GENOME
```

#### Data pre-processing

#### remove PCR Duplicates

```shell
GATK --java-options "-Xmx10G -Djava.io.tmpdir=./" MarkDuplicates -I wes.sorted.bam -O wes.sorted.MarkDuplicates.bam -M wes.sorted.bam.metrics > log.mark 2>&1

# 查看被标记重复的reads
samtools view –f 1024 wes.sorted.MarkDuplicates.bam | less

samtools index wes.sorted.MarkDuplicates.bam
```



```shell
# 去除PCR重复
samtools markup -r <input.bam> <output.bam>
samtools markup -S  <input.bam> <output.bam>
```

```shell
INDEX=/umac/biosoft/GATK/resources/bundle/hg38/bwa_index/gatk_hg38
fq1=clean_fastq/CGU_OSCC_32_WXS_N_1_val_1.fq.gz
fq2=clean_fastq/CGU_OSCC_32_WXS_N_2_val_2.fq.gz
sample='oscc'
GENOME=/umac/biosoft/GATK/resources/bundle/hg38/Homo_sapiens_assembly38.fasta
GATK=/umac/biosoft/GATK/gatk-4.0.2.1/gatk
DBSNP=/umac/biosoft/GATK/resources/bundle/hg38/dbsnp_146.hg38.vcf.gz

bwa mem -t 5 -M -R "@RG\tID:$sample\tSM:$sample\tLB:WES\tPL:Illumina" $INDEX $fq1 $fq2 1>$sample.sam

$GATK --java-options "-Xmx20G -Djava.io.tmpdir=./" SortSam -SO coordinate -I $sample.sam -O $sample.bam 1>log.sort 2>&1

samtools index $sample.bam
samtools flagstat $sample.bam > ${sample}.alignment.flagstat
samtools stats $sample.bam > ${sample}.alignment.stat
echo plot-bamstats -p ${sample}_QC ${sample}.alignment.stat

$GATK --java-options "-Xmx20G -Djava.io.tmpdir=./" MarkDuplicates -I $sample.bam -O ${sample}_marked.bam -M $sample.metrics 1>log.mark 2>&1

$GATK --java-options "-Xmx20G -Djava.io.tmpdir=./" FixMateInformation -I ${sample}_marked.bam -O ${sample}_marked_fixed.bam -SO coordinate 1>log.fix 2>&1
samtools index ${sample}_marked_fixed.bam
```

#### Search CNV and SNV

```shell
## 首先设置好软件地址
GENOME=/umac/biosoft/GATK/resources/bundle/hg38/Homo_sapiens_assembly38.fasta
GATK=/umac/biosoft/GATK/gatk-4.0.2.1/gatk
DBSNP=/umac/biosoft/GATK/resources/bundle/hg38/dbsnp_146.hg38.vcf.gz
sample='oscc'

$GATK  --java-options "-Xmx20G -Djava.io.tmpdir=./" HaplotypeCaller -R $GENOME -I ${sample}_marked_fixed.bam  --dbsnp $DBSNP -O ${sample}_raw.vcf 1>log.HC 2>&1
```



```shell
bam=${sample}_marked_fixed.bam
time $GATK  --java-options "-Xmx20G -Djava.io.tmpdir=./"   BaseRecalibrator \
-I $bam -R $GENOME --output ${sample}_recal.table --known-sites $kgSNP --known-sites $kgINDEL
time $GATK  --java-options "-Xmx20G -Djava.io.tmpdir=./"   ApplyBQSR \
-I $bam -R $GENOME --output ${sample}_recal.bam -bqsr ${sample}_recal.table
rm ${sample}_marked_fixed.bam

for bam in  /home/jianmingzeng/data/alignment/*_recal.bam
do
  if((i%$1==$2))
        then
sample=$(basename "$bam" _recal.bam)
echo $sample
$GATK  --java-options "-Xmx20G -Djava.io.tmpdir=./"   HaplotypeCaller  \
-ERC GVCF  -L $bed -R $GENOME -I $bam  --dbsnp $DBSNP -O  ${sample}_raw.vcf

        fi
        i=$((i+1))
done

for bed in  chr{1..22} chrX chrY
do
  if((i%$1==$2))
        then
echo $bed

time $GATK  --java-options "-Xmx20G -Djava.io.tmpdir=./"   GenomicsDBImport  \
-L $bed -R $GENOME \
-V 1NT-1_raw.vcf \
-V 1NT-2_raw.vcf \
--genomicsdb-workspace-path gvcfs_${bed}.db

time $GATK  --java-options "-Xmx20G -Djava.io.tmpdir=./"   GenotypeGVCFs  \
-R $GENOME  -V gendb://gvcfs_${bed}.db  -O final_${bed}.vcf

        fi
        i=$((i+1))
done


```



```shell
source activate wes
GATK=/home/jmzeng/biosoft/gatk4/gatk-4.0.6.0/gatk
ref=/public/biosoft/GATK/resources/bundle/hg38/Homo_sapiens_assembly38.fasta
snp=/public/biosoft/GATK/resources/bundle/hg38/dbsnp_146.hg38.vcf.gz
indel=/public/biosoft/GATK/resources/bundle/hg38/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz  

for sample in {7E5239.L1,7E5240,7E5241.L1}
do 
echo $sample  
# Elapsed time: 7.91 minutes
$GATK --java-options "-Xmx20G -Djava.io.tmpdir=./" MarkDuplicates \
    -I $sample.bam \
    -O ${sample}_marked.bam \
    -M $sample.metrics \
    1>${sample}_log.mark 2>&1 


## Elapsed time: 13.61 minutes
$GATK --java-options "-Xmx20G -Djava.io.tmpdir=./" FixMateInformation \
    -I ${sample}_marked.bam \
    -O ${sample}_marked_fixed.bam \
    -SO coordinate \
    1>${sample}_log.fix 2>&1 

samtools index ${sample}_marked_fixed.bam

##  17.2 minutes
$GATK --java-options "-Xmx20G -Djava.io.tmpdir=./"  BaseRecalibrator \
    -R $ref  \
    -I ${sample}_marked_fixed.bam  \
    --known-sites $snp \
    --known-sites $indel \
    -O ${sample}_recal.table \
    1>${sample}_log.recal 2>&1 
    
$GATK --java-options "-Xmx20G -Djava.io.tmpdir=./"   ApplyBQSR \
    -R $ref  \
    -I ${sample}_marked_fixed.bam  \
    -bqsr ${sample}_recal.table \
    -O ${sample}_bqsr.bam \
    1>${sample}_log.ApplyBQSR  2>&1 
    
## 使用GATK的HaplotypeCaller命令
$GATK --java-options "-Xmx20G -Djava.io.tmpdir=./" HaplotypeCaller \
     -R $ref  \
     -I ${sample}_bqsr.bam \
      --dbsnp $snp \
      -O ${sample}_raw.vcf \
      1>${sample}_log.HC 2>&1  

done 
```



### mutect2-somatic mutation

#### 构建PON

* First, run gatk Mutect2 in tumor-only mode on each normal sample to call all detectable variants: Needs an interval list.

##### Run Mutect2 in tumor-only mode for each normal sample:

```shell
## $1 for the config file, such as : normal_bam_for_pon.txt 
## $2 and $3 for submit jobs.
# for i in {0..5};do sbatch run_PoN-step1.sh normal_bam_for_pon.txt 6 $i;done
GENOME=/home/biosoft/GATK/resources/bundle/hg38/Homo_sapiens_assembly38.fasta 
GATK=/home/biosoft/gatk/gatk-4.1.8.1/gatk 
cat $1 | while read normal_bam
do
    echo $normal_bam
    if((i%$2==$3))
    then
    id=$(basename "$normal_bam" _recal.bam)
    $GATK Mutect2 -R ${GENOME} -I $normal_bam --max-mnp-distance 0 -O ${id}_mutect2_normal.vcf.gz 1> ${id}_mutect2_normal.log 2>&1
    fi
    i=$((i+1))
done
```

##### Create a GenomicsDB from the normal Mutect2 calls:

```shell
GENOME=/home/biosoft/GATK/resources/bundle/hg38/Homo_sapiens_assembly38.fasta 
GATK=/home/biosoft/gatk/gatk-4.1.8.1/gatk 
interval=/home/biosoft/GATK/resources/bundle/hg38/resources_broad_hg38_v0_wgs_calling_regions.hg38.interval_list 

# normal_bam_for_pon.txt
${GATK} GenomicsDBImport -R ${GENOME} -L ${interval} \
--merge-input-intervals TRUE $(ls *.vcf.gz | awk '{print "-V "$0" "}') \
--genomicsdb-workspace-path pon_db 1> GenomicsDBImport.log 2>&1
```

##### Combine the normal calls using CreateSomaticPanelOfNormals:

```shell
gnomad=/home/biosoft/GATK/resources/bundle/hg38/somatic-hg38_af-only-gnomad.hg38.vcf 

${GATK} CreateSomaticPanelOfNormals -R ${GENOME} \
--germline-resource ${gnomad} -V gendb://pon_db \
-O pon.vcf.gz 1> CreateSomaticPanelOfNormals.log 2>&1
```

#### CALL MUTATIONS IN THE TUMOR IN SOMATIC MODE.

```shell
GENOME=/home/jianmingzeng/biosoft/GATK/resources/bundle/hg38/Homo_sapiens_assembly38.fasta 
reference=$GENOME
GATK=/home/jianmingzeng/biosoft/gatk/gatk-4.1.8.1/gatk 
cat $config_file |while read id
do
 arr=($id)
 normal_bam=${arr[1]}
 tumor_bam=${arr[2]}
 sample=${arr[0]}
 # 上面是解析配置文件config
 time $GATK Mutect2 -R $reference \
 -I $tumor_bam -tumor $(basename "$tumor_bam" _recal.bam) \
 -I $normal_bam -normal $(basename "$normal_bam" _recal.bam) \
 -pon pon.vcf.gz \
 -O ${sample}_mutect2.vcf

done ## end for $config_file
```



## GWAS

Genome-wide association study (GWAS), 

R packages: qqman(曼哈顿图), GAPIT(GWAS分析), CMplot(绘图), 

### Gene Family Analysis
1. Download HMM model by protein motif id from **Pfam** database
   Download genome from Ensemble, JGI, NCBI
2. Search protein with motif by **hmmsearch**
3. Construct evolutionary tree by MEGA-X
4. Search motif by MEME to reveal gene function
5. Draw gene chromosome location map
6. Gene structure analysis
7. Ka/Ks calculator
```shell
hmmsearch --cut_tc --domtblout NB-ARC-PF00931.txt NB-ARC-PF00931.hmm Arabidopsis_thaliana.TAIR10.pep.all.fa
```

* [GWAS数据分析专题](https://mp.weixin.qq.com/s?src=11&timestamp=1648189838&ver=3697&signature=3JCkOyNohBDsr8Wi6YqWJa8-x1KO2d7P5PneErZD6SKXcRUhJziaTWa2IgGVL5cRoekKTP*ncU-j2kWtNBpmto6rHDcEHmyoedfSk60Dcb5TnmYqik1cCOgPOLjIHu4K&new=1)

## Genome Assembler 
### [SPAdes](https://github.com/ablab/spades)


## MSI

### [MSIsensor-pro](https://github.com/xjtu-omics/msisensor-pro)

> MSIsensor-pro is an updated version of msisensor. MSIsensor-pro evaluates Microsatellite Instability (MSI) for cancer patients with next generation sequencing data. It accepts the whole genome sequencing, whole exome sequencing and target region (panel) sequencing data as input.

## eccDNA



```shell
#!/bin/bash

mkdir -p $outputDir/03_bwa

bwa mem -t $threads -q $bwaIndexDir 01_raw/$fq1 01_raw/$fq2 | \
    samtools view -@ $threads -t $chromSizes -b -o | \
    samtools sort -@ $threads $outputDir/03_bwa/$prefix.sorted.bam
samtools index $outputDir/03_bwa/$prefix.sorted.bam
samtools flagstat $outputDir/03_bwa/$prefix.sorted.bam \
    > $outputDir/03_bwa/$prefix.sorted.flagstat

samtools view -h $outputDir/03_bwa/$prefix.sorted.bam | \
    awk '$6 ~ /S/ || $1 ~ /^@/{print}' | \
    samtools view -@ $threads -b \
        -o $outputDir/03_bwa/$prefix.sorted.softClipReads.bam
samtools index $outputDir/03_bwa/$prefix.sorted.softClipReads.bam
samtools flagstat $outputDir/03_bwa/$prefix.sorted.softClipReads.bam \
    > $outputDir/03_bwa/$prefix.sorted.softClipReads.flagstat

###########################################################
mkdir -p $outputDir/04_circlemap

samtools sort -@ $threads -n -o $outputDir/03_bwa/$prefix.sortedByName.bam \
    $outputDir/03_bwa/$prefix.sorted.bam

Circle-Map ReadExtractor -i $outputDir/03_bwa/$prefix.sortedByName.bam \
    -o $outputDir/04_circlemap/$prefix.circular_read_candidates.bam

samtools sort -@ $threads \
    -o $outputDir/04_circlemap/$prefix.circular_read_candidates.sorted.bam \
    $outputDir/04_circlemap/$prefix.circular_read_candidates.bam

samtools index $outputDir/04_circlemap/$prefix.circular_read_candidates.sorted.bam

###########################################################
# Detecting the circular DNA

Circle-Map Realign -t $threads -fasta $genomeSeq \
    -i $outputDir/04_circlemap/$prefix.circular_read_candidates.sorted.bam \
    -qbam $outputDir/03_bwa/$prefix.sortedByName.bam \
    -sbam $outputDir/03_bwa/$prefix.sorted.bam \
    -o $outputDir/04_circlemap/$prefix.circularDNA.bed

```

---

# Reference

1. Genome Analysis Toolkit: https://gatk.broadinstitute.org/hc/en-us
2. A practical introduction to GATK 4 on Biowulf (NIH HPC): https://hpc.nih.gov/training/gatk_tutorial/
3. 