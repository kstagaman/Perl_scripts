#!/usr/bin/perl
# shuffle2.pl
use strict; use warnings;

die "usage: testproj.pl <dna sequence>\n" unless @ARGV == 1;
my ($sequence) = @ARGV;
my @shuff_seq = ();
my @seq = split("", $sequence);

while (@seq) {
	my $seqlength = @seq;
	my $pos = int rand $seqlength;
	my $val = splice(@seq, $pos, 1);
	push(@shuff_seq, $val);
}
print "@shuff_seq\n";