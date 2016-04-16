#!/usr/bin/perl
# blastn_v_results.pl
use strict; use warnings;

die "Usage: blastn_v_results.pl <blast results file> <candidates fasta file>\n" unless @ARGV == 2;

open BLAST, "<$ARGV[0]" or die "Error: cannot open blast results file\n";
my @query_files;

for (my $i = 1; $i < 40; $i++) {
	open BLAST, "<$ARGV[0]" or die "Error: cannot open blast results file\n";
	while (my $line = <BLAST>) {
		if ($line =~ /Query\=\s+$i\:/) {
#			print "$line";

			open OUT, ">v_query_$i.txt" or die "Error: cannot create ouput";
			push @query_files, "v_query_$i.txt";
			
			while (1) {
				my ($id) = $line =~ /^\s+(\d+\:Ig[MZ]2*_[ABCD]_\d+\.*\d*\:N\d+\:bp\d{2,3})\s+/;
				my ($score) = $line =~ /\:bp\d{2,3}\s+(\d{2,3}\.*\d*)/;
				print OUT "$id\t$score\n" unless (!$id);
				$line = <BLAST>;
				last if ($line =~ /^\>/ or $line =~ /No hits found/);
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
	my ($q_num) = $query_file =~ /(\d{1,2})/;
	while (<QUERY>) {
		my ($index) =  $_ =~ /^(\d+)\:Ig[MZ]2*_[ABCD]_\d+\.*\d*\:N\d+\:bp\d{2,3}/;
		my ($sample) = $_ =~ /^\d+(\:Ig[MZ]2*_[ABCD]_\d+\.*\d*)\:N\d+\:bp\d{2,3}/;
		my ($nbp) =    $_ =~ /^\d+\:Ig[MZ]2*_[ABCD]_\d+\.*\d*(\:N\d+\:bp\d{2,3})/;
		my ($score) =  $_ =~ /^\d+\:Ig[MZ]2*_[ABCD]_\d+\.*\d*\:N\d+\:bp\d{2,3}\t(\d{2,3}\.*\d*)/;
		$queries[$j] = {v_seg => $q_num, id => $index, sample => $sample, nbp => $nbp, score => $score};
		$j++;
	}
	close QUERY;
}

my $count = @queries;
my @good_queries;

for (my $k = 0; $k < $count - 1; $k++) {
	if ($queries[$k]->{score} / $queries[$k+1]->{score} > 1.5 or $queries[$k]->{score} >= 50) {
		push @good_queries, $queries[$k];
	}
}
# open GOOD, ">check_good_queries.txt" or die "Error: cannot creat check good file\n";
# foreach my $good_query (@good_queries) {
#	print GOOD "$good_query->{id}\t$good_query->{v_seg}\t$good_query->{score}\n";
# }
# close GOOD;

open SEQS, "<$ARGV[1]" or die "Error: cannot open sequences file\n";
open OUT, ">v_matched_candidates.fa" or die "Error: cannot create output fasta\n";
open CHECK, ">check_v_file.txt" or die "Error: cannot create check file\n";

my @sorted_queries = sort {$a->{id} <=> $b->{id}} @good_queries;

#foreach my $query (@sorted_queries) {
#	print "$query->{id}\t$query->{v_seg}\t$query->{score}\n";
#}
#my $linecount = 1;
#my $matchcount = 1;

while (my $line = <SEQS>) {
	if ($line =~ /^\>/){
#		if ($linecount % 500 == 0) {print "line count: $linecount\n";}
#		$linecount++;
		my ($seq_id) = $line =~ /^\>(\d+)\:/;
		my $querycount = 1;
		foreach my $query (@sorted_queries) {
#			if ($linecount % 500 == 0 and $querycount % 10000 == 0) {print "\tquery count: $querycount\t$query->{id} $seq_id\n";}
#			$querycount++;
			if ($query->{id} == $seq_id) {
#				print "\t\tmatchcount: $matchcount\n";
#				$matchcount++;
				$line = <SEQS>;
				my ($seq) = $line =~ /([ACGTN]+)/;
				print OUT "\>$query->{id}$query->{sample}$query->{nbp}\:V$query->{v_seg}\:\n$seq\n" unless $seq =~ /^[ACGTN]{1}$/;
				print CHECK "$query->{id}$query->{sample}\t$query->{v_seg}\t$query->{score}\n" unless $seq =~ /^[ACGTN]{1}$/;

			}
		}
	}
 }
close SEQS; close OUT; close CHECK;