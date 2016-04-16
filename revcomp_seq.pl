#!/usr/bin/perl
# revcomp_seq.pl
use strict; use warnings;

die "Usage: revcomp_seq.pl <sequence>\n" unless @ARGV == 1;

my $seq = uc $ARGV[0];
my $revseq = reverse $seq;
$revseq =~ tr/ACGTURYKMBVDH/TGCAAYRMKVBHD/;
print "\n\t$revseq\n\n";