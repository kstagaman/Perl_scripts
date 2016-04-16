#!/usr/bin/perl
# uc_fasta.pl
use strict; use warnings;

# use this script to capitalize the sequences in a fasta file

die "Usage: uc_fasta.pl <fasta file>\n" unless @ARGV == 1;

open IN, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";
open OUT, ">$ARGV[0].uc" or die "Error: cannot create $ARGV[0].uc\n";

while (<IN>) {
	if ($_ =~ /^\>/) {
		my ($id) = $_ =~ /(.+)/;
		$_ = <IN>;
		my ($seq) = $_ =~ /^([acgt]+)/;
		my ($ucseq) = uc($seq);
		print OUT "$id\n$ucseq\n";
	}
}
close IN; close OUT;
