#!/usr/bin/perl
# classify_seqs_v_ksize_stats.pl
use strict; use warnings;

die "Usage: classify_seqs_j_ksize_stats.pl <igm/igz2> <trunc/notrunc>\n" unless @ARGV == 2;
die "Usage: classify_seqs_j_ksize_stats.pl <igm/igz2> <trunc/notrunc>\n" unless $ARGV[0] =~ /ig[mz]2*/;
die "Usage: classify_seqs_j_ksize_stats.pl <igm/igz2> <trunc/notrunc>\n" unless $ARGV[1] =~ /(no)*trunc/;

my ($igtype) = $ARGV[0];
my ($trunc);
if ($ARGV[1] =~ /notrunc/) {
	($trunc) = '';
}
else {
	($trunc) = '_trunc';
}

my @ksize3s = `ls *ksize3*V$trunc.taxonomy`;
my @ksize4s = `ls *ksize4*V$trunc.taxonomy`;
my @ksize6s = `ls *ksize6*V$trunc.taxonomy`;
my @ksize8s = `ls *ksize8*V$trunc.taxonomy`;
my @ksize10s = `ls *ksize10*V$trunc.taxonomy`;
chomp(@ksize3s, @ksize4s, @ksize6s, @ksize8s, @ksize10s);

my $numfiles = @ksize3s;
my @seq_ids;
my @v_segs3;
my @v_segs4;
my @v_segs6;
my @v_segs8;
my @v_segs10;
my ($parameter_id3);
my ($parameter_id4);
my ($parameter_id6);
my ($parameter_id8);
my ($parameter_id10);
my @nums_mutations;


