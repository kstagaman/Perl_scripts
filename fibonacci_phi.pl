#!/usr/bin/perl
# fibonacci_phi.pl
use strict; use warnings;

die "Usage: fibonacci_phi.pl <number>\n" unless @ARGV == 1;

my $n = $ARGV[0];
my $x = 1;
my $y = 1;

print "$x\n";

for (my $i = 0; $i < $n; $i++) {
	my $phi = $y / $x;
	print "\t$phi\n$y\n";
	my $z = $x + $y;
	$x = $y;
	$y = $z;
}
