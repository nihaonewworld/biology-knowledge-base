############################################################
# Single-cell transcriptomics analysis framework
#-----------------------------------------------------------

# Seurat V5
install.packages("Seurat")
install.packages("SeuratObject")
remotes::install_github("satijalab/seurat-wrappers")
# Presto performs a fast Wilcoxon rank sum test and auROC analysis
remotes::install_github("immunogenomics/presto")
install.packages('Rfast2')

# Seurat V4
remotes::install_version("Matrix", version = "1.6-4")
remotes::install_version("SeuratObject", version = "4.1.4")
remotes::install_version("Seurat", version = "4.4.0")
# Seurat V3
remotes::install_version("Seurat", version = "3.2.3")
# Seurat V2
# packageurl <- "https://cran.r-project.org/src/contrib/Archive/Seurat/Seurat_2.3.4.tar.gz"
# install.packages(packageurl, repos=NULL, type="source")
remotes::install_version("Seurat", version = "2.3.4")

# Monocle
BiocManager::install("monocle") # monocle2
remotes::install_github("bnprks/BPCells/r")
install.packages(
	"https://cran.r-project.org/src/contrib/Archive/grr/grr_0.9.5.tar.gz",
	repos = NULL, type = "source")
# conda install libabseil
install.packages("spdep")
remotes::install_github('cole-trapnell-lab/monocle3')

# Bioconductor
BiocManager::install("scran")
BiocManager::install("scater")
BiocManager::install("scuttle")

# A toolkit for single-cell immune profiling
# https://github.com/BorchLab/scRepertoire
BiocManager::install("scRepertoire")

############################################################
# Single-cell epigenomics / multi-omics analysis framework
#-----------------------------------------------------------

# Signac (Seurat)
install.packages("Signac")
# remotes::install_version("Signac", version = "1.11.0")

# Cicero (Monocle3)
# Single-cell epigenomics analysis framework
BiocManager::install("cicero")
# remotes::install_github(
# 	"cole-trapnell-lab/cicero-release", ref = "monocle3")

# ArchR
# https://github.com/GreenleafLab/ArchR
remotes::install_github(
  "GreenleafLab/ArchR", ref = "master", 
  repos = BiocManager::repositories())

# SnapATAC
# snap (Single Nucleus Accessibility Profile) file
# https://github.com/r3fang/SnapTools
pip install snaptools
# https://github.com/r3fang/SnapATAC
install.packages(c('doSNOW', "plot3D"))
remotes::install_github("r3fang/SnapATAC")

# Scverse
# annotated multimodal data objects
pip install mudata
# Single-cell multi-omics analysis framework
pip install muon
# Single-cell epigenomics analysis framework
# https://github.com/scverse/SnapATAC2
pip install "numpy<2.0" "pandas<2.2" "anndata<=0.10.9"
pip install snapatac2

# Large-scale single-cell perturbation experiments
# https://github.com/scverse/pertpy
pip install pertpy

############################################################
# Spatial single-cell transcriptomics analysis framework
#-----------------------------------------------------------

# Seurat
# Apache Arrow C++ library for R
# https://github.com/apache/arrow
# conda install -c conda-forge libarrow
# conda install conda-forge::compilers
install.packages("arrow")

# Stereopy (MGI)
# python 3.8
pip install stereopy

############################################################
# Data format
#-----------------------------------------------------------
# Seurat Object
remotes::install_github("mojaveazure/seurat-disk")

# HDF5
BiocManager::install("rhdf5")
BiocManager::install("HDF5Array")

# An R interface for loom files
remotes::install_github("mojaveazure/loomR")
BiocManager::install("LoomExperiment")

# conversion of different single-cell data formats
remotes::install_github("cellgeni/sceasy")

# RPy2 converter from AnnData to SingleCellExperiment and back.
# https://github.com/theislab/anndata2ri
pip install anndata2ri

