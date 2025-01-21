process CHROMPLOTTER {
    // TODO : SET FIXED VERSION WHEN PIPELINE IS STABLE
    container 'ghcr.io/bwbioinfo/rs-chromplotter:latest'

    tag "$meta.id"
    label 'process_cpu_med'
    label 'process_memory_med'
    label 'process_time_med'
    
    input:
    tuple val(meta),
        path(in_bed),
        val(in_chrom)

    output:
    tuple val(meta), 
        path("*.svg"),
        val(in_chrom),
        optional: true,
        emit: chromplot
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    chromplotter \\
    ${args} \\
    --bedfile ${in_bed} \\
    --chrom ${in_chrom} \\
    --output ${prefix}_${in_chrom}.svg

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        chromplotter: \$( chromplotter --version )
    END_VERSIONS
    """
}