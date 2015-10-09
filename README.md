## Simulating NGS Reads:
    
##### Produce reads:
- There are two scripts:
    -     `sim.pl/sim.py        ## distributes mutations randomly`
    -     `simUniform.pl/simUniform.py ## distributes mutations uniformaly per base in fastq file`
- Run the script eg: `perl sim.pl`. For more information run `perl sim.pl --help` or `python3 sim.py`
- Following Output files are generated by each script

>      read.fq     ## simulated reads without mutation
>      readSNV.fq  ## simulated reads with mutation
>      pos.bed     ## positions in genome of the reads


##### Perform Alignment:
- Run the following commands

>        bwa aln -t 8 ref/1.fa readSNV.fq > readSNV.sai
>        bwa samse ref/1.fa readSNV.sai readSNV.fq > readSNV.sam
>        samtools view -bT ref/1.fa readSNV.sam > readSNV.bam

##### Compare positions of simulated reads vs reads aligned using bedtools:
    
>      bamToBed -i readSNV.bam|awk '{print$1,"\t",$2,"\t",$3,"\t",$6}' >readSNV.bed
>      grep -v '-' readSNV.bed >tmp.bed && mv tmp.bed readSNV.bed ## remove reads mapped to -ve strand
>      intersectBed -u -f 0.075 -a pos.bed -b readSNV.bed |wc -l  ## no. of overlapped reads  min overlap 75%
>      intersectBed -v  -a pos.bed -b readSNV.bed |wc -l          ## reads aligned to different position than simulated from

