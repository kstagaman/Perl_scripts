#!/usr/bin/perl
# match_seqs.pl
use strict; use warnings;

# use this script to see if two different fasta files have matching sequences and print the matching seqs to the outfile. In this case, the sequences are given the id from the 1st fasta file which is appended with the J segment assigned to it in the 2nd file

die "Usage: match_seqs.pl <fasta file 1> <fasta file 2>\n" unless @ARGV == 2;

open FA1, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";
open FA2, "<$ARGV[1]" or die "Error: cannot open $ARGV[1]\n";

my(%seq_id1s, %seq_id2s);

while (<FA1>) {
	if ($_ =~ /^\>/) {
		my ($id) = $_ =~ /(\>.+)/;
		$_ = <FA1>;
		my ($seq) = $_ =~ /([AGCT]+)/;
		# print "$seq\n";
		$seq_id1s{$seq} = $id;
	}
}

while (<FA2>) {
	if ($_ =~ /^\>/) {
		my ($id) = $_ =~ /(\>.+)/;
		# print "$id\n";
		$_ = <FA2>;
		my ($seq) = $_ =~ /([AGCT]+)/;
		# print "$seq\n";
		$seq_id2s{$seq} = $id unless !$seq;
	}
}

close FA1; close FA2;

open OUT, ">$ARGV[0].thresh_jsegs" or die "Error: cannot create $ARGV[0].thresh_jsegs\n";

my @seq1s = keys %seq_id1s;
my @seq2s = keys %seq_id2s;

foreach my $seq1 (@seq1s) {
	# print "$seq1\n";
	foreach my $seq2 (@seq2s) {
		if ($seq2 =~ /$seq1/) {
			my ($jseg) = $seq_id2s{$seq2} =~ /^\>.+\;\d{1,2}\;\d\;(\d)\;\d\;\d{3}/;
			print "$seq_id1s{$seq1}J$jseg\n$seq1\n";
			print OUT "$seq_id1s{$seq1}J$jseg\n$seq1\n";
		}
	}
}

close OUT;