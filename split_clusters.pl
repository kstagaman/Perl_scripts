#!/usr/bin/perl
# split_clusters.pl
use strict; use warnings;


# Use this script after running a uclust and producing a *sorted* results FASTA file.

my $usage = "\n\tsplit_clusters.pl <FASTA file>\n\n";

die $usage unless @ARGV == 1;
if ($ARGV[0] =~ /^-he*l*p*/) {help_text()}

open CHK, "<$ARGV[0]" or die "\n\tError: cannot open $ARGV[0]\n\n";
my $check = <CHK>;
if ($check !~ /^\>0\|\*\|/) {die $usage}
close CHK;

my ($filename)  = $ARGV[0] =~ /^(\S+)\.clusts/;
my ($extension) = $ARGV[0] =~ /clusts\.((fa|rem.fa|fa_1|fa_2))$/;

open IN, "<$ARGV[0]";
my @seqs_by_cluster;
my $i = 0;

while (<IN>) {

	if ($_ =~ /^\>/) {
		my ($cluster) = /^\>(\d+)\|/;
		my $id  = $_;
		my $seq = <IN>;
		chomp ($id, $seq);
		$seqs_by_cluster[$i] = {clust => $cluster, id => $id, seq => $seq};
		$i++;
	}
}

close IN;

my %cluster_ids;

foreach my $elem (@seqs_by_cluster) { $cluster_ids{$elem->{clust}}++ }

my @clusters = sort {$a <=> $b} keys %cluster_ids;
my $count = 0;

foreach my $cluster (@clusters) {
	open OUT, ">$filename.clust_$cluster.$extension" or die "\n\tError: cannot create $filename.clust_$cluster.$extension\n\n";
	my $end = $count + $cluster_ids{$cluster};

	for (my $i = $count; $i < $end; $i++) {
		print OUT "$seqs_by_cluster[$i]->{id}\n$seqs_by_cluster[$i]->{seq}\n";
		$count++;
	}

	close OUT;
}

sub help_text {
	print $usage;
}