#!/usr/bin/perl
# discard_short_reads.pl
use strict; use warnings;

# Use this script to remove any sequences below the indicated threshold from fasta seqs.

die "Usage: discard_short_reads.pl <fasta file> <threshold>\n" unless @ARGV == 2;

open IN, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";
my ($filename) = $ARGV[0] =~ /(\S+)\.fa/;
my ($extension) = $ARGV[0] =~ /\.(r*e*m*\.*fa_*[12]*)/;

open OUT, ">$filename.gt$ARGV[1]bp.$extension" or die "Error: cannot create $filename.gt$ARGV[1].fa\n";

while (<IN>) {
	if ($_ =~ /^\>/) {
		my ($id) = $_;
		chomp $id;
		$_ = <IN>;
		my ($seq) = $_;
		chomp $seq;
		if (length($seq) >= $ARGV[1]) {
			print OUT "$id\n$seq\n";
		}
	}
}

close IN; close OUT;