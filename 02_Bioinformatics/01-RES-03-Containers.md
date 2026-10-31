---
Title: Container
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2022-06-23
Modified: 2024-03-16
Tags:
  - Docker
  - Apptainer
  - Singularity
---
# Overview

> A container platform is a software suite used to deploy, manage, and scale containerized applications, streamlining operations like orchestration, monitoring, and security. It bridges development and production, allowing lightweight, portable software packages to run consistently across hybrid or multi-cloud environments
> - Image
> - Container
> - Repository

# Docker

## Image

```shell
# Search image
docker search ubuntu
# Obtain image
docker pull [选项] [Docker Registry 地址[:端口号]/]仓库名[:标签]
docker pull ubuntu:24.04

# Exporte image
docker image save ubuntu > docker-ubuntu.tar.gz
# Load image
docker image load -i docker-ubuntu.tar.gz

# List image
docker image ls
docker image ls ubuntu
docker image ls -f since=ubuntu:24.04
docker image ls -q
docker image ls --format "{{.ID}}: {{.Repository}}"
docker image ls --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}"
# Viem image information
docker image inspect $image_id

# Delete image
docker image rm $image_id
# Delete dangling image
docker image prune

# 
docker history $$image_id

# View the space occupied by images, containers, and data volumes
docker system df
```

```shell
# Import image from rootfs compressed package
docker import $image.tar.gz $Repository/$image:$label

# Exporting an image
docker save $image -o $filename
docker save $image | gzip > $filename.tar.gz
# Loading the image
docker load -i $filename.tar.gz
```

### Create image

```shell
# Save the container as an image. Note: Use docker commit with caution
docker commit \
    --author "xxx <xxx@.gmail.com>" \
    --message "Basic conda" \
    $container $Repository/$image:$label
```

```shell
# Customizing images using Dockerfile (recommendation)
docker build -t $imageName . -f $Dockerfile
```

```Dockerfile
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
```

Optimize Dockerfile
1. [dive](https://github.com/wagoodman/dive): A tool for exploring a docker image, layer contents, and discovering ways to shrink the size of your Docker/OCI image.
2. [slim](https://github.com/slimtoolkit/slim): Optimize Your Experience with Containers. Make Your Containers Better, Smaller, More Secure and Do Less to Get There.
3. [fromlatest.io](https://www.fromlatest.io/): Optimize Dockerfile (Web tools)
## Container

```shell
# Running the container interactively
docker run -it --rm ubuntu:24.04 bash
# Running the container in background and print container ID
docker run -d --rm ubuntu:24.04 bash

# Network Management: Port Mapping 
docker run -d -p 127.0.0.1:80:80 nginx:alpine

# Starting a terminated container
docker container start $container_id
# Restarting the container
docker container restart $container_id
# Terminating the container
docker container stop $container_id

# List container
docker container ls
docker ps
# View container information
docker container inspect $container_id
# View container logs
docker container logs $container_id

# Entering the container
docker exec -it $container_id bash
# Exiting will cause the container to stop, which is not recommended.
docker attach $container_id

# Removing a terminated container
docker container rm $containerId
# Clean up all terminated containers
docker container prune

# Exporting the container
docker export $containerId > $filename.tar
# Importing the container as a image
docker import $containerId.tar $Repository/$image:$label
```

## Data Management

### Volume & Mount

```shell
# Create volume
docker volume create $volumeName
# View volume
docker volume ls
# View volume information
docker volume inspect $volumeName
# Delete volume
docker volume rm $volumeName
# Clean up all invalid volume
docker volume prune
```

```shell
# Mount
docker run -it --name $containerName \
    # -v $volumeName:/home/ubuntu/data \ # The old way
    --mount source=$volumeName,target=/home/ubuntu/data \ # The new way
    # --mount type=bind,source=/home/ubuntu/data,target=/home/ubuntu/data \ # The new way
    $image:$label
```

```shell
docker cp <container_id>:<path_in_container> <path_on_host>
```

## Repository

### [Docker Hub](https://hub.docker.com/)

```shell
# login Docker Hub
docker login
# Search image from Docker Hub
docker search $image
# Download image from Docker Hub
docker pull $image:$label
# Upload image to Docker Hub
docker push username/ubuntu:18.04
```

### Private Repository

```shell
# Build a private image repository
docker run -d -p 5000:5000 --restart=always --name registry registry
docker run -d -p 5000:5000 -v $pathOfRegistry:/var/lib/registry registry
# View the images in the repository
curl 127.0.0.1:5000/v2/_catalog
```

```shell
# Upload image to private image repository
docker tag ubuntu:latest 127.0.0.1:5000/ubuntu:latest
docker push 127.0.0.1:5000/ubuntu:latest
```

```shell
# Download image from private image repository
docker pull 127.0.0.1:5000/ubuntu:latest
```

# [Apptainer](https://github.com/apptainer/apptainer) ([Singularity](https://github.com/apptainer/singularity))

Apptainer (formerly Singularity) is an open source container platform designed to be simple, fast, and secure. Many container platforms are available, but Apptainer is designed for ease-of-use on shared systems and in high performance computing (HPC) environments.
# [Kubernetes (K8s)](https://github.com/kubernetes/kubernetes)