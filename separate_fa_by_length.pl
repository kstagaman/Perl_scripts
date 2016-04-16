#!/usr/bin/perl
# separate_fa_by_length.pl
use strict; use warnings;

# Use this script to separate files into new files by length of the sequences
# You can divide the seqs into any number of bins by giving the max length (max bp)
# for each category you want to divide.  E.g. if you want two categories, with a max of 60 bp
# for one, and the longest seq length, do $ separate_fa_by_length.pl <fasta file> 60

die "Usage: separate_fa_by_length.pl <fasta file> <max bp1> ... <max bp n>\n" unless @ARGV >= 2;

my ($filename) = $ARGV[0] =~ /(\S+)\.*r*e*m*\.fa/;
my ($extension) = $ARGV[0] =~ /\.(r*e*m*\.*fa\S*)$/;
my @max_bps = @ARGV[1..@ARGV-1];

open IN, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";
my @seq_data;
my $i = 0;

while (<IN>) {
	if ($_ =~ /^\>/) {
		my ($id) = $_ =~ /(.+)/;
		$_ = <IN>;
		my ($seq) = $_ =~	/([ACGT]+)/;
		my $len = length($seq);
		$seq_data[$i] = {id => $id, seq => $seq, len => $len};
		$i++;
	}
}

close IN;

my @sorted_seq_data = sort {$a->{len} <=> $b->{len}} @seq_data;
push @max_bps, $sorted_seq_data[-1]->{len};
my $h = 0;

foreach my $max_bp (@max_bps) {
	open OUT, ">$filename.${max_bp}bp.$extension" or die "Error: cannot create $filename.${max_bp}bp.$extension\n";
	
	for (my $i = $h; $i < @sorted_seq_data; $i++) {
		
		if ($sorted_seq_data[$i]->{len} < $max_bp + 1) {
			print OUT "$sorted_seq_data[$i]->{id}:$sorted_seq_data[$i]->{len}bp\n$sorted_seq_data[$i]->{seq}\n";
			$h++;
		}
	}

	close OUT;
}