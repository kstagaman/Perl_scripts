#!/usr/bin/perl
# compare_cs2cs.pl
use strict; use warnings;

# Use this script to compare the results from classify.seqs() (in mothur) using different parameters (e.g. ksize)
# This script assumes that samples are the same for each TAXONOMY file, and only the classify.seqs() parameters are different

my $usage = "\n\tUsage: compare_cs2cs.pl TAXONOMY_1 TAXONOMY_2 [TAXONOMY_3 ... TAXONOMY_N] [-h]\n\n";
die $usage unless @ARGV >= 1;

if (@ARGV < 2) {
	if ($ARGV[0] =~ /^-he*l*p*/) {help_text()}
	else						 {die $usage}
}
# default variables
my @infiles = @ARGV;

# "global" variables
my %taxa;
my @ksizes;
my $sample;
my $extension;
my @comparisons;
my @match_headers;
my @ksize_headers;
my @conversion_headers;



for (my $i=0; $i < @infiles; $i++) {
	open IN, "<$infiles[$i]" or die "\n\tError: cannot open $infiles[$i]\n\n";
	($ksizes[$i]) = $infiles[$i] =~ /\.k(\d{1,2})\./;
	if ($i == 0) {
		($sample)    = $infiles[$i] =~ /([mz][abcd]\S+)\.k/;
		($extension) = $infiles[$i] =~ /((fa_1|fa_2|rem.fa)).taxonomy$/;
	}

	while (<IN>) {
		my ($id)    = /^(\S+)\s/;
		my ($taxon) = /(\S+)\(\d{1,3}\)\;$/;
		# my ($score) = $_ =~ /\((\d{1,3})\)\;$/;
		$taxa{$id}[$i] = $taxon; 
	}

	close IN;
}

my @ids = keys %taxa;
my @seq_nums;

for (@ids) {
	my ($seq_num) = /^(\d+):/;
	push @seq_nums, $seq_num;
}

my @sorted_ids = @ids[ sort { $seq_nums[$a] <=> $seq_nums[$b] } 0 .. $#seq_nums ];

for (my $k=0; $k < @ksizes; $k++) {
	my $param  = "k$ksizes[$k]";
	my $ksize = "ksize.$ksizes[$k]";
	push @comparisons, $param;
	push @ksize_headers, $ksize;
}

my $comparison = join ('', @comparisons);
my $ksize_header = join (',', @ksize_headers);

for (my $k=0; $k < @ksizes-1; $k++) {

	for (my $l=$k+1; $l < @ksizes; $l++) {
		my $match= "k$ksizes[$k].v.k$ksizes[$l]";
		my $conversion = "k$ksizes[$k]k$ksizes[$l].conversion";
		push @match_headers, $match;
		push @conversion_headers, $conversion;
	}
}

my $match_header = join (',', @match_headers);
my $conversion_header = join (',', @conversion_headers);

open OUT, ">$sample.$comparison.$extension.csv" or die "\n\tError: cannot create $sample.$comparison.$extension.csv\n\n";
print OUT "sample,seq_id,$ksize_header,$match_header,$conversion_header\n";

foreach my $id (@sorted_ids) {
	print OUT "$sample,$id,";

	for (my $i=0; $i < @{ $taxa{$id} }; $i++) {
		print OUT "$taxa{$id}[$i],";
	}

	for (my $i=0; $i < @{ $taxa{$id} }-1; $i++) {

		for (my $j=$i+1; $j < @{ $taxa{$id} }; $j++) {

			if ($taxa{$id}[$i] eq $taxa{$id}[$j]) {
				print OUT "1,";
			} else {
				print OUT "0,";
			}
		}
	}

	for (my $i=0; $i < @{ $taxa{$id} }-1; $i++) {

		for (my $j=$i+1; $j < @{ $taxa{$id} }; $j++) {

			if ($taxa{$id}[$i] eq $taxa{$id}[$j]) {
				print OUT "NA";
				print OUT "," unless $i == @{ $taxa{$id} }-2 and $j == @{ $taxa{$id} }-1;
			} else {
				print OUT "$taxa{$id}[$i]\>$taxa{$id}[$j]";
				print OUT "," unless $i == @{ $taxa{$id} }-2 and $j == @{ $taxa{$id} }-1;
			}
		}
	}


	
	print OUT "\n";
}

close OUT;

sub help_text {
	die $usage;
	print "\t\t-h: this helpful help screen\n";
	print "\t\tTAXONOMY_N: A taxonomy file produced by classify.seqs() in the mothur package\n\n";
}

