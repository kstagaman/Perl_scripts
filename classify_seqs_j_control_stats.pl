#!/usr/bin/perl
# classify_seqs_j_control_stats.pl
use strict; use warnings;

# use this script to determine if classify.seqs results in the same Jm assignments that the Weinstein et al group had.

die "Usage: classify_seqs_j_control_stats.pl <.taxonomy file>\n" unless @ARGV == 1;

open IN, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";

my(@seq_ids, @control_js, @assigned_js);

while (<IN>) {
	my ($seq_id)     = $_ =~ /(|:.+)\;V/;
	my ($control_j)  = $_ =~ /\;J(\d)/;
	my ($raw_assigned_j) = $_ =~ /(J[mz]\d)/;
	my $assigned_j;
	if    ($raw_assigned_j =~ /Jm1/) {$assigned_j = 1}
	elsif ($raw_assigned_j =~ /Jm2/) {$assigned_j = 2}
	elsif ($raw_assigned_j =~ /Jm3/) {$assigned_j = 3}
	elsif ($raw_assigned_j =~ /Jm4/) {$assigned_j = 4}
	elsif ($raw_assigned_j =~ /Jm5/) {$assigned_j = 5}
	elsif ($raw_assigned_j =~ /Jz1/) {$assigned_j = 6}
	elsif ($raw_assigned_j =~ /Jz2/) {$assigned_j = 7}
	last if ($_ =~ /^\s+/);
	push @seq_ids, $seq_id;
	push @control_js, $control_j;
	push @assigned_js, $assigned_j;
}

close IN;

open OUT, ">control_jm_jz_assignments.csv" or die "Error: cannot create control_jm_jz_assignments.csv\n";

my $numsame_control_assigned = 0;
my $total_seqs = @seq_ids;

print OUT "sequence,control_j,assigned_j,same\n";

for (my $i = 0; $i < $total_seqs; $i++) {
	print OUT "$seq_ids[$i],$control_js[$i],$assigned_js[$i],";
	if ($control_js[$i] == $assigned_js[$i]) {
		print OUT "1\n";
		$numsame_control_assigned++;
	}
	else {
		print OUT "0\n";
	}
}

my $freq_control_assigned_matching = $numsame_control_assigned / $total_seqs;

printf OUT "Number of matching assignments: %d \(%.2f\)\n", $numsame_control_assigned, $freq_control_assigned_matching;
printf     "Number of matching assignments: %d \(%.2f\)\n", $numsame_control_assigned, $freq_control_assigned_matching;