---
Title: AI in Drug Discovery (AIDD)
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2025-05-25
Modified: 2026-07-06
tags:
  - AIDD
  - Incomplete
ai-usage: Original draft by author; text revised and expanded with the assistance of AI.
---
# 1. Introduction

## 1.1 CADD

> Computer-Aided Drug Design (CADD) represents a well-established paradigm in modern pharmaceutical research that utilizes computational techniques to discover, design, and optimize biologically active compounds. 
> Grounded in the principles of biophysics, structural biology, and thermodynamics, CADD is methodologically categorized into Structure-Based Drug Design (SBDD) and Ligand-Based Drug Design (LBDD). 
> SBDD leverages molecular docking and molecular dynamics (MD) simulations to evaluate ligand-receptor binding affinities within a defined three-dimensional target pocket, while LBDD relies on pharmacophore modeling and quantitative structure-activity relationship (QSAR) analysis when the target structure is unavailable. 
> By simulating molecular interactions and predicting absorption, distribution, metabolism, excretion, and toxicity (ADMET) profiles, CADD significantly streamlines the lead optimization process, reducing empirical costs and accelerating the identification of viable drug candidates.
> 
> - Step 1: Target Identification & Structure Preparation.
> - Step 2: Hit Discovery
>   1. Method 1: Structure-Based Drug Design, SBDD
>      - Molecular Docking
>   2. Method 2: Ligand-Based Drug Design, LBDD
>      - Pharmacophore Modeling
> - Step 3: Lead Optimization
>   - Molecular Dynamics
> - Step 4: ADMET Prediction
>   1. Absorption
>   2. Distribution
>   3. Metabolism
>   4. Excretion
>   5. Toxicity

## 1.2 AIDD

