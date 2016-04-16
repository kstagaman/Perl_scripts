#!/usr/bin/perl
# blastn_j_results.pl
use strict; use warnings;

# This script takes the results of blasting the canonical J segments against a database comprised of the candidate sequences Tom Conlin put together from the Weinstein (2009) data and uses them to assign a J segment to each sequence (if possible).


die "Usage: blastn_j_results.pl <blast results file> <candidates fasta file>\n" unless @ARGV == 2;

open BLAST, "<$ARGV[0]" or die "Error: cannot open blast results file\n";
my @query_files;

for (my $i = 1; $i < 6; $i++) {
	open BLAST, "<$ARGV[0]" or die "Error: cannot open blast results file\n";
	while (my $line = <BLAST>) {
		if ($line =~ /Query\=.*$i/) {
#			print "$line";

			open OUT, ">j_query_$i.txt" or die "Error: cannot create ouput";
			push @query_files, "j_query_$i.txt";
			
			while (1) {
				my ($id) = $line =~ /^\s+(\d+\:N\d+\:bp\d{2,3}\:)/;
				my ($score) = $line =~ /^\s+\d+\:N\d+\:bp\d{2,3}\:\s+(\d{2,3}\.*\d*)/;
				print OUT "$id\t$score\n" unless (!$id);
				$line = <BLAST>;
				last if ($line =~ /^\>/);
			}
			close OUT;
		}
	}
	close BLAST;
}

my @queries;


my $j = 0;

foreach my $query_file (@query_files) {
	open QUERY, "<$query_file" or die "Error: cannot open query file";
	my ($q_num) = $query_file =~ /(\d)/;
	while (<QUERY>) {
		my ($index) = $_ =~ /^(\d+)\:N\d+\:bp\d{2,3}\:/;
		my ($nbp) = $_ =~ /^\d+(\:N\d+\:bp\d{2,3}\:)/;
		my ($score) = $_ =~ /^\d+\:N\d+\:bp\d{2,3}\:\t(\d{2,3}\.*\d*)/;
		$queries[$j] = {j_seg => $q_num, id => $index, nbp => $nbp, score => $score};
		$j++;
	}
	close QUERY;
}


my $count = @queries;
my @good_queries;

for (my $k = 0; $k < $count - 1; $k++) {
	if ($queries[$k]->{score} >= 80) {
		push @good_queries, $queries[$k];
	}
}


open SEQS, "<$ARGV[1]" or die "Error: cannot open sequences file";
open OUT, ">j_matched_candidates.fa" or die "Error: cannot create output fasta";
open CHECK, ">check_j_file.txt" or die "Error: cannot create check file";

my @sorted_queries = sort {$a->{id} <=> $b->{id}} @good_queries;


while (my $line = <SEQS>) {
	if ($line =~ /^\>/){
		my ($seq_id) = $line =~ /^\>(\d+)\:/;
		foreach my $query (@sorted_queries) {
			if ($query->{id} == $seq_id) {
				$line = <SEQS>;
				my ($seq) = $line =~ /([ACGTN]+)/;
				print OUT "\>$query->{id}$query->{nbp}J$query->{j_seg}\:\n$seq\n" unless $seq =~ /^N{1}$/;
				print CHECK "$query->{id}\t$query->{j_seg}\t$query->{score}\n";
			}
		}
	}
}
close SEQS; close OUT; close CHECK;