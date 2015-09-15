## Simulating NGS Reads

### Produce reads:
- Run the script `sim.pl`. For more information run `sim.pl --help`

### Generate Alignment and comapre
- Run the following commands :

      bwa aln -t 8 ref/1.fa readSNV.fq > readSNV.sai
      bwa samse ref/1.fa readSNV.sai readSNV.fq > readSNV.sam
      samtools view -bT ref/1.fa readSNV.sam > readSNV.bam

##Comparing reads simulated vs reads aligned
    
      /apps/bedtools/2.4.2/BEDTools/bin/bamToBed -i readSNV.bam|awk '{print$1,"\t",$2,"\t",$3,"\t",$6}' >readSNV.bed
      grep -v '-' readSNV.bed >tmp.bed && mv tmp.bed readSNV.bed ## remove reads mapped to -ve strand
      /apps/bedtools/2.4.2/BEDTools/bin/intersectBed -u -f 0.075 -a pos.bed -b readSNV.bed |wc -l ##no. of overlapped reads  min overlap 75%
     /apps/bedtools/2.4.2/BEDTools/bin/intersectBed -v  -a pos.bed -b readSNV.bed |wc -l ## reads aligned to different position than simulated from

