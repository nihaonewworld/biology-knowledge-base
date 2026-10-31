---
Title: Single-Cell Sequencing Technologies
Author: Cao Qiang
Email: qiangcao2014@gmail.com
Created: 2020-06-08
Modified: 2026-10-14
ai-usage: Original draft by author; text revised and expanded with the assistance of AI.
---

# Single-Cell Sequencing Technologies

## 1. Cell isolation and indexing

| Strategy | How cellular identity is retained | Strengths | Limitations | Representative methods |
|---|---|---|---|---|
| Micromanipulation or fluorescence-activated cell sorting (FACS) into plates | One cell per well; a well-specific library index or early cell barcode | Selected cells can be recovered; FACS can retain index-sorting information; flexible chemistry | Separate reactions increase handling and reagent use | Tang's method, Smart-seq2/3, CEL-Seq2[^tang][^smart2protocol][^cel2] |
| Valve-based microfluidics | Individual cells occupy separate reaction chambers | Integrated capture and reaction handling; small volumes | Chip geometry constrains suitable cell sizes; instrument and chip dependence | C1 implementations of single-cell RNA-seq[^cel2] |
| Droplet microfluidics | Cells and barcoded beads are co-encapsulated in water-in-oil droplets | Thousands of cells can be processed in parallel | Multiplets, empty droplets, ambient RNA, and loading losses | Drop-seq, inDrop, 10x droplet gene expression[^drop][^indrop][^chromium] |
| Microwell arrays | A cell and a barcoded bead share a small well | Simple devices; parallel loading; some designs permit imaging | Occupancy, cell dimensions, sealing, and transcript diffusion affect recovery | Seq-Well, Microwell-seq[^seqwell][^microwell] |
| Combinatorial indexing | Successive split–pool reactions label intact fixed cells or nuclei with a barcode combination | Large scale without isolating every cell into a separate reaction | Barcode collisions, cell loss during transfers, and fixation-dependent efficiency | sci-RNA-seq, SPLiT-seq[^sci][^split] |

For randomly loaded cells, increasing occupancy increases the probability of multiplets. **Cell recovery** is the fraction of input cells yielding usable profiles; **molecular capture efficiency** is the fraction of molecules recovered from a cell. These are different quantities. Bead loading can be engineered independently of cell loading.[^drop][^indrop][^chromium]

## 2. Development timeline

Selected milestones are listed by **first formal publication date**. A later protocol, journal issue, or updated chemistry does not reset the introduction date of the original method.

| First journal publication | Method or milestone | Technical contribution |
|---|---|---|
| 2009-04-06 | Single-cell mRNA-seq | Transcriptome sequencing from an individual mammalian cell using cDNA tailing and amplification.[^tang] |
| 2011-03-13 | Single-nucleus genome sequencing | Genome-wide copy-number profiling of individual tumor nuclei.[^navin] |
| 2011-05-04 | STRT | Early cell barcoding through template switching and multiplexed 5′-end profiling.[^strt] |
| 2012-07-22 | Smart-seq | Improved transcript-body coverage from single-cell RNA inputs.[^smart] |
| 2012-08-30 | CEL-Seq | Early barcoding and pooling followed by T7 IVT.[^celseq] |
| 2012-12-21 | MALBAC | Quasi-linear preamplification for single-cell genome sequencing.[^malbac] |
| 2013-09-22 | Smart-seq2 | Improved reverse transcription, template switching, and cDNA amplification; the detailed protocol followed on 2014-01-02.[^smart2][^smart2protocol] |
| 2013-09-25 | Single-cell Hi-C | Chromosome-contact libraries from individual cells.[^hic] |
| 2014-02-14 | MARS-seq | Automated sorting, molecular indexing, and pooled 3′ RNA counting.[^mars] |
| 2014-07-20 | scBS-seq | Genome-wide single-cell bisulfite sequencing.[^scbs] |
| 2015-04-27 | G&T-seq | Physical separation and sequencing of a cell's genome and transcriptome.[^gnt] |
| 2015-05-07 | sci-ATAC-seq | Combinatorial indexing of accessible chromatin.[^sciatac] |
| 2015-05-21 | Drop-seq and inDrop | Parallel droplet-based transcriptome barcoding.[^drop][^indrop] |
| 2015-06-17 | Microfluidic scATAC-seq | Accessible-chromatin profiling in individually isolated cells.[^atac] |
| 2016-04-28 | CEL-Seq2 | Improved sensitivity and simplified library construction for IVT-based counting.[^cel2] |
| 2017-01-16 | 10x droplet RNA profiling; MATQ-seq | Scalable gel-bead indexing and, independently, sensitive total-RNA profiling.[^chromium][^matq] |
| 2017-02-13 | Seq-Well | Membrane-sealed microwells for parallel RNA capture.[^seqwell] |
| 2017-04-14 | LIANTI | Transposon insertion coupled to linear genome amplification.[^lianti] |
| 2017-07-31 | CITE-seq | Joint RNA and antibody-derived protein measurements.[^cite] |
| 2017-08-11 | snmC-seq | Scalable single-nucleus methylome profiling.[^snmc] |
| 2017-08-18 | sci-RNA-seq | Combinatorial indexing of single-cell transcriptomes.[^sci] |
| 2017-08-28 | DroNc-seq | Droplet transcriptomics of isolated nuclei.[^dronc] |
| 2018-02-12 | RamDA-seq | Broad transcript-body coverage of polyadenylated and non-polyadenylated RNA.[^ramda] |
| 2018-02-22 | Microwell-seq; scNMT-seq | Scalable microwell RNA-seq and joint accessibility–methylation–RNA profiling.[^microwell][^scnmt] |
| 2018-03-09 | Quartz-Seq2 | Efficient conversion of sequencing reads into UMI counts.[^quartz] |
| 2018-03-15 | SPLiT-seq | Split–pool ligation barcoding of fixed cells or nuclei; the issue date is 2018-04-13.[^split] |
| 2018-07-26 | mcSCRB-seq | Molecular crowding improves plate-based RNA capture.[^mcscrb] |
| 2018-09-20 | snmC-seq2 | Improved single-nucleus methylome library quality.[^snmc2] |
| 2019-02-20 | sci-RNA-seq3 | Three-level indexing enables million-cell-scale studies.[^sci3] |
| 2019-04-22 | ECCITE-seq | Joint transcripts, proteins, clonotypes, sample tags, and CRISPR-guide readouts.[^eccite] |
| 2019-04-29 | CUT&Tag | Antibody-tethered Tn5 profiling, including a single-cell implementation.[^cuttag] |
| 2019-08-02 | Droplet scATAC-seq | Scalable gel-bead barcoding of accessible chromatin.[^chromatac] |
| 2020-05-04 | Smart-seq3 | Full-length coverage combined with 5′ UMI counting.[^smart3] |
| 2021-04-09 | TEA-seq | Joint RNA, surface epitopes, and accessibility.[^tea] |
| 2021-05-31 | scifi-RNA-seq | Combinatorial pre-indexing combined with droplet indexing.[^scifi] |
| 2021-06-03 | ASAP-seq and DOGMA-seq | Accessibility–protein and accessibility–protein–RNA measurements.[^dogma] |
| 2021-06-07 | PTA | Preferential amplification of primary genomic templates.[^pta] |
| 2022-05-30 | Smart-seq3xpress; FLASH-seq | Lower-volume full-length RNA workflows and streamlined cDNA generation.[^smart3x][^flash] |
| 2022-06-27 | VASA-seq | High-throughput, strand-specific total-RNA sequencing.[^vasa] |
| 2023-06-08 | MAS-ISO-seq | Programmed cDNA concatenation increases long-read isoform-sequencing throughput.[^masiso] |
| 2025-01-11 | inDrops-2 | Updated open droplet platform supporting IVT or template-switching/PCR workflows; the issue date is 2025-01-27.[^indrop2] |

