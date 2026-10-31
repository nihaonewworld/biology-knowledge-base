---
Title: AI-driven Protein Design
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2025-05-10
Modified: 2026-01-19
---
# 1. Introduction

> AI-driven Protein Design represents a transformative paradigm in structural biology and macromolecular engineering, transitioning the field from the empirical modification of natural proteins to the **de novo generation of entirely novel molecular structures**. This technology fundamentally operates across two interconnected computational vectors: backbone generation, which utilizes **geometric diffusion models** (e.g., RFdiffusion) to sculpt stable, target-specific 3D scaffolds, and sequence design (inverse folding), which leverages **deep graph neural networks** (e.g., ProteinMPNN) to identify optimal amino acid sequences that precisely fold into those scaffolds. Enriched by large protein language models (pLMs) that decode evolutionary syntax and verified in silico through high-fidelity structural predictors, this programmable approach bypasses the screening constraints of traditional directed evolution.

## 1.1 Structure Prediction

> Structure Prediction addresses the fundamental biological challenge of mapping a linear amino acid sequence to its native three-dimensional conformation (Sequence $\rightarrow$ Structure). Grounded historically in Anfinsen's dogma, which posits that a protein's tertiary structure is uniquely determined by its primary sequence, the field has been revolutionized by deep learning architectures such as AlphaFold and ESMFold. By integrating evolutionary information from multiple sequence alignments (MSAs) with spatial attention mechanisms, modern algorithms can rapidly predict atomic coordinates with near-experimental accuracy. This capability is pivotal for elucidating molecular mechanisms, characterizing target-ligand interactions, and providing the structural foundations necessary for modern rational drug design.

## 1.2 Inverse Folding

> Inverse Folding, often referred to as fixed-backbone protein design, solves the mathematical reverse of the structure prediction problem by mapping a target three-dimensional backbone topology to viable amino acid sequences (Structure $\rightarrow$ Sequence). Given a specific geometric scaffold, inverse folding algorithms navigate a vast combinatorial sequence space to identify primary structures optimized to stabilize the desired fold while minimizing energetic frustration. Contemporary methodologies rely heavily on geometric graph neural networks (GNNs), such as ProteinMPNN, which treat the protein backbone as a spatial graph and utilize message-passing operations to condition sequence selection on local structural environments. This technology serves as a cornerstone for de novo protein engineering, enabling the customized creation of therapeutics, biosensors, and biocatalysts with unprecedented structural fidelity.

## 1.3 Application

> 1. Drug Discovery:
> 2. Vaccine Development: Rapid antigen design
> 3. Enzyme Engineering: Custom catalysts for industrial processes
> 4. Gene Therapy: Optimized delivery vectors

## Commercial  Platform

