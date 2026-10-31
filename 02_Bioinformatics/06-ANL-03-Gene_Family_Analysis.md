---
Title: Gene Family Analysis
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2020-08-24
Modified: 2026-10-14
ai-usage: Original draft by author; text revised and expanded with the assistance of AI.
---
# 1. Introduction

Gene family analysis identifies related genes, reconstructs their evolutionary relationships, and investigates functional conservation or divergence. For epigenetic regulators, combine sequence and domain evidence with expression, chromatin occupancy, molecular interactions, and perturbation data.

## 1. Define the Family and Biological Question

| Concept | Meaning and practical implication |
| --- | --- |
| Homologs | Genes related by common ancestry. Report sequence identity or similarity; avoid “percentage homology.” |
| Orthologs | Homologs whose divergence traces to a speciation event. Relationships can be one-to-one, one-to-many, or many-to-many. |
| Paralogs | Homologs whose divergence traces to a duplication event; they can occur within or between species. |
| Orthogroup | Genes descended from one ancestral gene at a specified ancestral node. Membership depends on the species set and evolutionary depth. |
| Domain-defined group | Proteins sharing a domain, potentially across several gene families with different architectures and functions. |

Distinguish a **gene family** from a **functional class**. Chromatin writers, erasers, readers, and remodelers are functional classes containing multiple families. A shared catalytic or binding domain alone does not establish equivalent substrate specificity or biological function.

Define the scope before searching: target species, reference members, required domains, treatment of inactive homologs and pseudogenes, and the question being tested. Typical questions include identifying all members, resolving human–mouse orthology, comparing paralog specialization, or testing lineage-specific duplication.

