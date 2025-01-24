process MPGI_SUMMARIZE_MODS {
    // TODO : SET FIXED VERSION WHEN PIPELINE IS STABLE
    container 'ghcr.io/chusj-pigu/tools:latest'

    tag "$meta.id"
    label 'process_cpu_med'
    label 'process_memory_med'
    label 'process_time_med'
    errorStrategy { task.attempt <= 3 ? 'retry' : 'terminate' }
    
    input:
    tuple val(meta), path(in_bam), path(bam_index)

    output:
    tuple val(meta), path("*.csv"), emit: modifications_summary
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    summarize_modifications.nu \\
        --mods ${in_bam} \\
        --mapped ${bam_index} \\
        --output ${prefix}.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nushell: \$( nu --version )
    END_VERSIONS
    """
}

process MPGI_COUNTFEATURES {
    // TODO : SET FIXED VERSION WHEN PIPELINE IS STABLE
    container 'ghcr.io/chusj-pigu/tools:latest'

    tag "$meta.id"
    label 'process_cpu_med'
    label 'process_memory_med'
    label 'process_time_med'
    errorStrategy { task.attempt <= 3 ? 'retry' : 'terminate' }
    
    input:
    tuple val(meta), path(input)

    output:
    tuple val(meta), path("*.csv"), emit: features_summary
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    countfeatures.nu \\
        ${input} \\
        ${prefix}-features-summary.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nushell: \$( nu --version )
    END_VERSIONS
    """
}