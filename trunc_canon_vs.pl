#!/usr/bin/perl
# trunc_canon_vs.pl
use strict; use warnings;

open IN, "</Users/keaton/Desktop/Igm_classify_seqs_v_by_ksize/V.fa" or die "Error: cannot open V.fa";
open OUT, ">/Users/keaton/Desktop/Igm_classify_seqs_v_by_ksize/V_trunc.fa" or die "Error: cannot creat V_trunc.fa";

while (<IN>) {
	if ($_ =~ /^\>/) {
		my ($id) = $_;
		chomp $id;
		$_ = <IN>;
		my ($fullseq) = $_;
		chomp $fullseq;
		my ($seq) = substr($fullseq, 0, 84);
		print OUT "$id\n$seq\n";
	}
}

close IN; close OUT;