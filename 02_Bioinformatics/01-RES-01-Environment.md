---
Title: Environment
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2021-10-17
Modified: 2025-09-06
tags:
  - WSL
  - Conda
  - Docker
---
# 1. Linux

## a). [WSL](https://github.com/microsoft/WSL) for [Windows](https://learn.microsoft.com/windows/wsl/)

```shell
# List available Linux distributions that can be installed
wsl --list --online
# List all installed Linux distributions
wsl --list --verbose

# Install WSL with default settings and default Linux distribution
wsl --install
# Install Linux distributions and specify a custom installation directory
wsl --install --distribution Ubuntu-24.04 --location E:\WSL\Ubuntu-24.04
wsl --install --distribution Ubuntu-26.04 --location E:\WSL\Ubuntu-26.04

# Export a distribution to a backup tar file
wsl --export <DistroName> E:\WSL\backup.tar
# Import a distribution from a tar file to a custom location
wsl --import <DistroName> E:\WSL\CustomPath E:\WSL\backup.tar

# Check the status and version of WSL currently running
wsl --status

# Set a specific distribution as the default
wsl --setdefault <DistroName>

# Stop/terminate a specific running distribution immediately
wsl --terminate <DistroName>
# Shut down all running WSL instances and the WSL 2 backend VM
wsl --shutdown

# Unregister (completely uninstall/delete) a distribution and remove all its data
wsl --unregister <DistroName>
```

```shell
# Update the package index/list to get the latest package information
sudo apt update
# Upgrade all installed packages to their latest available versions
sudo apt upgrade -y
# Upgrade packages and automatically handle dependencies
sudo apt full-upgrade -y
# Remove automatically installed packages that are no longer needed
sudo apt autoremove -y

# Install essential compilation tools (gcc, g++, make, dpkg-dev, etc.)
sudo apt install -y build-essential
# Install Make (automation and compilation tool)
sudo apt install -y make
# Install CMake (cross-platform build system generator)
sudo apt install -y cmake
# Install pkg-config (helper tool used when compiling applications)
sudo apt install -y pkg-config

# Install common command-line text editors
sudo apt install -y vim nano
# Install archiving and compression utilities
sudo apt install -y zip unzip tar gzip bzip2 pigz
# Install system monitoring tools (htop provides an interactive process viewer)
sudo apt install -y htop tree
# Install basic network troubleshooting and fetch tools
sudo apt install -y curl wget net-tools iputils-ping dnsutils
# Install Git for version control
sudo apt install -y git
# Install GNU Screen (terminal multiplexer for managing multiple sessions)
sudo apt install -y screen

```
## b). [Ubuntu](https://ubuntu.com/)

> Ubuntu_ is the modern, open source operating system on Linux.
## c). Linux Tool

