#!/usr/bin/perl
# seqdump.pl
use strict; use warnings;


my $usage = "Usage: seqdump.pl <fasta file> <gene id>";

die $usage unless @ARGV == 2;

open IN, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]";
open OUT, ">$ARGV[0].1" or die "Error: cannot create $ARGV[0].1";

while (<IN>) {

	if ($_ =~ /^\>/) {
		my ($genus) = $_ =~ /\[(\w{2})/;
		my ($species) = /\[\w+\s(\w)/;
		my ($prot_id) = /\|(NP_\d+\.*\d*)\|/;
		print OUT ">$ARGV[1]_$genus$species\_$prot_id\n";

	} else {
		my ($seq_line) = /([A-Z]+)/;
		print OUT "$seq_line\n";
	}
	
}

close IN; close OUT;