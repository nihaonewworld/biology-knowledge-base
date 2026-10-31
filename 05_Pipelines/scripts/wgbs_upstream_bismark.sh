input_dir=01_fastq
output_dir=02_output

prefix="mESC_Tet1_WT_rep1"
bismark_index="mm10_gencode"

mkdir -p ${output_dir}/02_clean
mkdir -p ${output_dir}/logs

trim_galore --cores 6 --paired --phred33 --gzip \
    -q 20 --stringency 1 -e 0.1 --length 20 \
    --basename ${prefix} -o ${output_dir}/02_clean \
    ${input_dir}/${prefix}_R1.fq.gz \
    ${input_dir}/${prefix}_R2.fq.gz \
    &> ${output_dir}/logs/trim_galore.${prefix}.log

mv ${output_dir}/02_clean/${prefix}_val_1.fq.gz ${output_dir}/02_clean/${prefix}_R1.fq.gz
mv ${output_dir}/02_clean/${prefix}_val_2.fq.gz ${output_dir}/02_clean/${prefix}_R2.fq.gz

mkdir -p ${output_dir}/03_align

bismark --parallel 12 --bowtie2 --bam --nucleotide_coverage \
    --genome ${bismark_index} \
    --temp_dir ${output_dir}/03_align \
    -1 ${output_dir}/02_clean/${prefix}_R1.fq.gz \
    -2 ${output_dir}/02_clean/${prefix}_R2.fq.gz \
    -o ${output_dir}/03_align \
    &> ${output_dir}/logs/bismark_align.${prefix}.log

# mESC_Tet1_WT_rep1_R1_bismark_bt2_pe.bam
# mESC_Tet1_WT_rep1_R1_bismark_bt2_pe.nucleotide_stats.txt
# mESC_Tet1_WT_rep1_R1_bismark_bt2_PE_report.txt

for file in ${output_dir}/03_align/${prefix}*bismark_bt2*
do
    new=$(sed -E 's/_R1//' <<< "$file")
    mv "$file" $new
done

# mESC_Tet1_WT_rep1_bismark_bt2_pe.bam
# mESC_Tet1_WT_rep1_bismark_bt2_pe.nucleotide_stats.txt
# mESC_Tet1_WT_rep1_bismark_bt2_PE_report.txt

deduplicate_bismark --bam --output_dir ${output_dir}/03_align \
    -o ${prefix} ${output_dir}/03_align/${prefix}_bismark_bt2_pe.bam \
    &> ${output_dir}/logs/bismark_rmdup.${prefix}.log

# mESC_Tet1_WT_rep1.deduplicated.bam
# mESC_Tet1_WT_rep1.deduplication_report.txt

mkdir -p ${output_dir}/04_bismark

bismark_methylation_extractor --parallel 6 --paired-end \
    --comprehensive --no_overlap --bedGraph --gzip --buffer_size 60G \
    --genome_folder ${bismark_index} \
    -o ${output_dir}/04_bismark ${output_dir}/03_align/${prefix}.deduplicated.bam \
    &> ${output_dir}/logs/bismark_extractor.${prefix}.log

# CHG_context_mESC_Tet1_WT_rep1.deduplicated.txt.gz
# CHH_context_mESC_Tet1_WT_rep1.deduplicated.txt.gz
# CpG_context_mESC_Tet1_WT_rep1.deduplicated.txt.gz
# mESC_Tet1_WT_rep1.deduplicated.bedGraph.gz
# mESC_Tet1_WT_rep1.deduplicated.bismark.cov.gz
# mESC_Tet1_WT_rep1.deduplicated.M-bias.txt
# mESC_Tet1_WT_rep1.deduplicated_splitting_report.txt

for file in ${output_dir}/04_bismark/*${prefix}*
do
    new=$(sed -E 's/\.deduplicated//; s/_bismark_bt2_pe//' <<< "$file")
    mv "$file" $new
done

# CHG_context_mESC_Tet1_WT_rep1.txt.gz
# CHH_context_mESC_Tet1_WT_rep1.txt.gz
# CpG_context_mESC_Tet1_WT_rep1.txt.gz
# mESC_Tet1_WT_rep1.bedGraph.gz
# mESC_Tet1_WT_rep1.bismark.cov.gz
# mESC_Tet1_WT_rep1.M-bias.txt
# mESC_Tet1_WT_rep1_splitting_report.txt

coverage2cytosine --merge_CpG --gzip \
    --genome_folder ${bismark_index} \
    --dir ${output_dir}/04_bismark -o ${prefix} \
    ${output_dir}/04_bismark/${prefix}.bismark.cov.gz \
    &> ${output_dir}/logs/bismark_mergeCpG.${prefix}.log

# mESC_Tet1_WT_rep1.CpG_report.merged_CpG_evidence.cov.gz
# mESC_Tet1_WT_rep1.CpG_report.txt.gz
# mESC_Tet1_WT_rep1.cytosine_context_summary.txt

bismark2bedGraph --CX --buffer_size 60G \
    -o ${prefix}.CHG \
    --dir ${output_dir}/04_bismark \
    ${output_dir}/04_bismark/CHG_context_${prefix}.txt.gz \
    &> ${output_dir}/logs/bismark2bedGraph_CHG.${prefix}.log

# mESC_Tet1_WT_rep1.CHG.gz
# mESC_Tet1_WT_rep1.CHG.gz.bismark.cov.gz

bismark2bedGraph --CX --buffer_size 60G \
    -o ${prefix}.CHH \
    --dir ${output_dir}/04_bismark \
    ${output_dir}/04_bismark/CHH_context_${prefix}.txt.gz \
    &> ${output_dir}/logs/bismark2bedGraph_CHH.${prefix}.log

# mESC_Tet1_WT_rep1.CHH.gz
# mESC_Tet1_WT_rep1.CHH.gz.bismark.cov.gz