## 3. Single-cell and single-nucleus RNA sequencing

### 3.1 Smart-seq2: full-length, plate-based RNA-seq

**Principle and workflow.** Smart-seq2 improves the Smart-seq template-switching strategy.[^smart2][^smart2protocol]

1. Isolate one cell into lysis buffer and anneal an anchored oligo(dT) primer to polyadenylated RNA.
2. Reverse-transcribe RNA with a Moloney murine leukemia virus-derived reverse transcriptase. Betaine, optimized Mg²⁺ conditions, and a TSO containing a terminal locked nucleic acid improve cDNA generation and template switching.
3. Amplify cDNA using the common sequences introduced by the oligo(dT) primer and TSO. The reverse transcriptase provides the terminal transferase activity; a separate terminal transferase is not part of this step.
4. Purify and assess amplified cDNA, then use Tn5 tagmentation to fragment it and introduce sequencing adapters.
5. Add sample indexes by PCR and pool indexed libraries for sequencing. Each cell remains separate until its identity is encoded.

**Technical features.** Transcript-body coverage; poly(A) selection; no UMI in the original chemistry; generally non-strand-specific libraries. Cell identity is normally encoded by the library index. The method accommodates selected cells in individual wells and standard multiwell formats.[^smart2protocol]

**Advantages.** Sensitive gene detection and transcript-body coverage support splice-junction analysis, expressed-variant interrogation, and reconstruction of expressed immune-receptor sequences. Off-the-shelf reagents and open chemistry permit adaptation.[^smart2]

**Limitations.** Per-cell handling and deeper sequencing requirements limit scale. PCR duplicates cannot be resolved by original-molecule UMIs; reverse-transcription bias and incomplete coverage remain. Non-polyadenylated RNA is poorly represented, and short reads cannot unambiguously resolve all isoforms.[^smart2][^smart2protocol]

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fnprot.2014.006/MediaObjects/41596_2014_Article_BFnprot2014006_Fig1_HTML.jpg" 
        alt="Smart-seq2 protocol flowchart and workflow for full-length RNA sequencing from single cells"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> Overview of the Smart-seq2 experimental protocol workflow. 
        Adapted from <a href="https://doi.org/10.1038/nprot.2014.006" target="_blank" rel="noopener noreferrer">Picelli et al. (2014)</a>, <i>Nature Protocols</i>.
    </figcaption>
</figure>

### 3.2 Smart-seq3 and Smart-seq3xpress

**Principle and workflow.** Smart-seq3 retains oligo(dT)-initiated reverse transcription and transcript-body coverage but introduces an **8 nt UMI in the TSO**. Following cDNA amplification and controlled tagmentation, libraries contain both 5′ UMI-bearing fragments and internal fragments. The former support molecular counting; the latter provide transcript-body information. Molecule reconstruction uses linked sequence information and is incomplete for many transcripts.[^smart3]

**Technical features.** Plate-based processing; poly(A) capture; 5′ UMI counting combined with internal coverage. Internal fragments do not all retain the UMI. Smart-seq3xpress miniaturizes and streamlines the workflow while retaining this design.[^smart3][^smart3x]

**Advantages.** Combines molecular counts with information on alleles and isoforms; improves sensitivity over Smart-seq2 in the original comparisons. Miniaturization reduces reagent consumption.[^smart3][^smart3x]

**Limitations.** More complex library interpretation than end-tag counting; reconstruction depends on coverage and informative sequence. Plate handling, poly(A) selection, and incomplete reverse transcription remain constraints.[^smart3]

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fs41587-020-0497-0/MediaObjects/41587_2020_497_Fig1_HTML.png" 
        alt="Experimental workflow and technical overview of biotechnology methodology"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> Overview of the experimental methodology and workflow. 
        Adapted from <a href="https://doi.org/10.1038/s41587-020-0497-0" target="_blank" rel="noopener noreferrer">Nature Biotechnology</a>.
    </figcaption>
</figure>

### 3.3 10x droplet 3′ gene expression

**Principle and workflow.** Cells, reverse-transcription reagents, and barcoded gel beads are partitioned into gel beads-in-emulsion (GEMs). Bead dissolution releases primers carrying a cell barcode, UMI, and oligo(dT). Lysis and reverse transcription occur inside GEMs. After emulsion breakage, pooled cDNA is amplified, fragmented, and converted into 3′-enriched libraries.[^chromium]

**Technical features.** Poly(A)-selected, UMI-based gene counting. The original 2017 implementation used a **14 nt cell barcode and 10 nt UMI**. Later Chromium chemistries have different barcode/read configurations; these original values must not be used to parse every 10x library.[^chromium]

**Advantages.** Parallel capture and shared reactions support large cell surveys with relatively little per-cell handling.

**Limitations.** End-tag libraries provide limited isoform information. Ambient RNA, multiplets, cell loss, and variable RNA capture affect usable profiles. Greater loading does not translate directly into proportional recovery of singlets.[^chromium]

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fncomms14049/MediaObjects/41467_2017_Article_BFncomms14049_Fig1_HTML.jpg" 
        alt="Experimental workflow and structural overview from Nature Communications study"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> Overview of the experimental workflow and methodology. 
        Adapted from <a href="https://doi.org/10.1038/ncomms14049" target="_blank" rel="noopener noreferrer">Nature Communications</a>.
    </figcaption>
</figure>

### 3.4 5′ gene expression and paired V(D)J sequencing

**Principle and workflow.** In droplet 5′ workflows, oligo(dT)-initiated reverse transcription and template switching produce cDNA carrying cellular and molecular identifiers associated with the transcript's 5′ end. Amplified cDNA is divided into gene-expression and receptor-enrichment branches. Receptor-specific constant-region primers enrich T-cell receptor (TCR) or B-cell receptor (BCR) transcripts while retaining cellular identity.[^eccite]

