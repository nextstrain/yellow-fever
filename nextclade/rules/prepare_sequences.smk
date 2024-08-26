"""
This part of the workflow prepares sequences for constructing the
phylogenetic tree.
"""
rule align_and_extract_prM_E:
    input:
        # TODO once this repo is fully automated and uploading data to
        # S3, this step should download data from there instead of
        # depending on the ingest build
        sequences = "../ingest/results/sequences.fasta",
        reference = config["files"]["reference_prM-E_fasta"],
    output:
        sequences = "results/sequences.fasta",
    params:
        min_length = config['align_and_extract_prM-E']['min_length'],
        min_seed_cover = config['align_and_extract_prM-E']['min_seed_cover'],
    log:
        "logs/align_and_extract_prM_E.txt",
    benchmark:
        "benchmarks/align_and_extract_prM_E.txt",
    threads: workflow.cores
    shell:
        r"""
        nextclade3 run \
            --jobs {threads:q} \
            --input-ref {input.reference:q} \
            --output-fasta {output.sequences:q} \
            --min-seed-cover {params.min_seed_cover:q} \
            --min-length {params.min_length:q} \
            --silent \
            {input.sequences:q} \
          &> {log:q}
        """

rule filter:
    input:
        include = config["files"]["include"],
        # TODO once this repo is fully automated and uploading data to
        # S3, this step should download data from there instead of
        # depending on the ingest build
        metadata = "../ingest/results/metadata.tsv",
        sequences = "results/sequences.fasta",
    output:
        sequences = "results/aligned.fasta",
    params:
        strain_id = config["strain_id_field"],
    log:
        "logs/filter.txt",
    benchmark:
        "benchmarks/filter.txt"
    shell:
        r"""
        augur filter \
            --sequences {input.sequences:q} \
            --metadata {input.metadata:q} \
            --metadata-id-columns {params.strain_id:q} \
            --exclude-all \
            --include {input.include:q} \
            --output {output.sequences:q} \
          &> {log:q}
        """
