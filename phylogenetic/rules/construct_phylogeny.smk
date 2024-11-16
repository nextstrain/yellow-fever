"""
This part of the workflow constructs the phylogenetic tree.
"""

rule tree:
    """Building tree"""
    input:
        alignment = "results/{gene}/aligned_and_filtered.fasta"
    output:
        tree = "results/{gene}/tree_raw.nwk"
    log:
        "logs/{gene}/tree.txt",
    benchmark:
        "benchmarks/{gene}/tree.txt"
    shell:
        r"""
        augur tree \
            --alignment {input.alignment:q} \
            --output {output.tree:q}
          2> {log:q}
        """

rule refine:
    """
    Refining tree
      - use {params.coalescent} coalescent timescale
      - estimate {params.date_inference} node dates
      - filter tips more than {params.clock_filter_iqd} IQDs from clock expectation
    """
    input:
        tree = "results/{gene}/tree_raw.nwk",
        alignment = "results/{gene}/aligned_and_filtered.fasta",
        metadata = "data/metadata.tsv"
    output:
        tree = "results/{gene}/tree.nwk",
        node_data = "results/{gene}/branch_lengths.json"
    params:
        coalescent = config["refine"]["coalescent"],
        date_inference = config["refine"]["date_inference"],
        clock_filter_iqd = config["refine"]["clock_filter_iqd"],
        strain_id = config["strain_id_field"]
    log:
        "logs/{gene}/refine.txt",
    benchmark:
        "benchmarks/{gene}/refine.txt"
    shell:
        r"""
        augur refine \
            --tree {input.tree:q} \
            --alignment {input.alignment:q} \
            --root mid_point \
            --metadata {input.metadata:q} \
            --metadata-id-columns {params.strain_id:q} \
            --output-tree {output.tree:q} \
            --output-node-data {output.node_data:q} \
            --coalescent {params.coalescent:q} \
            --date-confidence \
            --date-inference {params.date_inference:q} \
            --clock-filter-iqd {params.clock_filter_iqd:q} \
            --stochastic-resolve \
          2> {log:q}
        """
