rule copy_example_data:
    input:
        sequences="example_data/sequences.fasta",
        metadata="example_data/metadata.tsv",
    output:
        sequences=temp("data/sequences.fasta"),
        metadata=temp("data/metadata.tsv"),
    shell:
        """
        cp -f {input.sequences} {output.sequences}
        cp -f {input.metadata} {output.metadata}
        """


# force this rule over downloading from nextstrain
ruleorder: copy_example_data > decompress
