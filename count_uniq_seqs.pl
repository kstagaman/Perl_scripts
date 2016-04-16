#!/usr/bin/perl
# count_uniq_seqs.pl
use strict; use warnings;

my $infile = $ARGV[0];

open IN, "<$infile" or die "\n\tError: cannot open $infile\n\n";

my $count = 0;

while (<IN>) {

	if ($_ =~ /^\>/){
		my ($abund) = /N(\d+)/;
		$count += $abund;
	}
}

print "\t$infile: $count\n";