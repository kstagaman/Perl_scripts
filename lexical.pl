#!/usr/bin/perl
# lexical.pl
use strict; use warnings;

my $x;					# declaration without assignment
$x = 1;
my ($y, $z) = (2, 3);	# you can declare and assign, even as a list
if ($x < $y) {
	my ($z, $q) = (10, 15);
	print "inside: X = $x, Y = $y, Z = $z\n";
}
print "outside: X = $x, Y = $y, Z = $z\n";
print "outside: $x $y $z $q\n";