rule copy_example_ncbi_data:
    input:
        ncbi_dataset="example-data/ncbi_dataset.zip"
    output:
        ncbi_dataset=temp("data/ncbi_dataset.zip")
    shell:
        r"""
        cp -f {input.ncbi_dataset} {output.ncbi_dataset}
        """
# force this rule over NCBI data fetch
ruleorder: copy_example_ncbi_data > fetch_ncbi_dataset_package


DATASET_NAME = config["nextclade"]["dataset_name"]
rule copy_example_nextclade_data:
    input:
        nextclade_dataset="example-data/nextclade_dataset.zip"
    output:
        nextclade_dataset=temp("data/nextclade_data/{DATASET_NAME}.zip")
    shell:
        r"""
        cp -f {input.nextclade_dataset} {output.nextclade_dataset}
        """
# force this rule over Nextclade data fetch
ruleorder: copy_example_nextclade_data > get_nextclade_dataset
