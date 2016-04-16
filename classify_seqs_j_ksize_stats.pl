#!/usr/bin/perl
# classify_seqs_j_ksize_stats.pl
use strict; use warnings;

die "Usage: classify_seqs_j_ksize_stats.pl <igm/igz2>\n" unless @ARGV == 1 and $ARGV[0] =~ /ig[mz]2*/;

my ($igtype) = $ARGV[0];

my @ksize3s = `ls *ksize3*Jm*.taxonomy`;
my @ksize4s = `ls *ksize4*Jm*.taxonomy`;
my @ksize6s = `ls *ksize6*Jm*.taxonomy`;
my @ksize8s = `ls *ksize8*Jm*.taxonomy`;
chomp(@ksize3s, @ksize4s, @ksize6s, @ksize8s);

my $numfiles = @ksize3s;
my @seq_ids;
my @nums_mutations;
my(@j_segs3, @j_segs4, @j_segs6, @j_segs8);
my(@bootstraps3, @bootstraps4, @bootstraps6, @bootstraps8);
my($parameter_id3, $parameter_id4, $parameter_id6, $parameter_id8);


for (my $i = 0; $i < $numfiles; $i++) {
	open K3, "<$ksize3s[$i]" or die "Error: cannot open $ksize3s[$i]\n";
	open K4, "<$ksize4s[$i]" or die "Error: cannot open $ksize4s[$i]\n";
	open K6, "<$ksize6s[$i]" or die "Error: cannot open $ksize6s[$i]\n";
	open K8, "<$ksize8s[$i]" or die "Error: cannot open $ksize8s[$i]\n";

	($parameter_id3) = $ksize3s[$i] =~ /(ksize\d{1,2})/;
	($parameter_id4) = $ksize4s[$i] =~ /(ksize\d{1,2})/;
	($parameter_id6) = $ksize6s[$i] =~ /(ksize\d{1,2})/;
	($parameter_id8) = $ksize8s[$i] =~ /(ksize\d{1,2})/;

	while (<K3>) {
		my ($seq_id) = $_ =~ /^(.+)\s+\S/;
		my ($raw_j_seg) = $_ =~ /\s+(J[mz]\d)/;
		my ($bootstrap) = $_ =~ /Jm\d\((\d{1,3})\)\;/;
		my ($num_mutations) = $ksize3s[$i] =~ /mutated(\d{1,3})x/;
		if (!$num_mutations) {($num_mutations) = 0};
		my ($j_seg) = code_jseg($raw_j_seg);
		last if ($_ =~ /^\s+/);
		push @seq_ids, $seq_id;
		push @j_segs3, $j_seg;
		push @nums_mutations, $num_mutations;
		push @bootstraps3, $bootstrap;
	}
	
	while (<K4>) {
		my ($raw_j_seg) = $_ =~ /\s+(J[mz]\d)/;
		my ($bootstrap) = $_ =~ /Jm\d\((\d{1,3})\)\;/;
		my ($j_seg) = code_jseg($raw_j_seg);
		last if ($_ =~ /^\s+/);
		push @j_segs4, $j_seg;
		push @bootstraps4, $bootstrap;
	}

	while (<K6>) {
		my ($raw_j_seg) = $_ =~ /\s+(J[mz]\d)/;
		my ($bootstrap) = $_ =~ /Jm\d\((\d{1,3})\)\;/;
		my ($j_seg) = code_jseg($raw_j_seg);
		last if ($_ =~ /^\s+/);
		push @j_segs6, $j_seg;
		push @bootstraps6, $bootstrap;	
	}
	
	while (<K8>) {
		my ($raw_j_seg) = $_ =~ /\s+(J[mz]\d)/;
		my ($bootstrap) = $_ =~ /Jm\d\((\d{1,3})\)\;/;
		my ($j_seg) = code_jseg($raw_j_seg);
		last if ($_ =~ /^\s+/);
		push @j_segs8, $j_seg;
		push @bootstraps8, $bootstrap;	
	}
	
	close K3; close K4; close K6; close K8;
}

open OUT, ">$igtype\_jsegs\_$parameter_id3\_v_$parameter_id4\_v_$parameter_id6\_v_$parameter_id8.stats.csv";

my $numsame_k3_k4 = 0;
my $numsame_k3_k6 = 0;
my $numsame_k3_k8 = 0;
my $numsame_k4_k6 = 0;
my $numsame_k4_k8 = 0;
my $numsame_k6_k8 = 0;
my $total_seqs = @seq_ids;

print OUT "sequence,num_mutations,$parameter_id3,bootstrap_$parameter_id3,$parameter_id4,bootstrap_$parameter_id4,$parameter_id6,bootstrap_$parameter_id6,$parameter_id8,bootstrap_$parameter_id8,same_k3_k4,same_k3_k6,same_k3_k8,same_k4_k6, same_k4_k8,same_k6_k8\n";

