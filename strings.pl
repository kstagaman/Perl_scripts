#!/usr/bin/perl
# strings.pl
use strict; use warnings;

my $s1 = "Hello";
my $s2 = "World\n";
my $s3 = $s1 . " " . $s2;
print $s3;
if    ($s1 eq $s2) {print "same string\n"}
elsif ($s1 gt $s2) {print "$s1 is greater than $s2\n"}
elsif ($s1 lt $s2) {print "$s1 is less than $s2\n"}