#!/usr/bin/env python
import sys
import re
import random
import argparse
parser = argparse.ArgumentParser(description='This program simulates reads from a given genome')
parser.add_argument( '-l', "--read_length", type=int, help='expected read length', required=True)
parser.add_argument( '-n', "--read_number", type=int, help='expected number of readsh', required=True)
parser.add_argument( '-e', "--error_rate", type=float, help='expected error rate', required=True)
parser.add_argument( '-f', "--genome", type=str, help='genome fasta file', required=True)
args = parser.parse_args()
read_length = args.read_length
read_number = args.read_number
error_rate = args.error_rate
genome = args.genome

dna = ""
with open(genome,"rt") as f:
     for line in f:
         if not re.match(">",line):
            line = line.rstrip("\n")
            dna = dna + line
basecount = len(dna)

def variant(base):
    baselist = ["A","T","G","C"]
    if base == "N":
       return base
    else:
        baselist.remove(base)
        sub = (random.choice(baselist))
        return sub
snv = (error_rate * read_length * read_number)
no_of_reads = read_number

def writeFile(of):
    of.write("@HISEQ/1:" + str(i+1) + "\n")
    of.write("".join(fasta) + "\n")
    of.write("+" + "\n")
    of.write("?" * read_length + "\n")

with open("read.fq", "w") as of1:
    with open('readSNV.fq', 'w') as of2:
         with open('pos.bed', 'w') as of3:
            for i in range(no_of_reads):
                pos = (random.randrange(basecount-read_length))
                of3.write("1" + "\t" + str(pos) + "\t" + str(pos+50) + "\t+" + "\n")
                fasta = list(dna[pos:pos+read_length])
                writeFile(of1)
                if i < snv:
                   ranpos = random.randrange(read_length -1)
                   nuc = fasta[ranpos]
                   fasta[ranpos] = variant(nuc)
                   writeFile(of2)
                else:
                    writeFile(of2)
sys.exit(0)
