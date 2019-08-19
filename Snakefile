# vim: syntax=python expandtab
# Compare and evaluate adapter and quality trimming tools.
# Original implementation by Brian Bushnell (2014): 
#   http://seqanswers.com/forums/showthread.php?t=42776
# "gruseq" adapters downloaded from:
#   http://seqanswers.com/forums/attachment.php?attachmentid=2993&d=1398383571
# Fredrik Boulund 2019

TOOLS=[
    "cutadapt",
    "trimmomatic",
    "bbduk",
    "fastp",
]

rule all:
    input:
        #expand("processed/{tool}.fq", tool=TOOLS),
        expand("grades/{tool}.grade.txt", tool=TOOLS),
        

rule download_fastq:
    output:
        "SRR9218144.fastq.gz"
    conda: "env.yaml"
    shell:
        """
        wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR921/004/SRR9218144/SRR9218144.fastq.gz
        """

rule add_adapters:
    input:
        fastq=rules.download_fastq.output,
        adapters="gruseq.fa",
    output:
        "dirty.fq"
    log: "logs/add_adapters.log"
    conda: "env.yaml"
    shell:
        """
        addadapters.sh \
            in={input.fastq} \
            out={output} \
            qout=33 \
            ref={input.adapters} \
            right \
            int=f \
            2> {log}
        """

rule cutadapt:
    input:
        fastq=rules.add_adapters.output,
        adapters="gruseq.fa",
    output:
        "processed/cutadapt.fq"
    log: "logs/cutadapt.log"
    conda: "env.yaml"
    threads: 10
    benchmark:
        repeat("benchmarks/cutadapt.benchmark.txt", 3)
    shell:
        """
        cutadapt \
            --cores {threads} \
            --minimum-length 10 \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATATGATACTGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATAACTGCGTGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATAGGTCCATGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATAGCTAATTGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATATATCGCTGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATACAATTGTGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATAATCTGATGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATATAGGCTTGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATACTGATCTGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATAGTCAGGTGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATACCAGTATGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATAAGGCGTTGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATATCGATTATTGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATATCGGAACGTGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATATGCGATCTTGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATAAACGAAACTGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATACGAACATATGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATACGCTTTACTGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATACGCCAAGGTGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATACGGGACCTTGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATAACGTACGTTGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATACTCGCCTGTGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATATAGCTGTGTGAGACGTGCAACGAGGAGCAGGC \
            --anywhere CTGACCTTCTCATATACGAGCTTAGAATCGATATGGAAGGGTGAGACGTGCAACGAGGAGCAGGC \
            {input.fastq} \
            > {output} \
            2> {log}
        """

rule trimmomatic:
    input:
        fastq=rules.add_adapters.output,
        adapters="gruseq.fa",
    output:
        "processed/trimmomatic.fq"
    conda: "env.yaml"
    log: "logs/trimmomatic.log"
    threads: 10
    benchmark:
        repeat("benchmarks/trimmomatic.benchmark.txt", 3)
    shell:
        """
        trimmomatic \
            SE \
            -phred33 \
            -threads {threads} \
            {input.fastq} \
            {output} \
            ILLUMINACLIP:gruseq.fa:2:28:10 \
            MINLEN:10 \
            > {log}
        """


rule bbduk:
    input:
        fastq=rules.add_adapters.output,
        adapters="gruseq.fa",
    output:
        "processed/bbduk.fq"
    conda: "env.yaml"
    log: "logs/bbduk.log"
    threads: 10
    benchmark:
        repeat("benchmarks/bbduk.benchmark.txt", 3)
    shell:
        """
        bbduk.sh \
            in={input.fastq} \
            out={output} \
            ref={input.adapters} \
            ktrim=r \
            mink=12 \
            hdist=1 \
            minlen=10 \
            threads={threads} \
            2> {log}
        """

rule fastp:
    input:
        fastq=rules.add_adapters.output,
        adapters="gruseq.fa",
    output:
        fq="processed/fastp.fq",
        html="processed/fastp.html",
        json="processed/fastp.json",
    conda: "env.yaml"
    log: "logs/fastp.log"
    threads: 10
    benchmark:
        repeat("benchmarks/fastp.benchmark.txt", 3)
    shell:
        """
        fastp \
            --in1 {input.fastq} \
            --out1 {output.fq} \
            --adapter_fasta {input.adapters} \
            --thread {threads} \
            --html {output.html} \
            --json {output.json} \
            --length_required 10 \
            2> {log}
        """

rule grade:
    input:
        "processed/{tool}.fq"
    output:
        "grades/{tool}.grade.txt"
    conda: "env.yaml"
    shell:
        """
        addadapters.sh \
            in={input} \
            grade \
            > {output}
        """