**Readout and strengths.** A 5′ gene-expression library provides end-tag counts; a separate V(D)J library supports receptor-contig reconstruction and pairing of expressed chains by cell barcode. Shared barcodes connect clonotypes to transcriptional states.

**Limitations.** A 5′ gene-expression library alone is not a full-length receptor library. Chain recovery depends on expression, enrichment, and sequencing coverage; doublets and multiple expressed chains complicate pairing. Antigen specificity is not directly measured by receptor sequencing.[^eccite]

### 3.5 Drop-seq

**Principle and workflow.** Single cells and oligo(dT)-coated microparticles enter droplets, where cells lyse and RNA hybridizes to bead-bound primers. **Reverse transcription occurs after emulsion breakage**, on pooled beads. Template switching, PCR, and tagmentation produce 3′-enriched libraries.[^drop]

**Technical features.** The original bead oligonucleotide contains a **12 nt cell barcode and 8 nt UMI**. The study profiled 44,808 mouse retinal cells across experiments; this is a study total, not a guaranteed single-run yield.

**Advantages.** Open methodology, inexpensive capture reagents, and parallel gene counting.

**Limitations.** Random co-loading of cells and beads wastes input material. Bead quality and microfluidic operation influence performance. Ambient RNA and multiplets remain important, and 3′ counting provides limited isoform resolution.[^drop]

### 3.6 inDrop and inDrops-2

**inDrop.** Deformable hydrogel beads carry photocleavable barcoded primers. Co-encapsulation places a cell and bead in a droplet; light releases primers for in-droplet reverse transcription. Cell barcodes, UMIs, and a T7 promoter enable pooled IVT amplification and 3′ RNA counting. High bead occupancy improves productive partitioning, but bead synthesis, photorelease, emulsion stability, and multistep IVT library preparation add complexity.[^indrop]

**inDrops-2.** The updated platform supports both IVT and template-switching/PCR branches, including preserved-cell workflows. The paper reports approximately **5,000 cells min⁻¹** processing and lower preparation costs in its own comparisons. Processing rate is not the rate of recovered, quality-filtered transcriptomes. Flexibility and lower reagent expenditure are strengths; custom microfluidics and implementation-dependent performance remain limitations.[^indrop2]

### 3.7 CEL-Seq2 and plate-based 3′ counting

**CEL-Seq2 workflow.**[^celseq][^cel2]

1. Isolate cells into wells or microfluidic chambers and reverse-transcribe poly(A) RNA using a primer containing a cell barcode, UMI, oligo(dT), and T7 promoter sequence.
2. Pool barcoded products and synthesize double-stranded cDNA containing a functional T7 promoter.
3. Amplify by IVT, fragment amplified RNA, and reverse-transcribe it again.
4. Complete sequencing adapters by PCR to obtain strand-specific 3′ counting libraries.

The published CEL-Seq2 design uses **6 nt cell barcodes and 6 nt UMIs**. Shorter primers, optimized enzymes, and removal of a ligation step improve sensitivity relative to CEL-Seq.[^cel2]

**Advantages.** Early pooling reduces per-cell library handling; UMIs support counting; IVT avoids repeated exponential amplification during the principal amplification stage.

**Limitations.** Multiple enzymatic stages can lose material, IVT increases elapsed preparation time, and end-tag sequencing gives little transcript-isoform information. IVT does not remove reverse-transcription bias.[^cel2]

Two related plate-based approaches are useful comparisons:

| Method | Principle | Advantages | Limitations |
|---|---|---|---|
| MARS-seq | FACS into wells, early molecular/cellular barcoding, pooling, T7 IVT, and 3′ counting | Links sorted-cell metadata with scalable molecular counting | Sorting and automation requirements; end-tag readout[^mars] |
| mcSCRB-seq | Barcoded oligo(dT) reverse transcription under molecular-crowding conditions, template switching, early pooling, and PCR | Sensitive, economical plate-based counting; the original reaction used 7.5% PEG 8000 | Poly(A) selection and 3′ enrichment; liquid-handling and reaction-condition dependence[^mcscrb] |

### 3.8 SPLiT-seq and sci-RNA-seq: combinatorial indexing

**SPLiT-seq workflow.** Fixed, permeabilized cells or nuclei remain intact during successive labeling reactions. A well-specific reverse-transcription barcode is followed by two split–pool ligation rounds. After lysis and sublibrary preparation, PCR introduces an additional index. Each cell is identified by its barcode combination. The original method used oligo(dT) and random primers and profiled **156,049 mouse brain/spinal-cord nuclei**.[^split]

**sci-RNA-seq workflow.** The original method combines indexed in situ reverse transcription with pooling, redistribution by sorting, second-strand synthesis/tagmentation, and PCR indexing. sci-RNA-seq3 introduces three indexing levels—reverse transcription, ligation, and PCR—and demonstrated approximately **2 million mouse embryonic cells**.[^sci][^sci3]

**Advantages.** Large barcode spaces enable high throughput without one-cell-per-well isolation. The first indexing round can encode samples, and fixed material facilitates batching.

**Limitations.** Two cells can acquire the same complete barcode combination. Fixation, permeabilization, washing, and pooling can reduce RNA recovery or selectively lose cells. The theoretical number of barcode combinations is not the usable cell capacity; loading must keep collisions acceptable.[^split][^sci][^sci3]

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fs41586-019-0969-x/MediaObjects/41586_2019_969_Fig1_HTML.png" 
        alt="Experimental workflow and structural overview from Nature publication"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> Overview of the experimental workflow and structural analysis. 
        Adapted from <a href="https://doi.org/10.1038/s41586-019-0969-x" target="_blank" rel="noopener noreferrer">Nature (2019)</a>.
    </figcaption>
</figure>

### 3.9 Microwell approaches and DNBelab C4

| Method        | Principle and representative parameters                                                                                                                                                                                                                    | Advantages                                                                | Limitations                                                                                                       |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| Seq-Well      | Cells and barcoded beads occupy subnanoliter wells. A semipermeable membrane retains macromolecules during lysis while allowing reagent exchange. Recovered beads undergo pooled reverse transcription and library preparation.                            | Portable hardware; thousands of cells per array in the original study     | Loading and membrane sealing affect recovery; primarily 3′ gene counting[^seqwell]                                |
| Microwell-seq | An agarose array with approximately 10⁵ wells receives cells and barcoded magnetic beads; captured RNA undergoes reverse transcription, amplification, and 3′ library enrichment. The original workflow loaded approximately 5,000–10,000 cells per array. | Simple fabrication and low-cost parallel processing                       | Cell/bead occupancy, bead recovery, and cell-size compatibility constrain efficiency[^microwell]                  |
| DNBelab C4    | Negative-pressure droplet generation co-encapsulates cells and barcoded RNA-capture beads. Captured RNA is reverse-transcribed after bead recovery; amplified cDNA is converted into libraries compatible with DNB sequencing.                             | Portable droplet generation; compatible with the DNB sequencing ecosystem | Cell loss, multiplets, and end-tag limitations; barcode/read layouts depend on kit version[^dnbe-preprint][^dnbe] |

