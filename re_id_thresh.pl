#!/usr/bin/perl
# re_id_thresh.pl
use strict; use warnings;

# use this script to insert V, D, and J into thresh* output from Weinstein et al.

die "Usage: re_id_thresh.pl <thresh fasta file>\n" unless @ARGV == 1;

open IN, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";
open OUT, ">$ARGV[0].vdj" or die "Error: cannot create $ARGV[0].vdj\n";

while (<IN>) {
	if ($_ =~ /^\>/) {
		my ($id) = $_ =~ /^(\>.+\;)\d{1,2}\;\d\;\d\;\d{1,3}\;\d{3}/;
		my ($raw_v)  = $_ =~ /^\>.+\;(\d{1,2})\;\d\;\d\;\d{1,3}\;\d{3}/;
		my ($raw_d)  = $_ =~ /^\>.+\;\d{1,2}\;(\d)\;\d\;\d{1,3}\;\d{3}/;
		my ($raw_j)  = $_ =~ /^\>.+\;\d{1,2}\;\d\;(\d)\;\d{1,3}\;\d{3}/;
		my $v = $raw_v + 1;
		my $d = $raw_d + 1;
		my $j = $raw_j + 1;
		$_ = <IN>;
		my ($seq) = $_ =~ /^(\w+)/;
		# print "$id\V$v\D$d\J$j$ms\n$seq\n";
		print OUT "$id","V$v\;","D$d\;","J$j\n$seq\n" unless !$seq;
	}
}
close IN; close OUT;