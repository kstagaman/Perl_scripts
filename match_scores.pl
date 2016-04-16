#!/usr/bin/perl
# match_scores.pl
use strict; use warnings;

# use this script in same directory as V_ or J_query_\d.txt files

die "Usage: match_scores.pl <output title>" unless @ARGV == 1;

my @query_files = `ls *_query_*.txt`;
chomp @query_files;
my $i = 1;

open OUT, ">$ARGV[0].csv";
print OUT "query\, id\, score\,\n";

foreach my $query_file (@query_files) {
	open IN, "<$query_file" or die "Error: cannot open one or more query files\n";
	while (<IN>) {
		my ($id) =    $_ =~ /^(\d+\:N\d+\:bp\d+\:)\t/;
		my ($score) = $_ =~ /\t(\d+\.*\d*)$/;
		print OUT "$i\, $id\, $score\,\n";
	}
	$i++;
	close IN;
}

close OUT;