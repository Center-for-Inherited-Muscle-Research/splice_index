#!/bin/bash
#
#SBATCH --job-name=si_nf
##SBATCH --output=$HOME/path/to/slurm_logs/mass_nf_%j.out
##SBATCH --error=$HOME/path/to/slurm_logs/mass_nf_%j.err
##SBATCH --mail-type=FAIL
##SBATCH --mail-user=<user_email>
#SBATCH --mem=20G
#SBATCH --time=24:00:00

# ©2023, Virginia Commonwealth University, MDTRP, Kameron Bates, Kobe Ikegami

# Working on Athena Feb 28th, 2024 - James Percy

module load apptainer

export NXF_VER=19.10.0

singularity exec \
--env SLURM_CONF=/etc/slurm/slurm.conf \
--bind /etc/passwd,/etc/group \
--bind /etc/slurm/ \
--bind /lib64/libslurmfull-22.05.9.so:/usr/lib/x86_64-linux-gnu/libslurmfull-22.05.9.so \
--bind /bin/sbatch \
--bind /usr/lib64/slurm/ \
--bind /lib64/libmunge.so.2:/usr/lib/x86_64-linux-gnu/libmunge.so.2 \
--bind /lib64/libgfortran.so.5:/usr/lib/x86_64-linux-gnu/libgfortran.so.5 \
--bind /lib64/libquadmath.so.0:/usr/lib/x86_64-linux-gnu/libquadmath.so.0 \
--bind /run/munge \
/path/to/splice_index.sif nextflow run  /path/to/splice_index.nf \
 --reads "/path/to/read_dir/*_R{1,2}.fastq.gz" \
 --genome_dir "path/to/genome_dir/genome_prefix" \
 --out_dir "/path/to/output_dir" \
 --norms "/path/to/normalized_values.xlsx"

