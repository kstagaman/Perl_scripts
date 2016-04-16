#!/usr/bin/perl
# sequencecheck.pl
use strict; use warnings;

# take sequence from command-line and make upper case
my $seq = uc($ARGV[0]);

if ($seq !~ m/^ATG/) {	# test for start codon
	print_error();
}
elsif($seq !~ m/(TGA|TAG|TAA)$/) {	# test for stop codon
	print_error();
}
elsif($seq !~ m/^[ACGTN]+$/) {	# test for non DNA characters
	print_error();
}
else {
	print "$seq looks like a valid CDS\n";
}

sub print_error {
	print "$ARGV[0] is not a valid sequence for a CDS\n";
	print "It may not start with an ATG start codon\n";
	print "It may not end with a stop codon\n";
	print "It may contain non ATCGN DNA characters\n";
}