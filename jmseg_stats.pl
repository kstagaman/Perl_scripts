#!/usr/bin/perl
# jmseg_stats.pl
use strict; use warnings;

die "Usage: jmseg_stats.pl" unless @ARGV == 0;

my @taxonfiles = `ls *.taxonomy`;
chomp @taxonfiles;

open OUT, ">Stats_for_IgM_diversity.csv" or die "Error: cannot create ouput file\n";
print OUT "Ig,tank,fish,dpf,std_length,sIg_RQ,num_seqs,freq_Jm1,freq_Jm2,freq_Jm3,freq_Jm4,freq_Jm5\n";

foreach my $taxonfile (@taxonfiles) {
	my ($ig)   = $taxonfile =~ /distinct_(Ig[MZ]2*)/;
	my ($tank) = $taxonfile =~ /[MZ]2*_([ABCD])_/;
	my ($fish) = $taxonfile =~ /[ABCD]_(\d{2}\.*\d*)\./;
	my ($jm1, $jm2, $jm3, $jm4, $jm5, $totalseqs) = (0, 0, 0, 0, 0);
	
	open IN, "<$taxonfile" or die "Error: cannot open $taxonfile\n";
	
	while (<IN>) {
		my ($jseg) = $_ =~ /95\s+(Jm\d)/;
		# print "$jseg\n";
		$totalseqs++;
		if    ($jseg =~ /Jm1/) {$jm1++}
		elsif ($jseg =~ /Jm2/) {$jm2++}
		elsif ($jseg =~ /Jm3/) {$jm3++}
		elsif ($jseg =~ /Jm4/) {$jm4++}
		elsif ($jseg =~ /Jm5/) {$jm5++}
	}
	
	my $freqjm1 = $jm1 / $totalseqs;
	my $freqjm2 = $jm2 / $totalseqs;
	my $freqjm3 = $jm3 / $totalseqs;
	my $freqjm4 = $jm4 / $totalseqs;
	my $freqjm5 = $jm5 / $totalseqs;
	
	print OUT "$ig,$tank,$fish,75,,,$totalseqs,$freqjm1,$freqjm2,$freqjm3,$freqjm4,$freqjm5\n";
}
