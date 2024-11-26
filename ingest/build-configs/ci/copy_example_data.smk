rule copy_example_data:
    input:
        ncbi_dataset="example-data/ncbi_dataset.zip"
    output:
        ncbi_dataset=temp("data/ncbi_dataset.zip")
    shell:
        """
        cp -f {input.ncbi_dataset} {output.ncbi_dataset}
        """

# force this rule over NCBI data fetch
ruleorder: copy_example_data > fetch_ncbi_dataset_package
