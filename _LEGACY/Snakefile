rule all:
    input:
        auspice_tree = "auspice/yellow-fever_tree.json",
        auspice_meta = "auspice/yellow-fever_meta.json"

rule files:
    params:
        input_sequences = ["data/genbankReleased.fasta", "data/newSequences.fasta"],
        input_metadata = ["data/genbankReleased.csv", "data/newSequences.csv"],
        reference = "config/YFV112.gb",
        auspice_config = "config/auspice_config.json"

files = rules.files.params

rule parse:
    """Parsing provided metadata & sequences into augur formats"""
    input:
        metadata = files.input_metadata,
        sequences = files.input_sequences
    output:
        sequences = "results/sequences.fasta",
        metadata = "results/metadata.tsv",
        latlongs = "results/latlongs.tsv"
    params:
        fasta_fields = "strain virus accession date region country division city db segment authors url title journal paper_url"
    shell:
        """
        python scripts/parseMetadata.py \
            --metadataIn {input.metadata} \
            --metadataOut {output.metadata} \
            --latlongs {output.latlongs} \
            --sequencesIn {input.sequences} \
            --sequencesOut {output.sequences}
        """

rule align:
    """
    Aligning sequences to {input.reference}
      - filling gaps with N
    """
    input:
        sequences = "results/sequences.fasta",
        reference = files.reference
    output:
        alignment = "results/aligned.fasta"
    shell:
        """
        augur align \
            --sequences {input.sequences} \
            --reference-sequence {input.reference} \
            --output {output.alignment} \
            --fill-gaps \
            --remove-reference
        """

rule tree:
    """Building tree using IQ-TREE"""
    input:
        alignment = "results/aligned.fasta"
    output:
        tree = "results/tree_raw.nwk"
    shell:
        """
        augur tree \
            --alignment {input.alignment} \
            --output {output.tree}
        """

rule refine:
    """
    Refining tree to add names to internal nodes and inferring a timetree.
    NOTE: this step can drop samples which are extreme outliers in the root-to-tip analysis
    """
    input:
        tree = "results/tree_raw.nwk",
        alignment = "results/aligned.fasta",
        metadata = "results/metadata.tsv"
    output:
        tree = "results/tree.nwk",
        node_data = "results/branch_lengths.json"
    params:
        root="best",
        coalescent = "opt",
        clock_filter_iqd = 4,
        date_inference = "marginal"
    shell:
        """
        augur refine \
            --tree {input.tree} \
            --alignment {input.alignment} \
            --metadata {input.metadata} \
            --output-tree {output.tree} \
            --output-node-data {output.node_data} \
            --timetree \
            --coalescent {params.coalescent} \
            --date-confidence \
            --date-inference {params.date_inference} \
            --clock-filter-iqd {params.clock_filter_iqd} \
            --root {params.root}
        """

rule ancestral:
    """Reconstructing ancestral sequences and mutations"""
    input:
        tree = "results/tree.nwk",
        alignment = "results/aligned.fasta",
    output:
        node_data = "results/nt_muts.json"
    params:
        inference = "joint"
    shell:
        """
        augur ancestral \
            --tree {input.tree} \
            --alignment {input.alignment} \
            --output {output.node_data} \
            --inference {params.inference}
        """

rule traits:
    """Inferring ancestral traits for {params.columns!s}"""
    input:
        tree = "results/tree.nwk",
        metadata = "results/metadata.tsv",
    output:
        node_data = "results/traits.json",
    params:
        columns = "country"
    shell:
        """
        augur traits \
            --tree {input.tree} \
            --metadata {input.metadata} \
            --output {output.node_data} \
            --columns {params.columns} \
            --confidence
        """


rule export:
    """Exporting data files for for auspice"""
    input:
        tree = "results/tree.nwk",
        metadata = "results/metadata.tsv",
        branch_lengths = "results/branch_lengths.json",
        traits = "results/traits.json",
        nt_muts = "results/nt_muts.json",
        auspice_config = files.auspice_config,
        lat_longs = "results/latlongs.tsv",
        annotation_file = "config/genome_annotation_file.json"
    output:
        auspice_tree = rules.all.input.auspice_tree,
        auspice_meta = rules.all.input.auspice_meta
    shell:
        """
        augur export \
            --tree {input.tree} \
            --metadata {input.metadata} \
            --node-data {input.branch_lengths} {input.traits} {input.nt_muts} {input.annotation_file} \
            --lat-longs {input.lat_longs} \
            --auspice-config {input.auspice_config} \
            --output-tree {output.auspice_tree} \
            --output-meta {output.auspice_meta}
        """

rule clean:
    """Removing directories: {params}"""
    params:
        "results ",
        "auspice"
    shell:
        "rm -rfv {params}"
