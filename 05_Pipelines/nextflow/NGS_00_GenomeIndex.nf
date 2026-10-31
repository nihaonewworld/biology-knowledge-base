nextflow.enable.dsl=2

params.genome_dir       = params.genome_dir       ?: "${System.getProperty('user.home')}/reference/Homo_sapiens/hg38"
params.genome_fasta     = params.genome_fasta     ?: "${params.genome_dir}/GRCh38.primary_assembly.genome.fa"
params.genome_gtf       = params.genome_gtf       ?: "${params.genome_dir}/gencode.v48.annotation.gtf"
params.transcript_fasta = params.transcript_fasta ?: "${params.genome_dir}/gencode.v48.transcripts.fa"
params.ncrna_fasta      = params.ncrna_fasta      ?: "${params.genome_dir}/Homo_sapiens.GRCh38.ncrna.fa"
params.index_dir        = params.index_dir        ?: "${params.genome_dir}/index"
params.star_overhang    = params.star_overhang    ?: 149
params.salmon_k         = params.salmon_k         ?: 31

workflow {
    def genome_fasta_ch     = Channel.value(file(params.genome_fasta))
    def genome_gtf_ch       = Channel.value(file(params.genome_gtf))
    def transcript_fasta_ch = Channel.value(file(params.transcript_fasta))
    def ncrna_fasta_ch      = Channel.value(file(params.ncrna_fasta))

    def rrna_ch = EXTRACT_RRNA(ncrna_fasta_ch)
    rrna_ch.into { rrna_for_bt2; rrna_for_bt1 }

    BOWTIE2_GENOME(genome_fasta_ch)
    BOWTIE2_NCRNA(ncrna_fasta_ch)
    BOWTIE2_RRNA(rrna_for_bt2)
    BOWTIE1_RRNA(rrna_for_bt1)
    BWA_INDEX(genome_fasta_ch)
    BISMARK_INDEX(genome_fasta_ch)
    STAR_INDEX(genome_fasta_ch, genome_gtf_ch)
    HISAT2_INDEX(genome_fasta_ch, genome_gtf_ch)
    SALMON_INDEX(transcript_fasta_ch)
    KALLISTO_INDEX(transcript_fasta_ch)
}

process EXTRACT_RRNA {
    label 'small'
    input:
        path ncrna_fasta
    output:
        path 'rrna.fa'
    script:
        """
        mkdir -p "${params.index_dir}"
        seqkit grep -n -r -p "gene_biotype:rRNA" -o rrna.fa "$ncrna_fasta"
        cp rrna.fa "${params.index_dir}/rrna.fa"
        """
}

process BOWTIE2_GENOME {
    label 'medium'
    input:
        path genome_fasta
    output:
        path 'bowtie2_genome.done'
    script:
        """
        mkdir -p "${params.index_dir}/bowtie2_index"
        bowtie2-build --threads ${task.cpus} "$genome_fasta" "${params.index_dir}/bowtie2_index/genome" \
            > "${params.index_dir}/bowtie2_index.log" 2>&1
        touch bowtie2_genome.done
        """
}

process BOWTIE2_NCRNA {
    label 'medium'
    input:
        path ncrna_fasta
    output:
        path 'bowtie2_ncrna.done'
    script:
        """
        mkdir -p "${params.index_dir}/bowtie2_index"
        bowtie2-build --threads ${task.cpus} "$ncrna_fasta" "${params.index_dir}/bowtie2_index/ncrna" \
            > "${params.index_dir}/bowtie2_index_ncRNA.log" 2>&1
        touch bowtie2_ncrna.done
        """
}

process BOWTIE2_RRNA {
    label 'medium'
    input:
        path rrna_fasta
    output:
        path 'bowtie2_rrna.done'
    script:
        """
        mkdir -p "${params.index_dir}/bowtie2_index"
        bowtie2-build --threads ${task.cpus} "$rrna_fasta" "${params.index_dir}/bowtie2_index/rrna" \
            > "${params.index_dir}/bowtie2_index_rRNA.log" 2>&1
        touch bowtie2_rrna.done
        """
}

