# Benchmarking adapter and quality trimming tools
Original implementation by Brian Bushnell (2014): 
http://seqanswers.com/forums/showthread.php?t=42776

The following tools are compared:

 - bbduk
 - cutadapt
 - fastp
 - trimmomatic

## Fake adapters, "gruseq"
The fake truseq adapters, "gruseq", provided by Brian Bushnell, downloaded from: 
http://seqanswers.com/forums/attachment.php?attachmentid=2993&d=1398383571

## Test data
A single sample is downloaded from SRA. Feel free to replace it with whatever
you want. 

# Running
Run the benchmarking workflow with `snakemake --use-conda --jobs 10`