> 1. [zsh 安装与配置：9步打造高效命令行](https://zhuanlan.zhihu.com/p/441676276)
# 2.  Package Management
## a). Conda

> 1. [Conda](https://docs.conda.io/projects/conda/en/stable/index.html) provides package, dependency, and environment management for any language.
> 2. [Miniconda](https://www.anaconda.com/docs/getting-started/miniconda/main) is a free, miniature installation of Anaconda Distribution that includes only conda, Python, the packages they both depend on, and a small number of other useful packages.
> 3. [Mamba](https://github.com/mamba-org/mamba): is a reimplementation of the conda package manager in C++.

```shell
# Download the latest Miniconda installer for Linux
wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-$(uname -m).sh
# Run the installer script
bash Miniconda3-latest-Linux-x86_64.sh
# Refresh the shell configuration to apply conda PATH settings
source .bashrc
# Disable automatic activation of the base environment upon opening a new shell
conda config --set auto_activate false
```

```shell
# Add channels
conda config --add channels conda-forge
conda config --add channels bioconda
# tsinghua mirror
https://mirrors.tuna.tsinghua.edu.cn/anaconda
# Enable showing the source URL when searching or installing packages
conda config --set show_channel_urls yes
# Display current list of configured channels
conda config --show channels
# Remove a specific channel (e.g., the default free channel)
conda config --remove channels free
```

```shell
# View all created working environments
conda info -e/--envs

# Create a new environment
conda create -n r452 -c conda-forge r-base=4.5.2 python=3.12
# Create a new environment from an existing configuration file
conda env create -f environment.yml
# Create a environmentby cloning an existing one to a new name
conda create -n new --clone r452

# Activate a target environment
conda activate r452
# Deactivate the currently active environment
conda deactivate

# Remove an entire environment and all its installed packages
conda remove -n r452 --all

# Rename an environment
conda create -n new --clone r452
conda remove -n r452 --all
```

```shell
# View all installed packages in a specific environment without activating it
conda list -n r452

# Install a specific package with exact version and build string specification (pkg_name=version=build_string)
conda install -y -c conda-forge r-xml=3.99_0.3=r36hcdcec82_1
# Install a local package file (.conda or .tar.bz2)
conda install --use-local libdeflate-1.18-h0b41bf4_0.conda

# Update all possible packages in the active environment
conda update --all
# Update packages while keeping the specified package version frozen
conda update --freeze-installed r-base

# Export the currently active environment configuration to a yaml file
conda env export > environment.yml

# Clear all conda caches
conda clean --all
```
## b). [Bioconductor](https://www.bioconductor.org/)

> The Bioconductor project aims to develop and share open source software for precise and repeatable analysis of biological data.
## c). [pip](https://github.com/pypa/pip)

> pip is the package installer for Python.

# 3. IDE

> Integrated Development Environment (IDE)

## 1. [JupyterLab](https://github.com/jupyter/)

```shell
conda create -n jupyterlab -c conda-forge jupyterlab nodejs
# pip install jupyterlab
```

```shell
jupyter lab --generate-config
vi ~/.jupyter/jupyter_lab_config.py

c = get_config()  #noqa
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.port_retries = 0
c.ServerApp.open_browser = False
c.ServerApp.root_dir = '/home/user'
```

```shell
screen -S runjupyter
conda activate jupyterlab
jupyter lab --port 8888
ctrl + A + D

screen -ls
kill $id
screen -r runjupyter
```

```shell
# Install the IPython kernel package for Jupyter
pip install ipykernel

# Register the Python kernel with Jupyter
python -m ipykernel install --user --name py312 \
	--display-name "Python 3.12 (r452, Scanpy)"
python -m ipykernel install --user --name deepl \
	--display-name "Python 3.12 (deepl)"
```

```R
# Install the IRkernel package from CRAN to enable R in Jupyter notebooks
# Note: Ensure Python and ipykernel are installed
install.packages("IRkernel")

# Register the R kernel with Jupyter
IRkernel::installspec(
	user = TRUE, name = "r363", displayname = "R 3.6.3 (Seurat V2)")
IRkernel::installspec(
	user = TRUE, name = "r403", displayname = "R 4.0.3 (Seurat V3)")
IRkernel::installspec(
	user = TRUE, name = "r423", displayname = "R 4.2.3 (Seurat V4)")
IRkernel::installspec(
	user = TRUE, name = "r452", displayname = "R 4.5.2 (Seurat V5)")
```
## 2. [Rstudio Server](https://posit.co/products/open-source/rstudio)

```shell
sudo apt-get update & sudo apt-get upgrade
sudo apt-get install gdebi-core

# Download Rstudio server
wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2023.12.1-402-amd64.deb

sudo gdebi rstudio-server-latest-amd64.deb
```

```shell
# Modify environment configuration
sudo vi /etc/rstudio/rserver.conf

# Server Configuration File
www-port=8787
rsession-which-r=/home/bin/R
```

```shell
# Open port
sudo ufw allow 8787
sudo ufw enable
sudo ufw reload
sudo ufw status

# Start
sudo rstudio-server start
sudo apt-get remove rstudio-server -y
```

# 4. AI Application

## a). [Claude Code](https://github.com/anthropics/claude-code)
## b). [Codex](https://github.com/openai/codex)
## c). [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness)
## d). [OpenCode](https://github.com/anomalyco/opencode)

---
# Appendix

## Conda Environment

```shell
conda create -n ngstools -y python=3.12 r-base=4.5.2

conda install -y sra-tools
conda install -y fastqc
conda install -y trimmomatic
conda install -y trim-galore
conda install -y cutadapt
conda install -y fastp
conda install -y seqkit seqtk
conda install -y samtools
conda install -y picard=3.4.0
conda install -y bwa minimap2
conda install -y bowtie bowtie2
conda install -y star hisat2
conda install -y bismark
conda install -y subread
conda install -y kallisto
conda install -y bedtools
conda install -y homer

# htslib version conflict
conda install -y salmon=1.11.4
conda install -y stringtie

# Python
conda install -y deeptools htseq macs3 umi_tools multiqc
conda install -y snakemake=9.19.0
```

```txt
perl-5.32.1,
openjdk-25.0.1
python-3.12.13
r-base-4.5.2

sra-tools-3.4.1
fastqc-0.12.1
trimmomatic-0.40
cutadapt-5.2
trim-galore-0.6.11
fastp-1.3.1
seqkit-2.13.0
seqtk-1.5
samtools-1.23.1
picard-3.4.0
bwa-0.7.19
minimap2-2.30
bowtie-1.3.1
bowtie2-2.5.4
star-2.7.11b
hisat2-2.2.2
subread-2.1.1
kallisto-0.52.0
bedtools-2.31.1
bismark-0.25.1
homer-5.1

?salmon-1.11.4
?stringtie-3.0.0 -3.0.3

?htseq-2.1.2
?deeptools-3.5.5 -3.5.6
macs3-3.0.4
umi_tools-1.1.6
multiqc-1.33
?snakemake-9.19.0
```