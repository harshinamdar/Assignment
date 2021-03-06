#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
my $genome_fasta;
my $read_length;
my $read_number;
my $error_rate;
my $help;
my $man;
GetOptions('genome_fasta=s'  => \$genome_fasta,
           'read_length=i'   => \$read_length,
           'read_number=i'   => \$read_number,
           'error_rate=f'    => \$error_rate,
           'help!'           => \$help,
           );
pod2usage(-verbose => 1)  if ($help);
           pod2usage(-verbose => 2)  if ($man);
           unless ( defined( $genome_fasta ) && defined( $read_length ) )
                  {
                   Pod::Usage::pod2usage( -exitstatus => 1);
                  }

open (my $infile,"<",$genome_fasta)|| die "can't open file: $!";
local $/ = "\n>";  # read by FASTA record
my $Sequence;
my $basecount;
while (my$seq_chunk = <$infile>) {
       chomp $seq_chunk;
       $seq_chunk =~ s/^>*.+\n//;  # remove FASTA header
       $seq_chunk =~ s/\n//g;  # remove endlines
       $Sequence.=$seq_chunk;
      }
close($infile);
my $A=$Sequence=~tr/A/A/;
my $G=$Sequence=~tr/G/G/;
my $T=$Sequence=~tr/T/T/;
my $C=$Sequence=~tr/C/C/;
my $N=$Sequence=~tr/N/N/;
$basecount=($A+$G+$T+$C+$N)-$read_length; # -$read_length: to restrict max rand position and allow last bases to be simulated.

my $count=0;	
my @ranPOS = @{randomNUM($read_number,$basecount)};
open (my $outfile,">","pos.bed")||die "can't open $!";
open (my $outfile1,">","read.fq")||die "can't open $!";
open (my $outfile2,">","readSNV.fq")||die "can't open $!";	
      foreach my $pos(@ranPOS){
        print $outfile "1\t",$pos-1,"\t",$pos+$read_length-1,"\t","+","\n"; ## save read pos as 0-based bed file
	$count++;
        my $fasta=substr($Sequence,$pos,$read_length);
        print $outfile1 "\@HISEQ:".$count.":".$pos."#0/1","\n";
        print $outfile1 $fasta,"\n";
        print $outfile1 "+", "\n";
        print $outfile1 "?" x $read_length,"\n";
        my $snv = $read_number * $read_length * $error_rate; ## calculate no. of bases to be substituted in genome
        if ($count <= $snv){
            my $ran = int(rand($read_length-1));
            my $nuc = substr($fasta,$ran,1);
	    substr($fasta,$ran,1,randomSub($nuc));
            print $outfile2 "\@HISEQ:".$count.":".$pos."#0/1","\n";
            print $outfile2 $fasta,"\n";
            print $outfile2 "+", "\n";
            print $outfile2 "?" x $read_length,"\n";	
	    }
	else {
	      print $outfile2 "\@HISEQ:".$count.":".$pos."#0/1","\n";
              print $outfile2 $fasta,"\n";
              print $outfile2 "+", "\n";
              print $outfile2 "?" x $read_length,"\n";
	     }
	}
close ($outfile);
close ($outfile1);
close ($outfile2);
##Suroutine to return random positions in genome
################################################
sub randomNUM {
    my ($j,$k)= @_;
    my @arrRND;
    for (my $i=0;$i<$j;$i++){
         my $ranNUM = int(rand($k));	
         push @arrRND,$ranNUM;
    }
         return \@arrRND;
}

##Subroutine to return random substitue base: eg. if 'A' then return T or G or C
################################################################################
sub randomSub {
     my $base=$_[0];
     my @chars=("A","G","C","T");
        foreach my$b(@chars){
                if ($b eq "$base"){
                @chars=grep{!/^$base/}@chars;
                my $substitute = @chars[map{rand @chars}(1)];
                return $substitute;
                }
        }
}

=head1 SYNOPSIS

perl sim.pl [options]

  Options:

   --genome_fasta
   --read_length
   --read_number
   --error_rate
   
   Example:
        perl sim.pl --genome_fasta genome.fa --read_length 50 --read_number 100000 --error_rate 0.01

=head1 DESCRIPTION

##
This program simulates single end reads in fastq format from a given genome and also introduces random mutations. 

##

=head1 OPTIONS

=over 4


=item B<--genome_fasta>

Provide reference genome fasta file

=item B<--read_length>

Provide expected read length for simulated reads

=item B<--read_number>

Provide expected number of simulated reads to be produced

=item B<--error_rate>

Provide rate of mutation to be introduced in simulated reads

=back

=head1 COPYRIGHT

This program is free software and can redistributed and/or modified.

=cut

