# Nextstrain repository for yellow fever virus

<!-- ##TODO## finish updating this -->

This repository is in the process of being upgraded to follow the
[pathogen repo
guide](https://github.com/nextstrain/pathogen-repo-guide/).

## Installation

Follow the [standard installation
instructions](https://docs.nextstrain.org/en/latest/install.html) for
Nextstrain's suite of software tools.

## Working on this repo

This repo is configured to use [pre-commit](https://pre-commit.com),
to help automatically catch common coding errors and syntax issues
with changes before they are committed to the repo.
.
If you will be writing new code or otherwise working within this repo,
please do the following to get started:

1. install `pre-commit` by running either `python -m pip install
   pre-commit` or `brew install pre-commit`, depending on your
   preferred package management solution
2. install the local git hooks by running `pre-commit install` from
   the root of the repo
3. when problems are detected, correct them in your local working tree
   before committing them.

Note that these pre-commit checks are also run in a GitHub Action when
changes are pushed to GitHub, so correcting issues locally will
prevent extra cycles of correction.
