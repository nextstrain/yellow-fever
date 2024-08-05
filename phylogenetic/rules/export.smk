"""
This part of the workflow collects the phylogenetic tree and annotations to
export a Nextstrain dataset.
"""

rule export:
    """Exporting data files for for auspice"""
    input:
        tree = "results/{gene}/tree.nwk",
        metadata = "../ingest/results/metadata.tsv",
        branch_lengths = "results/{gene}/branch_lengths.json",
        nt_muts = "results/{gene}/nt_muts.json",
        aa_muts = "results/{gene}/aa_muts.json",
        traits = "results/{gene}/traits.json",
        colors = config["files"]["colors"],
        auspice_config = lambda wildcard: "defaults/auspice_config.json" if wildcard.gene in ["genome"] else "defaults/auspice_config_N450.json",
        description=config["files"]["description"]
    output:
        auspice_json = "auspice/yellow-fever-virus_{gene}.json"
    params:
        metadata_columns = config["export"]["metadata_columns"],
        strain_id = config["strain_id_field"],
    log:
        "logs/{gene}/export.txt",
    benchmark:
        "benchmarks/{gene}/export.txt"
    shell:
        """
        augur export v2 \
            --tree {input.tree:q} \
            --metadata {input.metadata:q} \
            --metadata-id-columns {params.strain_id:q} \
            --node-data {input.branch_lengths:q} {input.traits:q} {input.nt_muts:q} {input.aa_muts:q} \
            --colors {input.colors:q} \
            --metadata-columns {params.metadata_columns} \
            --auspice-config {input.auspice_config:q} \
            --include-root-sequence-inline \
            --output {output.auspice_json:q} \
            --description {input.description:q} \
          2> {log:q}
        """
