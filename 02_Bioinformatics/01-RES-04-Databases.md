---
Title: Databases
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2020-10-20
Modified: 2026-10-14
ai-usage: Original draft by author; text revised and expanded with the assistance of AI.
---
# Bioinformatics Databases

## 1. Public Data Archives and Reference Annotation

| Database | Main content and use |
| --- | --- |
| [GEO](https://www.ncbi.nlm.nih.gov/geo/) | Functional genomics studies, sample metadata, processed matrices, and supplementary files; a primary entry point for public transcriptomic and epigenomic datasets. |
| [SRA](https://www.ncbi.nlm.nih.gov/sra) | Raw sequencing reads for RNA-seq, ChIP-seq, ATAC-seq, WGBS, and other assays. |
| [ENA](https://www.ebi.ac.uk/ena/browser/home) | Sequencing archive with file-level metadata and direct FASTQ download links; useful for retrieving public reads programmatically. |
| [GSA](https://ngdc.cncb.ac.cn/gsa/) / [GSA-Human](https://ngdc.cncb.ac.cn/gsa-human) | CNCB-NGDC sequencing archives; GSA-Human hosts human genetic data, including datasets requiring controlled access. |
| [NCBI Datasets](https://www.ncbi.nlm.nih.gov/datasets/) / [RefSeq](https://www.ncbi.nlm.nih.gov/refseq/) | Genome assemblies, reference transcripts and proteins, gene annotations, and assembly metadata. |
| [GENCODE](https://www.gencodegenes.org/) | Human and mouse gene and transcript annotations, including protein-coding genes and lncRNAs; reference GTF/FASTA files for RNA-seq analysis. |
| [Ensembl](https://www.ensembl.org/) | Genome and gene annotations, stable identifiers, orthology, and comparative genomics; legacy releases and tools are available through archives. |
| [UCSC Genome Browser](https://genome.ucsc.edu/) | Reference genomes and genomic annotation tracks, with access to regulatory elements, conservation, repeats, and public epigenomic signals. |
| [Dfam](https://www.dfam.org/) | Transposable element and repeat-family sequences and models for repeat annotation and transposon-associated regulatory analysis. |

## 2. Epigenomic Atlases and Regulatory Elements

| Database | Main content and use |
| --- | --- |
| [ENCODE](https://www.encodeproject.org/) | Human and mouse functional genomics data, including TF/histone ChIP-seq, ATAC-seq, DNase-seq, methylation, and RNA-seq, with experiment metadata and QC. |
| [SCREEN](https://screen.encodeproject.org/) | ENCODE candidate cis-regulatory elements (cCREs), promoter/enhancer-like annotations, supporting signals, and candidate target-gene links. |
| [Roadmap Epigenomics](https://egg2.wustl.edu/roadmap/web_portal/) | Reference human tissue and cell epigenomes, including histone marks, DNA methylation, accessibility, and ChromHMM states. |
| [EpiMap](https://compbio.mit.edu/epimap/) | Integrated observed and imputed epigenomic tracks, chromatin states, active enhancers, and correlation-based enhancer–gene links across human biosamples. |
| [FANTOM5](https://fantom.gsc.riken.jp/5/) | CAGE-based transcription start sites, promoter activity, and transcribed enhancer atlases across tissues, primary cells, and differentiation time courses. |
| [VISTA Enhancer Browser](https://enhancer.lbl.gov/) | Human and mouse candidate enhancers tested in transgenic mouse embryos, with tissue-specific reporter activity and images for developmental regulatory studies. |
| [4D Nucleome](https://data.4dnucleome.org/) | Hi-C and related chromatin conformation datasets, nuclear imaging, and processed interaction maps for studying three-dimensional genome organization. |
| [MethBank](https://ngdc.cncb.ac.cn/methbank/) | Single-base DNA methylomes, methylation profiles, and differentially methylated regions across tissues, development, and disease. |

## 3. Binding Profiles and Motifs

| Database | Main content and use |
| --- | --- |
| [Cistrome Data Browser](https://db3.cistrome.org/browser/) | Uniformly processed human and mouse ChIP-seq profiles of TFs, cofactors, and chromatin regulators, alongside ATAC-seq/DNase-seq accessibility data. |
| [ChIP-Atlas](https://chip-atlas.org/) | Reprocessed public ChIP-seq binding profiles with peak browsing, overlap enrichment, and candidate target-gene analysis across cell types and conditions. |
| [GTRD](https://gtrd.biouml.org/) | Uniformly processed TF ChIP-seq peaks and aggregated binding-site clusters for querying occupancy near genes and across genomic regions. |
| [POSTAR3](https://postar.ncrnalab.org/) | CLIP-seq-derived RBP binding sites across species, integrated with RNA structure, translation, and variant annotations for studying post-transcriptional regulation. |
| [ENCORI / starBase](https://starbase.sysu.edu.cn/) | CLIP-supported RBP–RNA binding sites and interaction networks, with additional miRNA–target and RNA–RNA interaction resources. |
| [CIS-BP](https://cisbp.ccbr.utoronto.ca/) / [CISBP-RNA](https://cisbp-rna.ccbr.utoronto.ca/) | Experimentally measured and inferred binding motifs for TFs and RBPs, respectively, with species, protein-family, and evidence annotations. |
| [JASPAR](https://jaspar.elixir.no/) | Curated TF binding profiles across species; the CORE collection provides non-redundant, experimentally supported motifs for scanning and enrichment analysis. |
| [HOCOMOCO](https://hocomoco.autosome.org/) | Curated human and mouse TF binding models derived from in vivo and in vitro assays; useful for regulatory sequence analysis and motif-based variant interpretation. |
| [ATtRACT](https://attract.cnic.es/) | Experimentally supported RBP binding motifs, consensus sequences, and position weight matrices, with assay and literature annotations. |

## 4. Transcriptome Reanalysis and Expression Atlases

| Database | Main content and use |
| --- | --- |
| [recount3](https://rna.recount.bio/) / [recount2](https://jhubiostatistics.shinyapps.io/recount/) | Uniformly processed public RNA-seq with gene/exon coverage counts, splice-junction counts, and bigWigs; recount3 covers human and mouse, while recount2 provides the earlier human collection. |
| [GTEx](https://www.gtexportal.org/home/) | Human tissue expression and eQTL/sQTL data for tissue specificity and genetic regulation of transcription and splicing. |
| [Human Protein Atlas](https://www.proteinatlas.org/) | Tissue, cell-type, and subcellular RNA/protein expression, including brain, immune, and cancer resources. |

## 5. Single-Cell and Developmental Atlases

| Database | Main content and use |
| --- | --- |
| [CELLxGENE Discover](https://cellxgene.cziscience.com/) | Curated single-cell expression collections with standardized cell metadata and downloadable matrices; Census supports queries across datasets. |
| [CATlas](https://www.catlas.org/catlas/) | Single-cell epigenomic atlases and cell-type-specific cis-regulatory elements, including brain datasets and regulatory sequence models. |
| [Human Cell Atlas](https://data.humancellatlas.org/) | Human tissue and cell atlas studies with sequencing files, expression matrices, and donor/sample metadata. |
| [Descartes / BBI Single-Cell Atlases](https://descartes.brotmanbaty.org/) | Single-cell gene expression and chromatin accessibility atlases, including human fetal development and model-organism developmental datasets. |
| [CellMarker](https://bio-bigdata.hrbmu.edu.cn/CellMarker/) | Literature-curated human and mouse cell-type markers with tissue and evidence annotations for single-cell cluster annotation. |

## 6. Cancer Genomics and Tumor Microenvironment

| Database | Main content and use |
| --- | --- |
| [GDC / TCGA](https://portal.gdc.cancer.gov/) | Cancer cohort data, including gene expression, DNA methylation, mutations, copy-number alterations, and clinical annotations. |
| [UCSC Xena](https://xenabrowser.net/datapages/) | Downloadable cancer multi-omics matrices and clinical data, including TCGA and integrated TCGA/GTEx expression collections. |
| [cBioPortal](https://www.cbioportal.org/) | Cancer genomic alterations and clinical associations across published cohorts, with mutation, copy-number, and survival exploration. |
| [DepMap](https://depmap.org/portal/) | Cancer cell line molecular profiles and CRISPR gene dependencies for investigating essential genes and context-specific vulnerabilities. |
| [TISCH2](https://tisch.compbio.cn/) | Annotated tumor single-cell RNA-seq datasets covering malignant, immune, and stromal populations; useful for tumor microenvironment expression and cell-state comparisons. |

## 7. Immune and Neural Atlases

| Database | Main content and use |
| --- | --- |
| [ImmGen](https://www.immgen.org/) | Mouse immune cell expression and chromatin accessibility across lineages, differentiation, and activation states. |
| [DICE](https://dice-database.org/) | Human immune cell expression, eQTLs, and epigenomic resources for cell-type-specific immune regulation. |
| [Allen Brain Map](https://brain-map.org/) | Human and mouse brain cell types, spatial gene expression, developmental atlases, and anatomical reference data. |
| [PsychENCODE](https://www.psychencode.org/resources) | Human brain transcriptomic and epigenomic datasets, regulatory networks, and QTL resources for neurodevelopment and psychiatric disease. |

## 8. Genetic and Epigenetic Associations

| Database | Main content and use |
| --- | --- |
| [GWAS Catalog](https://www.ebi.ac.uk/gwas/) | Published variant–trait associations and available summary statistics for linking regulatory regions to complex traits and disease. |
| [EWAS Catalog](https://www.ewascatalog.org/) | Published DNA methylation–trait associations searchable by CpG, gene, genomic region, or phenotype; useful for interpreting disease-associated methylation changes. |
| [eQTL Catalogue](https://www.ebi.ac.uk/eqtl/) | Uniformly processed human expression and splicing QTL datasets across tissues and cell types; useful for regulatory variant interpretation and colocalization. |
| [gnomAD](https://gnomad.broadinstitute.org/) | Population allele frequencies, variant QC, and gene constraint metrics for filtering and prioritizing candidate variants. |

## 9. Functional Annotation and Molecular Networks

| Database | Main content and use |
| --- | --- |
| [Gene Ontology](https://geneontology.org/) | Biological process, molecular function, and cellular component annotations for functional interpretation and enrichment analysis. |
| [Reactome](https://reactome.org/) | Curated molecular reactions and pathways for pathway enrichment and interpretation of signaling and regulatory mechanisms. |
| [KEGG](https://www.kegg.jp/) | Pathway maps, orthology groups, and molecular interaction and reaction networks. |
| [MSigDB](https://www.gsea-msigdb.org/gsea/msigdb/) | Hallmark, pathway, regulatory, immunologic, and cell-type gene sets for GSEA and signature-based analysis. |
| [STRING](https://string-db.org/) | Protein functional association networks integrating experiments, curated knowledge, coexpression, and other evidence. |
| [BioGRID](https://thebiogrid.org/) | Literature-curated protein and genetic interactions with experimental evidence; useful for chromatin complexes, signaling networks, and functional interaction analysis. |
| [CellPhoneDB](https://www.cellphonedb.org/) | Curated ligands, receptors, and their interactions, including multisubunit complexes; a reference for inferring cell–cell communication from single-cell expression data. |
| [UniProt](https://www.uniprot.org/) | Protein functions, domains, post-translational modifications, and interaction annotations for interpreting TFs, chromatin regulators, and signaling proteins. |
