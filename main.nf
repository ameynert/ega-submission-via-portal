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

    nextflow run https://git.ecdf.ed.ac.uk/igmmbioinformatics/ega-submission-via-portal --reads '*_R{1,2}.fastq.gz' -profile conda

    Mandatory arguments:
      --reads [file]                Path to input data (must be surrounded with quotes)
      -profile [str]                Configuration profile to use. Can use multiple (comma separated)
                                    Available: conda

    Other options:
      --outdir [file]                 The output directory where the results will be saved
      -name [str]                     Name for the pipeline run. If not specified, Nextflow will automatically generate a random mnemonic

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
if (params.readPaths) {
    Channel
        .from(params.readPaths)
        .map { row -> [ row[0], [ file(row[1][0], checkIfExists: true), file(row[1][1], checkIfExists: true) ] ] }
        .ifEmpty { exit 1, "params.readPaths was empty - no input files supplied" }
        .into { ch_read_files_encrypt }
} else {
    Channel
        .fromFilePairs(params.reads, 2)
        .ifEmpty { exit 1, "Cannot find any reads matching: ${params.reads}\nNB: Path needs to be enclosed in quotes!" }
        .into { ch_read_files_encrypt }
}

/*
 * STEP 1 - Encrypt
 */
process encrypt {
    tag "$name"
    label 'process_medium'

    input:
    set val(name), file(reads) from ch_read_files_encrypt

    output:
    file into ch_encrypt_results

    script:
    """

    """
}

/*Channel
  .from ch_encrypt_results
  .into { ch_runs_csv_input, ch_upload_input }*/

/*
 * STEP 2 - Collect output and generate CSV file for Runs
 */
/*process runscsv {
    publishDir "${params.outdir}", mode: 'copy'

    input:
    file from ch_runs_csv_input.collect().ifEmpty([])

    output:
    file "*.csv"

    script:
    """

    """
}*/

/*
 * STEP 3 - Upload output via Aspera to EGA box
 */
/*process upload {
    publishDir "${params.outdir}/pipeline_info", mode: 'copy'

    input:
    file from ch_upload_input

    output:

    script:
    """

    """
}
*/