for (my $i = 0; $i < $total_seqs; $i++) {
	print OUT "$seq_ids[$i],$nums_mutations[$i],$j_segs3[$i],$bootstraps3[$i],$j_segs4[$i],$bootstraps4[$i],$j_segs6[$i],$bootstraps6[$i],$j_segs8[$i],$bootstraps8[$i],";
	if ($j_segs3[$i] =~ /$j_segs4[$i]/) {
		print OUT "1,";
		$numsame_k3_k4++;
	}
	else {
		print OUT "0,";
	}
	if ($j_segs3[$i] =~ /$j_segs6[$i]/) {
		print OUT "1,";
		$numsame_k3_k6++;
	}
	else {
		print OUT "0,";
	}
	if ($j_segs3[$i] =~ /$j_segs8[$i]/) {
		print OUT "1,";
		$numsame_k3_k8++;
	}
	else {
		print OUT "0,";
	}
	if ($j_segs4[$i] =~ /$j_segs6[$i]/) {
		print OUT "1,";
		$numsame_k4_k6++;
	}
	else {
		print OUT "0,";
	}
	if ($j_segs4[$i] =~ /$j_segs8[$i]/) {
		print OUT "1,";
		$numsame_k4_k8++;
	}
	else {
		print OUT "0,";
	}
	if ($j_segs6[$i] =~ /$j_segs8[$i]/) {
		print OUT "1\n";
		$numsame_k6_k8++;
	}
	else {
		print OUT "0\n";
	}
}


my $freq_k3_k4_matching = $numsame_k3_k4 / $total_seqs;
my $freq_k3_k6_matching = $numsame_k3_k6 / $total_seqs;
my $freq_k3_k8_matching = $numsame_k3_k8 / $total_seqs;
my $freq_k4_k6_matching = $numsame_k4_k6 / $total_seqs;
my $freq_k4_k8_matching = $numsame_k4_k8 / $total_seqs;
my $freq_k6_k8_matching = $numsame_k6_k8 / $total_seqs;

printf OUT "Number of matching assignments - ksize3 and ksize4: %d \(%.2f\)\n", $numsame_k3_k4, $freq_k3_k4_matching;
printf "Number of matching assignments - ksize3 and ksize4: %d \(%.2f\)\n", $numsame_k3_k4, $freq_k3_k4_matching;

printf OUT "Number of matching assignments - ksize3 and ksize6: %d \(%.2f\)\n", $numsame_k3_k6, $freq_k3_k6_matching;
printf "Number of matching assignments - ksize3 and ksize6: %d \(%.2f\)\n", $numsame_k3_k6, $freq_k3_k6_matching;

printf OUT "Number of matching assignments - ksize3 and ksize8: %d \(%.2f\)\n", $numsame_k3_k8, $freq_k3_k8_matching;
printf "Number of matching assignments - ksize3 and ksize8: %d \(%.2f\)\n", $numsame_k3_k8, $freq_k3_k8_matching;

printf OUT "Number of matching assignments - ksize4 and ksize6: %d \(%.2f\)\n", $numsame_k4_k6, $freq_k4_k6_matching;
printf "Number of matching assignments - ksize4 and ksize6: %d \(%.2f\)\n", $numsame_k4_k6, $freq_k4_k6_matching;

printf OUT "Number of matching assignments - ksize4 and ksize8: %d \(%.2f\)\n", $numsame_k4_k8, $freq_k4_k8_matching;
printf "Number of matching assignments - ksize4 and ksize8: %d \(%.2f\)\n", $numsame_k4_k8, $freq_k4_k8_matching;

printf OUT "Number of matching assignments - ksize6 and ksize8: %d \(%.2f\)\n", $numsame_k6_k8, $freq_k6_k8_matching;
printf "Number of matching assignments - ksize6 and ksize8: %d \(%.2f\)\n", $numsame_k6_k8, $freq_k6_k8_matching;


close OUT;

# subroutines

sub code_jseg {
	my ($raw_j_seg) = @_;
	my $j_seg;
	if    ($raw_j_seg =~ /Jm1/) {$j_seg = 1}
	elsif ($raw_j_seg =~ /Jm2/) {$j_seg = 2}
	elsif ($raw_j_seg =~ /Jm3/) {$j_seg = 3}
	elsif ($raw_j_seg =~ /Jm4/) {$j_seg = 4}
	elsif ($raw_j_seg =~ /Jm5/) {$j_seg = 5}
	elsif ($raw_j_seg =~ /Jz1/) {$j_seg = 6}
	elsif ($raw_j_seg =~ /Jz2/) {$j_seg = 7}
	return $j_seg;
}

	
