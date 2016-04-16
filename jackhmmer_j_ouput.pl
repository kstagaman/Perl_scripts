#!/usr/bin/perl
# jackhmmer_j_ouput.pl
use strict; use warnings;

die "Usage: jackhmmer_output.pl <jackhmmer_file.out>\n" unless @ARGV == 1;
open IN, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";
my ($filetag) = $ARGV[0] =~ /(Ig[MZ]2*_[ABCD]_\d{2}\.*\d*)/;
open OUT, ">$filetag\_J_align_stats.txt";

while (<IN>) {

	if ($_ =~ /Query:/) {
		my ($jseg) = $_ =~ /(Jm\d)/;
		print OUT "$jseg\n";
		print OUT "\tRound: 1\t";
	}
	
	if ($_ =~ /Round:\s+\d/) {
		my ($round) = $_ =~ /Round:\s+(\d)/;
		print OUT "\tRound: $round\t";
	}
	
	if ($_ =~ /\(domZ\):/) {
		my ($targets_over_thresh) = $_ =~ /(\d{1,3})/;
		print OUT "Targets: $targets_over_thresh\n";
	}
}

close IN; close OUT;