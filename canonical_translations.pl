#!/usr/bin/perl
# canonical_translation.pl
use strict; use warnings;

# use with directory containing .rev.fa files from order_amplicons.pl

my @IgMfiles = `ls IgM*`;
my @IgZ2files = `ls IgZ2*`;
chomp (@IgMfiles, @IgZ2files);
open (MAA, ">canonically_translated_IgM_revreads.txt");
open (Z2AA, ">canonically_translated_IgZ2_revreads.txt");


foreach my $IgMfile (@IgMfiles) {
	open (MNT, "<$IgMfile") or die "Error: cannot open one or more IgM files";
	
	while (my $line = <MNT>) {
		my @seqs;

		if ($line =~ /^\w/) {
			($seqs[0]) = $line;
			chomp @seqs;
			($seqs[1]) = substr($seqs[0], 1, length($seqs[0]));
			($seqs[2]) = substr($seqs[0], 2, length($seqs[0]));
			
			foreach my $seq (@seqs) {
				my $aaseq = translate($seq);

				if ($aaseq =~ /LSQC/) {
					print MAA "$aaseq\n";
					print "$aaseq\n";
				}
			}
		}
	}
	close MNT;
}
close MAA;

foreach my $IgZ2file (@IgZ2files) {
	open (Z2NT, "<$IgZ2file") or die "Error: cannot open one or more IgZ2 files";
	
	while (my $line = <Z2NT>) {
		my @seqs;

		if ($line =~ /^\w/) {
			($seqs[0]) = $line;
			chomp @seqs;
			($seqs[1]) = substr($seqs[0], 1, length($seqs[0]));
			($seqs[2]) = substr($seqs[0], 2, length($seqs[0]));
			
			foreach my $seq (@seqs) {
				my $aaseq = translate($seq);
				
				if ($aaseq =~ /MSQC/) {
					print Z2AA "$aaseq\n";
					print "$aaseq\n";
				}
			}
		}
	}
	close Z2NT;
}
close Z2AA;


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
