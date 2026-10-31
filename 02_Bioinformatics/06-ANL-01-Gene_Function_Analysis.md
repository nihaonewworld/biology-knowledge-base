---
Title: Gene Function Analysis
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2020-08-24
Modified: 2023-11-05
---
# Gene Set And Pathway

### 1. GO
Gene Ontology ([GO](https://geneontology.org)) is a logical structure that describing the full complexity of the biology, comprising the ‘classes’ (often referred to as ‘terms’) describing the many different types of molecular functions (Molecular Function), the pathways carrying out different biological programs (Biological Process), and the cellular locations where these occur (Cellular Component). The GO is structured by relating each class to other classes using specific relations.

- Class: 
	1. Molecular Function (MF)
	2. Biological Process (BP)
	3. Cellular Component (CC)

wget https://current.geneontology.org/ontology/go-basic.obo -nv -O go-basic.obo

[GO.db](https://bioconductor.org/packages/release/data/annotation/html/GO.db.html)

### 2. KEGG
Kyoto Encyclopedia of Genes and Genomes ([KEGG](https://www.genome.jp/kegg))

- Class:
	1. Metabolism
	2. Genetic information processing
	3. Environmental information processing
	4. Cellular processes
	5. Organismal systems
	6. Human diseases
	7. Drug development

The KEGG MODULE database is a collection of KEGG modules, manually defined functional units of gene sets.

[KEGGREST](https://www.bioconductor.org/packages/release/bioc/html/KEGGREST.html)

### 3. MSigDb
The Molecular Signatures Database ([MSigDb](https://www.gsea-msigdb.org/gsea/msigdb)) is a resource of tens of thousands of annotated gene sets for use with GSEA software, divided into Human and Mouse collections.

- [msigdbr](https://igordot.github.io/msigdbr): The msigdbr R package provides Molecular Signatures Database (MSigDB) gene sets.

### 4. DO
Disease Ontology ([DO](https://disease-ontology.org)) has been developed as a standardized ontology for human disease to provide the biomedical community with consistent, reusable, and sustainable descriptions of human disease terms, phenotype characteristics, and related medical vocabulary disease concepts.

- [DOSE](https://bioconductor.org/packages/release/bioc/html/DOSE.html): Disease Ontology Semantic and Enrichment analysis

### 5. DisGeNET
Disease Gene Network ([DisGeNET](https://disgenet.com)) a knowledge management platform integrating and standardizing data about disease-associated genes and variants from multiple sources, including the scientific literature.

### 6. Reactome
[Reactome Pathway Database](https://reactome.org) is an open-source, open-access, manually curated, and peer-reviewed pathway database. Our aim is to provide user-friendly bioinformatics tools for visualizing, interpreting, and analyzing pathway knowledge to support basic and clinical research, genome analysis, modeling, systems biology, and education.

- [ReactomePA](https://bioconductor.org/packages/release/bioc/html/ReactomePA.html): Reactome Pathway Analysis

### 7. WikiPathways
[WikiPathways](https://www.wikipathways.org) is an open science platform for biological pathways contributed, updated, and used by the research community.

### 8. MeSH
Medical Subject Headings ([MeSH](https://www.ncbi.nlm.nih.gov/mesh)) is the NLM controlled vocabulary thesaurus used for indexing articles for PubMed.

- [meshes](https://bioconductor.org/packages/release/bioc/html/meshes.html)： MeSH Enrichment and Semantic analyses


## Analysis Method

### 1. ORA
Over Representation Analysis (ORA), hypergeometric test (one-tailed Fisher’s exact test):

| - | gene set | Not in gene set | Sum|
| - | - | - | - |
|In foreground | **k** | M − k | M (foreground) |
|Not in foreground | K − k | N − K − (M − k) | N−M|
|Sum | K (gene set) | N − K | N (universe) |

$ p = 1 - \displaystyle\sum_{i = 0}^{k-1}\frac{{M \choose i}{{N-M} \choose {n-i}}} {{N \choose n}} $

R (Bioconductor / CRAN / Github)
1. [clusterProfiler](https://github.com/YuLab-SMU/clusterProfiler)
2. [topGO](https://bioconductor.org/packages/release/bioc/html/topGO.html)
3. [GOfuncR](https://www.bioconductor.org/packages/release/bioc/html/GOfuncR.html)
4. [GOstats](https://www.bioconductor.org/packages/release/bioc/html/GOstats.html)
5. [GOexpress](https://www.bioconductor.org/packages/release/bioc/html/GOexpress.html)
6. [ViSEAGO](https://www.bioconductor.org/packages/release/bioc/html/ViSEAGO.html) 
7. [CompGO](https://www.bioconductor.org/packages/3.13/bioc/html/CompGO.html)

### 2. GSEA
Gene Set Enrichment Analysis (GSEA), 

1. Calculation of an Enrichment Score
2. Esimation of Significance Level of ES
3. Adjustment for Multiple Hypothesis Testing

- [fgsea](https://github.com/alserglab/fgsea): fgsea is an R package (Bioconductor) for fast preranked gene set enrichment analysis.

### 3. GSVA
Gene Set Variation Analysis

[GSVA](https://www.bioconductor.org/packages/release/bioc/html/GSVA.html)


### Leading edge analysis and core enriched genes
?

## Semantic Similarity?

what it is?

1. GO semantic similarity analysis: [GOSemSim](https://www.bioconductor.org/packages/release/bioc/html/GOSemSim.html), GO-terms Semantic Similarity Measures
2. DO semantic similarity analysis: [DOSE](https://bioconductor.org/packages/release/bioc/html/DOSE.html), Disease Ontology Semantic and Enrichment analysis
3. MeSH semantic similarity analysis: [meshes](https://bioconductor.org/packages/release/bioc/html/meshes.html), MeSH Enrichment and Semantic analyses
4. 



#### Kyoto Encyclopedia of Genes and Genomes (KEGG)

#### [g:Profiler](https://biit.cs.ut.ee/gprofiler/gost)
`g:GOSt` performs functional enrichment analysis, also known as over-representation analysis (ORA) or gene set enrichment analysis, on input gene list.
#### [Enrichr](https://maayanlab.cloud/Enrichr)
Enrichr: interactive and collaborative HTML5 gene list enrichment analysis tool


clusterProfiler: R package, Functional enrichment
[Metascape](https://metascape.org/gp/index.html): Web site, Functional enrichment


#### [EggNOG-mapper](https://github.com/eggnogdb/eggnog-mapper)
EggNOG-mapper is a tool for fast functional annotation of novel sequences. It uses precomputed orthologous groups and phylogenies from the eggNOG database (http://eggnog5.embl.de) to transfer functional information from fine-grained orthologs only.

```shell
# Download the eggNOG-mapper databases
download_eggnog_data.py --data_dir eggnogDatabase
# Create a diamond database for Bacteria
create_dbs.py -m diamond --dbname bacteria --taxa Bacteria --data_dir eggnogDatabase
```

```shell
emapper.py --cpu $threads --override -i $protein.fa --data_dir eggnogDatabase \
	-m diamond --dmnd_db eggnogDatabase/fungi.dmnd \
	--output $outputPrefix --output_dir $outputDir
```
