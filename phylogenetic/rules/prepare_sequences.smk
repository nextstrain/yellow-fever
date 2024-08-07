"""
This part of the workflow prepares sequences for constructing the
phylogenetic tree.
"""

rule filter:
    message: """
    Filtering to
      - {params.sequences_per_group} sequence(s) per {params.group_by!s}
      - excluding strains in {input.exclude}
      - minimum genome length of {params.min_length}
    """
    input:
        exclude = config["files"]["exclude"],
        include = config["files"]["include_genome"],
        # TODO once this repo is fully automated and uploading data to
        # S3, this step should download data from there instead of
        # depending on the ingest build
        metadata = "../ingest/results/metadata.tsv",
        sequences = "../ingest/results/sequences.fasta"
    output:
        sequences = "results/{gene}/filtered.fasta"
    params:
        group_by = config["filter"]["group_by"],
        min_date = config["filter"]["min_date"],
        min_length = config["filter"]["min_length"],
        sequences_per_group = config["filter"]["sequences_per_group"],
        strain_id = config["strain_id_field"]
    log:
        "logs/{gene}/filter.txt",
    benchmark:
        "benchmarks/{gene}/filter.txt"
    shell:
        """
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

rule align:
    input:
        sequences="results/genome/filtered.fasta",
        reference=config["files"]["reference_gb"],
        genemap=config["files"]["genemap"],
    output:
        alignment="results/{gene}/aligned.fasta",
    log:
        "logs/{gene}/align.txt",
    benchmark:
        "benchmarks/{gene}/align.txt"
    shell:
        """
        augur align \
            --sequences {input.sequences} \
            --reference-sequence {input.reference} \
            --output {output.alignment} \
            --fill-gaps \
            --remove-reference \
          2> {log:q}
        """
