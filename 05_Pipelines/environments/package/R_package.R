#!/usr/bin/env Rscript
# ==============================================================================
# R Package Installation & Environment Setup Script
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. Environment Initialization & Repository Settings
# ------------------------------------------------------------------------------
# Options for CRAN/Bioconductor mirrors (Uncomment to use Chinese mirrors)
# options(repos = c(CRAN = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))
# options(BioC_mirror = "https://mirrors.tuna.tsinghua.edu.cn/bioconductor")
# options(BioC_mirror = "https://mirrors.westlake.edu.cn/bioconductor")

# Update all existing CRAN packages
update.packages(ask = FALSE, checkBuilt = TRUE)

# ------------------------------------------------------------------------------
# Layer 1: Core Package Managers & Base Infrastructure
# ------------------------------------------------------------------------------
# Install from remote repositories / 远程包安装工具
install.packages("remotes")
# install.packages("devtools")

# Fast, modern package installer / 快速包管理工具
install.packages("pak")

# Initialize Bioconductor Manager
if (!require("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}
BiocManager::install(update = FALSE)
# BiocManager::install(version = "3.22") # R 4.5.2
# BiocManager::install(version = "3.20") # R 4.4.3
# BiocManager::install(version = "3.18") # R 4.3.3
# BiocManager::install(version = "3.10") # R 3.6.3

# Non-invasive code formatting / 规范代码格式化工具
install.packages("styler")

# Command-line argument parsing / 命令行参数解析器
install.packages("optparse")

# Simple git client for R / Git版本控制客户端库
install.packages("gert")

# Working with HTTP/Web API / HTTP网络请求与API接口
install.packages("httr")

# Network requests & web client / 常用网络客户端工具
install.packages("RCurl")

# Simple web scraping / 网页数据爬取与解析工具
install.packages("rvest")

# Dynamic document generation / 动态文档生成工具
install.packages("rmarkdown")

# Authoring books & docs / 多页文档与电子书编写
install.packages("bookdown")

# Web app development framework / 交互式Web应用框架
install.packages("shiny")

# Themes for Shiny apps / Shiny应用主题外貌库
install.packages("shinythemes")

# Native R kernel for Jupyter / Jupyter的R语言内核
install.packages("IRkernel")

# Interface to Python / R与Python交互调用接口
install.packages("reticulate")

# Pipeline workflow / 生信自动化分析工作流引擎
BiocManager::install("systemPipeR")

# ------------------------------------------------------------------------------
# Layer 2: System Libraries, Rendering Drivers & Image Processing
# ------------------------------------------------------------------------------
# Parse XML & HTML documents / XML与HTML文件解析
# conda install -c conda-forge libxml2-devel zlib
install.packages("XML")
# Modern, fast XML parser / 现代高效XML解析器
install.packages("xml2")

# High-performance graphics device / 高性能图形渲染引擎
# conda install -c conda-forge freetype expat pkg-config
install.packages("ragg")

# Render SVG into bitmap arrays / SVG矢量图渲染
# sudo apt install -y xorg-dev
# conda install -c conda-forge librsvg glib
install.packages("rsvg")

# High-quality display graphics / 高质量图形输出驱动
# conda install -c conda-forge xorg-xproto
install.packages("Cairo")

# Embedded JavaScript engine / R中运行JS代码的引擎
# sudo apt install libv8-dev
install.packages("V8")

# Advanced image processing / ImageMagick图像处理
# conda install imagemagick
install.packages("magick")

# ------------------------------------------------------------------------------
# Layer 3: Parallel Computing, Math, Optimization & Core Data Structures
# ------------------------------------------------------------------------------
# Unified parallel API / 统一的并行计算框架
install.packages("future")

# Foreach looping construct / 循环并行计算结构
install.packages("foreach")

# Parallel backend for foreach / foreach并行计算后端
install.packages("doParallel")

# Modern applied statistics / 经典应用统计分析函数
# Version issue
install.packages("MASS")
# remotes::install_version("MASS", version = "7.3-60")

# Sparse/dense matrix operations / 稀疏与稠密矩阵运算
# Version issue
install.packages("Matrix")
# remotes::install_version("Matrix", version = "1.6-4")

# Fast matrix row/col stats / 高效矩阵行/列统计运算
install.packages("matrixStats")

# Read sparse matrix files / 读取稀疏矩阵格式文件
install.packages("readsparse")

# Infrastructure for ordering / 序列化与排列优化算法
install.packages("seriation")

# Combinatorial utilities / 排列组合数学计算工具
install.packages("combinat")

# Quadratic programming / 二次规划最优化问题求解器
install.packages("quadprog")

# Nonlinear optimization / 非线性规划最优化算法库
install.packages("nloptr")

# Hash digest generation / 内存对象哈希生成与校验
install.packages("digest")

# ------------------------------------------------------------------------------
# Layer 4: Data Import/Export, Data Wrangling & Spatial Extensions
# ------------------------------------------------------------------------------
# Swiss-knife file I/O / 瑞士军刀式多格式数据读写
install.packages("rio")

# SPSS, Stata, and SAS
install.packages("haven")

# Fast JSON parser & generator / JSON数据解析与生成
install.packages("jsonlite")

# Interface to HDF5 format / HDF5大型数据格式接口
# conda install -c conda-forge hdf5=1.14.6
install.packages("hdf5r")

# BioC HDF5 array support / 生信级HDF5数据接口
BiocManager::install("rhdf5")

# Read Excel spreadsheets / 读取Excel文件 (.xls/xlsx)
install.packages("readxl")

# Export Excel files / 高效导出Excel文件 (.xlsx)
install.packages("writexl")

# Read non-tabular Excel / 导入结构不规则Excel数据
install.packages("tidyxl")

# Read, write & edit Excel / 读写及修改Excel表格
install.packages("openxlsx")

# Fast object serialization / R对象极速序列化读写
install.packages("qs")

# Next-gen fast serialization / 新一代R对象序列化工具
install.packages("qs2")

# Ultra-fast data manipulation / 超高性能数据处理
install.packages("data.table")

# Opinionated collection for DS / 核心数据科学工具集
install.packages("tidyverse")

# Flexibly reshape data / 数据重构与长宽格式转换
install.packages("reshape2")

# Sliding window functions / 滑动窗口数据计算工具
install.packages("slider")

# Time series forecasting / 时间序列预测与分析模型
install.packages("forecast")
# install.packages("prophet")

# Measurement units support / 带有物理单位的数据处理
install.packages("units")

# Spherical geometry ops / 球形几何测量与计算工具
install.packages("s2")

# Simple Features spatial data / 矢量地理数据处理标准
install.packages("sf")

# Spatial raster & vector data / 栅格与矢量地理数据分析
install.packages("terra")

# # Database Connectivity
# install.packages("DBI")
# install.packages("dbplyr")
# install.packages("duckdb")
# install.packages("odbc")

# ------------------------------------------------------------------------------
# Layer 5: Base Statistics & Machine Learning Frameworks
# ------------------------------------------------------------------------------
# Resampling hypothesis tests / 重采样多重假设检验
BiocManager::install("multtest")

# Unified multiple testing / 统一多重假设检验框架
install.packages("mutoss")

# Meta-analysis of p-values / P值Meta分析整合方法
install.packages("metap")

# Pipe-friendly stat tests / 管道流友好的统计检验
install.packages("rstatix")

# Data analysis & stat methods / 综合数据分析与统计工具
install.packages("Hmisc")

# Fitting/testing model tools / 交叉表与模型拟合工具
install.packages("gmodels")

# Linear mixed-effects models / 线性混合效应模型拟合
install.packages("lme4")

# Kernel smoothing & density / 核密度估计与多元分析
install.packages("ks")

# Multivariate data analysis / 多变量数据分析(PCA等)
install.packages("FactoMineR")

# Extract/visualize PCA results/ 多变量分析结果可视化
install.packages("factoextra")

# Generalized PCA for counts / 计数数据的广义PCA分析
install.packages("glmpca")

# Modeling & machine learning / 现代机器学习建模框架
install.packages("tidymodels")

# T-SNE dimensionality reduction/ T-SNE降维算法实现
install.packages("Rtsne")

# UMAP dimension reduction / UMAP降维算法高效实现
install.packages("uwot")

# Cluster analysis procedures / 经典聚类分析算法集
install.packages("cluster")

# Poisson clustering for RNA-seq/ 泊松模型测序数据聚类
install.packages("PoiClaClu")

# Gaussian mixture models / 高斯混合模型聚类与分类
install.packages("mclust")

# Recursive mixture modeling / 递归分层混合模型聚类
install.packages("RPMM")

# Fast nearest neighbor search / 快速近邻搜索算法
install.packages("FNN")

# Training classification models/ 机器学习模型训练框架
install.packages("caret")

# Random forests algorithm / 随机森林机器学习分类器
install.packages("randomForest")

# Evaluation metrics for ML / 机器学习评价指标计算
install.packages("MLmetrics")

# ROC curves performance / 分类器ROC曲线与性能评估
install.packages("ROCR")

# Principal Component Analysis / 基因组学PCA主成分分析
BiocManager::install("PCAtools")

# ------------------------------------------------------------------------------
# Layer 6: Core Visualization Engine, Themes & Color Palettes
# ------------------------------------------------------------------------------
# Grammar of graphics plotting / 优雅的数据可视化图表
install.packages("ggplot2")

# Highlight plot components / 突出高亮显示特定图表元素
install.packages("gghighlight")

# Publication ready plots / 科研出版级图表快速绘制
install.packages("ggpubr")

# Extra ggplot2 features / ggplot2功能增强扩展包
install.packages("ggforce")

# Axis and legend helpers / 坐标轴与图例调整辅助工具
install.packages("lemon")

# Scale positions and bounds / 映射与坐标轴刻度控制
install.packages("scales")

# Multiple scales support / 图表中支持多组映射刻度
install.packages("ggnewscale")

# Rich text in ggplot2 / 支持Markdown/HTML富文本
install.packages("ggtext")

# Non-overlapping text labels / 防止文本标签重叠引线
install.packages("ggrepel")

# Direct labeling for plots / 在数据点旁直接标注标签
install.packages("directlabels")

# Advanced legends / 高级图例指南控制
remotes::install_github("teunbrand/gtguides")

# Extra themes & scales / 丰富图表主题风格与调色板
install.packages("ggthemes")

# Rasterize ggplot2 layers / 高密度数据点图层栅格化
install.packages("ggrastr")

# Plot layout alignment / 多个图表对齐组合与排版
install.packages("cowplot")

# Combine separate ggplots / 极简语法多图表拼接组合
install.packages("patchwork")

# Arrange multiple grid plots / 多图形布局与对齐排版
install.packages("gridExtra")

# BBC style plot theme / BBC新闻风格图表主题
remotes::install_github("bbc/bbplot")

# Tidy interface for plotting / 简洁语法极简数据作图
install.packages("tidyplots")

# Clean minimal theme / 极简风格ggplot2主题
remotes::install_github("sjessa/ggmin")

# Fortify stat tools for ggplot/ 常见统计模型快速绘图
install.packages("ggfortify")

# Visualize distributions / 绘制分布与不确定性置信度
install.packages("ggdist")

# Visualisation theme for easystats/ 现代化统计可视化主题
install.packages("see")

# ColorBrewer palettes / 经典ColorBrewer调色板
install.packages("RColorBrewer")

# Comprehensive palette collection/ 整合上百种调色板调取
install.packages("paletteer")

# Scientific journal colors / 顶级学术期刊风格配色方案
install.packages("ggsci")

# Colorblind-friendly colors / 色盲友好定色板(彩色)
install.packages("viridis")

# Light viridis palettes / 色盲友好调色板轻量版
install.packages("viridisLite")

# Color space manipulation / 颜色空间操作与色调变换
install.packages("colorspace")

# Perceptual colors / 认知感官无偏渐变配色
remotes::install_github("thomasp85/scico")

# Colorblind check / 色盲模拟与效果检查
remotes::install_github("clauswilke/colorblindr")

# Munsell color system / 孟塞尔色彩体系工具
remotes::install_github("cwickham/munsell")

# Arctic color palettes / 极光与北欧风格主题配色
install.packages("nord")

# Large color palettes / 含海量颜色的离散调色板
install.packages("pals")

# Art museum palettes / 大都会艺术博物馆艺术配色
install.packages("MetBrewer")

# Wes Anderson movie colors / 韦斯·安德森电影配色
install.packages("wesanderson")

# ------------------------------------------------------------------------------
# Layer 7: Specialized Graphics, Networks & Interactive Plots
# ------------------------------------------------------------------------------
# Alluvial/Sankey diagrams / 桑基图与冲击图绘制工具
install.packages("ggalluvial")

# Ridgeline density plots / 山脊重叠密度分布图绘制
install.packages("ggridges")

# Beeswarm point plots / 蜂群散点重叠分布图绘制
install.packages("ggbeeswarm")

# Half plots / 半小提琴图与半箱线图
remotes::install_github("erocoar/gghalves")

# Extension to ggplot2 / 矩阵相关性散点图扩展包
install.packages("GGally")

# Animated ggplot graphics / 动态与动画GIF图表制作
install.packages("gganimate")

# Pretty heatmaps / 经典灵活的静态热图绘制包
install.packages("pheatmap")

# Tidy heatmaps from data / 管道流风格热图绘制工具
install.packages("tidyheatmaps")

# Heatmap with network / 热图与网络关联整合图
remotes::install_github("Hy4m/linkET")

# Visualization of corr-matrix / 经典相关性矩阵可视化
install.packages("corrplot")

# ggplot2 corr-matrix / ggplot2风格相关性矩阵图
install.packages("ggcorrplot")

# Radar charts / 雷达图可视化画板
remotes::install_github("ricardo-bion/ggradar")

# Advanced radar charts / 高级雷达图绘制工具
remotes::install_github("xl0418/ggradar2")

# Area-proportional Venn/Euler/ 面积比例韦恩图与欧拉图
install.packages("eulerr")

# ggplot2 Venn diagrams / ggplot2风格2-4组分韦恩图
install.packages("ggVennDiagram")

# ggplot2 UpSet plots / ggplot2语法UpSet集合交集图
install.packages("ggupset")

# Advanced UpSet plots / 复杂的UpSet交集组合图
install.packages("ComplexUpset")

# Standard UpSet plots / 经典UpSet多集合交集可视化
install.packages("UpSetR")

# Venn diagrams / 多维韦恩图画板工具
remotes::install_github("js229/Vennerable")

# Reroot & color dendrograms / 层次聚类树状图增强与染色
install.packages("dendextend")

# Treemap visualization / 矩形树状层级结构图绘制
install.packages("treemap")

# Tidy graph manipulation / 管道流图与网络数据操作
install.packages("tidygraph")

# Network graph visualization / ggplot2语法的复杂网络图
install.packages("ggraph")

# Circular visualization / 弦图与环形基因组可视化
install.packages("circlize")

# Hexagonal binning plot / 六边形二维频数蜂窝图
install.packages("hexbin")

# Interactive ROC plots / 可交互式ROC曲线绘制工具
install.packages("plotROC")

# HTML5 interactive wordcloud / HTML5交互式词云图生成
install.packages("wordcloud2")

# 3D scatter plots / 三维空间散点图绘制工具
install.packages("scatterplot3d")

# Interactive web graphics / 交互式Web动态图表引擎
install.packages("plotly")

# Interface to Apache ECharts / ECharts交互图表R接口
install.packages("echarts4r")

# Highcharts JS interface / Highcharts交互图表接口
install.packages("highcharter")

# D3 JavaScript network graph/ 基于D3的交互网络节点图
install.packages("networkD3")

# ------------------------------------------------------------------------------
# Layer 8: Bioconductor Core Containers, File I/O & Databases
# ------------------------------------------------------------------------------
# Read/write SAM/BAM files / BAM/SAM比对文件操作
BiocManager::install("Rsamtools")

# Import/export bed/bw/gtf / 基因组Track注释轨导入
BiocManager::install("rtracklayer")

# Tidy ranges manipulation / 管道流基因组区间操作
BiocManager::install("plyranges")

# Genome seqnames & metadata / 基因组染色体信息管理
BiocManager::install("GenomeInfoDb")

# Interval ops on genome / 基因组区间 overlap 计算
BiocManager::install("GenomicRanges")

# Gene model containers / 基因结构与转录本容器
BiocManager::install("GenomicFeatures")

# Alignments containers / 测序reads比对区间容器
BiocManager::install("GenomicAlignments")

# Download NCBI GEO data / GEO公共数据库数据下载
BiocManager::install("GEOquery")

# ArrayExpress data / ExpressionAtlas数据库获取
BiocManager::install("ExpressionAtlas")

# TCGA data download & analysis/ TCGA癌症数据库接口
BiocManager::install("TCGAbiolinks")

# SRA database metadata query / NCBI SRA元数据查询工具
BiocManager::install("SRAdb")

# Airway RNA-Seq dataset / 气道平滑肌RNA-seq示例数据
BiocManager::install("airway")

# Human annotation database / 人类基因组综合注释库
BiocManager::install("Homo.sapiens")

# Mouse annotation database / 鼠标基因组综合注释库
BiocManager::install("Mus.musculus")

# Human Entrez ID mapping / 人类基因ID转化数据库
BiocManager::install("org.Hs.eg.db")

# Mouse Entrez ID mapping / 小鼠基因ID转化数据库
BiocManager::install("org.Mm.eg.db")

# hg19 transcript DB / 人hg19转录本数据库
BiocManager::install("TxDb.Hsapiens.UCSC.hg19.knownGene")

# hg38 transcript DB / 人hg38转录本数据库
BiocManager::install("TxDb.Hsapiens.UCSC.hg38.knownGene")

# mm10 transcript DB / 鼠mm10转录本数据库
BiocManager::install("TxDb.Mmusculus.UCSC.mm10.knownGene")

# mm39 transcript DB / 鼠mm39转录本数据库
BiocManager::install("TxDb.Mmusculus.UCSC.mm39.knownGene")

# Ensembl v86 Human DB / Ensembl人注释库
BiocManager::install("EnsDb.Hsapiens.v86")

# Ensembl v79 Mouse DB / Ensembl鼠注释库
BiocManager::install("EnsDb.Mmusculus.v79")

# Full hg38 genome / 人hg38全基因组
BiocManager::install("BSgenome.Hsapiens.UCSC.hg38")

# Full mm10 genome / 鼠mm10全基因组
BiocManager::install("BSgenome.Mmusculus.UCSC.mm10")

# Local GenBank database / 本地化GenBank缓存与查询
install.packages("restez")

# Genomic data retrieval / BioMart与NCBI数据批量获取
install.packages("biomartr")

# ------------------------------------------------------------------------------
# Layer 9: Functional Enrichment, Motifs, Pathways & Functional Annotations
# ------------------------------------------------------------------------------
# MSigDB gene sets in tidy format / MSigDB通路数据库
install.packages("msigdbr")

# Gene Ontology annotation DB / GO数据库基础注释文件
BiocManager::install("GO.db")

# Client for KEGG REST API / KEGG通路数据库API接口
BiocManager::install("KEGGREST")

# Correct invalid gene symbols / 人鼠基因符号标准化修复
install.packages("HGNChelper")

# Homologous gene translation / 同源基因(人/鼠等)快捷转换
install.packages("homologene")

# Over-representation analysis / 基因集富集与超几何检验
install.packages("mulea")

# Functional enrichment / GO/KEGG富集分析旗舰包
BiocManager::install("clusterProfiler")

# Fast gene set enrichment (GSEA) / 快速GSEA预排序富集分析
BiocManager::install("fgsea")

# Gene set variation analysis / 单样本单细胞GSVA变异分析
BiocManager::install("GSVA")

# GO enrichment with topology / 考虑拓扑结构的GO富集分析
BiocManager::install("topGO")

# Gene length bias in GO / 考虑基因长度偏好性的GO富集
BiocManager::install("goseq")

# Disease Ontology enrichment / 人类疾病本体论(DO)富集分析
BiocManager::install("DOSE")

# Simplify GO / 语义相似度简化GO富集结果
BiocManager::install("simplifyEnrichment")

# KEGG pathway visualizer / 表达量映射KEGG通路图绘制
BiocManager::install("pathview")

# Interface to g:Profiler / g:Profiler线上富集分析接口
install.packages("gprofiler2")

# Sequence motif database / 常见转录因子Motif数据库
BiocManager::install("MotifDb")

# JASPAR motif database / JASPAR 2024转录因子数据库
BiocManager::install("JASPAR2024")

# Import/export motifs / Motif格式转换与操作工具
BiocManager::install("universalmotif")

# Interface to MEME Suite / MEME Motif分析工具箱R接口
BiocManager::install("memes")

# Motif analysis in genomic / 基因组区域Motif富集与表达
BiocManager::install("monaLisa")

# ------------------------------------------------------------------------------
# Layer 10: Genomics, Transcriptomics & High-Throughput Bioinformatic Tools
# ------------------------------------------------------------------------------
# Microarray normalization / 芯片与表达谱数据标准化
BiocManager::install("preprocessCore")

# Dual-color microarray data / 双色芯片数据处理与预处理
BiocManager::install("marray")

# Microarray probe annotation / 探针ID转换与GEO数据整合
install.packages("AnnoProbe")

# Imputation for microarray / 表达谱缺失值KNN插补
BiocManager::install("impute")

# Simple GEO/RNA-seq analysis / 极简转录组与GEO分析包
install.packages("tinyarray")

# Transcript quant with metadata/ Salmon量化结果及元数据
BiocManager::install("tximeta")

# Import transcript quant / 转录本表达量汇总到基因
BiocManager::install("tximport")

# Linear models for DE / 经典微阵列与RNA-seq差异表达
BiocManager::install("limma")

# Differential expression (NB) / 基于负二项分布差异表达
BiocManager::install("edgeR")

# Differential expression (DESeq2)/ RNA-seq差异分析标准包
BiocManager::install("DESeq2")

# Differential expression analysis / RNA-seq差异基因筛选
BiocManager::install("DEGseq")

# Splice graph analysis / 剪切图结构与可变剪切分析
BiocManager::install("SGSeq")

# Differential exon usage / 外显子差异使用与可变剪切
BiocManager::install("DEXSeq")

# High-res genomics / 高分辨率测序数据分析
remotes::install_github("mdeber/BRGenomics")

# Surrogate variable analysis / 代理变量分析与批次效应消除
BiocManager::install("sva")

# Independent SVA / 独立代理变量分析消除批次效应
install.packages("isva")

# Iterative Adjusted SVA / 迭代调整SVA批次效应分析
BiocManager::install("iasva")

# Remove unwanted variation / RUV方法消除RNA-seq批次效应
BiocManager::install("RUVSeq")

# Soft clustering for time-series / 时间序列表达模糊聚类
BiocManager::install("Mfuzz")

# Time course sequencing / 时间序列转录组分析与聚类
BiocManager::install("TCseq")

# Regression for time-course / 阶段时间序列差异基因筛选
BiocManager::install("maSigPro")

# Cell type enrichment / 64种免疫与基质细胞解离
remotes::install_github("dviraran/xCell")

# Immune deconv / 统一肿瘤免疫浸润解离
remotes::install_github("omnideconv/immunedeconv")

# MeRIP-Seq peak / m6A-seq差异修饰Peak调用
remotes::install_github("ZW-xjtlu/exomePeak2")

# Ribo-seq profiling data / 翻译图谱与核糖体印迹
BiocManager::install("RiboProfiling")

# Ribosome profiling analysis / 核糖体分析与周期性定位
BiocManager::install("riboSeqR")

# Ribo P-site determination / 核糖体P-site准确定位分析
remotes::install_github("LabTranslationalArchitectomics/riboWaltz")

# Translational efficiency / 翻译效率(TE)差异分析工具
BiocManager::install("anota2seq")

# Parse VCF files / VCF变异文件解析与注释
BiocManager::install("VariantAnnotation")

# Analyze MAF mutation data / MAF突变文件可视化与分析
BiocManager::install("maftools")

# Circular binary segmentation/ Copy Number拷贝数分割
BiocManager::install("DNAcopy")

# Somatic mutation patterns / 体细胞突变谱特征分析
BiocManager::install("SomaticSignatures")

# Decipher mutational signatures / DNA突变图谱抽取与分析
install.packages("mutSignatures")

# Mutational matrices / 突变矩阵生成与整理工具
remotes::install_version("ICAMS", version = "3.0.11")

# Hierarchical Dirichlet / 层次狄利克雷过程分析
remotes::install_github("steverozen/hdpx")

# Mutational signatures / HDP突变图谱推断
remotes::install_github("steverozen/mSigHdp")

# dN/dS for driver genes / dN/dS驱动基因选择
remotes::install_github("im3sanger/dndscv")

# Co-expression prioritization / 共表达驱动基因挖掘
BiocManager::install("cageminer")

# Illumina methylation arrays / 450k/850k甲基化芯片分析
BiocManager::install("minfi")

# Methylation analysis pipeline/ ChAMP甲基化芯片分析流程
BiocManager::install("ChAMP")

# Infinium DNA methylation / 极简Illumina甲基化预处理
BiocManager::install("sesame")

# Methylation enrichment / 甲基化差异基因富集分析
BiocManager::install("missMethyl")

# Methylation array normalization/ 甲基化数据标准化
BiocManager::install("wateRmelon")

# Array workflow / 甲基化芯片工作流包
BiocManager::install("methylationArrayAnalysis")

# Whole-genome bisulfite seq / BS-seq全基因组甲基化分析
BiocManager::install("bsseq")

# Differential methylation (DMR) / DMR与DML差异甲基化
BiocManager::install("DSS")

# De novo DMR identification / DMR区域识别与差异分析
BiocManager::install("DMRcate")

# DNA methylation analysis / DNA甲基化测序数据分析
BiocManager::install("methylKit")

# Candidate DMR detection / 基因组Bump寻找差异区域
BiocManager::install("bumphunter")

# Differential ChIP-Seq peaks / ChIP-Seq差异结合位点分析
BiocManager::install("DiffBind")

# Window-based ChIP-seq analysis / 基于窗口的ChIP-seq分析
BiocManager::install("csaw")

# Annotate ChIP peaks / ChIP-seq Peak注释与可视化
BiocManager::install("ChIPseeker")

# Peak annotation & overlap / Peak关联基因注释工具
BiocManager::install("ChIPpeakAnno")

# Consensus regions / 多样本 Peak 拟合共识区域
BiocManager::install("consensusSeekeR")

# ATAC-seq quality control / ATAC-seq测序数据质量控制
BiocManager::install("ATACseqQC")

# Chromatin accessibility motif/ 染色质开放性Motif变异
BiocManager::install("chromVAR")

# TFBS sequence analysis / 转录因子结合位点序列分析
BiocManager::install("TFBSTools")

# RepeatMasker parser / RepeatMasker结果解析
remotes::install_github("dwinter/repeatR")

# Biological seq retrieval / 生物序列(FASTA)检索与分析
install.packages("seqinr")

# K-mer counting & clustering / K-mer计数与序列聚类分析
install.packages("kmer")

# Periodic k-mers in DNA / DNA序列周期性K-mer识别
BiocManager::install("periodicDNA")

# Phylogenetics & evolution / 进化树构建与系统发育分析
install.packages("ape")

# Microbiome census data / 扩增子与微生物组分析框架
BiocManager::install("phyloseq")

# Community ecology package / 社区生态学与多样性指数分析
install.packages("vegan")

# Breast cancer subtyping / 乳腺癌分子分型(PAM50)计算
BiocManager::install("genefu")

# ------------------------------------------------------------------------------
# Layer 11: Advanced Bioinformatics Visualization
# ------------------------------------------------------------------------------
# Plot genomic data tracks / 基因组多轨道Tracks可视化
BiocManager::install("Gviz")

# Genomic data graphics / 基于ggplot2的基因组图谱绘制
BiocManager::install("ggbio")

# Chromatin/lollipop track / 棒棒糖图与染色质轨道
BiocManager::install("trackViewer")

# Circular genome visualization / 2D环状基因组图谱绘制
install.packages("RCircos")

# Chromosome idiograms / 染色体染色体组核型示意图
install.packages("RIdeogram")

# Transcript features plot / 基因特征结构RNA修饰分布图
BiocManager::install("Guitar")

# Sequence logo plots / 碱基序列 Logo 概率图绘制
BiocManager::install("seqLogo")

# Stacked motif logos / 多个Motif Logo聚类对齐堆叠
BiocManager::install("motifStack")

# Gene arrow maps ggplot2 / ggplot2基因结构箭头图绘制
install.packages("gggenes")

# Complex heatmaps / 复杂多图层热图绘制旗舰包
BiocManager::install("ComplexHeatmap")

# Signal enrichment / ChIP/ATAC信号富集热图
BiocManager::install("EnrichedHeatmap")

# Interactive / 交互式复杂热图生成
BiocManager::install("InteractiveComplexHeatmap")

# Cluster heatmap / 聚类热图与通路整合
remotes::install_github("junjunlab/ClusterGVis")

# Spatial tissue heatmap / 解剖图谱空间表达热图
BiocManager::install("spatialHeatmap")