> AI-driven Drug Discovery (AIDD) marks a transformative evolutionary shift in the pharmaceutical landscape, transitioning the industry from traditional physics-based computation to data-driven predictive and generative modeling. Powered by advanced deep learning architectures—such as Graph Neural Networks (GNNs) for molecular topology encoding, Transformers for protein structure prediction, and diffusion models or Generative Adversarial Networks (GANs) for de novo molecular design—AIDD effectively navigates the vast, multi-dimensional chemical space. By seamlessly integrating heterogeneous multi-omics data, automated retrosynthetic planning, and high-throughput property prediction, AIDD bypasses the computational bottlenecks of classical mechanics. This allows for the simultaneous optimization of multiple drug-like properties, dramatically compressing early-stage discovery timelines from years to months.
>
> - Step 1: Target Discovery & Knowledge Graphs
>
>   - [PandaOmics](https://pharma.ai/pandaomics): An AI-driven platform for therapeutic target and biomarker discovery.
> - Step 2: Protein Structure Prediction
>   - AlphaFold 2/3
>   - ESMFold
>   - RoseTTAFold
> - Step 3: De Novo Drug Design & Generation
>   - [REINVENT](https://github.com/MolecularAI/REINVENT4) is a molecular design tool for de novo design, scaffold hopping, R-group replacement, linker design, molecule optimization, and other small molecule design tasks.
>   - [DiffDock](https://github.com/gcorso/DiffDock)
> - Step 4: High-Throughput Property Prediction
>   - [DeepChem](https://github.com/deepchem/deepchem)
>   - [Chemprop](https://github.com/chemprop/chemprop): Chemprop is a repository containing message passing neural networks for molecular property prediction.
> - Step 5: Retrosynthetic Planning
>   - [AiZynthFinder](https://github.com/MolecularAI/aizynthfinder): AiZynthFinder is a tool for retrosynthetic planning. The default algorithm is based on a Monte Carlo tree search that recursively breaks down a molecule to purchasable precursors.

## 1.3 Drug Discovery Cycle

```text
Disease hypothesis -> target validation -> hit discovery -> hit confirmation
       -> hit-to-lead -> lead optimization -> candidate selection
                              |
                 Design -> Make -> Test -> Analyze
                    ^________________________|
```

**DMTA** is the iterative design–make–test–analyze cycle. ADMET, selectivity, and synthesis feasibility should influence every round.

| Stage               | Central question                                           | Decision evidence                                                                 |
| ------------------- | ---------------------------------------------------------- | --------------------------------------------------------------------------------- |
| Target validation   | Will the proposed intervention change disease biology?     | Genetics, perturbation, mechanism, and tissue context                             |
| Hit discovery       | Which compounds warrant testing?                           | Ranked, diverse, accessible candidates with explicit hypotheses                   |
| Hit confirmation    | Is the signal reproducible and target-related?             | Fresh material, concentration response, orthogonal assays, artifact checks        |
| Hit-to-lead         | Can a chemical series be improved?                         | Coherent structure–activity relationships (SAR), tractable chemistry, early ADMET |
| Lead optimization   | Can potency, exposure, and safety be balanced?             | Cellular engagement, selectivity, PK/PD, and safety margins                       |
| Candidate selection | Is the overall profile sufficient for further development? | Integrated efficacy, exposure, safety, formulation, and manufacturing evidence    |

A **hit** is a confirmed active compound; a **lead** is an optimizable series with supporting properties; a **development candidate** meets project-specific criteria. A high computational score alone establishes none of these.

## 1.4 Chemical and Pharmacological Foundations

### 1.4.1 Affinity, Potency, and Efficacy

| Quantity                            | Meaning                                                     | Interpretation                                                                                                     |
| ----------------------------------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| $K_d$                               | Equilibrium dissociation constant                           | Lower values indicate stronger equilibrium binding under specified conditions                                      |
| $K_i$                               | Inhibition constant in a defined mechanistic model          | Interpretation depends on the inhibition mechanism                                                                 |
| IC50                                | Concentration causing 50% inhibition in an assay            | Depends on assay conditions, substrate concentration, and time                                                     |
| EC50                                | Concentration producing half of the fitted maximal response | Measures functional potency, not necessarily affinity                                                              |
| $E_{\max}$                          | Maximum observed or fitted response                         | Measures efficacy within the assay system                                                                          |
| $k_{\mathrm{on}}, k_{\mathrm{off}}$ | Association and dissociation rate constants                 | For simple reversible binding, $K_d=k_{\mathrm{off}}/k_{\mathrm{on}}$ and residence time $\tau=1/k_{\mathrm{off}}$ |

For a concentration $X$ expressed in mol/L:

$$pX=-\log_{10}(X/1\,\mathrm{M})$$

Thus, 100 nM corresponds to pX = 7. Keep pKd, pKi, pIC50, and pEC50 as distinct endpoints. Their common logarithmic scale does not make them interchangeable.

For equilibrium binding with standard concentration $C^\circ=1\,\mathrm{M}$:

$$\Delta G^\circ_{\mathrm{bind}}=RT\ln(K_d/C^\circ)$$

At approximately 298 K, a tenfold decrease in $K_d$ corresponds to about 1.36 kcal/mol more favorable binding free energy. Small energy errors can therefore change predicted affinity substantially.

### 1.4.2 Physicochemical Properties

| Property                              | Why it matters                                  | Key distinction                                                    |
| ------------------------------------- | ----------------------------------------------- | ------------------------------------------------------------------ |
| Molecular weight (MW)                 | Influences size, diffusion, and property space  | Larger is not automatically worse; modality and route matter       |
| logP                                  | Neutral-species octanol/water partitioning      | Describes lipophilicity of the neutral form                        |
| logD at specified pH                  | Distribution including ionized species          | Report the pH; logD and logP are not interchangeable               |
| pKa                                   | Controls ionization with pH                     | Affects solubility, permeability, binding, and tissue distribution |
| H-bond donors/acceptors               | Influence recognition and desolvation           | Additional interactions can be offset by desolvation costs         |
| Topological polar surface area (TPSA) | Useful proxy for polarity                       | Does not capture every conformational or permeability effect       |
| Rotatable bonds                       | Describe molecular flexibility                  | Conformational restriction can help or hurt binding and exposure   |
| logS                                  | Usually $\log_{10}$ of molar aqueous solubility | Record pH, temperature, solid form, and measurement protocol       |

**Solubility is not solvation free energy.** Dissolution of a solid involves both escape from the crystal lattice and stabilization in solution. Ionization, polymorphism, aggregation, and equilibration time also matter. Distinguish intrinsic from pH-dependent solubility and kinetic from thermodynamic measurements.

Poor solubility can limit exposure or complicate formulation; it does not by itself establish toxicity or rule out a useful drug.

### 1.4.3 Medicinal Chemistry Heuristics

- **Lipinski's rule of five:** MW ≤ 500, logP ≤ 5, H-bond donors ≤ 5, and acceptors ≤ 10 are common oral small-molecule heuristics, not universal pass/fail rules.
- **Ligand efficiency:** often approximated as $LE=-\Delta G^\circ_{\mathrm{bind}}/N_{\mathrm{heavy}}$; helps contextualize affinity by size but is size- and convention-dependent.
- **Lipophilic efficiency:** $LipE=pIC50-\log P$ is one convention. Use comparable potency assays and state whether logP or logD is used.
- **Activity cliffs:** small structural changes can cause large potency changes; similarity does not guarantee similar activity.
- **Matched molecular pairs:** compare compounds differing by a defined transformation to study local SAR. [mmpdb](https://github.com/rdkit/mmpdb) supports this analysis.

# 2. Data Featrues

## 2.1 Molecular Representations

| Representation                | Encodes                                        | Useful for                                    | Main limitation                                                                   |
| ----------------------------- | ---------------------------------------------- | --------------------------------------------- | --------------------------------------------------------------------------------- |
| SMILES                        | Molecular graph serialized as text             | Storage, sequence models, generation          | Multiple strings can describe the same molecule; stereochemistry must be explicit |
| InChI/InChIKey                | Standardized identifiers                       | Cross-resource matching                       | Not a substitute for rich structure and assay records                             |
| Descriptors                   | MW, logP, TPSA, charge, and related properties | Interpretable baselines and filtering         | Limited structural detail                                                         |
| Morgan/ECFP-like fingerprints | Circular atom environments                     | Similarity, clustering, classical QSAR        | Hash collisions and limited 3D information                                        |
| Molecular graphs              | Atoms, bonds, and their features               | GNNs and message-passing models               | A 2D graph alone lacks bound geometry                                             |
| 3D conformers                 | Coordinates, distances, orientations           | Docking, shape comparison, equivariant models | Depend on conformer, protonation, and environment                                 |
| Pharmacophores                | Spatial arrangement of interaction features    | Ligand- or structure-based screening          | Sensitive to alignment and feature definitions                                    |
| Learned embeddings            | Features learned from pretraining              | Transfer learning and multimodal models       | Must demonstrate benefit on relevant held-out data                                |

For binary fingerprints, Tanimoto similarity is:

$$T(A,B)=\frac{|A\cap B|}{|A|+|B|-|A\cap B|}$$

Its value depends on fingerprint type, radius, length, chirality settings, and standardization. Morgan radius 2 is ECFP4-like: the corresponding neighborhood diameter is four bonds, but implementations need not be identical.

## Database

| Resource                                                         | Main use                                           | Important qualification                                                          |
| ---------------------------------------------------------------- | -------------------------------------------------- | -------------------------------------------------------------------------------- |
| [ChEMBL](https://www.ebi.ac.uk/chembl/)                          | Curated compounds, assays, and bioactivities       | Inspect assay type, target assignment, units, qualifiers, and provenance         |
| [BindingDB](https://www.bindingdb.org/)                          | Measured protein–ligand binding data               | Check experimental conditions and overlap with other databases                   |
| [PubChem](https://pubchem.ncbi.nlm.nih.gov/)                     | Chemical identities, properties, and bioassays     | Depositor records and assay contexts vary                                        |
| [RCSB PDB](https://www.rcsb.org/)                                | Experimental macromolecular structures             | Review validation reports, ligand density, constructs, and biological assemblies |
| [AlphaFold DB](https://alphafold.ebi.ac.uk/)                     | Predicted protein structures                       | Local confidence does not demonstrate pocket suitability                         |
| [UniProt](https://www.uniprot.org/)                              | Sequences, isoforms, functions, and annotations    | Resolve species, sequence version, and residue numbering                         |
| [Open Targets](https://platform.opentargets.org/)                | Target–disease evidence and prioritization         | Association strength is not proof of therapeutic causality                       |
| [ZINC](https://zinc.docking.org/)                                | Screening compounds and purchasable chemical space | Availability, supplier stock, and enumerated states can change                   |
| [MoleculeNet](https://doi.org/10.1039/C7SC02664A)                | Molecular ML benchmark datasets                    | Use the dataset-specific endpoint, split, and metric                             |
| [Therapeutics Data Commons](https://github.com/mims-harvard/TDC) | Therapeutic datasets and evaluation tasks          | Preserve benchmark definitions and split protocols                               |

---

# Workflow

## Basic Database

### [PDB](https://www.rcsb.org/)

> The RCSB Protein Data Bank (RCSB PDB) is a publicly accessible, curated repository of three-dimensional structural data for biological macromolecules, including proteins, nucleic acids, and their complexes.

### [PubChem](https://pubchem.ncbi.nlm.nih.gov/)

> PubChem® is the world's largest collection of freely accessible chemical information. Search chemicals by name, molecular formula, structure, and other identifiers. Find chemical and physical properties, biological activities, safety and toxicity information, patents, literature citations and more.

### [ChEMBL](https://www.ebi.ac.uk/chembl/)

> ChEMBL is a manually curated database of bioactive molecules with drug-like properties. It brings together chemical, bioactivity and genomic data to aid the translation of genomic information into effective new drugs.

### [ZINC](https://zinc.docking.org/)

> ZINC is a free database of commercially available compounds for virtual screening.

### Dataset

1. [MoleculeNet](https://deepchem.readthedocs.io/en/latest/api_reference/moleculenet.html)

> MoleculeNet is a widely used, large-scale benchmark suite designed to evaluate and train machine learning algorithms on molecular properties.
> - Zhenqin Wu, Bharath Ramsundar, Evan N. Feinberg, Joseph Gomes, Caleb Geniesse, Aneesh S. Pappu, Karl Leswing, Vijay Pande; MoleculeNet: a benchmark for molecular machine learning. **Chem. Sci.** 2018; 9 (2): 513–530. https://doi.org/10.1039/c7sc02664a. 



## Basic Toolkit

### [RDKit](https://github.com/rdkit/rdkit)

> The RDKit is a collection of cheminformatics and machine-learning software written in C++ and Python.

```shell
conda install -c conda-forge rdkit
```

```Python
```



### [ChimeraX](https://github.com/RBVI/ChimeraX)

> ChimeraX is an application for visualizing and analyzing molecule structures such as proteins, RNA, DNA, lipids as well as gene sequences, electron microscopy maps, X-ray maps, 3D light microscopy and 3D medical imaging scans.

### [PyMOL](https://github.com/schrodinger/pymol-open-source)

> PyMOL is a molecular visualization system widely used for the interactive visualization, analysis, and presentation of biomolecular structures. The commercial version of PyMOL is developed, maintained, and distributed by Schrödinger, Inc., building upon the open-source PyMOL foundation through a user-supported development model.

### [Biopython](https://github.com/biopython/biopython)

> Biopython is an open-source collection of Python libraries that provides tools for computational molecular biology and bioinformatics.

```shell
pip install biopython
```

### [DeepChem](https://github.com/deepchem/deepchem)

> DeepChem aims to provide a high quality open-source toolchain that democratizes the use of deep-learning in drug discovery, materials science, quantum chemistry, and biology.

```shell
pip install deepchem
```

```python
# Predicting the solubility of small molecules based on their chemical formulas.
# Load dataset (Delaney solubility dataset)
tasks, datasets, transformers = dc.molnet.load_delaney(featurizer='GraphConv')
train_dataset, valid_dataset, test_dataset = datasets
# Create a model (Graph Convolutional Network, GCN)
model = dc.models.GraphConvModel(n_tasks=1, mode='regression', dropout=0.2, batch_normalize=False)
# Train the model on the dataset
model.fit(train_dataset, nb_epoch=100)
# Evaluate the model on the test set
metric = dc.metrics.Metric(dc.metrics.pearson_r2_score)
print("Training set score:", model.evaluate(train_dataset, [metric], transformers))
print("Test set score:", model.evaluate(test_dataset, [metric], transformers))
# Predicted log(solubility)
solubilities = model.predict_on_batch(test_dataset.X[:10])
for molecule, solubility, test_solubility in zip(test_dataset.ids, solubilities, test_dataset.y):
    print(solubility, test_solubility, molecule)
```

### [PaddleHelix](https://github.com/PaddlePaddle/PaddleHelix)

> PaddleHelix is a bio-computing tool, taking advantage of the machine learning approaches, especially deep neural networks, for facilitating the development of the following areas:
> - Drug Discovery. Provide 1) Large-scale pre-training models: compounds and proteins; 2) Various applications: molecular property prediction, drug-target affinity prediction, and molecular generation.
> - Vaccine Design. Provide RNA design algorithms, including LinearFold and LinearPartition.
> - Precision Medicine. Provide application of drug-drug synergy.

## Virtual Screening

### [AutoDock Vin](https://github.com/ccsb-scripps/AutoDock-Vina)

> AutoDock Vina is one of the fastest and most widely used open-source docking engines.

### [DiffDock](https://github.com/gcorso/DiffDock)

> **DiffDock** is a state-of-the-art framework for **docking small molecules to proteins**, leveraging diffusion steps, twists, and turns to accurately predict binding structures. The repository now defaults to **DiffDock-L**, an updated version offering significant enhancements in performance and generalization. To run the original DiffDock model, users can revert to an earlier version using the GitHub commit history. 
>
> For standard complexes, DiffDock confidence scores ($c$) indicate high confidence when $c > 0$, moderate confidence when $-1.5 < c \le 0$, and low confidence when $c \le -1.5$. These thresholds assume a typical drug-like molecule bound to a medium-sized protein in a bound-like conformation. If your target involves large ligands, large protein complexes, or unbound (apo) conformations, these baseline intervals should be shifted downward.
>
> DiffDock does not predict the binding affinity of the ligand to the protein.
>
> 1. Corso, G., Stärk, H., Jing, B., Barzilay, R. & Jaakkola, T. DiffDock: Diffusion Steps, Twists, and Turns for Molecular Docking. In International Conference on Learning Representations (ICLR) (2023).
> 2. Corso, G., Deng, A., Polizzi, N., Barzilay, R. & Jaakkola, T. Deep Confident Steps to New Pockets: Strategies for Docking Generalization. In International Conference on Learning Representations (ICLR) (2024).

```shell
# Conda
conda env create --file environment.yml
# Docker
docker build . -f Dockerfile -t diffdock
docker pull rbgcsail/diffdock
```

```shell
# Docking Prediction

# For a single complex
python -m inference --config default_inference_args.yaml \
    --protein_path {input.protein.pdb} \
#   --protein_sequence GIQSYCTPPYSVLQDPPQPVV \
    --ligand {input.ligand.sdf} \
#   --ligand {input.ligand.mol2} \
#   --ligand "COc(cc1)ccc1C#N" \
    --out_dir {output.dir}
# Sequences will be folded with ESMFold.

# For many complexes
python -m inference --config default_inference_args.yaml \
    --protein_ligand_csv {input.protein_ligand.csv} \
    --out_dir {output.dir}
```



# *Workflow 2:* Molecular Docking

## Protein-Protein Docking

### [HADDOCK3](https://github.com/haddocking/haddock3)

HADDOCK, standing for **H**igh **A**mbiguity **D**riven protein-protein DOCKing, is a widely used computational tool for the integrative modeling of biomolecular interactions.

### [DiffDock-PP](https://github.com/ketatam/DiffDock-PP)

DiffDock-PP is a new approach to rigid-body protein-protein docking that is based on a diffusion generative model that learns to translate and rotate unbound protein structures into their bound conformations, and a confidence model that learns to rank different poses generated by the score model and select the best one.

[AlphaFold-Multimer](https://github.com/google-deepmind/alphafold): flexible protein-protein interactions

[RoseTTAFold2NA](https://github.com/uw-ipd/RoseTTAFold2NA): protein-nucleic acid interactions

## Protein-Ligand Docking

### [AutoDock Vina](https://github.com/ccsb-scripps/AutoDock-Vina)

AutoDock Vina is one of the fastest and most widely used open-source docking engines. It is a turnkey computational docking program that is based on a simple scoring function and rapid gradient-optimization conformational search.

### [DiffDock](https://github.com/gcorso/DiffDock)

Diffusion Steps, Twists, and Turns for Molecular Docking

### [DynamicBind](https://github.com/luwei0917/DynamicBind)

DynamicBind recovers ligand-specific conformations from unbound protein structures, promoting efficient transitions between different equilibrium states.

---
# Reference

> 1. Zhang, K., Yang, X., Wang, Y. et al. Artificial intelligence in drug development. Nat Med 31, 45–59 (2025). https://doi.org/10.1038/s41591-024-03434-4.
