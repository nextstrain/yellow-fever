"""
This part of the workflow constructs the phylogenetic tree.
"""

rule tree:
    """Building tree"""
    input:
        alignment = "results/{build}/aligned_and_filtered.fasta"
    output:
        tree = "results/{build}/tree_raw.nwk"
    log:
        "logs/{build}/tree.txt",
    benchmark:
        "benchmarks/{build}/tree.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        augur tree \
            --alignment {input.alignment:q} \
            --output {output.tree:q}
        """

rule refine:
    """
    Refining tree
      - use {params.coalescent} coalescent timescale
      - estimate {params.date_inference} node dates
      - filter tips more than {params.clock_filter_iqd} IQDs from clock expectation
    """
    input:
        tree = "results/{build}/tree_raw.nwk",
        alignment = "results/{build}/aligned_and_filtered.fasta",
        metadata = "data/metadata.tsv"
    output:
        tree = "results/{build}/tree.nwk",
        node_data = "results/{build}/branch_lengths.json"
    params:
        strain_id = config["strain_id_field"],
        timetree = lambda w: "--timetree" if w.build == "genome" else "",
        clock_rate = config["refine"]["clock_rate"],
        clock_std_dev = config["refine"]["clock_std_dev"],
        coalescent = config["refine"]["coalescent"],
        date_inference = config["refine"]["date_inference"],
        clock_filter_iqd = config["refine"]["clock_filter_iqd"],
    log:
        "logs/{build}/refine.txt",
    benchmark:
        "benchmarks/{build}/refine.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        augur refine \
            --tree {input.tree:q} \
            --alignment {input.alignment:q} \
            --root mid_point \
            --metadata {input.metadata:q} \
            --metadata-id-columns {params.strain_id:q} \
            --output-tree {output.tree:q} \
            --output-node-data {output.node_data:q} \
            {params.timetree:q} \
            --clock-rate {params.clock_rate} \
            --clock-std-dev {params.clock_std_dev} \
            --coalescent {params.coalescent:q} \
            --date-confidence \
            --date-inference {params.date_inference:q} \
            --clock-filter-iqd {params.clock_filter_iqd:q} \
            --stochastic-resolve
        """
