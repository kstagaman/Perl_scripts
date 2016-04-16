#!/usr/bin/perl
# classify_seqs_v_control_stats.pl
use strict; use warnings;

# use this script to determine if classify.seqs results in the same V assignments that the Weinstein et al group had.

die "Usage: classify_seqs_v_control_stats.pl <.taxonomy file>\n" unless @ARGV == 1;

open IN, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";

my(@seq_ids, @control_vs, @assigned_vs);

while (<IN>) {
	my ($seq_id)     = $_ =~ /(|:.+)\;V/;
	my ($control_v)  = $_ =~ /\;V(\d{1,2})\;D/;
	my ($assigned_v) = $_ =~ /\s+V(\d{1,2})/;
	last if ($_ =~ /^\s+/);
	push @seq_ids, $seq_id;
	push @control_vs, $control_v;
	push @assigned_vs, $assigned_v;
}

close IN;

open OUT, ">control_vm_vz_assignments.csv" or die "Error: cannot create control_vm_vz_assignments.csv\n";

my $numsame_control_assigned = 0;
my $total_seqs = @seq_ids;

print OUT "sequence,control_v,assigned_v,same\n";

for (my $i = 0; $i < $total_seqs; $i++) {
	print OUT "$seq_ids[$i],$control_vs[$i],$assigned_vs[$i],";
	if ($control_vs[$i] == $assigned_vs[$i]) {
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