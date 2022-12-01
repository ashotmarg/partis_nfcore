process PARTIS_ANNOTATE {
    tag "$meta.id"
    label 'process_single'

    // conda (params.enable_conda ? "YOUR-TOOL-HERE" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
        'quay.io/matsengrp/partis' }"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("*.yaml")     , emit: yaml
    tuple val(meta), path("outdir/*")   , emit: outfolder
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    /partis/bin/partis \\
    annotate \\
    --parameter-dir outdir \\
    --parameter-out-dir outdir \\
    --infname ${fasta} \\
    --outfname ${prefix}.yaml \\
    $args \\


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        partis: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' ))
    END_VERSIONS
    """
}
