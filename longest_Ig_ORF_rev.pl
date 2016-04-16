#!/usr/bin/perl
# longest_Ig_ORF_rev.pl
use strict; use warnings;

die "Usage: <fasta reverse reads file>\n" unless @ARGV == 1;

open(IN, "<$ARGV[0]") or die "Error: cannot open file\n";
my ($tag) = $ARGV[0] =~ /(.+)\.fa/;
open(OUT, ">$tag\_translations\.fa");

my @aaseqs;
my $line_count = 0;
my @ids;

while (<IN>) {
	my @seqs;
	if ($_ =~ /^\>/) {		# get fasta id tag for each nt seq
		my $id = $_; 
		chomp $id;
		push(@ids, $id);
	}
	
	else {
		$seqs[0] = $_;	# start with full sequence, this will be traslated from reading frame 1
		chomp @seqs;
		$seqs[1] = substr($seqs[0], 1, length($seqs[0]));	# get seq minus 1st nt for reading frame 2
		$seqs[2] = substr($seqs[0], 2, length($seqs[0]));	# get seq minus first 2 nt for reading frame 3
	
		foreach my $seq (@seqs) {
			my $aaseq = translate($seq);	# translate sequence in 3 reading frames
			if (@aaseqs == 0) {			
				push (@aaseqs, $aaseq) unless $aaseq =~ /\*/;
				print OUT "$ids[$line_count]\n";  # print seq id to out file
				print OUT "$aaseq\n";	# if this is the first aa seq without a stop codon, write to the out file
			}
			elsif ($aaseq !~ /\*/ and $aaseqs[0] !~ /$aaseq/ ) {
				splice (@aaseqs, 0, 1, $aaseq);
				print OUT "$ids[$line_count]\n";  # print seq id to out file
				print OUT "$aaseq\n";	# if the sequence has no stop codon, and doesn't match the prev seq, print to out file
			}
		}
		$line_count++;
		if ($line_count % 1000 == 0) {print "$line_count lines completed\n"}
	}
}

close IN; close OUT;



sub translate {
	my ($seq) = @_;
	my @aas;
	my $aa;
	for (my $i = 0; $i < length($seq) - 2; $i +=3) {
		my $codon = substr($seq, $i, 3);
		if    ($codon =~ m/[TU][TU][TUCY]/)             {$aa = 'F';}
		elsif ($codon =~ m/[TU][TU][AGR]/)              {$aa = 'L';}
		elsif ($codon =~ m/C[TU][ACGTUNMRWSYKVHDB]/)    {$aa = 'L';}
		elsif ($codon =~ m/A[TU][TUCAMWYH]/)            {$aa = 'I';}
		elsif ($codon =~ m/A[TU]G/)                     {$aa = 'M';}
		elsif ($codon =~ m/G[TU][ACGTUNMRWSYKVHDB]/)    {$aa = 'V';}
		elsif ($codon =~ m/[TU]C[ACGTUNMRWSYKVHDB]/)    {$aa = 'S';}
		elsif ($codon =~ m/AG[TUCY]/)	         	    {$aa = 'S';}
		elsif ($codon =~ m/CC[ACGTUNMRWSYKVHDB]/) 		{$aa = 'P';}
		elsif ($codon =~ m/AC[ACGTUNMRWSYKVHDB]/) 		{$aa = 'T';}
		elsif ($codon =~ m/GC[ACGTUNMRWSYKVHDB]/) 		{$aa = 'A';}
		elsif ($codon =~ m/[TU]A[TUCY]/)			 	{$aa = 'Y';}
		elsif ($codon =~ m/[TU]A[AGR]/)				 	{$aa = '*';}
		elsif ($codon =~ m/CA[TUCY]/)			 		{$aa = 'H';}
		elsif ($codon =~ m/CA[AGR]/)		     		{$aa = 'Q';}
		elsif ($codon =~ m/AA[TUCY]/)				 	{$aa = 'N';}
		elsif ($codon =~ m/AA[AGR]/)			 		{$aa = 'K';}
		elsif ($codon =~ m/GA[TUCY]/)			 		{$aa = 'D';}
		elsif ($codon =~ m/GA[AGR]/)			 		{$aa = 'E';}
		elsif ($codon =~ m/[TU]G[TUCY]/)			 	{$aa = 'C';}
		elsif ($codon =~ m/[TU]GA/)				 		{$aa = '*';}
		elsif ($codon =~ m/[TU]GG/)				 		{$aa = 'W';}
		elsif ($codon =~ m/CG[ACGTUNMRWSYKVHDB]/) 		{$aa = 'R';}
		elsif ($codon =~ m/AG[TUCY]/)			 		{$aa = 'S';}
		elsif ($codon =~ m/AG[AGR]/)			 		{$aa = 'R';}
		elsif ($codon =~ m/GG[ACGTUNMRWSYKVHDB]/) 		{$aa = 'G';}
		else 										 	{$aa = 'X';}
	    push(@aas, $aa);
	}
	my $aaseq = join("", @aas);
	return $aaseq;
}