process BOWTIE1_RRNA {
    label 'small'
    input:
        path rrna_fasta
    output:
        path 'bowtie1_rrna.done'
    script:
        """
        mkdir -p "${params.index_dir}/bowtie_index"
        bowtie-build --threads ${task.cpus} "$rrna_fasta" "${params.index_dir}/bowtie_index/rrna" \
            > "${params.index_dir}/bowtie_index_rRNA.log" 2>&1
        touch bowtie1_rrna.done
        """
}

process BWA_INDEX {
    label 'large'
    input:
        path genome_fasta
    output:
        path 'bwa_index.done'
    script:
        """
        mkdir -p "${params.index_dir}/bwa_index"
        bwa index -a bwtsw "$genome_fasta" -p "${params.index_dir}/bwa_index/genome" \
            > "${params.index_dir}/bwa_index.log" 2>&1
        touch bwa_index.done
        """
}

process BISMARK_INDEX {
    label 'medium'
    input:
        path genome_fasta
    output:
        path 'bismark_index.done'
    script:
        """
        mkdir -p "${params.index_dir}/bismark_index"
        ln -sf "$genome_fasta" "${params.index_dir}/bismark_index/genome.fa"
        bismark_genome_preparation --parallel ${task.cpus} --bowtie2 \
            --genomic_composition --verbose "${params.index_dir}/bismark_index" \
            > "${params.index_dir}/bismark_index.log" 2>&1
        touch bismark_index.done
        """
}

process STAR_INDEX {
    label 'large'
    input:
        path genome_fasta
        path genome_gtf
    output:
        path 'star_index.done'
    script:
        """
        mkdir -p "${params.index_dir}/star_index"
        STAR --runMode genomeGenerate --runThreadN ${task.cpus} \
            --genomeFastaFiles "$genome_fasta" \
            --sjdbGTFfile "$genome_gtf" \
            --sjdbOverhang ${params.star_overhang} \
            --genomeDir "${params.index_dir}/star_index" \
            > "${params.index_dir}/star_index.log" 2>&1
        touch star_index.done
        """
}

process HISAT2_INDEX {
    label 'large'
    input:
        path genome_fasta
        path genome_gtf
    output:
        path 'hisat2_index.done'
    script:
        """
        mkdir -p "${params.index_dir}/hisat2_index"
        hisat2_extract_splice_sites.py "$genome_gtf" > "${params.index_dir}/hisat2_index/extract_splice_sites.ss"
        hisat2_extract_exons.py "$genome_gtf" > "${params.index_dir}/hisat2_index/extract_exons.exon"
        hisat2-build -p ${task.cpus} \
            --ss "${params.index_dir}/hisat2_index/extract_splice_sites.ss" \
            --exon "${params.index_dir}/hisat2_index/extract_exons.exon" \
            "$genome_fasta" "${params.index_dir}/hisat2_index/genome" \
            > "${params.index_dir}/hisat2_index.log" 2>&1
        touch hisat2_index.done
        """
}

process SALMON_INDEX {
    label 'small'
    input:
        path transcript_fasta
    output:
        path 'salmon_index.done'
    script:
        """
        mkdir -p "${params.index_dir}/salmon_index"
        salmon index -p ${task.cpus} -k ${params.salmon_k} -t "$transcript_fasta" --gencode \
            -i "${params.index_dir}/salmon_index" \
            > "${params.index_dir}/salmon_index.log" 2>&1
        touch salmon_index.done
        """
}

process KALLISTO_INDEX {
    label 'small'
    input:
        path transcript_fasta
    output:
        path 'kallisto_index.done'
    script:
        """
        mkdir -p "${params.index_dir}/kallisto_index"
        kallisto index -t ${task.cpus} \
            -i "${params.index_dir}/kallisto_index/transcriptome" \
            "$transcript_fasta" > "${params.index_dir}/kallisto_index.log" 2>&1
        touch kallisto_index.done
        """
}