The original C4 technical description is a **2019 preprint**; a peer-reviewed 2020 application documents its experimental use. Neither establishes that later C4 v2/v3 barcode structures are identical, and the preprint date is not treated as a formal-publication milestone.[^dnbe-preprint][^dnbe]

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fnmeth.4179/MediaObjects/41592_2017_Article_BFnmeth4179_Fig1_HTML.jpg" 
        alt="Experimental workflow and methodology overview from Nature Methods publication"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> Overview of the experimental workflow and methodology. 
        Adapted from <a href="https://doi.org/10.1038/nmeth.4179" target="_blank" rel="noopener noreferrer">Nature Methods</a>.
    </figcaption>
</figure>

### 3.10 Single-nucleus RNA-seq

Single-nucleus RNA-seq (snRNA-seq) describes the **input material**, not a unique library chemistry. DroNc-seq adapted droplet RNA capture to isolated nuclei and demonstrated profiles from archived mouse and human brain. Nuclear RNA permits analysis of frozen or difficult-to-dissociate tissues, but incompletely represents cytoplasmic transcripts and contains a larger contribution from intronic, incompletely processed RNA. Whole-cell and nuclear profiles therefore measure overlapping but different RNA compartments.[^dronc]

### 3.11 Additional RNA-sequencing methods

| Method | Principle | Advantages | Limitations |
|---|---|---|---|
| Tang's original mRNA-seq | Oligo(dT) reverse transcription, poly(A) tailing of first-strand cDNA, second-strand synthesis, and PCR | Established transcriptome sequencing at single-cell input | Labor-intensive; amplification and transcript-length biases; no UMI[^tang] |
| STRT | Cell barcodes introduced by template switching, followed by early pooling and 5′-end enrichment | Multiplexed transcriptional profiling | End-biased coverage; original STRT should not be conflated with later UMI-bearing variants[^strt] |
| Quartz-Seq2 | Barcoded reverse transcription followed by optimized cDNA poly(A) tailing, second-strand synthesis, amplification, and 3′ UMI counting | Efficient use of shallow sequencing | Poly(A)-selected, end-tag readout and multiwell handling[^quartz] |
| MATQ-seq | Multiple primer-annealing reactions, first-strand cDNA dC tailing, and molecular tagging | Sensitive profiling of poly(A) and non-poly(A) transcripts | Laborious chemistry and limited scale compared with droplet counting[^matq] |
| RamDA-seq | Random displacement amplification during reverse transcription with oligo(dT) and not-so-random primers | Broad coverage of poly(A) and non-poly(A) RNA, including enhancer RNA | Original implementation lacks UMIs and strand specificity; greater sequencing demand[^ramda] |
| C1 CAGE | Random-primed, template-switching cap analysis of gene expression in microfluidic chambers | Resolves transcription start sites and promoter/enhancer-associated transcription | Specialized library interpretation and limited chamber throughput[^cage] |
| scifi-RNA-seq | In situ pre-indexing followed by overloaded droplet indexing | Multiple pre-indexed nuclei can share droplets, increasing scale | Combinatorial collisions and dependence on both pre-indexing and droplet chemistry[^scifi] |
| FLASH-seq | Streamlined reverse transcription and cDNA preamplification; optional UMI implementation | Rapid full-length preparation and compatibility with miniaturization | Poly(A) dependence; molecular counting depends on the selected variant[^flash] |
| VASA-seq | RNA fragmentation, end repair, polyadenylation, barcoded reverse transcription, IVT, and rRNA depletion | Strand-specific total-RNA coverage in plate or droplet formats | Fragment identifiers count captured fragments, not necessarily intact original transcripts; rRNA depletion and complex preparation[^vasa] |
| MAS-ISO-seq | Concatenates barcoded cDNAs into long arrays for PacBio sequencing, then separates constituent transcript reads computationally | Direct isoform structures with higher long-read throughput | Requires suitable upstream cDNA and accurate barcode assignment; incomplete cDNA remains incomplete[^masiso] |

**Long-read distinction.** PacBio or nanopore sequencing can read long single-cell-derived cDNAs, but cellular identity must already be encoded or maintained by separate libraries. A long-read sequencing instrument alone does not provide single-cell resolution. MAS-ISO-seq is a library/readout extension, not a cell-isolation strategy.[^masiso]

### 3.12 RNA library-design and performance comparison

The table refers to **published implementations**. Barcode lengths describe oligonucleotide segments, not necessarily the complete FASTQ read length. Sequencing orientation and index placement must be checked against the specific chemistry.

| Published implementation | RNA coverage | Molecular identifier | Quantitative parameter or demonstrated scale |
|---|---|---|---|
| Smart-seq2 | Transcript body; poly(A) RNA | None | Separate per-cell libraries; full-length cDNA followed by short-read sequencing[^smart2protocol] |
| Smart-seq3 | Transcript body plus 5′ tags | 8 nt 5′ UMI | UMI-bearing and internal reads coexist[^smart3] |
| CEL-Seq2 | Strand-specific 3′ tags | 6 nt UMI; 6 nt CB | Approximately threefold sensitivity improvement over CEL-Seq in the original comparison[^cel2] |
| Drop-seq | 3′ tags | 8 nt UMI; 12 nt CB | 44,808 retinal cells across the original study[^drop] |
| Original 10x implementation, 2017 | 3′ tags | 10 nt UMI; 14 nt CB | Approximately 68,000 PBMCs across the demonstration dataset[^chromium] |
| SPLiT-seq | Gene counting from oligo(dT)/random-primed RNA | UMI plus combinatorial indexes | 156,049 nuclei in the mouse nervous-system study[^split] |
| sci-RNA-seq3 | Predominantly 3′ counting | UMI plus three indexing levels | Approximately 2 million embryonic cells[^sci3] |
| VASA-seq | Strand-specific transcript-body coverage | Unique fragment identifier | Labels fragmented RNA; counts are not directly interchangeable with intact-transcript UMIs[^vasa] |

Genes detected per cell, UMI counts, and saturation depend on cell type, RNA content, sample preservation, sequencing depth, and filtering. Values from different papers are not controlled head-to-head rankings. In particular, a large cell line and a small resting lymphocyte should not be expected to yield the same library complexity.[^chromium][^sci]

## 4. Single-cell DNA sequencing

Single-cell DNA sequencing measures genomic sequence or copy number directly. Unlike RNA, a diploid autosomal locus usually has only two template copies before replication. Failure to capture one allele can therefore appear as homozygosity, and an early amplification error can resemble a somatic variant. **Allelic dropout, coverage breadth, coverage uniformity, and amplification error** are distinct performance characteristics.[^malbac][^pta]

### 4.1 Whole-genome amplification: MDA, MALBAC, and PTA

