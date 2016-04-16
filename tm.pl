#!/usr/bin/perl
# tm.pl
use strict; use warnings;

while (my $seq = <>) {
	chomp($seq);
	my $tm = tm($seq);
	print "Tm = $tm\n";
}

# calculate Tm
sub tm {
	my $seq = shift;
	my $A = $seq =~ tr/aA/aA/;
	my $C = $seq =~ tr/cC/cC/;
	my $G = $seq =~ tr/gG/gG/;
	my $T = $seq =~ tr/tT/tT/;
	my $tm = 2 * ($A + $T) + 4 * ($C + $G); # simple Tm formula
	return($tm)
}