# S4 Class for Spatially Resolved -omics Data
BiocManager::install("SpatialExperiment")
# The VisiumIO package provides a set of functions to import 10X Genomics Visium experiment data into a SpatialExperiment object
BiocManager::install("VisiumIO")
# Import and represent Xenium data from the 10X Xenium Analyzer
BiocManager::install("XeniumIO")
# Read in Xenium, CosMx, MERSCOPE or STARmapPLUS data as SpatialExperiment object
BiocManager::install("SpatialExperimentIO")
# Integrating SpatialExperiment with Simple Features in sf
BiocManager::install("SpatialFeatureExperiment")

# The ggspavis package contains visualization functions for spatial transcriptomics data.
# https://github.com/lmweber/ggspavis
BiocManager::install("ggspavis")

############################################################
# Optimize performance
#-----------------------------------------------------------
# Reduce memory usage and optimize performance
BiocManager::install("DelayedArray")
BiocManager::install("DelayedMatrixStats")

############################################################
# Algorithm
#-----------------------------------------------------------
# Fit a Gamma-Poisson Generalized Linear Model
BiocManager::install("glmGamPoi")

############################################################
# Utilities for Handling Single-Cell Droplet Data
#-----------------------------------------------------------
BiocManager::install("DropletUtils")

# https://github.com/constantAmateur/SoupX
install.packages('SoupX')

# https://github.com/campbio/decontX
BiocManager::install("decontX")

############################################################
# Doublet Detection
#-----------------------------------------------------------
# remotes::install_github("chris-mcginnis-ucsf/DoubletFinder@1b1d4e2") # v2.0.3
remotes::install_github('chris-mcginnis-ucsf/DoubletFinder')

# remotes::install_version("xgboost", version = "2.1.4") # for scDblFinder < v1.23.2
BiocManager::install("scDblFinder")


# a statistical framework for deconvolution of heterogeneous tissue samples based on mRNA-Seq data
remotes::install_git("https://git.bioconductor.org/packages/DeconRNASeq")
# https://github.com/EDePasquale/DoubletDecon
remotes::install_github('EDePasquale/DoubletDecon')

# https://github.com/kostkalab/scds
# remotes::install_version("xgboost", version = "2.1.4")
BiocManager::install("scds")

# https://github.com/13308204545/Chord
# devtools::install_github("13308204545/Chord")

# https://github.com/swolock/scrublet
pip install scrublet

pip install doubletdetection

############################################################
# Integration
#-----------------------------------------------------------
# remotes::install_github("immunogenomics/harmony")
install.packages("harmony")

# Implements the Leiden algorithm via an R interface
# https://github.com/kharchenkolab/leidenAlg
# conda install -c conda-forge gmp
install.packages("leidenAlg")
# RcppPlanc is an Rcpp wrapper for planc.
# https://github.com/welch-lab/RcppPlanc
install.packages("RcppPlanc")
# install.packages('RcppPlanc', repos = 'https:/welch-lab.r-universe.dev')
# LIGER is a package for integrating and analyzing multiple single-cell datasets.
# https://github.com/welch-lab/liger
# https://welch-lab.github.io/liger/index.html
install.packages("rliger")

# https://github.com/kharchenkolab/conos
install.packages('conos')

# Batch Correction Methods
BiocManager::install("batchelor")

# An R package to calculate representation of cells in 
# single-cell genomic data, by their similarities to external 
# references (RSS) or cell clusters in the data (CSS).
# https://github.com/quadbio/simspec
remotes::install_github("quadbiolab/simspec")

# scVi
# https://github.com/scverse/scvi-tools
pip install torch torchvision
pip install scvi-tools

# https://github.com/Teichlab/bbknn
pip install bbknn

# https://github.com/brianhie/scanorama
pip install scanorama

# https://github.com/theislab/trVAE
# python 3.6
pip install virtualenv

# https://github.com/KrishnaswamyLab/SAUCIE
git clone https://github.com/KrishnaswamyLab/SAUCIE
pip install -r SAUCIE/requirements.txt

