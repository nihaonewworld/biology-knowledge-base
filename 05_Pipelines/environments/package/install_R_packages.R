#!/usr/bin/env Rscript
# ==============================================================================
# R Package Installation & Environment Setup Script
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Environment Initialization & Repository Settings
# ------------------------------------------------------------------------------
# Options for CRAN/Bioconductor mirrors (Uncomment to use Chinese mirrors)
# options(repos = c(CRAN = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))
# options(BioC_mirror = "https://mirrors.tuna.tsinghua.edu.cn/bioconductor")

# Update all existing CRAN packages
update.packages(ask = FALSE, checkBuilt = TRUE)

# Install from remote repositories
install.packages("remotes")

# Fast, modern package installer
install.packages("pak")

# Initialize Bioconductor Manager
if (!require("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}
BiocManager::install(update = FALSE)


#-----------------------------------------------------------
# XML parser
#-----------------------------------------------------------
# conda install -c conda-forge libxml2-devel zlib
install.packages("XML")
install.packages("xml2")

#-----------------------------------------------------------
# Graphics device package
#-----------------------------------------------------------
# conda install -c conda-forge freetype expat pkg-config
install.packages("ragg")

#-----------------------------------------------------------
# SVG image rendering (X11)
#-----------------------------------------------------------
# sudo apt install -y xorg-dev
# conda install -c conda-forge librsvg glib
install.packages("rsvg")

#-----------------------------------------------------------
# Graphics device package (X11)
#-----------------------------------------------------------
# conda install -c conda-forge xorg-xproto
install.packages("Cairo")

#-----------------------------------------------------------
# Execute JavaScript code within R
#-----------------------------------------------------------
# sudo apt install libv8-dev
install.packages("V8")

#-----------------------------------------------------------
# ImageMagick library for advanced image processing
#-----------------------------------------------------------
# conda install imagemagick
install.packages("magick")

#-----------------------------------------------------------
# Version issue
#-----------------------------------------------------------
# Statistical functions
# remotes::install_version("MASS", version = "7.3-60")
install.packages("MASS")

# Sparse and dense matrix operations
# remotes::install_version("Matrix", version = "1.6-4")
install.packages("Matrix")

############################################################

#-----------------------------------------------------------
# Install R packages from repositories
#-----------------------------------------------------------
# options(repos = c(CRAN = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))

# Update all CRAN packages
update.packages(ask = FALSE, checkBuilt = TRUE)

install.packages("remotes")
# install.packages("devtools")
# https://github.com/r-lib/pak
install.packages("pak")

#-----------------------------------------------------------
# Install Bioconductor packages
#-----------------------------------------------------------
# options(BioC_mirror="https://mirrors.tuna.tsinghua.edu.cn/bioconductor")
# options(BioC_mirror = "https://mirrors.westlake.edu.cn/bioconductor")

if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

# BiocManager::install(version = "3.22") # R 4.5.2
# BiocManager::install(version = "3.20") # R 4.4.3
# BiocManager::install(version = "3.18") # R 4.3.3
# BiocManager::install(version = "3.10") # R 3.6.3
BiocManager::install(update = FALSE)

############################################################
# Others
#-----------------------------------------------------------
# Command-line argument parsing
install.packages(c("optparse"))
# Parallel computing & data processing
install.packages(c("future", "foreach", "doParallel"))
# Markdown reporting
install.packages(c("rmarkdown","bookdown"))
# Web applications
install.packages(c("shiny", "shinythemes"))
# Native R kernel for Jupyter
install.packages("IRkernel")
# Interface to Python
install.packages("reticulate")
# Workflow & code styling
install.packages("styler")

#-----------------------------------------------------------
# Data Import/Export
#-----------------------------------------------------------
# Universal data import/export
install.packages("rio")
# # SPSS, Stata, and SAS
# install.packages("haven")
# JSON
install.packages("jsonlite")
# XML
install.packages(c("XML", "xml2"))
# HDF5
# conda install -c conda-forge hdf5=1.14.6
install.packages("hdf5r")
BiocManager::install("rhdf5")
# Excel
install.packages(c("readxl", "writexl", "tidyxl", "openxlsx"))
# # Database Connectivity
# install.packages("DBI")
# install.packages("dbplyr")
# install.packages("duckdb")
# install.packages("odbc")

# Web API
install.packages(c("httr", "RCurl"))
# Web Scraping
install.packages("rvest")

# Quick serialization of R objects
# # https://github.com/qsbase/qs
install.packages("qs")
# https://github.com/qsbase/qs2
install.packages("qs2")

############################################################
# Data Handling & Structure
#-----------------------------------------------------------

# Data structure
install.packages("data.table")

# Transform data
install.packages("tidyverse")
install.packages("reshape2")

# Time series
install.packages("slider")
install.packages("forecast")
# install.packages("prophet")

# Units
# conda install udunits2
install.packages("units")

# Spatial Data
# Spherical geometry library for spatial calculations
# conda install libabseil
install.packages("s2")
# Standard package for handling vector spatial data
# conda install -c conda-forge gdal geos proj proj-data
install.packages("sf")
# For raster and vector spatial data analysis, modeling, and visualization.
install.packages("terra")

############################################################
# Math & Algorithms
#-----------------------------------------------------------
# Efficient matrix statistics
install.packages("matrixStats")
# Sparse matrix handling
install.packages("readsparse")
# Data ordering and arrangement optimization
install.packages("seriation")
# Permutations and combinations
install.packages("combinat")
# Quadratic programming solver
install.packages("quadprog")
# Nonlinear optimization
install.packages("nloptr")
# Hash Algorithm
install.packages("digest")

############################################################
# Statistical Analysis and Modeling
#-----------------------------------------------------------
# Unified Multiple Testing Procedures
# conda install fftw
BiocManager::install("multtest")
install.packages("mutoss")
# Meta-Analysis of Significance Values
install.packages("metap")
# Common statistical tests and result summaries
install.packages("rstatix")
# Tools for data analysis, descriptive statistics, and visualization
install.packages("Hmisc")
# Cross-tabulation and model fitting
install.packages("gmodels")
# Linear and generalized linear mixed-effects models
install.packages("lme4")
# Kernel density estimation and multivariate statistical analysis
install.packages("ks")
# PCA, factor analysis, and visualization
install.packages(c("FactoMineR", "factoextra"))
# Generalized linear model PCA
install.packages("glmpca")

############################################################
# Machine Learning
#-----------------------------------------------------------
# Machine learning modeling framework
install.packages("tidymodels")
# Dimensionality Reduction
# T-Distributed Stochastic Neighbor Embedding
install.packages("Rtsne")
# Uniform Manifold Approximation and Projection
install.packages("uwot")
# Standard clustering analysis methods
install.packages("cluster")
# Poisson model for clustering sequence data
install.packages("PoiClaClu")
# Gaussian mixture modeling for clustering, classification, and density estimation
install.packages("mclust")
# Recursively partitioned mixture model
install.packages("RPMM")
# Fast nearest neighbor search algorithm
install.packages("FNN")
# Classification and Regression
install.packages("caret")
# Random forests
install.packages("randomForest")
# Machine Learning Evaluation Metrics
install.packages("MLmetrics")
# visualizing classifier performance
install.packages("ROCR")
# # Interface to TensorFlow deep learning framework
# install.packages("tensorflow")

############################################################
# Visualization
#-----------------------------------------------------------
# remotes::install_version("ggplot2", version = "3.5.2")
install.packages("ggplot2")
# drawing elements
install.packages(c("gghighlight", "ggpubr", "ggforce", "lemon"))
# scales
install.packages(c("scales", "ggnewscale"))
# txt, labels
install.packages(c("ggtext", "ggrepel", "directlabels"))
# legends
remotes::install_github("teunbrand/gtguides")
# themes
install.packages(c("ggthemes"))

# Rasterized plotting for large datasets
install.packages(c("ggrastr"))

# Plot layout & composition
install.packages(c("cowplot", "patchwork", "gridExtra"))
remotes::install_github('bbc/bbplot')

# Simplified plotting interfaces
install.packages("tidyplots")
remotes::install_github("sjessa/ggmin")

# ggplot2 extension
install.packages(c("ggfortify", "ggdist", "see"))
# Alluvial / Sankey plots
install.packages("ggalluvial")
# Ridgeline plots
install.packages("ggridges")
# Beeswarm plots
install.packages("ggbeeswarm")
# half violin/boxplots
# https://github.com/erocoar/gghalves
remotes::install_github("erocoar/gghalves")
# Correlation and scatterplot matrix extensions
install.packages(c("GGally"))
# A Grammar of Animated Graphics
install.packages("gganimate")

#-----------------------------------------------------------
# Standard heatmap plotting
install.packages(c("pheatmap", "tidyheatmaps"))
# Advanced heatmap & linkage visualization
remotes::install_github("Hy4m/linkET")
# Correlation matrix visualization
install.packages(c("corrplot", "ggcorrplot"))
# Radar charts
remotes::install_github("ricardo-bion/ggradar", dependencies = TRUE)
remotes::install_github("xl0418/ggradar2", dependencies = TRUE)
# Venn & Upset
install.packages(c("eulerr", "ggVennDiagram"))
install.packages(c("ggupset", "ComplexUpset", "UpSetR"))
?remotes::install_github("js229/Vennerable")
# Dendrogram visualization
install.packages("dendextend")
# Treemap plotting
install.packages("treemap")
# Graph/network visualization
install.packages(c("tidygraph", "ggraph"))
# Circular visualization
install.packages("circlize")
# Hexbin chart
install.packages("hexbin")
# Interactive ROC curve plot
install.packages("plotROC")
# Wordcloud
install.packages("wordcloud2")
# 3D scatter plots
install.packages("scatterplot3d")
# Interactive visualization
install.packages(c("plotly", "echarts4r", "highcharter"))
# Interactive network graphs
install.packages("networkD3")

#-----------------------------------------------------------
# Color Palette
install.packages("RColorBrewer")
install.packages("paletteer")
install.packages("ggsci")
install.packages("viridis")
install.packages("viridisLite")
install.packages("colorspace")
remotes::install_github("thomasp85/scico")
remotes::install_github("clauswilke/colorblindr")
remotes::install_github("cwickham/munsell")
install.packages("nord")
install.packages("pals")
install.packages("MetBrewer")
install.packages("wesanderson")

############################################################
# Dataset
#-----------------------------------------------------------
# install.packages("palmerpenguins")
# install.packages("nycflights13")

############################################################
# Geographic Information System (GSI)
#-----------------------------------------------------------
# # Basic geographic map data
# install.packages("maps")
# # GIS data processing
# install.packages("stars")
# install.packages("mapproj")
# install.packages("rmapshaper")
# # ggplot2 spatial extensions
# install.packages("ggspatial")

############################################################
# Bioinformatics packages and Bioconductor packages
#-----------------------------------------------------------
# conda install -c conda-forge xz
# Tools for reading, writing, and manipulating SAM/BAM/FASTA sequencing files
BiocManager::install("Rsamtools")
# Import/export of genome annotation files
BiocManager::install("rtracklayer")

# Genomic Range Data Processing
BiocManager::install("plyranges")
BiocManager::install("GenomeInfoDb")
BiocManager::install("GenomicRanges")
BiocManager::install("GenomicFeatures")
BiocManager::install("GenomicAlignments")

# Database
#-----------------------------------------------------------
BiocManager::install(
  c("GEOquery", "ExpressionAtlas",
    "TCGAbiolinks", "SRAdb"))

# Dataset
#-----------------------------------------------------------
# RangedSummarizedExperiment for RNA-Seq in airway smooth muscle cells
BiocManager::install("airway")

#-----------------------------------------------------------
# Reference Genome Information
# Interface for annotation databases
BiocManager::install(
  c("Homo.sapiens", "Mus.musculus"))
BiocManager::install(
  c("org.Hs.eg.db", "org.Mm.eg.db"))
BiocManager::install(
  c("TxDb.Hsapiens.UCSC.hg19.knownGene", 
    "TxDb.Hsapiens.UCSC.hg38.knownGene",
    "TxDb.Mmusculus.UCSC.mm10.knownGene",
    "TxDb.Mmusculus.UCSC.mm39.knownGene"))
BiocManager::install(
  c("EnsDb.Hsapiens.v86", 
    "EnsDb.Mmusculus.v79"))
# EnsDb.Hsapiens.v75
BiocManager::install(
  c("BSgenome.Hsapiens.UCSC.hg38",
    "BSgenome.Mmusculus.UCSC.mm10"))
# BSgenome.Hsapiens.UCSC.hg19
# BSgenome.Mmusculus.UCSC.mm39

############################################################
# WGS & WES
#-----------------------------------------------------------
# Annotates genetic variants (VCF parsing, functional impact)
BiocManager::install("VariantAnnotation")
# Analysis and visualization of mutation annotation format (MAF) data
BiocManager::install("maftools")
# Circular Binary Segmentation for copy number data
BiocManager::install("DNAcopy")
# Single nucleotide variants (SNVs)
BiocManager::install("SomaticSignatures")
# DNA mutational signatures
install.packages("mutSignatures")

# Mutational Signature Discovery Using Hierarchical Dirichlet Processes
# https://cran.r-project.org/src/contrib/Archive/ICAMS/ICAMS_3.0.11.tar.gz
remotes::install_version("ICAMS", version = "3.0.11")
remotes::install_github("steverozen/hdpx")
remotes::install_github("steverozen/mSigHdp")
# Detects positively selected (driver) genes using dN/dS
remotes::install_github("im3sanger/dndscv")

# Candidate gene prioritization using co-expression networks
BiocManager::install("cageminer")

############################################################
# Microarray & RNA-seq
#-----------------------------------------------------------
# A collection of pre-processing functions
BiocManager::install("preprocessCore")
# Two-color spotted microarray data
BiocManager::install("marray")
# Annotate microarray probes
install.packages("AnnoProbe")
# Imputation for microarray data
BiocManager::install("impute")
# Microarray analysis
# https://github.com/cran/tinyarray
install.packages("tinyarray")
# Import transcript quantification results
BiocManager::install(c("tximeta", "tximport"))

# Differentially expressed genes (DEGs)
# Linear modeling for differential expression
BiocManager::install("limma")
# NB-based differential expression for RNA-seq
BiocManager::install("edgeR")
# Widely used RNA-seq differential expression analysis
BiocManager::install("DESeq2")
BiocManager::install("DEGseq")
# Splicing graph analysis
BiocManager::install("SGSeq")
# Differential exon usage analysis
BiocManager::install("DEXSeq")

# Tools for analyzing high-resolution sequencing data
remotes::install_github("mdeber/BRGenomics")

# Batch effect
#-----------------------------------------------------------
# Surrogate variable analysis for batch effects
BiocManager::install("sva")
# Independent surrogate variable analysis
install.packages("isva")
# Iteratively adjusted SVA
BiocManager::install("iasva")
# Remove unwanted variation
BiocManager::install("RUVSeq")

# Soft clustering for time-series expression
BiocManager::install("Mfuzz")
BiocManager::install("TCseq")
# Regression-based time-course analysis
BiocManager::install("maSigPro")

# Resampling-based multiple hypothesis testing
BiocManager::install("multtest")

# Inferring cell components based on expression matrix
# Immune and stroma cell types
remotes::install_github('dviraran/xCell')
# Immune cell
remotes::install_github("omnideconv/immunedeconv")
# Inferring cell components based on deconvolution
# BiocManager::install("DeconRNASeq")

# DNA methylation chip/arrays analysis
BiocManager::install("minfi")
BiocManager::install("ChAMP")
BiocManager::install("sesame")
BiocManager::install("missMethyl")
BiocManager::install("wateRmelon")
# DNA methylation chip/arrays analysis workflow
BiocManager::install("methylationArrayAnalysis")
# Whole-genome methylation analysis
BiocManager::install("bsseq")

# Differentially methylated loci or regions (DML/DMRs)
BiocManager::install("DSS")
BiocManager::install("DMRcate")
BiocManager::install("methylKit")
BiocManager::install("bumphunter")
# BiocManager::install("FEM") # v3.10

# Differentially binding analysis of peaks
BiocManager::install("DiffBind")
# ChIP-Seq Analysis with Windows
BiocManager::install("csaw")

# Peaks Annotation, Comparison, and Visualization
BiocManager::install("ChIPseeker")
BiocManager::install("ChIPpeakAnno")
# Detection of consensus regions
BiocManager::install("consensusSeekeR")
# Tools for the analysis of enrichment-based epigenomic data.
# BiocManager::install("Repitools") # v3.22

# ATAC-seq
BiocManager::install("ATACseqQC")
# identify motifs associated with variability in chromatin accessibility
BiocManager::install("chromVAR")
# Software Package for Transcription Factor Binding Site (TFBS) Analysis
BiocManager::install("TFBSTools")

# Peak Calling and differential analysis for MeRIP-Seq
remotes::install_github("ZW-xjtlu/exomePeak2")
# remotes::install_github("compgenomics/MeTPeak")
# remotes::install_github("compgenomics/MeTDiff")

# Ribosome Profiling Data Analysis
BiocManager::install("RiboProfiling")
BiocManager::install("riboSeqR")
remotes::install_github("LabTranslationalArchitectomics/riboWaltz")
# Differentially translational efficiency genes
BiocManager::install("anota2seq")

############################################################
# Common
#-----------------------------------------------------------
# Principal Components Analysis
BiocManager::install("PCAtools")

# Gene function database
install.packages("msigdbr")
BiocManager::install("GO.db")
BiocManager::install("KEGGREST")

# identification and correction of invalid gene symbols for human and mouse
install.packages("HGNChelper")
# Homologous gene
install.packages('homologene')

# Gene function enrichment analysis
install.packages("mulea")
# conda install conda-forge::xorg-kbproto
# install.packages("gdtools")
# remotes::install_github("YuLab-SMU/ggtree")
BiocManager::install("clusterProfiler")
# Gene Set Enrichment Analysis
BiocManager::install("fgsea")
# Gene Set Variation Analysis
BiocManager::install("GSVA")
# Enrichment Analysis for Gene Ontology
BiocManager::install("topGO")
BiocManager::install("goseq")
# Enrichment Analysis for Disease Ontology
BiocManager::install("DOSE")
# Simplify Functional Enrichment Results
BiocManager::install("simplifyEnrichment")
# Visualization
BiocManager::install("pathview")
install.packages("gprofiler2")

# Motif database
BiocManager::install("MotifDb")
BiocManager::install("JASPAR2024")
# Import, Modify, and Export Motifs
BiocManager::install("universalmotif")
# Motif analysis
# conda install -c conda-forge libgit2
install.packages("gert")
BiocManager::install("memes")
BiocManager::install("monaLisa")
# De novo motif discovery
# BiocManager::install("rGADEM")

############################################################
# Visualization
#-----------------------------------------------------------
# IGV plots
BiocManager::install("Gviz")
BiocManager::install("ggbio")
BiocManager::install("trackViewer")
# Circular visualization
install.packages("RCircos")
# Idiograms plots
install.packages("RIdeogram")
# Guitar
BiocManager::install("Guitar")
# Volcan plots
# BiocManager::install("EnhancedVolcano")
# Sequence logos
BiocManager::install("seqLogo")
BiocManager::install("motifStack")
# Gene arrow maps
install.packages("gggenes")



# Heatmap
BiocManager::install("ComplexHeatmap")
BiocManager::install("EnrichedHeatmap")
BiocManager::install("InteractiveComplexHeatmap")
remotes::install_github("junjunlab/ClusterGVis")

# Visualizing Spatial Assays in Anatomical Images
BiocManager::install("spatialHeatmap")
# remotes::install_github("jianhaizhang/spatialHeatmap",
#   build_vignettes=TRUE, dependencies=TRUE)

# Plotting R graph objects from the graph package
# BiocManager::install("Rgraphviz")

############################################################
# Others
#-----------------------------------------------------------
# Locally query GenBank
install.packages("restez")
install.packages("biomartr")
# Parsing GenBank files
# BiocManager::install("genbankr") # v3.18

# Read and analyse RepeatMasker output in R
remotes::install_github("dwinter/repeatR")

# Biological Sequences Retrieval and Analysis
install.packages("seqinr")
# K-mer counting and clustering for biological sequence analysis
install.packages("kmer")
# Set of tools to identify periodic occurrences of k-mers in DNA sequences
BiocManager::install("periodicDNA")

# Phylogenetics and evolution
install.packages("ape")
# Microbiome analysis
BiocManager::install("phyloseq")
# Ecological and diversity analysis
# remotes::install_github("vegandevs/vegan")
install.packages("vegan")

# Workflow Environment for Data Analysis and Report Generation
BiocManager::install("systemPipeR")

# Molecular subtyping and prognostic models of breast cancer (PAM50)
BiocManager::install("genefu")

############################################################
# R 3.6.3
#-----------------------------------------------------------
conda create -n r363 r-base=3.6.3 r-essentials r-devtools

if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install(version = "3.10")