**General workflow.** Isolate one cell or nucleus, lyse it, expose genomic DNA, amplify or directly tag the DNA, construct an indexed library, and sequence. Whole-genome amplification (WGA) increases material; it does not guarantee complete or unbiased genomic representation.[^navin][^pta]

| Method | Mechanism | Advantages | Limitations and technical parameters |
|---|---|---|---|
| Multiple displacement amplification (MDA) | Random primers initiate isothermal synthesis by highly processive, strand-displacing Φ29 DNA polymerase; displaced products support further priming | Long products and proofreading polymerase; broadly applicable WGA chemistry | Uneven branching amplification, chimeras, contamination sensitivity, and allelic dropout. The foundational reaction operates near 30 °C; WGA yield is not a measure of genome completeness[^mda] |
| Multiple annealing and looping-based amplification cycles (MALBAC) | Quasi-linear preamplification uses primers with common and random segments. Completed products form loops, reducing their reuse during preamplification; subsequent PCR generates sufficient material | More uniform representation than conventional MDA in the original comparison; useful for copy-number and variant measurements | PCR and preamplification errors remain. The paper reported approximately 93% genome coverage at 25× mean sequencing depth for its tested human cells, not universal recovery[^malbac] |
| Primary template-directed amplification (PTA) | Φ29-based synthesis incorporates exonuclease-resistant terminators. Shorter daughter products undergo limited reamplification, favoring synthesis from original genomic templates | Improved coverage uniformity, allelic balance, and variant detection in the original comparisons | Still subject to incomplete recovery and artifacts; relatively costly per-cell genome sequencing. The study reported greater than 95% genome capture under its tested conditions[^pta] |

**PTA workflow in practice.** Single-cell lysis and DNA preparation are followed by terminator-modulated isothermal amplification. Amplified DNA is purified, sequencing adapters/indexes are introduced, and libraries are sequenced. The mechanistic benefit is reduced propagation of daughter-template biases and errors, rather than complete elimination of amplification artifacts.[^pta]

**Interpretation of parameters.** Mean depth describes average sequencing redundancy; breadth describes how much of the genome is represented. Neither alone establishes the sensitivity for heterozygous variants. Copy-number profiling can use shallow libraries, whereas genome-wide single-nucleotide variant detection requires much more sequencing and sufficiently balanced allele recovery.[^navin][^malbac][^pta]

### 4.2 Targeted droplet single-cell DNA sequencing

**Principle and workflow.** The droplet method developed by Pellegrino et al. separates cell lysis from barcoding/amplification. Cells are first encapsulated and lysed; processed lysate droplets are then combined with barcoding reagents and target-specific PCR primers. Multiplex PCR amplifies selected genomic loci while attaching cellular indexes. Pooled amplicon sequencing recovers multilocus genotypes from individual cells.[^mission]

**Technical features.** Targeted DNA amplicons rather than a whole-genome library; the original implementation analyzed **62 targeted amplicons**, with thousands of cells processed per experiment.

**Advantages.** Concentrates sequencing on selected variants and measures their co-occurrence within cells. Higher cell numbers facilitate detection of minor clones.

**Limitations.** Variants outside the panel are missed. Primer-site variation, unequal amplicon amplification, allelic dropout, and doublets affect genotypes. These assay-specific parameters should not be generalized to every later commercial panel.[^mission]

### 4.3 Additional genome-sequencing approaches

| Method | Principle | Advantages | Limitations |
|---|---|---|---|
| Single-nucleus sequencing with degenerate-primer amplification | Flow-sort nuclei, amplify genomic material, and sequence shallowly for copy-number profiles | Resolves cellular copy-number heterogeneity | Sparse sequence representation limits comprehensive single-nucleotide variant detection[^navin] |
| LIANTI | Tn5 inserts T7-promoter-containing sequences; IVT and subsequent conversion amplify genomic fragments | Linear amplification reduces some amplification biases and permits fine-scale copy-number analysis | Multistep chemistry; incomplete locus recovery and sequencing errors remain[^lianti] |
| DLP+ | Image-guided single-cell dispensing and direct Tn5 library construction without a separate pre-library WGA step | Scalable shallow whole-genome libraries; connects cell images to genome profiles | Shallow individual libraries favor copy-number/replication measurements; library PCR is still required, and clone-level aggregation does not give deep genotypes for every cell[^dlp] |

## 5. Single-cell epigenome and chromosome-conformation sequencing

### 5.1 Single-cell ATAC-seq

**Principle.** The assay for transposase-accessible chromatin using sequencing (ATAC-seq) uses adapter-loaded Tn5 to cut and tag accessible DNA. Accessible regions are preferentially represented; protected nucleosomal DNA produces characteristic fragment-length patterns. This measures accessibility, not direct transcription-factor occupancy or RNA expression.[^atac]

**Droplet workflow.**[^chromatac]

1. Isolate nuclei and maintain their integrity while exposing chromatin to Tn5.
2. Tagment accessible DNA in bulk, retaining fragments within nuclei until cellular indexing.
3. Partition transposed nuclei with barcoded gel beads and attach a cell barcode to fragments through extension/amplification reactions.
4. Break the emulsion, complete indexed libraries, and sequence both ends of genomic fragments.

**Combinatorial alternative.** In sci-ATAC-seq, indexed transposition supplies an initial barcode; nuclei are pooled and redistributed for a second indexing step. Cells are distinguished by barcode combinations.[^sciatac]

**Technical parameters.** The 2019 droplet implementation used **16 nt cell barcodes**. Paired-end genomic coordinates identify fragments; there is no RNA-style transcript UMI. Relevant output measures include unique nuclear fragments per cell, enrichment at transcription start sites, fraction of fragments in accessible peaks, and the nucleosomal fragment-length distribution.[^chromatac]

**Advantages.** Scalable regulatory-element profiling with direct genomic localization and compatibility with isolated nuclei.

**Limitations.** Each locus has few genomic copies, so per-cell accessibility is sparse. Tn5 sequence preference, mitochondrial fragments, damaged nuclei, and multiplets affect results. Failure to observe a fragment does not prove that a locus is inaccessible.[^atac][^chromatac]

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fs41587-019-0206-z/MediaObjects/41587_2019_206_Fig1_HTML.png" 
        alt="Experimental workflow and methodology overview from Nature Biotechnology publication"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> Overview of the experimental workflow and methodology. 
        Adapted from <a href="https://doi.org/10.1038/s41587-019-0206-z" target="_blank" rel="noopener noreferrer">Nature Biotechnology</a>.
    </figcaption>
</figure>

### 5.2 DNA methylome sequencing: scBS-seq and snmC-seq2

**Principle and workflow.** Bisulfite treatment converts unmodified cytosine into uracil, read as thymine after amplification; protected modified cytosines remain cytosine. In scBS-seq, conversion precedes random-primed adapter synthesis to retain fragmented single-cell DNA. snmC-seq and snmC-seq2 adapt post-bisulfite library construction and indexing for scalable nuclear methylome profiling.[^scbs][^snmc][^snmc2]

