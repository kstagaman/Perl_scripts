#!/usr/bin/perl
# unique_seqs.pl
use strict; use warnings;

die "\n\tUsage unique_seqs.pl <fasta file>\n\n" unless @ARGV == 1;

open IN, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";
my ($filename) = $ARGV[0] =~ /(\S+)\.(rem.fa|fa|fa_[12])/;
my ($extension) = $ARGV[0] =~ /\.((rem.fa|fa|fa_[12]))$/;

my %uniq_seqs;
my %ids_map;

while (<IN>) {
	if ($_ =~ /^\>/){
		my $id = $_;
		my $seq = <IN>;
		chomp ($id, $seq);

		my ($seg) = $id =~ /:([VJ][mz]{0,1}\d{1,2})/;
		my $seg_seq = "$seg:$seq";
		$uniq_seqs{$seg_seq}++;
		push @{$ids_map{$seg_seq}}, $id;
	}
}

close IN;

open FA, ">$filename.uniq.$extension" or die "\n\tError: cannot create $filename.uniq.$extension\n\n";
open MAP, ">$filename.uniq_map.txt" or die "\n\tError: cannot create $filename.uniq_map.txt\n\n";

my @sorted_seqs = sort {$uniq_seqs{$b} <=> $uniq_seqs{$a}} keys %uniq_seqs;
my $i = 1;

foreach my $seg_seq (@sorted_seqs) {
	my ($seg) = $seg_seq =~ /^(\w+):/;
	my ($seq) = $seg_seq =~ /:([ACGT]+)$/;
	my $len = length $seq;
	print FA "\>$i:N$uniq_seqs{$seg_seq}:$seg:${len}bp\n$seq\n";

	print MAP "$i\n";
	foreach my $id (@{$ids_map{$seq}}) {
		print MAP "\t$id\n";
	}
	$i++;
}

close FA; close MAP;

