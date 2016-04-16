#!/usr/bin/perl
# count_combos_fasta.pl
use strict; use warnings;
use Good_library;

# use this script to count V and J combinations from the ID lines in a FASTA file
# V segment must have 2 digits, e.g. V03, V05, V12
# J segment must have 1 digit and Ig letter, e.g. Jm1, Jm4, Jz2
# Sample id must be in the format ma26 (IgM, Tank A, fish 26)

my $usage = "\n\tcount_combos_fasta.pl <FASTA>\n\n";

die $usage unless @ARGV == 1;

if ($ARGV[0] =~ /^\-he*l*p*/) {print $usage}
else {
	my ($name) = $ARGV[0] =~ /^(\S+)\.fa$/;
	open IN, "<$ARGV[0]" or die o_err($ARGV[0]);

	my %smpl_combo_counts;

	while (<IN>) {

		if ($_ =~ /^\>/) {
			my ($smpl)  = /^\>(\w+):/;
			my ($combo) = /(V\d{2}:J[mz]\d)/;

			${$smpl_combo_counts{$smpl}}{$combo}++;
		}
	}
	close IN;

	open O1, ">$name.combo_abund.txt"       or die o_err("$name.combo_abund.txt");
	open O2, ">$name.combo_split_abund.txt" or die o_err("$name.combo_split_abund.txt");

	print O1 "sample combo abundance\n";
	print O2 "sample vseg jseg abundance\n";

	my @smpls = sort keys %smpl_combo_counts;

	foreach my $smpl (@smpls) {
		my @combos = sort keys %{$smpl_combo_counts{$smpl}};

		foreach my $combo (@combos) {
			my ($vseg) = $combo =~ /^V(\d{2})/;
			my ($jseg) = $combo =~ /J[mz](\d)$/;

			print O1 "$smpl $combo ${$smpl_combo_counts{$smpl}}{$combo}\n";
			print O2 "$smpl $vseg $jseg ${$smpl_combo_counts{$smpl}}{$combo}\n";
		}
	}
	close O1; close O2;

}
