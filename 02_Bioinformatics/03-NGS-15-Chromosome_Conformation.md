---
Title: Chromosome Conformation
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2024-07-13
Modified: 2024-07-13
Tags:
  - Hi-C
---
# Introduction

## 1. Definition

**Chromosome conformation** refers to the three-dimensional (3D) spatial organization of the genome within the nucleus and describes how chromatin regions physically interact despite being separated by long genomic distances. This organization is hierarchically structured into **chromosome territories, A/B compartments, topologically associating domains (TADs), and chromatin loops**, which collectively regulate gene expression, DNA replication, genome stability, and other nuclear processes. Chromosome conformation is established through the coordinated actions of chromatin folding, loop extrusion mediated by cohesin, architectural proteins such as CTCF, and dynamic chromatin interactions. Hi-C and related chromosome conformation capture (3C)-based technologies enable genome-wide quantification of chromatin contact frequencies, providing comprehensive maps of 3D genome architecture and revealing how alterations in chromatin organization contribute to cellular differentiation, development, and disease.

## 2. Regulation Mechanism

## 3. Biological Functions

---

# Experimental Design

## Sequencing Technologies

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://media.springernature.com/full/springer-static/image/art%3A10.1186%2F1471-2164-15-S12-S11/MediaObjects/12864_2014_Article_6817_Fig1_HTML.jpg" 
        alt="Experimental workflow and methodology overview from BMC Genomics publication"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> Overview of the experimental workflow and methodology. 
        Adapted from <a href="https://doi.org/10.1186/1471-2164-15-S12-S11" target="_blank" rel="noopener noreferrer">BMC Genomics (2014)</a>.
    </figcaption>
</figure>

### Hi-C

> Hi-C is a genome-wide chromosome conformation capture (3C)-based sequencing technology that enables comprehensive mapping of chromatin interactions within the three-dimensional (3D) genome. In Hi-C, chromatin is first crosslinked with formaldehyde to preserve spatially proximal DNA interactions, followed by restriction enzyme digestion, end repair with biotin-labeled nucleotides, and proximity ligation under dilute conditions. DNA fragments that are spatially adjacent, rather than linearly contiguous, are preferentially ligated to generate chimeric DNA molecules. After enrichment of biotin-labeled ligation junctions, the resulting DNA library is subjected to high-throughput paired-end sequencing. The frequencies of paired-end reads are then used to reconstruct genome-wide chromatin contact maps, enabling the identification of chromosome territories, A/B compartments, topologically associating domains (TADs), chromatin loops, and other higher-order chromatin structures.
> - Jon-Matthew Belton, Rachel Patton McCord, Johan Harmen Gibcus, Natalia Naumova, Ye Zhan, Job Dekker. Hi–C: A comprehensive technique to capture the conformation of genomes. Methods. Volume 58, Issue 3. 2012. Pages 268-276. ISSN 1046-2023. https://doi.org/10.1016/j.ymeth.2012.05.001.

| Enzyme | Source | Recognition Motif | Overhang | Kit / Application |
| :--- | :--- | :--- | :--- | :--- |
| **DpnII** | *Diplococcus pneumoniae* G41 | `^GATC` | 5' GATC | in situ Hi-C, Capture-C |
| **MboI** | *Moraxella bovis* | `^GATC` | 5' GATC | Standard in situ Hi-C |
| **HindIII** | *Haemophilus influenzae* strain Rd | `A^AGCTT` | 5' AGCT | Original Hi-C (Lieberman-Aiden) |
| **BglII** | *Bacillus globigii* | `A^GATCT` | 5' GATC | 3C, Hi-C variants |
| **Enzyme Cocktail** | Synthetic Mixture (Recombinant) | `^GATC`, `G^ANTC` | 5' GATC, 5' ANTC | Arima-HiC Kit |

---

# Preprocessing

## 1. Quality Control

### [FastQC](https://github.com/s-andrews/FastQC)

## 2. Trimming Reads

### [Trim Galore](https://github.com/FelixKrueger/TrimGalore)

---

# Upstream Processing

## 1. [HiC-Pro](https://github.com/nservant/HiC-Pro)

