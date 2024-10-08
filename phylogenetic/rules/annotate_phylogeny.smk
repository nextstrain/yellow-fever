"""
This part of the workflow creates additional annotations for the
phylogenetic tree.
"""

rule ancestral:
    """Reconstructing ancestral sequences and mutations"""
    input:
        tree = "results/{gene}/tree.nwk",
        alignment = "results/{gene}/aligned_and_filtered.fasta"
    output:
        node_data = "results/{gene}/nt_muts.json"
    params:
        inference = config["ancestral"]["inference"]
    log:
        "logs/{gene}/ancestral.txt",
    benchmark:
        "benchmarks/{gene}/ancestral.txt"
    shell:
        r"""
        augur ancestral \
            --tree {input.tree:q} \
            --alignment {input.alignment:q} \
            --output-node-data {output.node_data:q} \
            --inference {params.inference:q} \
          2> {log:q}
        """

rule translate:
    """Translating amino acid sequences"""
    input:
        tree = "results/{gene}/tree.nwk",
        node_data = "results/{gene}/nt_muts.json",
        genemap = "defaults/genemap_{gene}.gff"
    output:
        node_data = "results/{gene}/aa_muts.json"
    log:
        "logs/{gene}/translate.txt",
    benchmark:
        "benchmarks/{gene}/translate.txt"
    shell:
        r"""
        augur translate \
            --tree {input.tree:q} \
            --ancestral-sequences {input.node_data:q} \
            --reference-sequence {input.genemap:q} \
            --output {output.node_data:q} \
          2> {log:q}
        """


rule traits:
    """Inferring ancestral traits for {params.columns!s}"""
    input:
        tree = "results/{gene}/tree.nwk",
        metadata = "../ingest/results/metadata.tsv",
    output:
        node_data = "results/{gene}/traits.json",
    params:
        columns = config["traits"]["columns"],
        strain_id = config["strain_id_field"],
    log:
        "logs/{gene}/traits.txt",
    benchmark:
        "benchmarks/{gene}/traits.txt"
    shell:
        r"""
        augur traits \
            --tree {input.tree:q} \
            --metadata-id-columns {params.strain_id:q} \
            --metadata {input.metadata:q} \
            --output {output.node_data:q} \
            --columns {params.columns} \
            --confidence \
          2> {log:q}
        """
