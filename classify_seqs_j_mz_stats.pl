#!/usr/bin/perl
# classify_seqs_j_mz_stats.pl
use strict; use warnings;

die "Usage: classify_seqs_j_mz_stats.pl <igm/igz2> <ksizevalue>\n" unless @ARGV == 2 or $ARGV[0] !~ /ig[mz]2*/;

my ($igtype) = $ARGV[0];
my ($k) = $ARGV[1];
my ($jtype);
if ($igtype =~ /igm/) {
	($jtype) = 'Jm';
}
else {
	($jtype) = 'Jm_Jz'; 
}

my @wildtypes = `ls *ksize$k.$jtype.taxonomy`;
my @mutants1  = `ls *ksize$k.mutated5x_1*`;
my @mutants2  = `ls *ksize$k.mutated5x_2*`;
my @mutants3  = `ls *ksize$k.mutated5x_3*`;
chomp(@wildtypes, @mutants1, @mutants2, @mutants3);

my $numfiles = @wildtypes;
my @seq_ids;
my @j_segs0;
my @j_segs1;
my @j_segs2;
my @j_segs3;
my ($parameter_id0);
my ($parameter_id1);
my ($parameter_id2);
my ($parameter_id3);

for (my $i = 0; $i < $numfiles; $i++) {
	open WT, "<$wildtypes[$i]" or die "Error: cannot open $wildtypes[$i]\n";
	open MU1, "<$mutants1[$i]" or die "Error: cannot open $mutants1[$i]\n";
	open MU2, "<$mutants2[$i]" or die "Error: cannot open $mutants2[$i]\n";
	open MU3, "<$mutants3[$i]" or die "Error: cannot open $mutants3[$i]\n";

	($parameter_id0) = $wildtypes[$i] =~ /noprimer\.(\w+)\.Jm/;
	($parameter_id1) = $mutants1[$i] =~ /noprimer\.ksize\d\.(\w+)\.Jm/;
	($parameter_id2) = $mutants2[$i] =~ /noprimer\.ksize\d\.(\w+)\.Jm/;
	($parameter_id3) = $mutants3[$i] =~ /noprimer\.ksize\d\.(\w+)\.Jm/;

	while (<WT>) {
		my ($seq_id) = $_ =~ /(\d+:Ig[MZ]2*_[ABCD]_\d{2}\.*\d*)/;
		my ($raw_j_seg)  = $_ =~ /\s+(J[mz]\d)/;
		my ($j_seg);
		if    ($raw_j_seg =~ /Jm1/) {$j_seg = 1}
		elsif ($raw_j_seg =~ /Jm2/) {$j_seg = 2}
		elsif ($raw_j_seg =~ /Jm3/) {$j_seg = 3}
		elsif ($raw_j_seg =~ /Jm4/) {$j_seg = 4}
		elsif ($raw_j_seg =~ /Jm5/) {$j_seg = 5}
		elsif ($raw_j_seg =~ /Jz1/) {$j_seg = 6}
		elsif ($raw_j_seg =~ /Jz2/) {$j_seg = 7}
		last if ($_ =~ /^\s+/);
		push @seq_ids, $seq_id;
		push @j_segs0, $j_seg;
	}
	
	while (<MU1>) {
		my ($raw_j_seg) = $_ =~ /\s+(J[mz]\d)/;
		my ($j_seg);
		if    ($raw_j_seg =~ /Jm1/) {$j_seg = 1}
		elsif ($raw_j_seg =~ /Jm2/) {$j_seg = 2}
		elsif ($raw_j_seg =~ /Jm3/) {$j_seg = 3}
		elsif ($raw_j_seg =~ /Jm4/) {$j_seg = 4}
		elsif ($raw_j_seg =~ /Jm5/) {$j_seg = 5}
		elsif ($raw_j_seg =~ /Jz1/) {$j_seg = 6}
		elsif ($raw_j_seg =~ /Jz2/) {$j_seg = 7}

		last if ($_ =~ /^\s+/);
		push @j_segs1, $j_seg;		
	}

	while (<MU2>) {
		my ($raw_j_seg) = $_ =~ /\s+(J[mz]\d)/;
		my ($j_seg);
		if    ($raw_j_seg =~ /Jm1/) {$j_seg = 1}
		elsif ($raw_j_seg =~ /Jm2/) {$j_seg = 2}
		elsif ($raw_j_seg =~ /Jm3/) {$j_seg = 3}
		elsif ($raw_j_seg =~ /Jm4/) {$j_seg = 4}
		elsif ($raw_j_seg =~ /Jm5/) {$j_seg = 5}
		elsif ($raw_j_seg =~ /Jz1/) {$j_seg = 6}
		elsif ($raw_j_seg =~ /Jz2/) {$j_seg = 7}
		last if ($_ =~ /^\s+/);
		push @j_segs2, $j_seg;		
	}
	
	while (<MU3>) {
		my ($raw_j_seg) = $_ =~ /\s+(J[mz]\d)/;
		my ($j_seg);
		if    ($raw_j_seg =~ /Jm1/) {$j_seg = 1}
		elsif ($raw_j_seg =~ /Jm2/) {$j_seg = 2}
		elsif ($raw_j_seg =~ /Jm3/) {$j_seg = 3}
		elsif ($raw_j_seg =~ /Jm4/) {$j_seg = 4}
		elsif ($raw_j_seg =~ /Jm5/) {$j_seg = 5}
		elsif ($raw_j_seg =~ /Jz1/) {$j_seg = 6}
		elsif ($raw_j_seg =~ /Jz2/) {$j_seg = 7}
		last if ($_ =~ /^\s+/);
		push @j_segs3, $j_seg;		
	}
	
	close WT; close MU1; close MU2; close MU3;
}

