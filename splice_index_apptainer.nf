#!/vcu_gpfs2/home/nej_lab/kameron_bin/nextflow

/*
 * Starting with a raw fastq aligns against reference inclusion and exclusion sequences using Hisat2
 * Counts reads for inclusion and exclusion products with samtools
 * Calculates Splice Index scores using normalized 95th percentile and median control
 */


/*
 * Defines parameters 
 */

params.reads = null
params.genome_dir = null
params.out_dir = null
params.norms = null

/*
 * Create channel for reads and check that they exist
 */
 Channel 
	.fromFilePairs(params.reads)
	.ifEmpty {error "Cannot find reads matching: ${params.reads}"}
	.set {reads_hisat}

/*
 * Algin reads using Hisat2 and bash 
 */
process Hisat2{
        queue 'cpu-large'
	executor 'slurm'
    clusterOptions '--export=ALL'
    tag "$sampleId"
	publishDir "${params.out_dir}/sam", mode: 'copy'
	
	input:

		tuple sampleId, file (reads) from reads_hisat

	output:

		file "*.sam" into sam_files

	script:
		
		"""
		module load apptainer
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
		/path/to/splice_index.sif hisat2 -x ${params.genome_dir}  -q -1 ${reads[0]}   -2 ${reads[1]}  --no-spliced-alignment --no-softclip   -S ${sampleId}.sam
		"""
}

/*
 * Use samtools and bash to count inclusion and exclusion products 
 */
process Counts{
	executor 'slurm'
    clusterOptions ''
    tag "$sampleId"
	publishDir "${params.out_dir}/counts", mode: 'copy'

	input:

		file (sam) from sam_files

	output:

		file "*.txt" into count_files

	script:
		sampleId = sam[0].toString().split("_")[0]
		"""
		module load apptainer
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
		/path/splice_index.sif samtools view -F 256 $sam | cut -f 3 | sort | uniq -c | sed 's@^\\s*@@' > ${sampleId}_counts.txt
		"""
}

/*
 * Use python script to calculate Masseq scores
 */
process score{
	executor 'slurm'
    clusterOptions ''
	publishDir "${params.out_dir}/score", mode: 'copy'

	input:

		file (counts) from count_files.collect()
	output:

		file '*.csv' into scores

	script:
		count_list = counts.join(",")
		"""
		module load apptainer
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
		 /path/to/splice_index.sif python3 /path/to/si_calc.py -f $count_list -n ${params.norms}
		"""





}

