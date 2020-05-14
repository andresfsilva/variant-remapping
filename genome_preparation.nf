#!/usr/bin/env nextflow

def helpMessage() {
    log.info"""
    Index the provided genome with bowtie and samtools
    Usage:
            --fasta                     Fasta file containing the reference genome.
            --outdir                    Directory where the index will be deployed.
    """
}

// Show help message
if (params.help) exit 0, helpMessage()

params.fasta  = "$baseDir/resources/genome.fa"
params.outdir = "$baseDir/resources/"


basename = file(params.fasta).getName()

/*
 * Index the provided reference genome using bowtie build
 */
process bowtieGenomeIndex {

    publishDir params.outdir,
        overwrite: false,
        mode: "move"

    input:
        path "genome_fasta" from params.fasta

    output:
        path "$basename.*.bt2"

    """
    bowtie2-build genome_fasta $basename
    """
}


/*
 * Index the provided reference genome using samtools faidx
 */
process samtoolsFaidx {

    publishDir params.outdir,
        overwrite: false,
        mode: "copy"

    input:
        path "$basename" from params.fasta

    output:
        path "${basename}.fai" into genome_fai

    """
    samtools faidx $basename
    """
}

/*
 * Extract chomosome/contig sizes
 */
process chromSizes {

    publishDir params.outdir,
        overwrite: false,
        mode: "copy"

    input:
        path "${basename}.fai" from genome_fai

    output:
        path "${basename}.chrom.sizes" into chrom_sizes

    """
    cut -f1,2 ${basename}.fai > ${basename}.chrom.sizes
    """
}
