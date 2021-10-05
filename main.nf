#!/usr/bin/env nextflow
/*
========================================================================================
                         ega-submission-via-portal
========================================================================================
 https://git.ecdf.ed.ac.uk/igmmbioinformatics/ega-submission-via-portal
----------------------------------------------------------------------------------------
*/

def helpMessage() {
    log.info"""
    Usage:

    The typical command for running the pipeline is as follows:

    nextflow run ameynert/ega-submission-via-portal --samples samples.csv --reads '*_R{1,2}.fastq.gz' --ega_cryptor /path/to/ega_cryptor.jar -profile conda

    Mandatory arguments:
      --samples [file]              Path to samples CSV file
      --reads [file]                Path to input data (must be surrounded with quotes, e.g. '*_R[1,2].fastq.gz]')
      --ega_cryptor [file]          Absolute path to EGA Cryptor JAR file (included in bin/ega-cryptor-2.0.0.jar)
      -profile [str]                Configuration profile to use. Can use multiple (comma separated)
                                    Available: conda

    Other options:
      --outdir [file]               The output directory where the results will be saved
      --ega_user [str]              EGA upload box account (e.g. ega-box-1234)
      --ega_password [str]          Password for EGA upload box account, must be specified if --ega-user is specified
      -name [str]                   Name for the pipeline run. If not specified, Nextflow will automatically generate a random mnemonic

    """.stripIndent()
}

// Show help message
if (params.help) {
    helpMessage()
    exit 0
}

/*
 * SET UP CONFIGURATION VARIABLES
 */

// Has the run name been specified by the user?
//  this has the bonus effect of catching both -name and --name
custom_runName = params.name
if (!(workflow.runName ==~ /[a-z]+_[a-z]+/)) {
    custom_runName = workflow.runName
}

/*
 * Create a channel for input read files
 */
ch_read_files = Channel
    .fromFilePairs(params.reads, size : 2)
    .ifEmpty { exit 1, "Cannot find any reads matching: ${params.reads}\nNB: Path needs to be enclosed in quotes!" }

/*
 * STEP 1 - Encrypt the FASTQ files. Generate a line of CSV output for runs, if not uploading to EGA, move the
 * encrypted files and md5 checksums to the output directory.
 */
process encrypt {
    tag "$name"

    if (params.ega_user.length() == 0) {
      publishDir "${params.outdir}", pattern: '*.{gpg,md5}', mode: 'move'
    }

    input:
    set val(sample), file(reads) from ch_read_files

    output:
    file '*.csv' into ch_runs_csv_output
    set val(sample), file('*') into ch_upload_input

    script:
    """
    java -Xmx8g -jar ${params.ega_cryptor} -i ${reads[0]} -t 8 -o .
    java -Xmx8g -jar ${params.ega_cryptor} -i ${reads[1]} -t 8 -o .

    echo "sample_${sample},${sample}_R1.fastq.gz,`cat ${sample}_R1.fastq.gz.gpg.md5`,`cat ${sample}_R1.fastq.gz.md5`,${sample}_R2.fastq.gz,`cat ${sample}_R2.fastq.gz.gpg.md5`,`cat ${sample}_R2.fastq.gz.md5`" > ${sample}.csv
    """
}

/*
 * STEP 2 - Collect the CSV output for runs
 */
process collect_runs_csv {

    publishDir "${params.outdir}", mode: 'copy'

    input:
    file(files) from ch_runs_csv_output.collect()

    output:
    file(runs)

    script:
    runs = "runs.csv"
    """
    echo \"Sample alias\",\"First Fastq File\",\"First Checksum\",\"First Unencrypted checksum\",\"Second Fastq File\",\"Second Checksum\",\"Second Unencrypted checksum\" > runs.csv
    cat ${files} >> runs.csv
    """
}

/*
 * STEP 3 - Upload output via Aspera to EGA box
 */
process upload {

    input:
    set sample, file(files) from ch_upload_input

    output:

    script:
    """
    export ASPERA_SCP_PASS=${params.ega_password}
    ascp -T -P 33001 -O 33001 -l 300M -QT -L- -k 1 ${sample}* ${params.ega_user}@fasp.ega.ebi.ac.uk:/.
    """
}