############################################################
# Integration assess
#-----------------------------------------------------------

BiocManager::install("CellMixS")
# 1. Detection of batch effects and biases in single-cell RNA-seq data
# 2. Evaluation and comparison of data integration

# https://github.com/cbib/Seurat-Integrate
remotes::install_github(
	"cbib/Seurat-Integrate", dependencies = TRUE,
	repos = BiocManager::repositories())
# Distance computation
install.packages('distances')
# Local Inverse Simpson’s Index computation
remotes::install_github("immunogenomics/lisi")
# K-nearest neighbour batch effect test
remotes::install_github('theislab/kBET')

############################################################
# Clustering
#-----------------------------------------------------------
# Find variable genes
# Single-cell consensus Clustering
BiocManager::install("SC3")
# Identify significantly variable genes
BiocManager::install("M3Drop")

# https://github.com/mengxu98/scop
pak::pak("mengxu98/scop")


BiocManager::install("MAST")

############################################################
# Visualization
#-----------------------------------------------------------
# Seurat
install.packages("scCustomize")
# Clustering trees
install.packages("clustree")
# simpler single cell RNAseq data Visualization
remotes::install_github("Japrin/sscVis")
# Nebulosa is an R package to visualize data from single cells based on kernel density estimation.
# https://github.com/powellgenomicslab/Nebulosa
BiocManager::install("Nebulosa")

BiocManager::install("simplifyEnrichment")
remotes::install_github("TheHumphreysLab/plot1cell")

BiocManager::install("dittoSeq")
BiocManager::install("Nebulosa")

############################################################
# Annotation cells
#-----------------------------------------------------------
# Automatic Annotation

# Bindings to C++ Libraries for Single-Cell Analysis
BiocManager::install("scrapper")
# https://github.com/dviraran/SingleR
BiocManager::install("SingleR")

# https://github.com/rnabioco/clustifyr
BiocManager::install("clustifyr")
# https://github.com/ZJUFanLab/scCATCH
install.packages("scCATCH")
# https://github.com/ggjlab/scHCL
remotes::install_github("ggjlab/scHCL")
# https://github.com/ggjlab/scMCA
remotes::install_github("ggjlab/scMCA")

# https://github.com/cole-trapnell-lab/garnett
remotes::install_github("cole-trapnell-lab/garnett")
# https://github.com/Irrationone/cellassign
# install.packages("tensorflow")
# tensorflow::install_tensorflow(extra_packages='tensorflow-probability', version = "2.1.0")
# tensorflow::tf_config()
remotes::install_github("Irrationone/cellassign")
# https://github.com/satijalab/azimuth
remotes::install_github('satijalab/azimuth')


# https://github.com/Teichlab/celltypist
pip install celltypist
# https://github.com/bowang-lab/scGPT
pip install scgpt "flash-attn<1.0.5"

# Efficient and precise single-cell reference atlas mapping with Symphony
# https://github.com/immunogenomics/symphony
install.packages("symphony")

#-----------------------------------------------------------
# CellMentor is a novel supervised cell type aware 
# non-negative matrix factorization (NMF) method designed for 
# enhanced cell type resolution in single-cell RNA sequencing analysis.
# https://github.com/petrenkokate/CellMentor
# BiocManager::install("CellMentor")

#-----------------------------------------------------------
# Reference Cell Type Datasets
BiocManager::install("celldex")

############################################################
# Trajectory Inference
#-----------------------------------------------------------
install.packages(
	"https://cran.r-project.org/src/contrib/Archive/smoother/smoother_1.3.tar.gz",
	repos = NULL, type = "source")
BiocManager::install("destiny")
BiocManager::install("slingshot")
BiocManager::install("TrajectoryUtils")

# https://github.com/statOmics/tradeSeq
BiocManager::install("tradeSeq")

