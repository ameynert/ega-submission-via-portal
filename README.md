# EGA Submission via Portal

**Supports encryption and upload of paired-end sequencing data to the European Genome/Phenome Archive (EGA) using the Submitter Portal CSV format for Run objects.**

## Introduction

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It is based on the nf-core template and only supports Conda.

## Resources

Download the EGA Cryptor JAR file. It's at bin/ega-cryptor-2.0.0.jar in this repository if the EGA link doesn't work.

```
wget https://ega-archive.org/files/EgaCryptor.zip
unzip EgaCryptor.zip
rm EgaCryptor.zip
```

## Running

The CSV file used to upload sample metadata to EGA must be provided. It links the internal EGA sample alias to its name. This pipeline assumes that the FASTQ files for upload are named in the format sample_R1.fastq.gz, sample_R2.fastq.gz.

```
nextflow run ameynert/ega-submission-via-portal \
  -profile conda \
  --reads '*_R{1,2}.fastq.gz' \
  --samples /absolute/path/to/samples.csv \
  --ega_cryptor /absolute/path/to/ega-cryptor-2.0.0.jar \
  --outdir output \
  --ega_user ega-box-1234 \
  --ega_password password
```

The CSV file for connecting uploaded paired-end FASTQ files to their sample aliases in the EGA Submitter Portal will be in the specified output folder as runs.csv.

## Credits

ega-submission-via-portal was originally written by Alison Meynert (alison.meynert@igmm.ed.ac.uk).

