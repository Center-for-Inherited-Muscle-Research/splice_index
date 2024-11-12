#! /bin/bash
#
#SBATCH --job-name rna_pipe
#SBATCH --output splice_index."%j".out
#SBATCH --error splice_index."%j".err
#SBATCH --mail-user $user.email
#SBATCH --mail-type=ALL
#SBATCH --partition cpu
#SBATCH --mem 15G
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1

# ©2023, Virginia Commonwealth University, MDTRP, Kameron Bates, Kobe Ikegami

module load miniconda3
conda activate splice_index
/path/to/nextflow run /path/to/splice_index.nf \
 --reads "/path/to/read_dir/*_R{1,2}.fastq.gz" \
 --genome_dir "path/to/genome_dir/genome_prefix" \
 --out_dir "/path/to/outdir" \
 --norms "/path/to/nej_norms_02jul2024.xlsx"


