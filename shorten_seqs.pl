#!/usr/bin/perl
# shorten_seqs.pl
use strict; use warnings;

# Use this script to remove a certain number of base pairs from the beginning <bol> or end <eol> of sequences (e.g. 5 or 6 bp barcodes)
# in a fasta file.

my ($usage) = "Usage: shorten_seqs.pl <bol/eol> <num bp> <fasta file>\n";
die $usage unless @ARGV == 3;
die $usage unless $ARGV[0] eq "bol" or $ARGV[0] eq "eol";
die $usage unless $ARGV[1] =~ /^\d+$/;

my ($filename) = $ARGV[2] =~ /^(\S+)\.r*e*m*\.*fa/;
my ($extension) = $ARGV[2] =~ /\.(r*e*m*\.*fas*t*a*_*[12]*)/;

open IN, "<$ARGV[2]" or die "Error: cannot open $ARGV[2]\n";
open OUT, ">$filename.rm$ARGV[1]$ARGV[0].$extension" or die "Error: cannot create $filename.rm$ARGV[1]$ARGV[0].$extension\n";

while (<IN>) {

	if ($_ =~ /^\>/) {
		my ($id) = $_;
		chomp $id;
		$_ = <IN>;
		my ($full_seq) = $_;
		chomp $full_seq;
		my ($seq);

		if ($ARGV[0] eq "bol") {
			($seq) = substr $full_seq, $ARGV[1]; 
		}
		else {
			($seq) = substr $full_seq, 0, -$ARGV[1];
		}

		print OUT "$id\n$seq\n";
	}
}

close IN; close OUT;