#!/usr/bin/perl
# split_repseqs_by_smpl.pl
use strict; use warnings;

my $usage = "\n\tsplit_repseqs_by_smpl.pl <Uclust FASTA file>\n\n";

die $usage unless @ARGV == 1;

open IN, "<$ARGV[0]" or die "\n\tError: cannot open $ARGV[0]\n\n";

my %curr_rep_seq;
my $count = 0;
print "working...\n";

while (<IN>) {

	if ($_ =~ /^\>\d+\|\*\|/) {
		my ($sample)    = /\|([mz][abcd]\d{2}):/;
		my ($rep_clust) = /^\>(\d+)/;
		my ($rep_id)    = /$sample:(\S+)/;
		my $rep_seq = <IN>;
		chomp $rep_seq;

		$curr_rep_seq{clust} = $rep_clust;
		$curr_rep_seq{id}    = $rep_id;
		$curr_rep_seq{seq}   = $rep_seq;

		open OUT, ">>$sample.VJ_rep_seqs.fa" or die "\n\tError: cannot write to $sample.VJ_rep_seqs.fa\n\n";
		print OUT "\>$rep_clust:$rep_id\n$rep_seq\n";
		close OUT;
		$count++;
		if ($count % 10000 == 0) {print "\r\t$count\trep seqs written"}
	}
	elsif ($_ =~ /^\>$curr_rep_seq{clust}\|\d/) {
		my ($sample) = /\|([mz][abcd]\d{2}):/;

		open OUT, ">>$sample.VJ_rep_seqs.fa" or die "\n\tError: cannot write to $sample.VJ_rep_seqs.fa\n\n";
		print OUT "\>$curr_rep_seq{clust}:$curr_rep_seq{id}\n$curr_rep_seq{seq}\n";
		close OUT;
	}
}
close IN;
print "\n";