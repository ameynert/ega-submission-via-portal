# EGA Submission via Portal

**Supports encryption and upload of paired-end sequencing data to the European Genome/Phenome Archive (EGA) using the Submitter Portal CSV format for Run objects.**

## Introduction

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It is based on the nf-core template and only supports Conda.

```
nextflow run https://git.ecdf.ed.ac.uk/igmmbioinformatics/ega-submission-via-portal -profile conda
```

## Credits

ega-submission-via-portal was originally written by Alison Meynert (alison.meynert@igmm.ed.ac.uk).

