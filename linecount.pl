#!/usr/bin/perl
# linecount.pl
use strict; use warnings;

my $lines = 0;
my $letters = 0;
while (<>) {
	$lines++;
	$letters += length($_);
}
print "$lines\t$letters\n"; 