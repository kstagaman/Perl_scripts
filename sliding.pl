#!/usr/bin/perl
# sliding.pl
use strict; use warnings;

die "usage: sliding.pl <window> <seq>" unless @ARGV == 2;

my ($window, $seq) = @ARGV;

for (my $i = 0; $i < length($seq) - $window + 1; $i++) {
	my $gc_count = 0;
	for (my $j = 0; $j < $window; $j++) {
		my $nt = substr($seq, $i + $j, 1);
		$gc_count++ if $nt =~ /[GC]/i;
	}
	printf "%d\t%.3f\n", $i, $gc_count/$window;
}