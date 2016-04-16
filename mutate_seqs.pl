#!/usr/bin/perl
# mutate_seqs.pl
use strict; use warnings;

# Use this script to introduce any number of mutations you'd like into any number of sequences contained in a fasta file.
# The sequences are introduced serially and it is possible that a later mutation could revert a previous mutation to its original state or that two different mutations could occur at the same site. For each mutation, there is a 50% chance of a substitution at a random site along the sequence, all bases are equally substituted.  There is a 25% chance of a deletion of any base along the sequence, and a 25% chance of a substitution of any of the 4 bases at any point in the sequence.

die "Usage: mutate_seq.pl <fasta file> <number of mutations>" unless @ARGV == 2;

my ($file) = $ARGV[0];
my ($num_mutations) = $ARGV[1];


my ($sample_id) = $file =~ /(.+)\.fas*t*a*$/;

open IN, "<$file" or die "Error: cannot open $file\n";

my @ids;
my @seqs;

while (<IN>) {
	if ($_ =~ /^\>/) {
		my ($id) = $_ =~ /(\>.+)/;
		chomp $id;
		push @ids, $id;
	}
	else {
		my ($seq) = $_ =~ /([ACGTURYKMBVDHN]+)/i;
		my ($ucseq) = uc($seq);
		push @seqs, $ucseq;
	}
}

close IN;

open OUT, ">$sample_id.mutated${num_mutations}x.fa" or die "Error: cannot create $sample_id.mutated${num_mutations}x.fa\n"; 

my $num_samples = @ids;
my @nts = ('A', 'C', 'G', 'T');

for (my $i = 0; $i < $num_samples; $i++) {
	print OUT "$ids[$i]\n";
	for (my $j = 0; $j < $num_mutations; $j++) {	
		my $mutation_type = int rand 4;
			
		if ($mutation_type >= 2) {
			my ($nt) = $nts[int rand 4];
			my $sub_site = int rand length $seqs[$i];
			my @seq = split("", $seqs[$i]);
			splice(@seq, $sub_site, 1, $nt);
			$seqs[$i] = join("", @seq);
		}
			
		elsif ($mutation_type == 1) {
			my ($nt) = $nts[int rand 4];
			my $sub_site = int rand length $seqs[$i];
			my @seq = split("", $seqs[$i]);
			splice(@seq, $sub_site, 0, $nt);
			$seqs[$i] = join("", @seq);
		}
			
		elsif ($mutation_type == 0) {
			my $sub_site = int rand length $seqs[$i];
			my @seq = split("", $seqs[$i]);
			splice(@seq, $sub_site, 1);
			$seqs[$i] = join("", @seq);
		}
	}
	print OUT "$seqs[$i]\n";
}	

close OUT;
