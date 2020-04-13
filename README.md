# EGA Submission via Portal

**Supports encryption and upload of paired-end sequencing data to the European Genome/Phenome Archive (EGA) using the Submitter Portal CSV format for Run objects.**

## Introduction

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It is based on the nf-core template and only supports Conda.

## Running

```
nextflow run https://git.ecdf.ed.ac.uk/igmmbioinformatics/ega-submission-via-portal \
  -profile conda \
  --reads '*_R{1,2}.fastq.gz' \
  --ega_cryptor '/absolute/path/to/ga-submission-via-portal/bin/ega-cryptor-2.0.0.jar' \
  --outdir output \
  --ega_user ega-box-1234 \
  --ega_password password
```

The CSV file for connecting uploaded paired-end FASTQ files to their samples (presuming FASTQ files are named sample_R1.fastq.gz and sample_R2.fastq.gz) in the EGA Submitter Portal will be in the specified output folder.

## Credits

ega-submission-via-portal was originally written by Alison Meynert (alison.meynert@igmm.ed.ac.uk).