for (my $i = 0; $i < $numfiles; $i++) {
	open K3, "<$ksize3s[$i]" or die "Error: cannot open $ksize3s[$i]\n";
	# print "$ksize3s[$i]\n";
	open K4, "<$ksize4s[$i]" or die "Error: cannot open $ksize4s[$i]\n";
	# print "$ksize4s[$i]\n";
	open K6, "<$ksize6s[$i]" or die "Error: cannot open $ksize6s[$i]\n";
	# print "$ksize6s[$i]\n";
	open K8, "<$ksize8s[$i]" or die "Error: cannot open $ksize8s[$i]\n";
	# print "$ksize8s[$i]\n";
	open K10, "<$ksize10s[$i]" or die "Error: cannot open $ksize10s[$i]\n";
	# print "$ksize10s[$i]\n";

	($parameter_id3) = $ksize3s[$i] =~ /(ksize\d{1,2})/;
	($parameter_id4) = $ksize4s[$i] =~ /(ksize\d{1,2})/;
	($parameter_id6) = $ksize6s[$i] =~ /(ksize\d{1,2})/;
	($parameter_id8) = $ksize8s[$i] =~ /(ksize\d{1,2})/;
	($parameter_id10) = $ksize10s[$i] =~ /(ksize\d{1,2})/;

	while (<K3>) {
		my ($seq_id)    = $_ =~ /^(.+)\s+\S/;
		my ($v_seg)     = $_ =~ /\s+V(\d{1,2})\(/;
		my ($num_mutations);
		if ($ksize3s[$i] =~ /mutated/) {
			($num_mutations) = $ksize3s[$i] =~ /mutated(\d{1,3})x/;
		}
		else {
			$num_mutations = 0;
		}
		last if ($_ =~ /^\s+/);
		push @seq_ids, $seq_id;
		push @v_segs3, $v_seg;
		push @nums_mutations, $num_mutations
	}
	
	while (<K4>) {
		my ($v_seg) = $_ =~ /\s+V(\d{1,2})\(/;
		last if ($_ =~ /^\s+/);
		push @v_segs4, $v_seg;	
	}

	while (<K6>) {
		my ($v_seg) = $_ =~ /\s+V(\d{1,2})\(/;
		last if ($_ =~ /^\s+/);
		push @v_segs6, $v_seg;	
	}
	
	while (<K8>) {
		my ($v_seg) = $_ =~ /\s+V(\d{1,2})\(/;
		last if ($_ =~ /^\s+/);
		push @v_segs8, $v_seg;
	}
	
	while (<K10>) {
		my ($v_seg) = $_ =~ /\s+V(\d{1,2})\(/;
		last if ($_ =~ /^\s+/);
		push @v_segs10, $v_seg;
				
	}

	
	close K3; close K4; close K6; close K8; close K10;
}

open OUT, ">$igtype\_vsegs$trunc\_$parameter_id3\_v_$parameter_id4\_v_$parameter_id6\_v_$parameter_id8\_v_$parameter_id10.stats.csv";

my $numsame_k3_k4 = 0;
my $numsame_k3_k6 = 0;
my $numsame_k3_k8 = 0;
my $numsame_k3_k10 = 0;
my $numsame_k4_k6 = 0;
my $numsame_k4_k8 = 0;
my $numsame_k4_k10 = 0;
my $numsame_k6_k8 = 0;
my $numsame_k6_k10 = 0;
my $numsame_k8_k10 = 0;
my $total_seqs = @seq_ids;

print OUT "sequence,num_mutations,$parameter_id3,$parameter_id4,$parameter_id6,$parameter_id8,$parameter_id10,same_k3_k4,same_k3_k6,same_k3_k8,same_k3_k10,same_k4_k6,same_k4_k8,same_k4_k10,same_k6_k8,same_k6_k10,same_k8_k10\n";

for (my $i = 0; $i < $total_seqs; $i++) {
	print OUT "$seq_ids[$i],$nums_mutations[$i],$v_segs3[$i],$v_segs4[$i],$v_segs6[$i],$v_segs8[$i],$v_segs10[$i],";
	if ($v_segs3[$i] =~ /$v_segs4[$i]/) {
		print OUT "1,";
		$numsame_k3_k4++;
	}
	else {
		print OUT "0,";
	}
	if ($v_segs3[$i] =~ /$v_segs6[$i]/) {
		print OUT "1,";
		$numsame_k3_k6++;
	}
	else {
		print OUT "0,";
	}
	if ($v_segs3[$i] =~ /$v_segs8[$i]/) {
		print OUT "1,";
		$numsame_k3_k8++;
	}
	else {
		print OUT "0,";
	}
	if ($v_segs3[$i] =~ /$v_segs10[$i]/) {
		print OUT "1,";
		$numsame_k3_k10++;
	}
	else {
		print OUT "0,";
	}
	if ($v_segs4[$i] =~ /$v_segs6[$i]/) {
		print OUT "1,";
		$numsame_k4_k6++;
	}
	else {
		print OUT "0,";
	}
	if ($v_segs4[$i] =~ /$v_segs8[$i]/) {
		print OUT "1,";
		$numsame_k4_k8++;
	}
	else {
		print OUT "0,";
	}
	if ($v_segs4[$i] =~ /$v_segs10[$i]/) {
		print OUT "1,";
		$numsame_k4_k10++;
	}
	else {
		print OUT "0,";
	}
	if ($v_segs6[$i] =~ /$v_segs8[$i]/) {
		print OUT "1,";
		$numsame_k6_k8++;
	}
	else {
		print OUT "0,";
	}
	if ($v_segs6[$i] =~ /$v_segs10[$i]/) {
		print OUT "1,";
		$numsame_k6_k10++;
	}
	else {
		print OUT "0,";
	}
	if ($v_segs8[$i] =~ /$v_segs10[$i]/) {
		print OUT "1\n";
		$numsame_k8_k10++;
	}
	else {
		print OUT "0\n";
	}
}


my $freq_k3_k4_matching = $numsame_k3_k4 / $total_seqs;
my $freq_k3_k6_matching = $numsame_k3_k6 / $total_seqs;
my $freq_k3_k8_matching = $numsame_k3_k8 / $total_seqs;
my $freq_k3_k10_matching = $numsame_k3_k10 / $total_seqs;
my $freq_k4_k6_matching = $numsame_k4_k6 / $total_seqs;
my $freq_k4_k8_matching = $numsame_k4_k8 / $total_seqs;
my $freq_k4_k10_matching = $numsame_k4_k10 / $total_seqs;
my $freq_k6_k8_matching = $numsame_k6_k8 / $total_seqs;
my $freq_k6_k10_matching = $numsame_k6_k10 / $total_seqs;
my $freq_k8_k10_matching = $numsame_k8_k10 / $total_seqs;

printf OUT "Number of matching assignments - ksize3 and ksize4: %d \(%.2f\)\n", $numsame_k3_k4, $freq_k3_k4_matching;
printf "Number of matching assignments - ksize3 and ksize4: %d \(%.2f\)\n", $numsame_k3_k4, $freq_k3_k4_matching;

printf OUT "Number of matching assignments - ksize3 and ksize6: %d \(%.2f\)\n", $numsame_k3_k6, $freq_k3_k6_matching;
printf "Number of matching assignments - ksize3 and ksize6: %d \(%.2f\)\n", $numsame_k3_k6, $freq_k3_k6_matching;

printf OUT "Number of matching assignments - ksize3 and ksize8: %d \(%.2f\)\n", $numsame_k3_k8, $freq_k3_k8_matching;
printf "Number of matching assignments - ksize3 and ksize8: %d \(%.2f\)\n", $numsame_k3_k8, $freq_k3_k8_matching;

printf OUT "Number of matching assignments - ksize3 and ksize10: %d \(%.2f\)\n", $numsame_k3_k10, $freq_k3_k10_matching;
printf "Number of matching assignments - ksize3 and ksize10: %d \(%.2f\)\n", $numsame_k3_k10, $freq_k3_k10_matching;

printf OUT "Number of matching assignments - ksize4 and ksize6: %d \(%.2f\)\n", $numsame_k4_k6, $freq_k4_k6_matching;
printf "Number of matching assignments - ksize4 and ksize6: %d \(%.2f\)\n", $numsame_k4_k6, $freq_k4_k6_matching;

printf OUT "Number of matching assignments - ksize4 and ksize8: %d \(%.2f\)\n", $numsame_k4_k8, $freq_k4_k8_matching;
printf "Number of matching assignments - ksize4 and ksize8: %d \(%.2f\)\n", $numsame_k4_k8, $freq_k4_k8_matching;

printf OUT "Number of matching assignments - ksize4 and ksize10: %d \(%.2f\)\n", $numsame_k4_k10, $freq_k4_k10_matching;
printf "Number of matching assignments - ksize4 and ksize10: %d \(%.2f\)\n", $numsame_k4_k10, $freq_k4_k10_matching;

printf OUT "Number of matching assignments - ksize6 and ksize8: %d \(%.2f\)\n", $numsame_k6_k8, $freq_k6_k8_matching;
printf "Number of matching assignments - ksize6 and ksize8: %d \(%.2f\)\n", $numsame_k6_k8, $freq_k6_k8_matching;

printf OUT "Number of matching assignments - ksize6 and ksize10: %d \(%.2f\)\n", $numsame_k6_k10, $freq_k6_k10_matching;
printf "Number of matching assignments - ksize6 and ksize10: %d \(%.2f\)\n", $numsame_k6_k10, $freq_k6_k10_matching;

printf OUT "Number of matching assignments - ksize8 and ksize10: %d \(%.2f\)\n", $numsame_k8_k10, $freq_k8_k10_matching;
printf "Number of matching assignments - ksize8 and ksize10: %d \(%.2f\)\n", $numsame_k8_k10, $freq_k8_k10_matching;

close OUT;