open OUT, ">$igtype\_$parameter_id0\_v_$parameter_id1\_v_$parameter_id2\_v_$parameter_id3.stats.csv";

my $numsame_wt_mu1 = 0;
my $numsame_wt_mu2 = 0;
my $numsame_wt_mu3 = 0;
my $numsame_mu1_mu2 = 0;
my $numsame_mu1_mu3 = 0;
my $numsame_mu2_mu3 = 0;
my $total_seqs = @seq_ids;

print OUT "sequence,$parameter_id0,$parameter_id1,$parameter_id2,$parameter_id3,same_wt_mu1,same_wt_mu2,same_wt_mu3,same_mu1_mu2, same_mu1_mu3,same_mu2_mu3\n";

for (my $i = 0; $i < $total_seqs; $i++) {
	print OUT "$seq_ids[$i],$j_segs0[$i],$j_segs1[$i],$j_segs2[$i],$j_segs3[$i],";
	if ($j_segs0[$i] =~ /$j_segs1[$i]/) {
		print OUT "1,";
		$numsame_wt_mu1++;
	}
	else {
		print OUT "0,";
	}
	if ($j_segs0[$i] =~ /$j_segs2[$i]/) {
		print OUT "1,";
		$numsame_wt_mu2++;
	}
	else {
		print OUT "0,";
	}
	if ($j_segs0[$i] =~ /$j_segs3[$i]/) {
		print OUT "1,";
		$numsame_wt_mu3++;
	}
	else {
		print OUT "0,";
	}
	if ($j_segs1[$i] =~ /$j_segs2[$i]/) {
		print OUT "1,";
		$numsame_mu1_mu2++;
	}
	else {
		print OUT "0,";
	}
	if ($j_segs1[$i] =~ /$j_segs3[$i]/) {
		print OUT "1,";
		$numsame_mu1_mu3++;
	}
	else {
		print OUT "0,";
	}
	if ($j_segs2[$i] =~ /$j_segs3[$i]/) {
		print OUT "1\n";
		$numsame_mu2_mu3++;
	}
	else {
		print OUT "0\n";
	}
}


my $freq_wt_mu1_matching = $numsame_wt_mu1 / $total_seqs;
my $freq_wt_mu2_matching = $numsame_wt_mu2 / $total_seqs;
my $freq_wt_mu3_matching = $numsame_wt_mu3 / $total_seqs;
my $freq_mu1_mu2_matching = $numsame_mu1_mu2 / $total_seqs;
my $freq_mu1_mu3_matching = $numsame_mu1_mu3 / $total_seqs;
my $freq_mu2_mu3_matching = $numsame_mu2_mu3 / $total_seqs;

printf OUT "Number of matching assignments - original and 1st mutated: %d \(%.2f\)\n", $numsame_wt_mu1, $freq_wt_mu1_matching;
printf "Number of matching assignments - original and 1st mutated: %d \(%.2f\)\n", $numsame_wt_mu1, $freq_wt_mu1_matching;

printf OUT "Number of matching assignments - original and 2nd mutated: %d \(%.2f\)\n", $numsame_wt_mu2, $freq_wt_mu2_matching;
printf "Number of matching assignments - original and 2nd mutated: %d \(%.2f\)\n", $numsame_wt_mu2, $freq_wt_mu2_matching;

printf OUT "Number of matching assignments - original and 3rd mutated: %d \(%.2f\)\n", $numsame_wt_mu3, $freq_wt_mu3_matching;
printf "Number of matching assignments - original and 3rd mutated: %d \(%.2f\)\n", $numsame_wt_mu3, $freq_wt_mu3_matching;

printf OUT "Number of matching assignments - 1st and 2nd mutated: %d \(%.2f\)\n", $numsame_mu1_mu2, $freq_mu1_mu2_matching;
printf "Number of matching assignments - 1st and 2nd mutated: %d \(%.2f\)\n", $numsame_mu1_mu2, $freq_mu1_mu2_matching;

printf OUT "Number of matching assignments - 1st and 3rd mutated: %d \(%.2f\)\n", $numsame_mu1_mu3, $freq_mu1_mu3_matching;
printf "Number of matching assignments - 1st and 3rd mutated: %d \(%.2f\)\n", $numsame_mu1_mu3, $freq_mu1_mu3_matching;

printf OUT "Number of matching assignments - 2nd and 3rd mutated: %d \(%.2f\)\n", $numsame_mu2_mu3, $freq_mu2_mu3_matching;
printf "Number of matching assignments - 2nd and 3rd mutated: %d \(%.2f\)\n", $numsame_mu2_mu3, $freq_mu2_mu3_matching;


close OUT;