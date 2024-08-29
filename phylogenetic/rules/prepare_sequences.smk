"""
This part of the workflow prepares sequences for constructing the
phylogenetic tree.
"""

rule filter_genome:
    input:
        exclude = config["files"]["genome"]["exclude"],
        include = config["files"]["genome"]["include"],
        # TODO once this repo is fully automated and uploading data to
        # S3, this step should download data from there instead of
        # depending on the ingest build
        metadata = "../ingest/results/metadata.tsv",
        sequences = "../ingest/results/sequences.fasta"
    output:
        sequences = "results/genome/filtered.fasta"
    params:
        group_by = config["filter"]["group_by"],
        min_date = config["filter"]["min_date"],
        min_length = config["filter"]["genome"]["min_length"],
        sequences_per_group = config["filter"]["genome"]["sequences_per_group"],
        strain_id = config["strain_id_field"]
    log:
        "logs/genome/filter_genome.txt",
    benchmark:
        "benchmarks/genome/filter_genome.txt"
    shell:
        r"""
        augur filter \
            --sequences {input.sequences:q} \
            --metadata {input.metadata:q} \
            --metadata-id-columns {params.strain_id:q} \
            --exclude {input.exclude:q} \
            --include {input.include:q} \
            --output {output.sequences:q} \
            --group-by {params.group_by} \
            --sequences-per-group {params.sequences_per_group:q} \
            --min-date {params.min_date:q} \
            --min-length {params.min_length:q} \
          2> {log:q}
        """

rule align_genome:
    input:
        sequences="results/genome/filtered.fasta",
        reference=config["files"]["genome"]["reference"],
    output:
        alignment="results/genome/aligned_and_filtered.fasta",
    log:
        "logs/genome/align_genome.txt",
    benchmark:
        "benchmarks/genome/align_genome.txt"
    shell:
        r"""
        augur align \
            --sequences {input.sequences} \
            --reference-sequence {input.reference} \
            --output {output.alignment} \
            --fill-gaps \
            --remove-reference \
          2> {log:q}
        """


rule align_and_extract_prME:
    input:
        reference=config["files"]["prM-E"]["reference"],
        # TODO once this repo is fully automated and uploading data to
        # S3, this step should download data from there instead of
        # depending on the ingest build
        sequences = "../ingest/results/sequences.fasta",
    output:
        alignment = "results/prM-E/aligned.fasta"
    params:
        group_by = config["filter"]["group_by"],
        min_date = config["filter"]["min_date"],
        min_length = config["filter"]["prM-E"]["min_length"],
        sequences_per_group = config["filter"]["prM-E"]["sequences_per_group"],
        strain_id = config["strain_id_field"]
    log:
        "logs/genome/filter_and_extract_prM-E.txt",
    benchmark:
        "benchmarks/genome/filter_and_extract_prM-E.txt"
    shell:
        r"""
        augur align \
            --sequences {input.sequences} \
            --reference-sequence {input.reference} \
            --output {output.alignment} \
            --fill-gaps \
            --remove-reference \
          2> {log:q}
        """


rule filter_prME:
    input:
        exclude = config["files"]["prM-E"]["exclude"],
        include = config["files"]["prM-E"]["include"],
        # TODO once this repo is fully automated and uploading data to
        # S3, this step should download data from there instead of
        # depending on the ingest build
        metadata = "../ingest/results/metadata.tsv",
        sequences = "results/prM-E/aligned.fasta"
    output:
        sequences = "results/prM-E/aligned_and_filtered.fasta"
    params:
        group_by = config["filter"]["group_by"],
        min_date = config["filter"]["min_date"],
        min_length = config["filter"]["prM-E"]["min_length"],
        sequences_per_group = config["filter"]["prM-E"]["sequences_per_group"],
        strain_id = config["strain_id_field"]
    log:
        "logs/genome/filter_prM-E.txt",
    benchmark:
        "benchmarks/genome/filter_prM-E.txt"
    shell:
        r"""
        augur filter \
            --sequences {input.sequences:q} \
            --metadata {input.metadata:q} \
            --metadata-id-columns {params.strain_id:q} \
            --exclude {input.exclude:q} \
            --include {input.include:q} \
            --output {output.sequences:q} \
            --group-by {params.group_by} \
            --sequences-per-group {params.sequences_per_group:q} \
            --min-date {params.min_date:q} \
            --min-length {params.min_length:q} \
          2> {log:q}
        """