For well-annotated organisms, begin with curated members and existing [Ensembl Compara gene trees](https://www.ensembl.org/info/docs/compara/homology_method.html); use a new sequence search to assess completeness or extend taxonomic coverage.

## 2. Prepare Sequences and Annotations

| Input | Purpose |
| --- | --- |
| Protein FASTA | Domain searches, homology searches, protein alignment, and phylogenetic inference. |
| Matched CDS FASTA | Codon alignments and coding-sequence selection analyses. |
| Genome FASTA and GFF3/GTF | Genomic coordinates, exon–intron structures, synteny, and inspection of questionable gene models. |
| Reference proteins | Experimentally characterized members and representatives of related subfamilies. |
| ID mapping table | Species, gene, transcript, and protein IDs; annotation release and selected isoform. |

Obtain matched files from the same assembly and annotation release through Ensembl, NCBI, or the relevant organism database. See [Bioinformatics Databases](01-RES-04-Databases.md) for resource links.

- Select one representative protein per gene for initial gene counting and orthology inference. Prefer a well-supported canonical isoform; a longest complete coding isoform is a fallback, not a universal biological choice.
- Retain alternative isoforms separately when domain inclusion or tissue-specific splicing is part of the question. Do not count transcripts as separate genes.
- Use unique, species-qualified FASTA IDs without spaces and retain a mapping to original identifiers.
- Flag partial proteins, internal stop codons, fragmented gene models, and assembly duplicates. Retained haplotigs can inflate family counts, while incomplete assemblies can mimic gene loss.
- Sample relevant species and suitable outgroups. Many nearly identical sequences add less phylogenetic information than balanced sampling across the lineages of interest.

## 3. Identify and Validate Candidate Members

### Profile and Sequence Searches

Use a curated profile HMM from [Pfam through InterPro](https://www.ebi.ac.uk/interpro/) to identify a conserved protein domain or family. Complement it with BLASTP or DIAMOND searches using characterized reference proteins when needed. Review disagreements between methods rather than requiring every candidate to pass both.

The example below searches a representative **proteome**, not genomic DNA, using the SET-domain profile [PF00856](https://www.ebi.ac.uk/interpro/entry/pfam/PF00856/). It retrieves SET-domain candidates; it does not identify every lysine methyltransferase or establish histone substrate specificity.

```bash
# Inputs: a downloaded PF00856 HMM and one representative protein per gene.
mkdir -p results

hmmsearch --cpu 8 --cut_ga \
  --domtblout results/SET.domtblout \
  PF00856.hmm proteome.representative.faa \
  > results/SET.hmmsearch.txt

# Column 1 is the target protein ID in hmmsearch domain output.
awk '!/^#/ && NF {print $1}' results/SET.domtblout \
  | sort -u > results/SET.candidate_ids.txt

# Inspect an empty candidate list before continuing.
if [ -s results/SET.candidate_ids.txt ]; then
  seqkit grep -f results/SET.candidate_ids.txt \
    proteome.representative.faa > results/SET.candidates.faa
fi
```

`--cut_ga` uses model-specific curated gathering thresholds and requires GA annotations in the HMM. `--cut_tc` uses trusted cutoffs, which are a different threshold set. For models without curated thresholds, assess sequence/domain E-values, alignment coverage, and known positives; no single cutoff is suitable for all families. `hmmsearch` searches a profile against sequences; `hmmscan` searches sequences against a profile database. See the [HMMER manual](https://eddylab.org/software/hmmer/Userguide.pdf) and [SeqKit documentation](https://bioinf.shenwei.me/seqkit/usage/).

### Candidate Curation

1. **Confirm domain architecture.** Annotate candidates with InterPro or InterProScan. Check domain order, copy number, and family-specific accessory domains against reference members.
2. **Inspect hit quality.** Review domain coverage, partial hits, low-complexity regions, and unusually short or long proteins. In `hmmsearch --domtblout`, profile coverage is `(hmm_to - hmm_from + 1) / query_length`; it is not coverage of the full protein.
3. **Examine conserved residues.** Compare catalytic and binding residues with characterized members. Missing residues may indicate an inactive homolog or an annotation error, rather than absence from the family.
4. **Resolve gene models.** Inspect genomic sequence, transcript support, and neighboring genes for apparent losses or split/duplicated annotations.
5. **Record decisions.** Maintain a candidate table with IDs, scores, domain coordinates, architecture, completeness, and inclusion/exclusion rationale.

Save the accepted full-length representatives as `family.curated.faa`. Keep provisional or partial candidates explicitly labeled instead of silently treating them as confirmed members.

## 4. Infer Orthology and Phylogenetic Relationships

### Orthology Inference

Use [Ensembl Compara](https://www.ensembl.org/info/docs/compara/homology_method.html) for supported species or [OrthoFinder](https://github.com/davidemms/OrthoFinder) for comparative analysis of species proteomes. A standard OrthoFinder analysis takes one proteome FASTA per species and produces ortholog assignments, gene trees, duplication events, and a species tree. Select hierarchical orthogroups at the ancestral node relevant to the question.

For a targeted family, interpret its gene tree against an independently supported species tree to distinguish duplication from speciation. Reciprocal best hits alone can miss one-to-many relationships. A gene tree, a species tree, and an orthogroup are different outputs; high branch support does not by itself establish orthology.

### Alignment and Tree Inference

Align homologous regions shared by the selected sequences. Full-length alignment is appropriate when architecture and sequence correspondence are comparable; domain-level alignment is often more defensible for divergent multidomain proteins. A tree inferred from one domain describes that domain's history, which may differ from the history of the full protein.

Prepare `family.homologous_regions.faa` from the curated sequences and reference members, recording extracted coordinates. Use the following [MAFFT L-INS-i](https://mafft.cbrc.jp/alignment/software/manual/manual.html) example for a modest sequence set; `mafft --auto` is a practical starting point for larger sets.

```bash
mafft --localpair --maxiterate 1000 --thread 8 \
  family.homologous_regions.faa > family.aligned.faa
```

Inspect the alignment for misaligned domains, fragments, and ambiguous columns. Save the reviewed alignment as `family.aligned.curated.faa`, retaining any masking decisions. Trimming is optional; aggressive trimming can remove informative sites.

```bash
# Example for an installation exposing the IQ-TREE 2 executable as iqtree2.
iqtree2 -s family.aligned.curated.faa \
  -m MFP -B 1000 -alrt 1000 \
  -T 8 -seed 12345 -pre family.tree
```

This runs model selection, maximum-likelihood inference, ultrafast bootstrap, and SH-aLRT support estimation. The executable may be named `iqtree`, `iqtree2`, or `iqtree3`; match it to the installed version and [IQ-TREE documentation](https://iqtree.github.io/doc/Quickstart). Retain the `.treefile`, `.iqtree`, and `.log` outputs.

Root the tree only with a justified homologous outgroup or a documented alternative. Check whether key groupings persist under reasonable alignment and taxon-sampling choices. Display species, subfamily, domain architecture, and support values alongside the tree using iTOL or ggtree.

## 5. Compare Domains, Motifs, and Genomic Organization

| Analysis | Main question | Approach |
| --- | --- | --- |
| Domain architecture | Which catalytic or interaction modules are conserved, gained, or lost? | InterPro/Pfam annotation displayed alongside the family tree. |
| Protein sequence motifs | Are short conserved sequence patterns shared or subfamily-specific? | MEME on curated proteins or comparable regions; interpret motifs against known domains and residues. |
| Exon–intron structure | Do homologs share coding-exon boundaries, or show structural divergence? | Compare matched representative transcripts using GFF3/GTF and CDS annotations. |
| Chromosomal location and synteny | Are genes clustered, and are neighboring genes conserved across species? | Examine genomic coordinates and conserved gene order; chromosome location alone does not establish duplication mechanism. |

An optional protein motif search with [MEME](https://meme-suite.org/meme/doc/meme.html):

```bash
meme family.curated.faa -protein -mod zoops \
  -nmotifs 5 -minw 6 -maxw 30 -oc results/meme_protein
```

These motif counts and widths are illustrative. `zoops` allows zero or one occurrence of each motif per sequence; use a repeated-occurrence model when biologically justified. Check low-complexity effects and sampling imbalance before interpreting motif differences.

**Protein sequence motifs differ from DNA/RNA binding motifs.** A conserved peptide pattern does not establish the nucleic-acid sequence recognized by a protein. TF/RBP binding preferences require binding-motif resources or binding assays; see the binding and motif section of [Bioinformatics Databases](01-RES-04-Databases.md).

## 6. Analyze Duplication and Selection When Relevant

### Duplication, Expansion, and Loss

Combine reconciled gene trees with synteny and assembly evidence to interpret duplication and loss. Count genes consistently across species and inspect outliers before inferring expansion. Tumor somatic copy-number amplification is distinct from an evolutionary increase in gene-family size across species.

For a genome-wide expansion/contraction study, [CAFE5](https://github.com/hahnlab/CAFE5) models gene-family counts across a dated species tree. It requires a suitable family-count matrix and a rooted, ultrametric **time tree**, with attention to annotation error. A substitution-length gene tree or a single target-family count vector is not a substitute for those inputs.

### Coding-Sequence Selection

The ratio `dN/dS` (also written `Ka/Ks` or `ω`) compares nonsynonymous and synonymous substitution rates per site. Values below, near, or above one are commonly interpreted in terms of purifying selection, neutrality, or positive selection within the fitted model; a pairwise estimate above one alone is insufficient evidence of adaptive evolution.

1. Select homologous coding sequences at an appropriate divergence level and verify their correspondence to the analyzed proteins.
2. Build a codon-aware alignment, either directly or by back-translating a protein alignment with the matched CDS. Preserve reading frames and remove ambiguous regions in whole codons.
3. Check for frameshifts, premature stops, recombination, very low synonymous divergence, and synonymous-site saturation.
4. Choose a hypothesis and model, report uncertainty, and correct for multiple testing where applicable. Do not calculate coding-sequence `dN/dS` from a protein alignment alone.

| Method in [HyPhy](https://hyphy.org/methods/selection-methods/) | Question |
| --- | --- |
| FEL | Which sites show pervasive positive or negative selection? |
| MEME | Which sites show episodic positive selection on some branches? |
| aBSREL | Which tested branches show episodic positive selection? |
| BUSTED | Is there evidence of positive selection at some sites on at least one tested branch? |

HyPhy's MEME selection test and MEME Suite's motif-discovery program are different methods. Choose selection analyses only when the sequence sampling and biological question support them.

## 7. Connect Family Relationships to Epigenetic Function

| Evidence | Useful comparison | Interpretation boundary |
| --- | --- | --- |
| Tissue and cell-state expression | Compare paralogs across development, immune activation, neural cell types, or tumor states using bulk and single-cell RNA-seq. | Separate cell-composition changes from within-cell-type regulation; highly similar paralogs can be difficult to quantify uniquely. |
| Chromatin occupancy | Compare ChIP-seq, CUT&RUN, or CUT&Tag profiles in matched cellular contexts. | Check antibody specificity and read mappability; similar occupancy does not establish identical function. |
| Chromatin state | Relate family-member perturbation to ATAC-seq, histone marks, or DNA methylation. | Accessibility alone does not demonstrate direct binding, and downstream changes can be indirect. |
| Complex membership | Compare interaction partners and mutually exclusive subunits of chromatin complexes. | Shared complexes can support related roles without implying interchangeable subunits. |
| Perturbation and rescue | Compare individual and combined knockout, knockdown, or catalytic-mutant phenotypes. | Validate reagent specificity; redundancy may become apparent only after combined perturbation. |
| Cancer alterations | Integrate mutations, copy number, expression, and dependency data. | Distinguish association from causation and account for lineage and genetic background. |

Useful case studies include TET paralogs, DNMT3A/DNMT3B, selected SET-domain methyltransferase subfamilies, and bromodomain-containing families. Define each family using its evolutionary and architectural context rather than pooling all chromatin regulators into one sequence analysis.

For enrichment analysis, use a background reflecting the genes that could have entered the analysis and consider biases from family selection and duplicated annotations. See [Gene Function Analysis](06-ANL-01-Gene_Function_Analysis.md).

## 8. Retain the Evidence Behind the Conclusions

Keep the curated member table and ID mapping, accepted sequences, domain annotations, reviewed alignment, supported tree, and question-specific comparison results. Record database releases, software versions, commands, thresholds, and curation decisions alongside these outputs.

A useful final figure combines the family tree with domain architecture and one biologically relevant comparison, such as cell-type expression or perturbation response. Separate established annotations, evolutionary inferences, and functional hypotheses in the accompanying interpretation.