**Technical features.** Base-resolution cytosine measurements at covered sites, with sparse and nonuniform per-cell coverage. The scBS-seq paper reported coverage of up to **48.4% of CpGs** in individual tested cells. snmC-seq2 improves mapping, library complexity, and coverage consistency relative to snmC-seq.[^scbs][^snmc2]

**Advantages.** Directly measures DNA modification patterns rather than inferring them from transcription; can assay CpG and non-CpG methylation in suitable material.

**Limitations.** Bisulfite damages DNA and reduces sequence complexity. Coverage is incomplete, and conventional bisulfite sequencing does **not distinguish 5-methylcytosine from 5-hydroxymethylcytosine**. Whole-genome methylome sequencing is more demanding than targeted gene-expression counting.[^scbs][^snmc]

### 5.3 Single-cell CUT&Tag

**Principle and workflow.** An antibody binds a chromatin protein or histone modification in permeabilized cells. Protein A–Tn5 is tethered through the antibody complex; Mg²⁺ activation inserts adapters near the target. In the original single-cell implementation, transposition was followed by dispensing individual cells into nanowells and indexed PCR.[^cuttag]

**Advantages.** Target-enriched libraries provide efficient profiling of selected chromatin features with small inputs.

**Limitations.** Signal depends on antibody specificity, epitope accessibility, target abundance, and background tagmentation. One antibody generally assays one feature; multiplexed variants require additional molecular discrimination. CUT&Tag is distinct from CUT&RUN, which uses antibody-tethered nuclease cleavage rather than Tn5 adapter insertion.[^cuttag]

### 5.4 Single-cell Hi-C

Crosslinking preserves DNA contacts; restriction digestion, end labeling, and proximity ligation generate junctions between contacting DNA fragments. Individual-cell libraries are recovered and sequenced to identify contact pairs. The method measures chromosome conformation, with sparse contacts per cell and resolution determined by informative ligation products and sequencing coverage. Crosslinking, digestion, and ligation introduce biases.[^hic]

Single-cell Hi-C is included as a sequencing assay of **intranuclear chromosome contacts**; it does not measure the positions of cells within tissue.[^hic]

## 6. Joint single-cell sequencing measurements

Joint assays preserve a shared cellular identity across experimentally measured modalities. Combining separate RNA and ATAC datasets computationally does not constitute a same-cell joint assay.[^gnt][^share]

### 6.1 CITE-seq: RNA and antibody-derived protein tags

**Principle and workflow.**[^cite]

1. Stain cells with antibodies conjugated to DNA oligonucleotides identifying each antibody target.
2. Wash away unbound antibodies and partition cells for RNA-seq.
3. Capture both polyadenylated cellular RNA and compatible antibody oligonucleotides using barcoded oligo(dT) beads.
4. Amplify and separate gene-expression and antibody-derived tag (ADT) libraries by size/targeted amplification.
5. Sequence both libraries and link measurements through the cell barcode.

**Advantages.** Combines transcriptional states with an experimentally selected protein panel; expands multiplexing beyond fluorescence-channel constraints.

**Limitations.** ADT counts measure antibody-associated tags, not absolute protein copy numbers. Antibody affinity, nonspecific binding, ambient tags, and epitope accessibility affect signal. Protein coverage is limited to the panel; the original assay emphasized cell-surface epitopes.[^cite]

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fnmeth.4380/MediaObjects/41592_2017_Article_BFnmeth4380_Fig1_HTML.jpg" 
        alt="Experimental workflow and methodology overview from Nature Methods publication"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> Overview of the experimental workflow and methodology. 
        Adapted from <a href="https://doi.org/10.1038/nmeth.4380" target="_blank" rel="noopener noreferrer">Nature Methods</a>.
    </figcaption>
</figure>

### 6.2 Joint RNA and accessibility: droplet Multiome and SHARE-seq

**Droplet Multiome workflow.** Nuclei undergo transposition while preserving RNA. A transposed nucleus is partitioned with a gel bead providing compatible oligonucleotides for RNA and accessible-DNA products. Reverse transcription and DNA indexing establish a shared cellular barcode; separate RNA and ATAC libraries are subsequently amplified and sequenced. The RNA component measures nuclear poly(A) RNA, whereas the ATAC component measures genomic fragments.[^dogma]

**Advantages.** Directly connects regulatory accessibility and transcription in the same nucleus. **Limitations.** Both modalities must survive the same preparation; poor nuclei can compromise both. Nuclear RNA differs from whole-cell RNA, and sparse paired measurements do not establish causal enhancer–gene relationships.[^dogma]

**SHARE-seq workflow.** Fixed cells/nuclei undergo chromatin transposition and RNA reverse transcription, followed by shared split–pool barcoding of DNA and cDNA. The assay separates the two molecular fractions to construct accessibility and RNA libraries. It provides scalable same-cell measurements without droplet capture, but fixation, transfer losses, combinatorial collisions, and uneven modality recovery remain constraints.[^share]

These workflows share a measurement objective but use different capture and indexing chemistries; one should not be cited as the original technical description of the other.

### 6.3 Additional joint and perturbation-linked assays

| Method               | Joint readout and principle                                                                                                                                                              | Advantages                                                                 | Limitations                                                                      |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| G&T-seq              | Capture poly(A) RNA on oligo(dT) beads; separate genomic DNA; apply RNA-seq and WGA independently                                                                                        | Connects genotype and transcriptome with flexible downstream chemistries   | Physical separation can lose material; WGA and RNA biases remain[^gnt]           |
| scNMT-seq            | GpC methyltransferase marks accessible DNA; RNA capture and bisulfite sequencing jointly measure transcription, endogenous CpG methylation, and accessibility-associated GpC methylation | Three linked molecular layers without treating ATAC as a methylation assay | Sparse coverage, overlapping cytosine contexts, and complex preparation[^scnmt]  |
| sci-CAR              | Combinatorial indexing jointly labels reverse-transcribed RNA and Tn5-tagged accessible DNA                                                                                              | Scalable two-modality measurements                                         | Low per-cell coverage and barcode collisions[^scicar]                            |
| SNARE-seq            | Droplets co-capture RNA and tagmented DNA using compatible capture/splint oligonucleotides                                                                                               | Shared barcodes link RNA and accessibility at scale                        | Efficient recovery of both molecule classes is technically demanding[^snare]     |
| REAP-seq             | DNA-barcoded antibodies and RNA libraries supply paired protein/transcript measurements                                                                                                  | Multiplexed phenotyping                                                    | Antibody-panel and binding-specificity limitations[^reap]                        |
| ECCITE-seq           | Extends 5′ sequencing to protein/sample tags, clonotypes, and directly captured guide RNAs                                                                                               | Connects perturbations or clonotypes with cellular phenotype               | Several library types and capture efficiencies require coordination[^eccite]     |
| TEA-seq              | Permeabilized-cell workflow jointly captures transcripts, surface epitopes, and accessible chromatin                                                                                     | Three modalities retain a common cell identity                             | Permeabilization must preserve RNA, chromatin, and surface-associated tags[^tea] |
| ASAP-seq / DOGMA-seq | ASAP-seq pairs accessibility and antibody tags; DOGMA-seq adds RNA using a compatible multimodal workflow                                                                                | Combines regulatory and protein information, with an RNA extension         | Modality-specific capture biases and antibody dependence[^dogma]                 |

