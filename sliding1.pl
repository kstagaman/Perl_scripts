#!/usr/bin/perl
# sliding1.pl
use strict; use warnings;
use Library;

die "usage: sliding.pl <window> <seq>" unless @ARGV == 2;
my ($window, $seq) = @ARGV;
for (my $i = 0; $i < length($seq) - $window + 1; $i++) {
	my $subseq = substr($seq, $i, $window);
	printf "%d\t%.3f\n", $i, Library::gc($subseq);
}