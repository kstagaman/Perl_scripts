#!/usr/bin/perl
# vj_combo_abund.pl
use strict; use warnings;

# use this script on a all*concordance.csv file to get counts of VJ combos

my $usage = "\n\tvj_combo_abund.pl <CSV file>\n\n";

die $usage unless @ARGV == 1;
die $usage unless $ARGV[0] =~ /.csv$/ or $ARGV =~ /^-he*l*p*$/;

if ($ARGV[0] =~ /^-he*l*p*$/) {help_text()}
else {
	my $infile = $ARGV[0];
	my ($sample) = $infile =~ /^(\w+)\./;

	my %combos_by_sample;

	open IN, "<$infile" or die "\n\tError: cannot open $infile\n\n";

	$_ = <IN>;

	while (<IN>) {
		my ($sample)     = /^([mz][abcd]\d{2}),/;
		my ($f_align)    = /^$sample,\w+,([\w\-]+),/;
		my ($class_seqs) = /^$sample,\w+,$f_align,\w+,(V\d{1,2})\:/;
		my ($r_align)    = /^$sample,\w+,$f_align,\w+,$class_seqs\:[\d\-]+,([\w\-]+),/;
		my ($bt2_jseg)   = /^$sample,\w+,$f_align,\w+,$class_seqs\:[\d\-]+,$r_align,\w+,((Jm[1-5]|\*)),/;
		# print "$sample $f_align $class_seqs $r_align $bt2_jseg\n";

		if ($f_align =~ /ighv/ and $bt2_jseg !~ /\*/) {
			my $combo = "$class_seqs-$bt2_jseg";

			if ($combos_by_sample{$sample}) {
				push @{$combos_by_sample{$sample}}, $combo;
			} else {
				$combos_by_sample{$sample} = [$combo];
			}
		}
	}
	close IN;

	my @samples = sort keys %combos_by_sample;

	open OUT, ">$sample.vj_combos.csv" or die "\n\tError: cannot create $sample.vj_combos.csv\n\n";
	print OUT "sample,combo,abundance\n";

	foreach my $sample (@samples) {
		my %combo_counts;

		foreach my $combo (@{$combos_by_sample{$sample}}) {
			$combo_counts{$combo}++;
		}

		my @combos = sort keys %combo_counts;

		foreach my $combo (@combos) {
			print OUT "$sample,$combo,$combo_counts{$combo}\n";
		}
	}
	close OUT;
}

sub help_text {
	print $usage;
}