> HiC-Pro was designed to process Hi-C data, from raw fastq files (paired-end Illumina data) to normalized contact maps. It supports the main Hi-C protocols, including digestion protocols as well as protocols that do not require restriction enzymes such as DNase Hi-C. In practice, HiC-Pro was successfully applied to many data-sets including dilution Hi-C, in situ Hi-C, DNase Hi-C, Micro-C, capture-C, capture Hi-C or HiChip data.
> 1. mapping: perform reads alignment - require fast files
> 2. proc_hic: perform Hi-C filtering - require BAM files
> 3. quality_checks: run Hi-C quality control plots
> 4. merge_persample: merge multiple inputs and remove duplicates if specified - require .validPairs files
> 5. build_contact_maps: Build raw inter/intrachromosomal contact maps - require .allValidPairs files
> 6. ice_norm : run ICE normalization on contact maps - require .matrix files
>
> - Servant, N., Varoquaux, N., Lajoie, B.R. et al. HiC-Pro: an optimized and flexible pipeline for Hi-C data processing. Genome Biol 16, 259 (2015). https://doi.org/10.1186/s13059-015-0831-x.

```shell
conda env create -f environment.yml -n hic-pro
conda activate hic-pro
make configure
make install
```

```shell
# Whole genome restriction enzyme fragments (hindiii, dpnii, mobi, bgiii)
HiC-Pro_3.1.0/bin/utils/digest_genome.py -r A^AGCTT \
    -o genome_hindiii_resfrag.bed genome.fa
HiC-Pro_3.1.0/bin/utils/digest_genome.py -r dpnii \
    -o genome_dpnii_resfrag.bed genome.fa
HiC-Pro_3.1.0/bin/utils/digest_genome.py -r hindiii dpnii \
    -o genome_hindiii_dpnii_resfrag.bed genome.fa
HiC-Pro_3.1.0/bin/utils/digest_genome.py -r ^GATC G^ANTC \
    -o genome_arima_resfrag.bed genome.fa
```

```shell
HiC-Pro -i {input.dir} -c {input.config} -o {output.dir}
```

## 2. [Juicer](https://github.com/aidenlab/juicer)

Juicer is a platform for analyzing kilobase resolution Hi-C data. In this distribution, we include the pipeline for generating Hi-C maps from fastq raw data files and command line tools for feature annotation on the Hi-C maps.

# Downstream Analysis

## 

