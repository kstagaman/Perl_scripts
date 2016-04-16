#!/usr/bin/perl
# make_classify_seqs_taxonomy_file.pl
use strict; use warnings;

# use this script to make a .taxonomy file from a fasta file

die "Usage: make_classify_seqs_taxonomy_file.pl <fasta file> <output name>\n" unless @ARGV == 2;

open IN, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";
open TAX, ">$ARGV[1].taxonomy" or die "Error: cannot create $ARGV[1].taxonomy\n";
open FA, ">$ARGV[1].fa" or die "Error: cannot create $ARGV[1].fa\n";

while (<IN>) {
	if ($_ =~ /^\>/) {
		my ($id) = $_ =~ /^\>(\S+)\s/;
		my ($taxonomy) = $_ =~ /\|.+\|.+\|.+\|(.+)$/;
		$taxonomy =~ tr/ /_/;
		print FA "$id\n";
		print TAX "$id\t$taxonomy\;\n";
	}
	elsif ($_ =~ /^[ACGTN]/) {
		my ($seq_line) = $_;
		print FA "$seq_line";
	}
}
close IN; close TAX; close FA;  