############################################################
# Gene Trajectory Inference
#-----------------------------------------------------------
# https://github.com/KlugerLab/GeneTrajectory
install.packages("flexclust")
install.packages("additivityTests")
install.packages(
	"https://cran.r-project.org/src/contrib/Archive/biclust/biclust_2.0.3.tar.gz",
	repos = NULL, type = "source")
remotes::install_github("KlugerLab/GeneTrajectory")

############################################################
# Cell-cell communication
#-----------------------------------------------------------
# API that integrates multiple intercellular communication methods and resources
# https://github.com/saezlab/liana
remotes::install_github('saezlab/liana')

# https://github.com/sqjin/CellChat (v1)
# https://github.com/jinworks/CellChat (v2)
remotes::install_github("jinworks/CellChat")

# Estimate the downstream effects of signalling
# https://github.com/saeyslab/nichenetr
remotes::install_github("saeyslab/nichenetr")
remotes::install_github("saeyslab/multinichenetr")

remotes::install_github("msraredon/NICHES")

# https://github.com/martaint/InterCellar
BiocManager::install("InterCellar")
BiocManager::install("SingleCellSignalR")

# https://github.com/BlishLab/scriabin
remotes::install_github("BlishLab/scriabin", ref = "main")
# https://github.com/Coolgenome/iTALK
remotes::install_github("Coolgenome/iTALK", build_vignettes = TRUE)

# https://github.com/soumelis-lab/ICELLNET
remotes::install_github("soumelis-lab/ICELLNET",ref="master", subdir="icellnet")
# https://github.com/ShellyCoder/cellcall
remotes::install_github("ShellyCoder/cellcall")
# https://github.com/SunXQlab/scMLnet
remotes::install_github("YUZIXD/scMLnet")

# https://github.com/tanlabcode/CytoTalk
# pip install git+https://github.com/fraenkel-lab/pcst_fast.git
devtools::install_github("tanlabcode/CytoTalk")

# https://github.com/saezlab/liana-py
# part of the scverse ecosystem

# https://github.com/ventolab/CellphoneDB
pip install cellphonedb

# MATLAB
# https://github.com/WangShuxiong/SoptSC

# Database
# https://github.com/ZJUFanLab/CellTalkDB
wget https://github.com/ZJUFanLab/CellTalkDB/releases/download/v1.0/scsrctdb-1.0.tar.gz
install.packages(pkgs = 'scsrctdb-1.0.tar.gz',repos = NULL, type = "source")


https://github.com/zcang/SpaOTsc
https://github.com/Zafar-Lab/Renoir

############################################################
# Gene function
#-----------------------------------------------------------
# enrichment statistical methods
pip install decoupler

# high dimensional WGCNA
# https://github.com/smorabit/hdWGCNA
BiocManager::install("GeneOverlap")

BiocManager::install("UCell")
remotes::install_github('smorabit/hdWGCNA')

# https://github.com/carmonalab/GeneNMF
install.packages("GeneNMF")

# Cell stemness analysis
# https://github.com/digitalcytometry/cytotrace2
# conda install -c conda-forge netcdf4
install.packages("ncdf4")
install.packages("HiClimR")
remotes::install_github("digitalcytometry/cytotrace2", subdir = "cytotrace2_r")

BiocManager::install("AUCell")

BiocManager::install("UCell")

BiocManager::install("singscore")

# https://github.com/YosefLab/VISION
# conda install -c anaconda libsodium
install.packages("sodium")
remotes::install_github("YosefLab/VISION")

# Infer Copy Number Variation from Single-Cell RNA-Seq Data
# conda install -c conda-forge jags
install.packages("rjags")
BiocManager::install("infercnv")

############################################################
# RNA velocity estimation
#-----------------------------------------------------------
# https://github.com/velocyto-team/velocyto.R
# conda install -c conda-forge libboost-devel
remotes::install_github("velocyto-team/velocyto.R")
# https://github.com/velocyto-team/velocyto.py
pip install "numpy<2.0" "pandas<2.2"
pip install velocyto

# https://scvelo.readthedocs.io/en/stable/
# https://github.com/theislab/scvelo
pip install scvelo

