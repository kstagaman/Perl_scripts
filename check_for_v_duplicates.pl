#!/usr/bin/perl
# check_for_v_dupilicates.pl
use strict; use warnings;

# use this script to check the results of blastn_v_results.pl for sequences that got two or more V segments assigned to them

die "Usage: check_for_v_duplicates.pl <check_v_file.txt>\n" unless @ARGV == 1;

open IN, "<$ARGV[0]" or die "Error: cannot open fasta file\n";
open OUT, ">duplicate_v_assignments.txt" or die "Error: cannot create output file\n";

my @lines1;
my @lines2;
my $i = 0;

while (<IN>) {
	my ($index) = $_ =~ /^(\d+)\:/;
	my ($sample) = $_ =~ /\:(Ig[MZ]2*_[ABCD]_\d{2}\.*\d*)\t/;
	my ($vseg) = $_ =~ /\t(\d{1,2})\t/;
	my ($score) = $_ =~ /\t(\d+\.*\d*)\n$/;
	$lines1[$i] = {id => $index, sample => $sample, v_seg => $vseg, score => $score};
	$lines2[$i] = {id => $index, sample => $sample, v_seg => $vseg, score => $score};
	$i++;
}

close IN;



for (my $j = 0; $j < @lines1; $j++) {
#	print "$lines1[$j]->{id}\:V$lines1[$j]->{v_seg} score\:$lines1[$j]->{score}\n";
	for (my $k = $j; $k < @lines2; $k++) {
#		print "$lines2[$k]->{id}\:V$lines2[$k]->{v_seg} score\:$lines2[$k]->{score}\n";
		if ($lines1[$j]->{id} =~ /$lines2[$k]->{id}/) {
			if ($lines1[$j]->{score} > $lines2[$k]->{score}) {
				print OUT "$lines1[$j]->{id}\:$lines1[$j]->{sample}\:V$lines1[$j]->{v_seg} score\:$lines1[$j]->{score}\t\(V$lines2[$k]->{v_seg} score\:$lines2[$k]->{score}\)\n";
			}
			elsif ($lines1[$j]->{score} < $lines2[$k]->{score}) {
				print OUT "$lines2[$k]->{id}\:$lines2[$k]->{sample}\:V$lines2[$k]->{v_seg} score\:$lines2[$k]->{score}\t\(V$lines1[$j]->{v_seg} score\:$lines1[$j]->{score}\)\n";
			}
			elsif ($lines1[$j]->{score} =~ $lines2[$k]->{score} and $lines1[$j]->{v_seg} !~ $lines2[$k]->{v_seg}) {
				print OUT "$lines1[$j]->{id}\:$lines1[$j]->{sample}\:V$lines1[$j]->{v_seg}\:V$lines2[$k]->{v_seg} score\:$lines1[$j]->{score}\n";
			}
		}
	}
}

close OUT;