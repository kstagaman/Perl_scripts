#!/usr/bin/perl
# float.pl
use strict; use warnings;

my $x = 0.1 + 0.1 + 0.1;
my $y = 0.3;
print $x, "\t", $y, "\t", $x - $y, "\n";
my $threshold = 0.001;
if (abs($x - $y) < $threshold) {print "close enough\n"}