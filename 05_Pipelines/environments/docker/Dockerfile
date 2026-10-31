# Dockerfile

FROM ubuntu:24.04 AS builder

RUN apt-get update && \
    rm -rf /var/lib/apt/lists/*

USER ubuntu
WORKDIR /home/ubuntu

COPY Miniconda3-latest-Linux-x86_64.sh .

SHELL ["/bin/bash", "-c"]

RUN bash Miniconda3-latest-Linux-x86_64.sh -b && \
	rm Miniconda3-latest-Linux-x86_64.sh

ENV PATH="/home/ubuntu/miniconda3/bin:$PATH"

RUN conda init && \
    conda config --set always_yes yes && \
    conda config --add channels defaults && \
    conda config --add channels free && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    conda config --set show_channel_urls true

FROM ubuntu:24.04

COPY --from=builder /home/ubuntu /home/ubuntu

USER ubuntu
WORKDIR /home/ubuntu

ENV PATH="/home/ubuntu/miniconda3/bin:$PATH"

RUN conda create -n ngstools && \
    conda install -n ngstools fastqc multiqc RSeQC && \
    conda install -n ngstools trim-galore trimmomatic umi_tools fastx_toolkit && \
    conda install -n ngstools samtools bedtools deeptools && \
    conda install -n ngstools sambamba picard && \
    conda install -n ngstools bioawk seqkit && \
    conda install -n ngstools homer meme && \
    conda install -n ngstools pigz \
&& conda create -n workflow && \
    conda install -n workflow snakemake nextflow \
&& conda create -n dnaseq && \
    conda install -n dnaseq python=3.8 macs2 idr rseg && \
    conda install -n dnaseq bwa bowtie bowtie2 && \
    conda install -n dnaseq bismark bsmap && \
    conda install -n dnaseq chromhmm seqkit \
&& conda create -n rnaseq && \
    conda install -n rnaseq hisat2 htseq && \
    conda install -n rnaseq star salmon kallisto && \
    conda install -n rnaseq subread && \
    conda install -n rnaseq stringtie && \
    conda install -n rnaseq rmats \
&& conda clean -afy

CMD ["/bin/bash"]

