#!/usr/bin/perl
# check_for_j_duplicates.pl
use strict; use warnings;

# use this script to check the results of blastn_j_results.pl for sequences that got two or more J segments assigned to them

die "Usage: check_for_j_duplicates.pl <check_j_file.txt>\n" unless @ARGV == 1;

open IN, "<$ARGV[0]" or die "Error: cannot open fasta file\n";
open OUT, ">duplicate_j_assignments.txt" or die "Error: cannot create output file\n";

my @lines1;
my @lines2;
my $i = 0;

while (<IN>) {
	my ($index) = $_ =~ /^(\d+)\t/;
	my ($jseg) = $_ =~ /\t(\d)\t/;
	my ($score) = $_ =~ /\t(\d+\.*\d*)\n$/;
	$lines1[$i] = {id => $index, j_seg => $jseg, score => $score};
	$lines2[$i] = {id => $index, j_seg => $jseg, score => $score};
	$i++;
}

close IN;



for (my $j = 0; $j < @lines1; $j++) {
	for (my $k = $j; $k < @lines2; $k++) {
		if ($lines1[$j]->{id} =~ /$lines2[$k]->{id}/) {
			if ($lines1[$j]->{score} > $lines2[$k]->{score}) {
				print OUT "$lines1[$j]->{id}\:J$lines1[$j]->{j_seg} score\:$lines1[$j]->{score}\t\(J$lines2[$k]->{j_seg} score\:$lines2[$k]->{score}\)\n";
			}
			elsif ($lines1[$j]->{score} < $lines2[$k]->{score}) {
				print OUT "$lines2[$k]->{id}\:J$lines2[$k]->{j_seg} score\:$lines2[$k]->{score}\t\(J$lines1[$j]->{j_seg} score\:$lines1[$j]->{score}\)\n";
			}
			elsif ($lines1[$j]->{score} =~ $lines2[$k]->{score} and $lines1[$j]->{j_seg} !~ $lines2[$k]->{j_seg}) {
				print OUT "$lines1[$j]->{id}\:J$lines1[$j]->{j_seg}\:J$lines2[$k]->{j_seg} score\:$lines1[$j]->{score}\n";
			}
		}
	}
}

close OUT;