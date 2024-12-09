We gratefully acknowledge the authors, originating and submitting
laboratories of the genetic sequences and metadata for sharing their
work. Please note that although data generators have generously shared
data in an open fashion, that does not mean there should be free
license to publish on this data. Data generators should be cited where
possible and collaborations should be sought in some circumstances.
Please try to avoid scooping someone else's work. Reach out if
uncertain.

#### Analysis

Our bioinformatic processing workflow can be found at
[github.com/nextstrain/yellow-fever][] and includes:

- sequence alignment by [augur align][]
- phylogenetic reconstruction using [IQTREE-2][]
- clade assignment using [Nextclade][]
- ancestral state reconstruction and temporal inference using [TreeTime][]

#### Underlying data

We curate sequence data and metadata from NCBI as starting point for
our analyses. We gratefully acknowledge the large contribution of over
500 sequences from Hill, et al.

#### Clade annotation

The clades we annotate on the yellow fever trees (Clades I-VII) are
roughly equivalent with the following genotypes as described in
[Mutebi et al.][] (J Virol. 2001 Aug;75(15):6999-7008) and [Bryant et
al.][] (PLoS Pathog. 2007 May 18;3(5):e75).

| Clade     | Genotype            |
|-----------|---------------------|
| Clade I   | Angola              |
| Clade II  | East Africa         |
| Clade III | East/Central Africa |
| Clade IV  | West Africa I       |
| Clade V   | West Africa II      |
| Clade VI  | South America I     |
| Clade VII | South America II    |

(N.b., this table is available as a TSV in this repo, at
`nextclade/defaults/clade-to-genotype.tsv`.)

---

Screenshots may be used under a [CC-BY-4.0 license][] and attribution
to nextstrain.org must be provided.

[github.com/nextstrain/yellow-fever]: https://github.com/nextstrain/yellow-fever
[augur align]: https://docs.nextstrain.org/projects/augur/en/stable/usage/cli/align.html
[IQTREE-2]: http://www.iqtree.org/
[Nextclade]: https://nextstrain.org/fetch/data.clades.nextstrain.org/v3/nextstrain/yellow-fever/prM-E/2024-11-05--09-19-52Z/tree.json
[TreeTime]: https://github.com/neherlab/treetime
[Mutebi et al.]: https://pubmed.ncbi.nlm.nih.gov/11435580/
[Bryant et al.]: https://pubmed.ncbi.nlm.nih.gov/17511518/
[CC-BY-4.0 license]: https://creativecommons.org/licenses/by/4.0/
