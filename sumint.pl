#!/usr/bin/perl
# sumint.pl
use strict; use warnings;

die "usage: sumint.pl <limit>\n" unless @ARGV == 1;
my ($limit) = @ARGV;
my $sum = 0;
for (my $i = 1; $i <= $limit; $i++) {$sum += $i}
print "$sum\n";