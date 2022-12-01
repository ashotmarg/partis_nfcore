process PARTIS_PARSEOUTPUT {
    tag "$meta.id"
    label 'process_single'

    // conda (params.enable_conda ? "YOUR-TOOL-HERE" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
        'quay.io/matsengrp/partis' }"

    input:
    tuple val(meta), path(yaml)

    output:
    tuple val(meta), path("plots/*")      , emit: plots
    tuple val(meta), path("*.fa")         , emit: outfasta
    path "versions.yml"                   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    /partis/bin/parse-output.py \\
    ${yaml} \\
    tmp_${prefix}.fa \\
    --extra-columns cdr3_length:naive_seq \\
    --plotdir plots \\
    $args \\


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        partis: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' ))
    END_VERSIONS
    """
}
