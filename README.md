# Nextstrain build for Yellow Fever

This build is currently designed for in-the-field running and is not yet generalised for a stable, updated nextstrain.org page.

## Install augur + auspice using conda

```
curl http://data.nextstrain.org/nextstrain.yml --compressed -o nextstrain.yml
conda env create -f nextstrain.yml
conda activate nextstrain
npm install --global auspice
```

When you're inside the "nextstrain" environment (via `conda activate nextstrain`) you should have both `augur` & `auspice` installed.
You can test this by running `augur --version` and `auspice --version`.
Currently, augur is around `v5.1.1` and auspice is around `v1.36.6`.


## Clone this repo

```
git clone https://github.com/nextstrain/yellow-fever.git
cd yellow-fever
mkdir data results auspice
```


## Make input files available

The bioinformatics "pipeline" for YFV starts with 4 main files as input: 
* `./data/genbankReleased.fasta`
* `./data/genbankReleased.csv`
* `./data/newSequences.fasta`
* `./data/newSequences.csv`

These are not committed to the github repo (they're "gitignored"), so you'll have to put them there.

These files are specified in the first few lines of the Snakemake file, which contains all the commands necessary to run the pipeline.
It's possible to use >2 sets of input files, or different file names, but you'll have to add / change them in the snakemake file.


Additionally, there are 2 other input-like files, also defined in the snakemake file:
* `./config/auspice_config.json` which contains options -- such as what traits to display as the color-by's on the tree -- which are used to control how auspice will visualise the data.
* `./config/YFV112.gb` the YFV reference used here -- currently [YF112](https://www.ncbi.nlm.nih.gov/nuccore/1269012770). Please replace this if needed & update the snakemake file accordingly.


## Run the pipeline

```
snakemake --printshellcmds
```

This will run all the steps defined in the Snakefile 🎉

These steps are (roughly):
1. __parse__ convert the (potentially multiple) CSV + FASTA files into the correct format for augur (TSV + FASTA). Also performs some field manipulation, such as extracting "country" from the "Sequence_name", extracting collection year, storing which file a sequence came from etcetera.
2. __align__ Using mafft
3. __tree__ Using IQ-TREE (cahn change this to RAxML or FastTree if needed)
4. __refine__ Normally this is where we date the internal nodes, but I haven't enabled this here. It is needed however to label the internal nodes & reroot the tree (see below).
5. __ancestral__ Infer ancestral mutations on the tree. This step could easily be dropped if desired!
6. __traits__ Use DTA to infer some traits across the tree. Currently used for "country" only. You can easily add fields to the snakemake file which will perform this for additional traits.
7. __export__ Create the final JSON for auspice to visualise.

Steps 1-6 produce output in `./results`, while step 7 (export) produces the JSONs in `./auspice`. Both of these directories are gitignored (as well as `./data`) so that files here won't be pushed up to GitHub.

## Visualise the data

```
auspice view --datasetDir auspice
```
Then open a browser at http://localhost:4000

Current color-bys include most of the metadata provided, as well as which file the samples came from, year of collection.
The GPS co-ordinates are per-strain, so that is the geographic-resolution available. We could also aggregate municipalities if desired (we'd need GPS coordinates for each one if so).


## To-Do
* The tree is rooted on the oldest available sequence ("JF912179", 1980), but there may be a better choice? This is defined in the Snakefile and is really easy to change.
* Reference sequence used may not be ideal.