<figure style="text-align: center; margin: 2rem 0;">
    <img 
        src="https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fs41467-018-03149-4/MediaObjects/41467_2018_3149_Fig1_HTML.jpg" 
        alt="Experimental workflow and methodology overview from Nature Communications publication"
        style="max-width: 100%; height: auto; border-radius: 4px;"
        loading="lazy"
    >
    <figcaption style="font-size: 0.9rem; color: #555; margin-top: 0.5rem;">
        <strong>Figure.</strong> Overview of the experimental workflow and methodology. 
        Adapted from <a href="https://doi.org/10.1038/s41467-018-03149-4" target="_blank" rel="noopener noreferrer">Nature Communications (2018)</a>.
    </figcaption>
</figure>

## 7. Original papers and author protocols

References below are primary research publications or original author protocols. The C4 technical preprint is explicitly identified and excluded from formal-publication dating.

[^tang]: Tang F et al. (2009). mRNA-Seq whole-transcriptome analysis of a single cell. *Nature Methods*. [Original paper](https://doi.org/10.1038/nmeth.1315).
[^navin]: Navin N et al. (2011). Tumour evolution inferred by single-cell sequencing. *Nature*. [Original paper](https://doi.org/10.1038/nature09807).
[^strt]: Islam S et al. (2011). Characterization of the single-cell transcriptional landscape by highly multiplex RNA-seq. *Genome Research*. [Original paper](https://doi.org/10.1101/gr.110882.110).
[^smart]: Ramsköld D et al. (2012). Full-length mRNA-Seq from single-cell levels of RNA and individual circulating tumor cells. *Nature Biotechnology*. [Original paper](https://doi.org/10.1038/nbt.2282).
[^celseq]: Hashimshony T et al. (2012). CEL-Seq: single-cell RNA-Seq by multiplexed linear amplification. *Cell Reports*. [Original paper](https://doi.org/10.1016/j.celrep.2012.08.003).
[^malbac]: Zong C et al. (2012). Genome-wide detection of single-nucleotide and copy-number variations of a single human cell. *Science*. [Original paper](https://doi.org/10.1126/science.1229164).
[^smart2]: Picelli S et al. (2013). Smart-seq2 for sensitive full-length transcriptome profiling in single cells. *Nature Methods*. [Original paper](https://doi.org/10.1038/nmeth.2639).
[^smart2protocol]: Picelli S et al. (2014). Full-length RNA-seq from single cells using Smart-seq2. *Nature Protocols*. [Author protocol](https://doi.org/10.1038/nprot.2014.006).
[^hic]: Nagano T et al. (2013). Single-cell Hi-C reveals cell-to-cell variability in chromosome structure. *Nature*. [Original paper](https://doi.org/10.1038/nature12593).
[^mars]: Jaitin DA et al. (2014). Massively parallel single-cell RNA-seq for marker-free decomposition of tissues into cell types. *Science*. [Original paper](https://doi.org/10.1126/science.1247651).
[^scbs]: Smallwood SA et al. (2014). Single-cell genome-wide bisulfite sequencing for assessing epigenetic heterogeneity. *Nature Methods*. [Original paper](https://doi.org/10.1038/nmeth.3035).
[^gnt]: Macaulay IC et al. (2015). G&T-seq: parallel sequencing of single-cell genomes and transcriptomes. *Nature Methods*. [Original paper](https://doi.org/10.1038/nmeth.3370).
[^sciatac]: Cusanovich DA et al. (2015). Multiplex single-cell profiling of chromatin accessibility by combinatorial cellular indexing. *Science*. [Original paper](https://doi.org/10.1126/science.aab1601).
[^drop]: Macosko EZ et al. (2015). Highly parallel genome-wide expression profiling of individual cells using nanoliter droplets. *Cell*. [Original paper](https://doi.org/10.1016/j.cell.2015.05.002).
[^indrop]: Klein AM et al. (2015). Droplet barcoding for single-cell transcriptomics applied to embryonic stem cells. *Cell*. [Original paper](https://doi.org/10.1016/j.cell.2015.04.044).
[^atac]: Buenrostro JD et al. (2015). Single-cell chromatin accessibility reveals principles of regulatory variation. *Nature*. [Original paper](https://doi.org/10.1038/nature14590).
[^cel2]: Hashimshony T et al. (2016). CEL-Seq2: sensitive highly-multiplexed single-cell RNA-Seq. *Genome Biology*. [Original paper](https://doi.org/10.1186/s13059-016-0938-8).
[^chromium]: Zheng GXY et al. (2017). Massively parallel digital transcriptional profiling of single cells. *Nature Communications*. [Original paper](https://doi.org/10.1038/ncomms14049).
[^matq]: Sheng K et al. (2017). Effective detection of variation in single-cell transcriptomes using MATQ-seq. *Nature Methods*. [Original paper](https://doi.org/10.1038/nmeth.4145).
[^seqwell]: Gierahn TM et al. (2017). Seq-Well: portable, low-cost RNA sequencing of single cells at high throughput. *Nature Methods*. [Original paper](https://doi.org/10.1038/nmeth.4179).
[^lianti]: Chen C et al. (2017). Single-cell whole-genome analyses by Linear Amplification via Transposon Insertion (LIANTI). *Science*. [Original paper](https://doi.org/10.1126/science.aak9787).
[^cite]: Stoeckius M et al. (2017). Simultaneous epitope and transcriptome measurement in single cells. *Nature Methods*. [Original paper](https://doi.org/10.1038/nmeth.4380).
[^snmc]: Luo C et al. (2017). Single-cell methylomes identify neuronal subtypes and regulatory elements in mammalian cortex. *Science*. [Original paper](https://doi.org/10.1126/science.aan3351).
[^sci]: Cao J et al. (2017). Comprehensive single-cell transcriptional profiling of a multicellular organism. *Science*. [Original paper](https://doi.org/10.1126/science.aam8940).
[^dronc]: Habib N et al. (2017). Massively parallel single-nucleus RNA-seq with DroNc-seq. *Nature Methods*. [Original paper](https://doi.org/10.1038/nmeth.4407).
[^reap]: Peterson VM et al. (2017). Multiplexed quantification of proteins and transcripts in single cells. *Nature Biotechnology*. [Original paper](https://doi.org/10.1038/nbt.3973).
[^ramda]: Hayashi T et al. (2018). Single-cell full-length total RNA sequencing uncovers dynamics of recursive splicing and enhancer RNAs. *Nature Communications*. [Original paper](https://doi.org/10.1038/s41467-018-02866-0).
[^microwell]: Han X et al. (2018). Mapping the Mouse Cell Atlas by Microwell-Seq. *Cell*. [Original paper](https://doi.org/10.1016/j.cell.2018.02.001).
[^scnmt]: Clark SJ et al. (2018). scNMT-seq enables joint profiling of chromatin accessibility DNA methylation and transcription in single cells. *Nature Communications*. [Original paper](https://doi.org/10.1038/s41467-018-03149-4).
[^quartz]: Sasagawa Y et al. (2018). Quartz-Seq2: a high-throughput single-cell RNA-sequencing method that effectively uses limited sequence reads. *Genome Biology*. [Original paper](https://doi.org/10.1186/s13059-018-1407-3).
[^split]: Rosenberg AB et al. (2018). Single-cell profiling of the developing mouse brain and spinal cord with split-pool barcoding. *Science*. [Original paper](https://doi.org/10.1126/science.aam8999).
[^mcscrb]: Bagnoli JW et al. (2018). Sensitive and powerful single-cell RNA sequencing using mcSCRB-seq. *Nature Communications*. [Original paper](https://doi.org/10.1038/s41467-018-05347-6).
[^mission]: Pellegrino M et al. (2018). High-throughput single-cell DNA sequencing of acute myeloid leukemia tumors with droplet microfluidics. *Genome Research*. [Original paper](https://doi.org/10.1101/gr.232272.117).
[^scicar]: Cao J et al. (2018). Joint profiling of chromatin accessibility and gene expression in thousands of single cells. *Science*. [Original paper](https://doi.org/10.1126/science.aau0730).
[^snmc2]: Luo C et al. (2018). Robust single-cell DNA methylome profiling with snmC-seq2. *Nature Communications*. [Original paper](https://doi.org/10.1038/s41467-018-06355-2).
[^cage]: Kouno T et al. (2019). C1 CAGE detects transcription start sites and enhancer activity at single-cell resolution. *Nature Communications*. [Original paper](https://doi.org/10.1038/s41467-018-08126-5).
[^sci3]: Cao J et al. (2019). The single-cell transcriptional landscape of mammalian organogenesis. *Nature*. [Original paper](https://doi.org/10.1038/s41586-019-0969-x).
[^eccite]: Mimitou EP et al. (2019). Multiplexed detection of proteins, transcriptomes, clonotypes and CRISPR perturbations in single cells. *Nature Methods*. [Original paper](https://doi.org/10.1038/s41592-019-0392-0).
[^cuttag]: Kaya-Okur HS et al. (2019). CUT&Tag for efficient epigenomic profiling of small samples and single cells. *Nature Communications*. [Original paper](https://doi.org/10.1038/s41467-019-09982-5).
[^chromatac]: Satpathy AT et al. (2019). Massively parallel single-cell chromatin landscapes of human immune cell development and intratumoral T cell exhaustion. *Nature Biotechnology*. [Original paper](https://doi.org/10.1038/s41587-019-0206-z).
[^snare]: Chen S et al. (2019). High-throughput sequencing of the transcriptome and chromatin accessibility in the same cell. *Nature Biotechnology*. [Original paper](https://doi.org/10.1038/s41587-019-0290-0).
[^dlp]: Laks E et al. (2019). Clonal decomposition and DNA replication states defined by scaled single-cell genome sequencing. *Cell*. [Original paper](https://doi.org/10.1016/j.cell.2019.10.026).
[^dnbe-preprint]: Liu C et al. (2019). A portable and cost-effective microfluidic system for massively parallel single-cell transcriptome profiling. *bioRxiv*, **preprint; not a formal journal publication**. [Original technical description](https://doi.org/10.1101/818450).
[^smart3]: Hagemann-Jensen M et al. (2020). Single-cell RNA counting at allele and isoform resolution using Smart-seq3. *Nature Biotechnology*. [Original paper](https://doi.org/10.1038/s41587-020-0497-0).
[^dnbe]: Zhu L et al. (2020). Single-cell sequencing of peripheral mononuclear cells reveals distinct immune response landscapes of COVID-19 and influenza patients. *Immunity*. [Original experimental study using C4](https://doi.org/10.1016/j.immuni.2020.07.009).
[^share]: Ma S et al. (2020). Chromatin potential identified by shared single-cell profiling of RNA and chromatin. *Cell*. [Original paper](https://doi.org/10.1016/j.cell.2020.09.056).
[^tea]: Swanson E et al. (2021). Simultaneous trimodal single-cell measurement of transcripts, epitopes, and chromatin accessibility using TEA-seq. *eLife*. [Original paper](https://doi.org/10.7554/eLife.63632).
[^scifi]: Datlinger P et al. (2021). Ultra-high-throughput single-cell RNA sequencing and perturbation screening with combinatorial fluidic indexing. *Nature Methods*. [Original paper](https://doi.org/10.1038/s41592-021-01153-z).
[^dogma]: Mimitou EP et al. (2021). Scalable, multimodal profiling of chromatin accessibility, gene expression and protein levels in single cells. *Nature Biotechnology*. [Original paper](https://doi.org/10.1038/s41587-021-00927-2).
[^pta]: Gonzalez-Pena V et al. (2021). Accurate genomic variant detection in single cells with primary template-directed amplification. *PNAS*. [Original paper](https://doi.org/10.1073/pnas.2024176118).
[^smart3x]: Hagemann-Jensen M et al. (2022). Scalable single-cell RNA sequencing from full transcripts with Smart-seq3xpress. *Nature Biotechnology*. [Original paper](https://doi.org/10.1038/s41587-022-01311-4).
[^flash]: Hahaut V et al. (2022). Fast and highly sensitive full-length single-cell RNA sequencing using FLASH-seq. *Nature Biotechnology*. [Original paper](https://doi.org/10.1038/s41587-022-01312-3).
[^vasa]: Salmen F et al. (2022). High-throughput total RNA sequencing in single cells using VASA-seq. *Nature Biotechnology*. [Original paper](https://doi.org/10.1038/s41587-022-01361-8).
[^masiso]: Al'Khafaji AM et al. (2023). High-throughput RNA isoform sequencing using programmed cDNA concatenation. *Nature Biotechnology*. [Original paper](https://doi.org/10.1038/s41587-023-01815-7).
[^indrop2]: Juzenas S et al. (2025). inDrops-2: a flexible, versatile and cost-efficient droplet microfluidic approach for high-throughput scRNA-seq of fresh and preserved clinical samples. *Nucleic Acids Research*. [Original paper](https://doi.org/10.1093/nar/gkae1312).
[^mda]: Dean FB et al. (2002). Comprehensive human genome amplification using multiple displacement amplification. *PNAS*. [Foundational WGA paper](https://doi.org/10.1073/pnas.082089499).