# https://github.com/theislab/cellrank
pip install cellrank

############################################################
# perturbation
#-----------------------------------------------------------
# https://github.com/neurorestore/Augur
remotes::install_github("neurorestore/Augur")

# Perturbation response modeling based on deep learning
# https://github.com/theislab/scgen
pip install scgen

# https://github.com/morris-lab/CellOracle
pip install celloracle

############################################################
# Immune repertoire analysis
#-----------------------------------------------------------
# https://github.com/BorchLab/scRepertoire
BiocManager::install("scRepertoire")

# https://github.com/immunomind/immunarch
pak::pkg_install("immunomind/immunarch")

# https://github.com/Japrin/STARTRAC
remotes::install_github("Japrin/STARTRAC")

# Single-cell immune receptor analysis framework
pip install scirpy

############################################################
# Metabolism
#-----------------------------------------------------------
# https://github.com/wu-yc/scMetabolism

remotes::install_github("wu-yc/scMetabolism")

# https://github.com/changwn/scFEA
git clone https://github.com/changwn/scFEA
pip install --user magic-impute

# Python 2.7
# https://github.com/YosefLab/Compass
python -m pip install git+https://github.com/yoseflab/Compass.git --upgrade

############################################################
# Others
#-----------------------------------------------------------
# delineates small extracellular vesicles at droplet resolution from single-cell transcriptomes
# https://github.com/bioinfo-biols/SEVtras
pip install SEVtras

# Host-Microbiome Interactions
# https://github.com/sjdlabgroup/SAHMI
Rscript script.R

# TRUST4 is a computational tool to analyze TCR and BCR sequences using unselected RNA sequencing data,
# https://github.com/liulab-dfci/TRUST4
git clone https://github.com/liulab-dfci/TRUST4.git

############################################################
# Dataset
#-----------------------------------------------------------
# SingleCellExperiment
BiocManager::install("scRNAseq")
# Seurat
remotes::install_github('satijalab/seurat-data')

############################################################
# Spatially-resolved transcriptomics
#-----------------------------------------------------------

# Spatially-aware quality control methods
# https://github.com/MicTott/SpotSweeper
BiocManager::install("SpotSweeper")

# Spatially-aware normalisation
# https://github.com/bhuvad/SpaNorm
BiocManager::install("SpaNorm")

# Identification of spatially variable genes (SVGs)
# https://github.com/lmweber/nnSVG
BiocManager::install("nnSVG")

# Clustering and enhancing the resolution
# https://github.com/edward130603/BayesSpace
BiocManager::install("BayesSpace")


# https://github.com/LieberInstitute/spatialLIBD
BiocManager::install("spatialLIBD")

############################################################
# Seurat v4
#-----------------------------------------------------------

install.packages("remotes")
install.packages("pak")

# Native R kernel for Jupyter
install.packages("IRkernel")

# conda install -c conda-forge libxml2-devel zlib pkg-config
install.packages("xml2")
# conda install -c conda-forge expat
install.packages("ragg")
install.packages("tidyverse")

remotes::install_version("MASS", version = "7.3-60")
remotes::install_version("Matrix", version = "1.6-4")
remotes::install_version("mgcv", version = "1.9-3")
remotes::install_version("ggplot2", version = "3.5.2")

remotes::install_version("SeuratObject", version = "4.1.4")
remotes::install_version("Seurat", version = "4.4.0")

remotes::install_github("chris-mcginnis-ucsf/DoubletFinder@1b1d4e2")

if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install(version = "3.18")

# conda install -c conda-forge xorg-xproto
install.packages("Cairo")
# conda install -c conda-forge gcc=13 # old version
BiocManager::install("rtracklayer")
remotes::install_version("xgboost", version = "2.1.4")
BiocManager::install("scDblFinder")

remotes::install_version("Signac", version = "1.11.0")

install.packages("harmony")

install.packages("clustree")

install.packages("scCustomize")


