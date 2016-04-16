#!/usr/bin/perl
# combine_bcs&primers.pl
use strict; use warnings;

my $usage = "\n\tUsage: combine_bcs\&primers.pl <barcode file TSV> <primer file FASTA> <output name>\n\n";

die $usage unless @ARGV == 3;

my $bcfile = $ARGV[0];
my $primerfile = $ARGV[1];
my $outname = $ARGV[2];
my %barcodes;
my %primers;

open BC, "<$bcfile" or die "\n\tError: cannot open $bcfile\n\n";

while (<BC>) {
	my ($sample)  = /^([mz][abcd]\d{2})\t/;
	my ($barcode) = /\t([ACGT]{5,6})$/;
	$barcodes{$sample} = $barcode;
}

close BC;

open PR, "<$primerfile" or die "\n\tError: cannot open $bcfile\n\n";

while (<PR>) {

	if ($_ =~ /^\>/) {
		my ($primer) = /^\>(\w+)/;
		my $seq = <PR>;
		chomp $seq;
		$primers{$primer} = $seq;
	}

}

close PR;

my @samples = sort keys %barcodes;
my @primer_labs = sort keys %primers;

open FAS, ">$outname.fa" or die "\n\tError: cannot create $outname.fa\n\n";
open TAB, ">$outname.tsv" or die "\n\tError: cannot create $outname.tsv\n\n";
open TAX, ">$outname.taxonomy" or die "\n\tError: cannot create $outname.taxonomy\n\n";

foreach my $sample (@samples) {

	foreach my $primer_lab (@primer_labs) {
		my $combo = "$barcodes{$sample}$primers{$primer_lab}";
		my $combo_len = length $combo;
		print FAS "\>$sample:$primer_lab\n$combo\n";
		print TAB "$sample:$primer_lab\t$combo\n";
		print TAX "$sample:$primer_lab\t$sample:$primer_lab\;\n";
		
		open TXT, ">>${outname}_$combo_len.txt" or die "\n\tError: cannot create ${outname}_$combo_len.txt\n\n";
		print TXT "$combo\n";
		close TXT;
	}

}

close FAS; close TAB; close TAX;

