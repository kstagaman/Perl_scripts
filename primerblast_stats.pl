#!/usr/bin/perl
# primerblast_stats.pl
use strict; use warnings;

# Use this script in a directory of FASTA files that have been produced using primerblast_output.pl

my $usage = "\n\tUsage: primerblast_stats.pl <m or z>\n\tUse this script in a directory containing all target FASTA files\n\n";

die $usage unless @ARGV == 1;

my $ig = $ARGV[0];
my @files = glob "$ig*b[frn]*";

open CSV, ">primerblast_stats.$ig.csv" or die "\n\tError: cannot create primerblast_stats.$ig.csv\n\n";
print CSV "sample,read,seq.num,abundance,length,primer,primer.score\n";

foreach my $file (@files) {
	open FA, "<$file" or die "\n\tError: cannot open $file\n\n";
	my ($sample) = $file =~ /^([mz][abcd]\d{2})\./;
	my ($read)   = $file =~ /((fa_1|fa_2|rem.fa))$/;

	while (<FA>) {

		if ($_ =~ /^\>/) {
			my ($seqnum) = /^\>(\d+):/;
			my ($abund)  = /:N(\d+):/;
			my ($len)    = /:(\d+)bp:/;
			my ($primer) = /:((fwd_\d{1,2}|rev_[mz]|no_hit))/;
			my ($primer_num) = substr($primer, 4);
			if (length($primer_num) == 1 and $primer_num !~ /[mz]/) {$primer = "fwd_0$primer_num"}
			my ($score)  = /\((\S+)\)$/ unless $primer eq "no_hit";
			if (!$score) {$score = "NA"}

			print CSV "$sample,$read,$seqnum,$abund,$len,$primer,$score\n";

		}
	}

	close FA;
}

close CSV;