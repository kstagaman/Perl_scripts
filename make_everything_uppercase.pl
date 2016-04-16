#!/usr/bin/perl
# make_everything_uppercase.pl
use strict; use warnings;

die "Usage: make_everything_uppercase.pl <file> <file> <file>" unless @ARGV == 3;

foreach my $file (@ARGV) {
	open IN, "<$file" or die "Error: cannot open txt file";
	open OUT, ">$file.uc" or die "Error: cannot create output file";
	while (<IN>) {
		my ($line) = uc $_;
		print OUT "$line";
	}
}

close IN; close OUT;

