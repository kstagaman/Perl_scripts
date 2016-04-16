#!/usr/bin/perl
# calc_avg_seq_length.pl
use strict; use warnings;

# use this script to calculate the average sequence length for a set of seqs in a fasta file

die "Usage: calc_avg_seq_length.pl <fasta file>\n" unless @ARGV == 1;

open IN, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";

my $total_lengths = 0;
my $seq_count = 0;

while (<IN>) {
	if ($_ !~ /^\>/) {
		my ($seq) = $_ =~ /([A-Z]+)/i;
		# print "$seq\n";
		my $length = length $seq;
		# print "$length\n";
		$total_lengths += $length;
		$seq_count++;
	}
}

my $avg_seq_length = $total_lengths / $seq_count;

printf "\nNumber seqs: %d\nAvg seq length: %.2f\n\n", $seq_count, $avg_seq_length;