> 1. [Cradle](https://www.cradle.bio/)

---
# *Workflow 1:* Protein Design

> From Structure Generation to Full Atomic Models

## 1. Backbone Generation

> Use diffusion models such as RFdiffusion to "hallucinate" new structures by denoising random atomic configurations until a viable structure emerges.

### a). [RFdiffusion](https://github.com/RosettaCommons/RFdiffusion)

> RFdiffusion is a generative model for protein structure design based on denoising diffusion probabilistic models.
> - Watson, J.L., Juergens, D., Bennett, N.R. *et al.* De novo design of protein structure and function with RFdiffusion. *Nature* **620**, 1089–1100 (2023). https://doi.org/10.1038/s41586-023-06415-8.

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fs41586-023-06415-8/MediaObjects/41586_2023_6415_Fig1_HTML.png" 
        alt="Diffusion models for protein structure design architecture and workflow"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> Diffusion models for protein structure design. 
        Adapted from <a href="https://doi.org/10.1038/s41586-023-06415-8" target="_blank" rel="noopener noreferrer">Watson et al. (2023)</a>, <i>Nature</i>.
    </figcaption>
</figure>

```shell
# De novo design
python ./scripts/run_inference.py \
	'contigmap.contigs=[150-150]' \
	inference.output_prefix={output.prefix} \
	inference.num_designs=10

# Motif scaffolding
python ./scripts/run_inference.py \
	'contigmap.contigs=[5-15/A10-25/30-40/0 B1-100]' \
	inference.input_pdb={input.file.pdb} \
	inference.output_prefix={output.prefix} \
	inference.num_designs=10

# Partial diffusion

# Binder diffusion
python ./scripts/run_inference.py \
	'contigmap.contigs=[B1-100/0 100-100]' \
	inference.output_prefix={output.prefix} \
	inference.num_designs=10
```

```shell
# Docker
docker pull rosettacommons/rfdiffusion:latest

docker run -it --rm --gpus all \
	-v $HOME/models:$HOME/models \
	-v $HOME/inputs:$HOME/inputs \
	-v $HOME/outputs:$HOME/outputs \
	rfdiffusion \
	inference.output_prefix=$HOME/outputs/motifscaffolding \
	inference.model_directory_path=$HOME/models \
	inference.input_pdb=$HOME/inputs/5TPN.pdb \
	inference.num_designs=10 \
	'contigmap.contigs=[10-40/A163-181/10-40]'
```

```shell
# Analyse Generated Structures
python ./utils/analyse_structures.py --prefix={input.prefix}
# Select Best Design
python ./utils/select_best_design.py --prefix={input.prefix}
# Prepare Structure for ProteinMPNN
python ./utils/prepare_scaffold.py --input_pdb={input.pdb} --output_pdb={output.pdb}
```

### b). [Rosetta](https://github.com/RosettaCommons/rosetta)

> The Rosetta software suite includes algorithms for computational modeling and analysis of protein structures. It has enabled notable scientific advances in computational biology, including de novo protein design, enzyme design, ligand docking, and structure prediction of biological macromolecules and macromolecular complexes.

### c). [Chroma](https://github.com/generatebio/chroma)

> Chroma is a generative model for designing proteins programmatically.

## 2. Sequence Design

> Utilize tools like ProteinMPNN to find the specific amino acid sequence that will fold into the generated backbone structure.

### a). [ProteinMPNN](https://github.com/dauparas/ProteinMPNN)

> ProteinMPNN is a message-passing neural network that designs amino acid sequences for given protein backbone structures.
> - J. Dauparas *et al.*, Robust deep learning–based protein sequence design using ProteinMPNN.*Science***378**,49-56(2022).DOI:[10.1126/science.add2187](https://doi.org/10.1126/science.add2187).

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://www.science.org/cms/10.1126/science.add2187/asset/45ce0aa1-07b3-4ad3-98d5-b52186a131a9/assets/images/large/science.add2187-f1.jpg" 
        alt="ProteinMPNN neural network architecture and workflow for robust protein sequence design"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> ProteinMPNN architecture. 
        Adapted from <a href="https://doi.org/10.1126/science.add2187" target="_blank" rel="noopener noreferrer">Dauparas et al. (2022)</a>, <i>Science</i>.
    </figcaption>
</figure>


```shell
python protein_mpnn_run.py --pdb_path {input.pdb} \
	--model_name "v_48_020" --sampling_temp "0.1" \
	--num_seq_per_target 50 --out_folder {output.dir}
# --sampling_temp: Controls sequence diversity, (0.05 ~ 0.1, 0.2 ~ 0.3)
# --num_seq_per_target: Number of sequences to generate, (50 ~ 200)
# --model_name: Different models available
```

```shell
# Analyse Sequence Properties
python analyse_sequences.py --fasta_file={input.fa}
# Filter and Select Sequences
python select_sequences.py --input_file={input.fa}
# Validate Sequence-Structure Compatibility (need dssp)
python validate_design.py --sequences-file={input.fa} --structure-file={input.pdb}
# Select Best Sequence
python extract_best_sequence.py --input_fasta={input.fa} --output_fasta={output.fa}
```

## 3. Structure Validation

### a). [AlphaFold3](https://github.com/google-deepmind/alphafold3) & [AlphaFold2](https://github.com/google-deepmind/alphafold)

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fs41586-021-03819-2/MediaObjects/41586_2021_3819_Fig1_HTML.png" 
        alt="AlphaFold neural network model architecture and data processing pipeline"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> AlphaFold Model Architecture. 
        Adapted from <a href="https://doi.org/10.1038/s41586-021-03819-2" target="_blank" rel="noopener noreferrer">Jumper et al. (2021)</a>, <i>Nature</i>.
    </figcaption>
</figure>

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fs41586-024-07487-w/MediaObjects/41586_2024_7487_Fig1_HTML.png" 
        alt="AlphaFold 3 neural network model architecture and biomolecular interaction prediction pipeline"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> AlphaFold 3 Model Architecture. 
        Adapted from <a href="https://doi.org/10.1038/s41586-024-07487-w" target="_blank" rel="noopener noreferrer">Abramson et al. (2024)</a>, <i>Nature</i>.
    </figcaption>
</figure>

> While AlphaFold 2 requires downloading roughly 556 GB of compressed databases that expand to over 2.6 TB, AlphaFold 3 requires a 252 GB download that extracts to about 630 GB (needing up to 1 TB of total disk space). Local installation for both versions involves cloning their GitHub repositories and configuring Docker environments, but AlphaFold 3 demands exceptionally high-end hardware, such as an NVIDIA GPU with Compute Capability 8.0+ (e.g., A100/H100) and at least 64 GB of RAM. Given these intense local system requirements, it is strongly recommended to use the free, web-based **[AlphaFold Server](https://alphafoldserver.com/)** instead of configuring it yourself.
> - Jumper, J., Evans, R., Pritzel, A. *et al.* Highly accurate protein structure prediction with AlphaFold. *Nature* **596**, 583–589 (2021). https://doi.org/10.1038/s41586-021-03819-2.
> - Abramson, J., Adler, J., Dunger, J. *et al.* Accurate structure prediction of biomolecular interactions with AlphaFold 3. *Nature* **630**, 493–500 (2024). https://doi.org/10.1038/s41586-024-07487-w.
> - [The Illustrated AlphaFold](https://elanapearl.github.io/blog/2024/the-illustrated-alphafold/)

### b). [MODELLER](https://salilab.org/modeller/)

> Modeller is a program for homology or comparative modeling of protein three-dimensional structures

```shell
# Prepare Input Files (RFdiffusion)
python ./utils/prepare_inputs.py --scaffold-pdb={input.pdb} --sequence-file={input.fa}
# Create MODELLER Script
python ./utils/build_model.py
# Analyse Generated Models
python ./utils/analyse_models.py
# Validate the Best Model
python ./utils/validate_best_model.py
# Visualise the Final Model
PyMOL ...
# Export Final Results
python ./utils/export_results.py
```

### c). Other

> 1. [RoseTTAFold](https://github.com/RosettaCommons/RoseTTAFold)
> 2. [RoseTTAFold All-Atom](https://github.com/baker-laboratory/RoseTTAFold-All-Atom)
> 3. [ESMFold](https://github.com/facebookresearch/ESM)

## 4. Experimental Validation

> The designed sequences are synthesized in a lab to verify their function and structure.
> 1. Gene synthesis and vector construction
> 2. Protein expression
> 3. Protein purification
> 4. Characterization

---

# Infrastructure & Toolkit

## 1). [Foundry](https://github.com/RosettaCommons/foundry)

> Foundry provides tooling and infrastructure for using and training all classes of models for protein design, including design (RFD3), inverse folding (ProteinMPNN) and protein folding (RF3).

---
# Database

> 1. [UniProt](https://www.uniprot.org/): The Universal Protein Resource (UniProt) is a comprehensive, high-quality, and freely accessible repository that integrates **protein sequence data with detailed functional annotations**.
> 2. [PDB](https://www.rcsb.org/): The RCSB Protein Data Bank (RCSB PDB) serves as a global archive for **the three-dimensional (3D) structural data of macromolecular complexes**, including proteins, DNA, and RNA.
> 3. [DSSP](https://github.com/PDB-REDO/dssp): DSSP (Dictionary of Secondary Structure in Proteins) is an algorithm originally designed by Wolfgang Kabsch and Chris Sander to standardise secondary structure assigment based on atomic coordinates.

---
# Reference

> 1. [DL4Proteins](https://github.com/Graylab/DL4Proteins-notebooks) Jupyter Notebooks Teach how to use Artificial Intelligence for Biomolecular Structure Prediction and Design.
> 2. [EvoSite3D](https://github.com/romainstuder/evosite3d): A comprehensive repository of scripts, software, and tutorials for molecular evolution, computational protein design, and structural bioinformatics.
> 3. [A roadmap for AI-driven protein design](https://github.com/miangoar/AI-driven-protein-design)
> 4. Zeming Lin et al. ,Evolutionary-scale prediction of atomic-level protein structure with a language model.Science379,1123-1130(2023).DOI:10.1126/science.ade2574.
> 5. Koh, H.Y., Zheng, Y., Yang, M. *et al.* AI-driven protein design. *Nat Rev Bioeng* **3**, 1034–1056 (2025). https://doi.org/10.1038/s44222-025-00349-8.