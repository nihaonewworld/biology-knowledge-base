---
Title: Proteomics
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2020-11-26
Modified: 2026-03-28
tags:
  - MS
  - Incomplete
---
# 1. Introduction

> Proteomics refers to the analysis of protein function through large-scale separation, identification and quantification using high-throughput technology.
> Proteomics, as the combination of proteome experimentation and data analysis, analyzes protein composition, structure, expression, modification status, and the interactions and connections between proteins at an overall level.
> Protein expression mapping: 2-DE combined with MS for quantitative proteome expression in cells
> Protein interaction mapping: yeast two-hybrid system coupled with MS to determine the interaction partners for each cell’s encoded proteins and the proteome-wide scale.

# 2. Experimental Design

## 2.1 Proteomic Strategies

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://cdn.ncbi.nlm.nih.gov/pmc/blobs/ddf2/9489649/bff24b78c674/nihms-1836683-f0001.jpg" 
        alt="Schematic illustration of the scientific study workflow and core mechanism from PMC publication"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> Overview of the experimental workflow and structural mechanism. 
        Source: <a href="https://www.ncbi.nlm.nih.gov/pmc/" target="_blank" rel="noopener noreferrer">PubMed Central (PMC)</a>.
    </figcaption>
</figure>

## 2.2 Sample Preparation

## 2.2 Protein and Peptide Separation

### 2.2.1 Electrophoresis

> 1. One-dimensional electrophoresis, 1-DE
> 2. Two-dimensional electrophoresis, 2-DE
> 3. 2D-DIGE
> 4. SDS-PAGE

### 2.2.2 Chromatography

> 1. Size exclusion chromatography (SEC)
> 2. Ion-exchange chromatography (IEC)
> 3. Affinity chromatography
> 4. **Liquid chromatography (LC)**

### 2.2.3 Antibody-based approach

> 1. immunohistochemistry (IHC) staining
> 2. Western blotting
> 3. Enzyme-linked immunosorbent assay (ELISA)

## 2.3 Protein identification and characterization

> 1. Edman sequencing
> 2. Protein microarray
> 3. Mass spectrometry

### 2.3.1 LC-MS

## 2.4 Others

> Protein pathway array (PPA), a gel-based high-throughput platform, employed antibody mixtures to detect antigens in a protein sample which can be extracted from biopsy or tissue.

---
# 3. Processing

## 3.1 Process raw data (Search library)

[MaxQuant](https://www.maxquant.org/) is a quantitative proteomics software package designed for analyzing large mass-spectrometric data sets.

## 3.2 Data analysis

The [Perseus](https://www.maxquant.org/perseus/) software platform supports biological and biomedical researchers in interpreting protein quantification, interaction and post-translational modification data.

* data filtering
  1. filter contaminating protein
  2. 过虑unique peptide >1
  3. 搜库时加了反库，可以过滤掉反库
* data conversion
* missing value replacement
* Z-score normalized
* heatmap and volcano map
* Differential protein screening
* Protein pathway and interaction analysis
  * QIAGEN Ingenuity Pathway Analysis (http://www.ingenuity.com, paid software)
  * String (https://string-db.org, free)

---
# Database

> 1. [ProteomeXchange](https://www.proteomexchange.org/): The ProteomeXchange (PX) consortium of proteomics resources aims to standardize data submission and dissemination of public MS proteomics data worldwide. 
> 	- Eric W Deutsch, Nuno Bandeira, Yasset Perez-Riverol, Vagisha Sharma, Jeremy J Carver, Luis Mendoza, Deepti J Kundu, Shengbo Wang, Chakradhar Bandla, Selvakumar Kamatchinathan, Suresh Hewapathirana, Benjamin S Pullman, Julie Wertz, Zhi Sun, Shin Kawano, Shujiro Okuda, Yu Watanabe, Brendan MacLean, Michael J MacCoss, Yunping Zhu, Yasushi Ishihama, Juan Antonio Vizcaíno, The ProteomeXchange consortium at 10 years: 2023 update, _Nucleic Acids Research_, Volume 51, Issue D1, 6 January 2023, Pages D1539–D1548, [https://doi.org/10.1093/nar/gkac1040](https://doi.org/10.1093/nar/gkac1040).
> 2. etc.

---
# Reference

> 1. [proteomics-data-analysis-tutorial](https://github.com/PNNL-Comp-Mass-Spec/proteomics-data-analysis-tutorial): A comprehensive tutorial for proteomics data analysis in R that utilizes packages developed by researchers at PNNL and from Bioconductor.