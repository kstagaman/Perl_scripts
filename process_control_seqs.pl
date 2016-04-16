#!/usr/bin/perl
# process_control_seqs.pl
use strict; use warnings;

# use to process rev reads from Weinstein et al (thresh... .fasta) so they're more like my rev reads

die "Usage: process_control_seqs.pl <fasta file>\n" unless @ARGV == 1;

open IN, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";
open OUT, ">$ARGV[0].noprimer" or die "Error: cannot create $ARGV[0].noprimer\n";

my ($rev_primer) = 'CTTCGGTTTGTCTCAGTGCA';

while (<IN>) {
	if ($_ =~ /^\>/) {
		my ($id) = $_;
		chomp $id;
		$_ = <IN>;
		my ($seq) = $_ =~ /^(\w+)$rev_primer$/;
		print OUT "$id\n$seq\n" unless !$seq;
	}
}

close IN; close OUT;