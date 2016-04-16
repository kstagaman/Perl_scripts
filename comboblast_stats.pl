#!/usr/bin/perl
# comboblast_stats.pl
use strict; use warnings;


# use this script after running comboblast_output.pl to create a directory filled with combo-matched FASTA files
# This script must be run in the directory containing all the target FASTA files

my $usage = "\n\tUsage: comboblast_stats.pl\n\nRun this script in the directory containing clustered FASTA files\n\n";
die $usage unless @ARGV == 0;

my @files = glob "*.fa";
# if (grep /^comboblast_stats.csv$/, glob "*") {die "\n\tError: comboblast_stats.csv already exists in this directory\n\n"}

open IGM, ">comboblast_stats.igm.csv" or die "\n\tError: cannot create comboblast_stats.igm.csv\n\n";
open IGZ, ">comboblast_stats.igz.csv" or die "\n\tError: cannot create comboblast_stats.igz.csv\n\n";
open NOH, ">comboblast_stats.nohit.csv" or die "\n\tError: cannot create comboblast_stats.nohit.csv\n\n";

print IGM "sample,ig,abundance,length,primer,primer.score\n";
print IGZ "sample,ig,abundance,length,primer,primer.score\n";
print NOH "sample,ig,abundance,length,primer,primer.score\n";

foreach my $file (@files) { 
	open IN, "<$file" or die "\n\tError: cannot open $file\n\n";

	while (<IN>) {

		if ($_ =~ /^\>/) {
			my ($sample)  = /:([mz][abcd]\d{2}):/;
			if (!$sample) {$sample = "no_hit"}
			my ($ig) = $sample =~ /^([mz])/ unless $sample eq "no_hit";
			if ($sample eq "no_hit") {$ig = "NA"}
			my ($abund)   = /:N(\d+):/;
			my ($seq_len) = /:(\d+)bp:/;
			my ($primer)  = /:((fwd_\d{1,2}|rev_[mz]|no_hit))/;
			my ($primer_score) = /\((\S+)\)/ unless $primer eq "no_hit";
			if ($primer eq "no_hit") {$primer_score = "NA"}

			if   ($ig eq "m") {
				print IGM "$sample,$ig,$abund,$seq_len,$primer,$primer_score\n";
			} 
			elsif ($ig eq "z") {
				print IGZ "$sample,$ig,$abund,$seq_len,$primer,$primer_score\n";
			}
			else {
				print NOH "$sample,$ig,$abund,$seq_len,$primer,$primer_score\n";
			}
		}
	}
}

close IN; close IGM; close IGZ; close NOH;