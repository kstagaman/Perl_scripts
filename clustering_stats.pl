#!/usr/bin/perl
# clustering_stats.pl
use strict; use warnings;

# use this script after running uclust and split_clusters.pl to create a directory filled with clustered FASTA files
# This script must be run in the directory containing the target FASTA files

my $usage = "\n\tUsage: clustering_stats.pl\n\nRun this script in the directory containing clustered FASTA files\n\n";
die $usage unless @ARGV == 0;

my @files = glob "*.fa";
# if (grep /^clustering_stats.csv$/, glob "*") {die "\n\tError: clustering_stats.csv already exists in this directory\n\n"}

open OUT, ">clustering_stats.csv" or die "\n\tError: cannot create clustering_stats.csv\n\n";
print OUT "cluster,primer,primer.count,avg.score\n";

foreach my $file (@files) {
	my %primer_counts;
	my %sum_primer_scores;
	my ($cluster) = $file =~ /clust_(\d+)/; 
	open IN, "<$file" or die "\n\tError: cannot open $file\n\n";

	while (<IN>) {

		if ($_ =~ /^\>/) {
			my ($primer) = /((fwd_\d{1,2}|rev_[mz]|no_hit))/;
			my ($score)  = /\((\S+)\)$/;
			if (!$score) {$score = "NA"}
			$primer_counts{$primer}++;
			$sum_primer_scores{$primer} += $score unless $primer eq "no_hit" or $score eq "NA";
			if ($score eq "NA") {$sum_primer_scores{$primer} = "NA"}
		}
	}

	my @primers = keys %primer_counts;
	my %avg_primer_scores;

	foreach my $primer (@primers) {
		$avg_primer_scores{$primer} = $sum_primer_scores{$primer} / $primer_counts{$primer}
		unless $primer eq "no_hit" or $sum_primer_scores{$primer} eq "NA";
		if ($sum_primer_scores{$primer} eq "NA") {
			$avg_primer_scores{$primer} = $sum_primer_scores{$primer};
		}

	}

	foreach my $primer (@primers) {
		my $primer_num = substr($primer, 4);
		my $twodprimer;
		if (length($primer_num) < 2 and $primer_num ne "[mz]") {
			$twodprimer="fwd_0$primer_num";
		} else {
			$twodprimer = $primer;
		}
		print OUT "$cluster,$twodprimer,$primer_counts{$primer},";
		if ($primer eq "no_hit") {print OUT "NA\n"}
		else 					 {print OUT "$avg_primer_scores{$primer}\n"}
	}
}