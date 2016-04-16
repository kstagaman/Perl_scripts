#!/usr/bin/perl
# conditional.pl
use strict; use warnings;

my ($x, $y) = @ARGV;
if ($x <=> $y) {
	print "a\n";
} else {
	print "b\n";
}