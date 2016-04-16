#!/usr/bin/perl
# filemunge.pl
use strict; use warnings;

open(IN, "<$ARGV[0]") or die "error reading $ARGV[0] for reading";
open(OUT, ">$ARGV[0].munge") or die "error creating $ARGV[0].munge";
while (<IN>) {
	chomp;
	my $rev = reverse $_;
	print OUT "$rev\n";
}
close IN;
close OUT;