> 1. [HiCRep](https://github.com/TaoYang-dev/hicrep)
> 	- R package to evaluate the reproducibility of Hi-C data.
> 	- Yang T, Zhang F, Yardımcı GG, Song F, Hardison RC, Noble WS, Yue F, Li Q. HiCRep: assessing the reproducibility of Hi-C data using a stratum-adjusted correlation coefficient. Genome Res. 2017 Nov;27(11):1939-1949. doi: 10.1101/gr.220640.117.
> 	- Dejun Lin, Justin Sanders, William Stafford Noble, HiCRep.py: fast comparison of Hi-C contact matrices in Python, Bioinformatics, Volume 37, Issue 18, September 2021, Pages 2996–2997, https://doi.org/10.1093/bioinformatics/btab097.
> 2. other

## 1. [GENOVA](https://github.com/robinweide/GENOVA)

> GENome Organisation Visual Analytics (GENOVA): a software suite to perform in-depth analyses on various levels of genome organisation, using Hi-C data.
>
> - Robin H van der Weide, Teun van den Brand, Judith H I Haarhuis, Hans Teunissen, Benjamin D Rowland, Elzo de Wit, Hi-C analyses with GENOVA: a case study with cohesin variants, *NAR Genomics and Bioinformatics*, Volume 3, Issue 2, June 2021, lqab040, https://doi.org/10.1093/nargab/lqab040.

```R
library(GENOVA)

data_40k <- load_contacts(signal_path = 'Hela-hic-rep1_40000.matrix', 
                          indices_path = 'Hela-hic-rep1_40000_abs.bed', sample_name='Hela-hic-rep1',
                          colour="black")
iced2_40k <- load_contacts(signal_path = 'sample_ActD_40000_iced_ed.matrix',
                           indices_path = 'Hela-hic-ActD-rep1_40000_abs.bed',
                           sample_name='sample_ActD_iced', colour="red",balancing = F)

hg19_bed <- read.table('hg19.bed', header = F)
exp <- get_test_data('40k')
```

```R
library('GENOVA')
library(patchwork)
library(ggplot2)
#读入数据
sample_name<-c('PAOA','MOCK')
Centromere<-read.table('hg38.centromere.bed')
chrom_size<-read.table('chrom_hg38.sizes',header = F)#用于后续AB compartment识别
#读入两样本40kb以及10kb矩阵
data1_40k<-load_contacts(signal_path = '/Data2/lizr/temp/HiC_fjb/PAOA/iced/40000/PAOA_40000_iced_ed.matrix',
                         indices_path = '/Data2/lizr/temp/HiC_fjb/PAOA/raw/40000/PAOA_40000_abs.bed',
                         sample_name=sample_name[1],
                         colour="black",balancing = F,centromeres = Centromere,
                         #scale_bp = NULL,
                         #z_norm = TRUE
                        )
data2_40k<-load_contacts(signal_path = '/Data2/lizr/temp/HiC_fjb/DMSO/iced/40000/DMSO_40000_iced_ed.matrix',
                         indices_path = '/Data2/lizr/temp/HiC_fjb/DMSO/raw/40000/DMSO_40000_abs.bed',
                         sample_name=sample_name[2],
                         colour="red",balancing = F,centromeres = Centromere,
                         #scale_bp = NULL,
                         #z_norm = TRUE,
                        )

```

```R
cm<-chromosome_matrix(data_40k)
visualise(cm)
```

```shell
#cut.off设置热图颜色显示上限，越低tad等看得越明显，效果见下图对比
hic_matrixplot(exp1 = data_40k,
               chrom = 'chr7',
               start = 25e6,
               end = 30e6,
               cut.off = 300)

hic_matrixplot(exp1 = data_40k,
               chrom = 'chr7',
               start = 25e6,
               end = 30e6,
               cut.off = 600)
```

```R
#colour同上方命令cut.off一样，都是限制颜色显示上限
pyramid(iced_40k, "chr3", 3.5e7, 4e7,colour = c(0,400))

#通过crop_y = c(0,2e6)限制交互距离，如图显示会截去头部
#同理可以通过crop_x = c(3.6e7,3.9e7)截去两端
pyramid(iced_40k,
        chrom =  "chr3",
        start =  3.5e7,
        end =  4e7,
        colour = c(0,400),
        crop_y = c(0,2e6)
        )
```

```R
# compartment analysis
#计算EV
#内部是拆开染色体大小臂计算的，但如果data信息里没有标注中节位置则整体一起算
#使用hg19确定A/B compartment,还可以使用H3K4me1peak等
cs<-compartment_score(data_100k,bed = hg19_bed)

#因为它是拆开大小臂计算的，如没有给中节位置则需要通过命令计算找到，并去除上面的value
#计算中节位置，将染色体中空白最长的bins视为着丝粒连接的中节
centros<-find_centromeres(data_100k$MAT,data_100k$IDX)
#通过中节位置去除这些bin上的CS值
mid_data<-cs$compart_scores
for(i in 1:nrow(centros)){
  should_rm<-intersect(which(mid_data$bin>=centros$start[i]),which(mid_data$bin<=centros$end[i]))
  mid_data<-mid_data[-should_rm,]
}
cs$compart_scores<-mid_data


#matrixplot_compartment.R
#推荐100-150kb
#单染色体热图,内部会自己计算cs,有修正就用CS_discovery=cs
#三种展现方式，也可以不加展现raw矩阵
#metric = c("contacts", "obsexp", "log2obsexp", "correlation")
#展现特定的染色体部位
#arm=c('all','p','q')
compartment_matrixplot(data_100k,
                       chrom = 'chr5',arm = 'all',
                       metric = 'correlation',
                       CS_discovery=cs
                       )
```

```R
# saddle plot
#读入数据
iced_100k<-load_contacts(signal_path = 'sample1_100000_iced_ed.matrix',
                         indices_path = 'sample1_data_100000_abs.bed',
                         sample_name='sample-100k',
                         colour="black",balancing = F)

iced2_100k<-load_contacts(signal_path = 'sample_ActD_100000_iced_ed.matrix',
                          indices_path = 'sample_ActD_100000_abs.bed',
                          sample_name='sample-ActD-100k',
                          colour="red",balancing = F)

#单样本
CS_hg19 = compartment_score(iced_100k,bed = hg19_bed)
saddle_out<-saddle(iced_100k,
                   CS_discovery = CS_hg19,
                   bins = 50)
visualise(saddle_out)

#两样本
#计算两个样本的compartment score,并绘制saddle plot 
CS_out_iced_hg19 = compartment_score(list(iced_100k,iced2_100k),bed = hg19_bed)
saddle_out<-saddle(list(iced_100k,iced2_100k),
                   CS_discovery = CS_out_iced_hg19,
                   bins = 50)
visualise(saddle_out,colour_lim_contrast = c(-0.4,0.4))
```

```R
# TAD calling
#计算insulation_score
ins<-insulation_score(iced_40k,window=10)
#call_tad
tadlist<-call_TAD_insulation(ins)

#绘制insulation score图
ID<- insulation_domainogram(
  iced_40k,
  chrom = 'chr7',
  start = 25e6,
  end = 29e6,
  window_range = c(1,50),
  step = 2
)
visualise(ID)
#可以让其不输出旁边的纵坐标，标题等，方便合并
plot(ID, minimalist = TRUE)

#展示TAD划分结果
hic_matrixplot(
  iced_40k,
  chrom = 'chr7',
  start = 25e6,
  end = 29e6,
  tads = tadlist
)

#增加绘制tad的功能
TAD_plot<-function(chrom,start,end,tad_bed,crop_y=2e6){
  tad_data<-tad_bed[tad_bed$chrom==chrom,]
  tad_data<-tad_data[(tad_data$start>=start)&(tad_data$end<=end),]
  tad_data_mean<-apply(tad_data[,c(2,3)], 1, mean)
  if(length(tad_data_mean)==0){return(NULL)}    
  df<-data.frame(x_left = tad_data$start, x_left_end = tad_data_mean, 
                 y_left = 0, y_left_end = tad_data$end-tad_data$start,
                 x_right= tad_data_mean, x_right_end = tad_data$end,
                 y_right = tad_data$end-tad_data$start,y_right_end = 0
  )
  
  #根据限制修改x轴
  df$x_right[df$y_right>crop_y]<-df$x_right_end[df$y_right>crop_y]-crop_y/2
  df$x_left_end[df$y_left_end>crop_y]<-df$x_left[df$y_left_end>crop_y]+crop_y/2
  #根据限制修改y轴
  df$y_right[df$y_right>crop_y]<-crop_y
  df$y_left_end[df$y_left_end>crop_y]<-crop_y
  
  return(df)
}


#实际使用 添加TAD描线和基因注释
df<-TAD_plot(chrom = target_chr,start = target_start,end = target_end,data1,heightlime)

      data1_40k_pyramid <- pyramid(
        data1_40k,
        chr = target_chr,start = target_start,end = target_end,
        crop_y = c(0, heightlime),
      ) +
        ggplot2::ggtitle(sample_name[1])+ 
        geom_segment(aes(x=x_left,y=y_left,xend=x_left_end,yend=y_left_end),colour="green",
                     data=df,size=1.5,show.legend = F)+
        geom_segment(aes(x=x_right,y=y_right,xend=x_right_end,yend=y_right_end),colour="green",
                     data=df,size=1.5,show.legend = F)+
        annotate(
          geom = "curve", x = anno_gene$V3+40000*4, y = heightlime/4, xend = anno_gene$V3, yend = 40000, colour="red",
          curvature = .3, arrow = arrow(length = unit(2, "mm"))
        )+
        annotate(geom = "text", x = anno_gene$V3+40000*4, y = heightlime/4+40000+V4, label = anno_gene_new_name,parse = TRUE,size=1.5,color=V5)

```

```R
# Diff差减图和相除图
  png(paste0('./rlt_newcolor_peak_hicplot/',peak$V1[i],'_',peak$V2[i],'_',peak$V3[i],'_',peak$V4[i],'_5e6_10k.png'), width = 6*1000, height = 6*1000,res=600)
  hic_matrixplot(exp1=data1_10k,
                 exp2=data2_10k,
                 chrom = peak$V1[i],
                 start=peak$V2[i]-5e6,
                 end=peak$V3[i]+5e6,
                 coplot='diff',
                 chip=list('./DMSO_PAOA.bw','./DMSO_PAOA.bw','./MockaddPAOA_MockaddMock.bw','./MockaddPAOA_MockaddMock.bw'),
                 #cut.off=6
  )
  dev.off()


#默认颜色
bezier_corrected_divergent <- c('#2399de', '#2399de', '#67cdfe', 
                                '#f5f5f5', 
                                '#fcb09d', '#ed6855', '#be2a21')
#改后的颜色
bezier_corrected_divergent <- c('#2399de', '#2399de', '#67cdfe', 
                                '#f5f5f5', 
                                '#fcb09d', 'red', 'red')
#修改命名空间里面的颜色参数
assignInNamespace('bezier_corrected_divergent',bezier_corrected_divergent,ns='GENOVA')
```

```R
# TAD - APA
#读入两个样本数据
iced_40k<-load_contacts(signal_path = 'sample_40000_iced_ed.matrix',
                        indices_path = 'sample1_data_40000_abs.bed',
                        sample_name='sample-40k',
                        colour="black",balancing = F)

iced2_40k<-load_contacts(signal_path = 'sample_ActD_40000_iced_ed.matrix',
                          indices_path = 'sample_ActD_40000_abs.bed',
                          sample_name='sample-ActD-40k',
                          colour="red",balancing = F)

#单样本
ins<-insulation_score(iced_40k,window=10)
tadlist<-call_TAD_insulation(ins)
ADA<-ATA(explist = iced_40k,bed = tadlist)
visualise(ADA,colour_lim_contrast = c(-5,5))

#多样本
ins<-insulation_score(list(iced_40k,iced2_40k),window=10)
tadlist<-call_TAD_insulation(ins)
ADA<-ATA(explist = list(iced_40k,iced2_40k),bed = tadlist$`sample-40k`)
visualise(ADA,
          colour_lim_contrast = c(-50,50),
          metric = 'diff')
```

```R
# tornado insulation
ins<-insulation_score(iced_40k,window=10)
tadlist<-call_TAD_insulation(ins,min_strength = 0.1)
tornado_insulation(ins,tadlist,region_width = 1000000)

#没画的代码，下面的是GENOVA的例图
tornado_insulation(Hap1_10kb_insulation, bed = CTCF, bed_pos = 'center')
```



```shell
# Loop calling
 for sample in *.hic; do echo $sample;  mkdir -p ./${sample%%.*};( for i in {{1..22},X,Y};do echo $i;done | while read i; do echo $i ; java -jar ~/software/juicer/juicer_tools.jar hiccups --cpu -c ${i} -r 10000 ${sample} ./${sample%%.*}/${sample/.hic/}.${i}_10kb.hiccups ; done & ) ;done 
```

```R
#!/bin/bash

# 指定要搜索的根文件夹
root_folder="/path/to/root/folder"

# 遍历所有子文件夹
find "$root_folder" -type d | while read -r folder; do
  # 检查子文件夹中是否存在 mergedata 文件
  mergedata_file="$folder/mergedata"
  if [ -f "$mergedata_file" ]; then
    # 去除 mergedata 文件的表头信息
    tail -n +3 "$mergedata_file" > "$mergedata_file.tmp"
    
    # 将 mergedata 文件合并到根文件夹中的 mergedata 文件中
    cat "$mergedata_file.tmp" >> "$root_folder/mergedata"
    #删除临时文件
    rm "$mergedata_file.tmp" 
  fi
done
```

```R
#loop分析
#第一步 转换矩阵 强制只有一个线程就很傻
#需要进入HiCpro镜像
cd /Data4/nbCloud/public/AllProject/@2024-09/project_66f3ac484072656d9c052ae7/task_66f4ece74072656d9c052cc6/merge_result
genomesize=/Data4/nbCloud/public/AllProject/@2024-09/project_66f3ac484072656d9c052ae7/task_670cc11b4072656d9c053a26/chrom_hg38.sizes
validpairs=/Data4/nbCloud/public/AllProject/@2024-09/project_66f3ac484072656d9c052ae7/task_66f4ece74072656d9c052cc6/merge_result/hic_results/data/HK1_HiC/HK1_HiC.allValidPairs
jar=/Data2/lizr/software/juicer/juicer_tools_1.22.01.jar
/HiC-Pro-3.1.0/bin/utils/hicpro2juicebox.sh -i $validpairs -g $genomesize -j $jar -o /Data4/nbCloud/public/AllProject/@2024-09/project_66f3ac484072656d9c052ae7/task_66f4ece74072656d9c052cc6/merge_result/

#第二步 juicer hiccups loop识别
cd /Data4/nbCloud/public/AllProject/@2024-09/project_66f3ac484072656d9c052ae7/task_66f4ece74072656d9c052cc6/merge_result
mkdir HK1_HiC_loop_rlt
Chr=$(echo chr{1..22} chrX chrY NC_007605.1 | tr ' ' ',')
java -jar /Data2/lizr/software/juicer/juicer_tools_1.22.01.jar hiccups -k KR --cpu --threads 10 -r 10000 -c $Chr HK1_HiC.allValidPairs.hic HK1_HiC_loop_rlt

java -jar /Data2/lizr/software/juicer/juicer_tools_1.22.01.jar hiccups -k KR --threads 10 --cpu -r 10000 -c $Chr HK1_EBV_HiC.allValidPairs.hic HK1_EBV_HiC_loop_rlt

```

```R
# loop - APA
sample1_loop<-read.table('merged_loops.bedpe')[,1:6]

#如果前面Hicpro生成矩阵时选的是complete,则需要对矩阵内信息去重
data_40k$MAT<-unique(data_40k$MAT,incomparables = FALSE)
data2_40k$MAT<-unique(data2_40k$MAT,incomparables = FALSE)
explist<-list(data_40k,data2_40k)
apa<-APA(explist,bedpe = sample1_loop)
plotdata<-visualise(apa)
```

## 2. [Cooler](https://github.com/open2c/cooler)



> - [GSE60495](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE60495)
> - [GSE63525](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE63525)
> - [GSE137285](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE137285)
> - 
> - 
